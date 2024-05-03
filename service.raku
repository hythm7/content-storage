use DB::Migration::Declare::Applicator;
use DB::Migration::Declare::Database::Postgres;
use DB::Pg;

use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::HTTP::Session::Pg;

use distributions-storage;
use distributions-storage-session;
use distributions-storage-database;
use distributions-storage-routes;

 
my $pg = DB::Pg.new(:conninfo(%*ENV<DB_CONN_INFO>));

my $applicator = DB::Migration::Declare::Applicator.new:
  schema-id => 'distributions-storage',
  source => $*PROGRAM.parent.add('migrations.raku'),
  database => DB::Migration::Declare::Database::Postgres.new,
  connection => $pg;

my $status = $applicator.to-latest;

note "Applied $status.migrations.elems() migration(s)";


my $ds = DistributionsStorage.new: :$pg;

class SessionStore does Cro::HTTP::Session::Pg[DistributionsStorage::Session] {
  method serialize( DistributionsStorage::Session $s ) {
    $s.to-json
  }

  method deserialize( $json --> DistributionsStorage::Session ) {
    DistributionsStorage::Session.from-json( $json )
  }
}

my Cro::Service $http = Cro::HTTP::Server.new(
  http => <1.1>,
  host => %*ENV<DISTRIBUTIONS_STORAGE_HOST> ||
  die("Missing DISTRIBUTIONS_STORAGE_HOST in environment"),
  port => %*ENV<DISTRIBUTIONS_STORAGE_PORT> ||
  die("Missing DISTRIBUTIONS_STORAGE_PORT in environment"),
  application => routes( $ds ),
  before => [
    SessionStore.new(
      db => $pg,
      cookie-name => '_distributions-storage-session')
    ], 
    after => [
      Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ]
  );

  $http.start;

  say "Listening at http://%*ENV<DISTRIBUTIONS_STORAGE_HOST>:%*ENV<DISTRIBUTIONS_STORAGE_PORT>";

  react {
    whenever signal(SIGINT) {
      say "Shutting down...";
      $http.stop;
      done;
    }

  }
