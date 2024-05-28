use DB::Migration::Declare::Applicator;
use DB::Migration::Declare::Database::Postgres;
use DB::Pg;

use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use Cro::HTTP::Session::Pg;
use Cro::WebApp::Template;

use EventSource::Server;

use distribution-storage;
use distribution-storage-session;
use distribution-storage-database;
use distribution-storage-routes-api;
use distribution-storage-routes-user;
use distribution-storage-routes-distribution;
use distribution-storage-routes-build;



my $pg = DB::Pg.new: conninfo =>  %*ENV<DB_CONN_INFO>;

my $db = DistributionStorage::Database.new: :$pg;

my $event-supplier = Supplier.new;

my $event-source-server = EventSource::Server.new: supply => $event-supplier.Supply; 




my sub routes( ) {

  template-location 'templates/';

  route {

    after { redirect '/user/login', :see-other if .status == 401 };

    get -> DistributionStorage::Session $session {

      my $user =  $session.user;
      my @dist = $db.select-distribution.map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });

      template 'index.crotmp', { :$user, :@dist };
    }

    include <api v1>      => api-routes(  :$db, :$event-supplier ),
             distribution => distribution-routes( :$db ),
             build        => build-routes( :$db, :$event-supplier ),
             user         => user-routes( :$db );

    get -> DistributionStorage::Session $session, 'server-sent-events' {
      content 'text/event-stream', $event-source-server.out-supply;
    }

    get -> 'static', *@path {
      static 'static', @path
    } 
  }
}
~        


my $applicator = DB::Migration::Declare::Applicator.new:
  schema-id => 'distribution-storage',
  source => $*PROGRAM.parent.add('migrations.raku'),
  database => DB::Migration::Declare::Database::Postgres.new,
  connection => $pg;

my $status = $applicator.to-latest;

note "Applied $status.migrations.elems() migration(s)";


my $ds = DistributionStorage.new: :$pg;

class SessionStore does Cro::HTTP::Session::Pg[DistributionStorage::Session] {
  method serialize( DistributionStorage::Session $s ) {
    $s.to-json
  }

  method deserialize( $json --> DistributionStorage::Session ) {
    DistributionStorage::Session.from-json( $json )
  }
}

my Cro::Service $http = Cro::HTTP::Server.new(
  http => <1.1>,
  host => %*ENV<DISTRIBUTION_STORAGE_HOST> ||
  die("Missing DISTRIBUTION_STORAGE_HOST in environment"),
  port => %*ENV<DISTRIBUTION_STORAGE_PORT> ||
  die("Missing DISTRIBUTION_STORAGE_PORT in environment"),
  application => routes( ),
  before => [
    SessionStore.new(
      db => $pg,
      sessions-table => 'session',
      cookie-name => '_distribution-storage-session')
    ], 
    after => [
      Cro::HTTP::Log::File.new( logs => $*OUT, errors => $*ERR )
    ]
  );

  $http.start;

  say "Listening at http://%*ENV<DISTRIBUTION_STORAGE_HOST>:%*ENV<DISTRIBUTION_STORAGE_PORT>";

  react {
    whenever signal(SIGINT) {
      say "Shutting down...";
      $http.stop;
      done;
    }

  }
