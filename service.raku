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
use content-storage-session;
use content-storage-database;
use content-storage-routes-api;
use content-storage-routes-distribution;
use content-storage-routes-build;
use content-storage-routes-user;


my $pg = DB::Pg.new: conninfo =>  %*ENV<DB_CONN_INFO>, converters => <DateTime>;

my $db = ContentStorage::Database.new: :$pg;

my $openapi-schema = 'openapi.json'.IO;

my $event-supplier = Supplier.new;

my $event-source-server = EventSource::Server.new: supply => $event-supplier.Supply; 

my $api-uri = "http://%*ENV<CONTENT_STORAGE_HOST>:%*ENV<CONTENT_STORAGE_PORT>/api/v1/";

my $api = Cro::HTTP::Client.new( base-uri => $api-uri, content-type => 'application/json' );



my sub routes( ) {

  template-location 'templates/';

  route {

    #after { redirect '/user/login', :see-other if .status == 401 };

    get -> ContentStorage::Session $session {

      my $user =  $session.user;
      my @dist = $db.select-distribution;

      template 'home.crotmp', { :$user, :@dist };
    }

    include <api v1>      => api-routes( :$openapi-schema, :$db, :$event-supplier ),
             distribution => distribution-routes( :$db ),
             build        => build-routes( :$api, :$db, :$event-supplier ),
             user         => user-routes( :$db );

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
  host => %*ENV<CONTENT_STORAGE_HOST> ||
  die("Missing CONTENT_STORAGE_HOST in environment"),
  port => %*ENV<CONTENT_STORAGE_PORT> ||
  die("Missing CONTENT_STORAGE_PORT in environment"),
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

  say "Listening at http://%*ENV<CONTENT_STORAGE_HOST>:%*ENV<CONTENT_STORAGE_PORT>";

  react {
    whenever signal(SIGINT) {
      say "Shutting down...";
      $http.stop;
      done;
    }

  }
