use JSON::Fast;

use DB::Migration::Declare::Applicator;
use DB::Migration::Declare::Database::Postgres;
use DB::Pg;

use Cro::HTTP::Log::File;
use Cro::HTTP::Client;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::HTTP::Session::Pg;
use Cro::WebApp::Template;

use EventSource::Server;

use content-storage;
use content-storage-config;
use content-storage-session;
use content-storage-database;
use content-storage-routes-api;
use content-storage-routes-distribution;
use content-storage-routes-build;
use content-storage-routes-user;


my Str:D  $host = config.get( 'host' );
my UInt:D $port = config.get( 'port' );

my UInt:D $api-page-limit = config.get( 'api.page-limit' );

my Str:D $build-test-command = config.get( 'build.test-command' );

my $pg = DB::Pg.new: conninfo =>  %*ENV<CONTENT_STORAGE_DB_CONN_INFO> || die("Missing CONTENT_STORAGE_DB_CONN_INFO in environment"), converters => <DateTime>;

my $db = ContentStorage::Database.new: :$pg;

my $openapi-schema = 'openapi.json'.IO;

my $event-supplier = Supplier.new;

my $event-source-server = EventSource::Server.new: supply => $event-supplier.Supply; 


my sub routes( ) {

  template-location 'templates/';

  route {

    include             distribution-routes( :$db ),
            build    => build-routes(        :$db ),
            user     => user-routes(         :$db ),
            <api v1> => api-routes(          :$db, :$openapi-schema, :$event-supplier );

    get -> ContentStorage::Session $session, 'server-sent-events' {
      content 'text/event-stream', $event-source-server.out-supply;
    }

    get -> 'favicon.ico' {
      static 'static/images/favicon/favicon.ico', 
    } 

    get -> 'images', *@path {
      static 'static/images', @path
    } 

    get -> 'css', *@path {
      static 'static/css', @path
    } 

    get -> 'js', *@path {
      static 'static/js', @path
    } 
  }
}


my $applicator = DB::Migration::Declare::Applicator.new:
  schema-id => 'content-storage',
  source => $*PROGRAM.parent.add('migrations.raku'),
  database => DB::Migration::Declare::Database::Postgres.new,
  connection => $pg;

my $status = $applicator.to-latest;

note "Applied $status.migrations.elems() migration(s)";


class SessionStore does Cro::HTTP::Session::Pg[ContentStorage::Session] {
  method serialize( ContentStorage::Session $s ) {
    $s.to-json
  }

  method deserialize( $json --> ContentStorage::Session ) {
    ContentStorage::Session.from-json( $json )
  }
}

my Cro::Service $http = Cro::HTTP::Server.new(
  http => <1.1>,
  :$host,
  :$port,
  application => routes( ),
  before => [
    SessionStore.new(
      db => $pg,
      sessions-table => 'session',
      cookie-name => 'SESSION_CONTENT_STORAGE'
    )
  ], 
  after => [
    Cro::HTTP::Log::File.new( logs => $*OUT, errors => $*ERR )
  ]
);

  $http.start;

  say "Listening at http://$host:$port";

  react {
    whenever signal(SIGINT) {
      say "Shutting down...";
      $http.stop;
      done;
    }

  }
