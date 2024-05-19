use File::Temp;
use Libarchive::Simple;
use EventSource::Server;

use DB::Pg;

use distribution-storage-database;
use distribution-storage-build;

unit class DistributionStorage;


has Supplier            $!supplier     = Supplier.new;
has Supply              $!supply       = $!supplier.Supply;
has EventSource::Server $!event-source = EventSource::Server.new: :$!supply; 

has DistributionStorage::Database $!db handles <
  insert-user
  select-user
  select-user-password
  select-distribution
  delete-dist
  >;

method build-supply ( ) { $!event-source.out-supply }

my enum Target    <BUILD DISTRIBUTION>;
my enum Operation <ADD UPDATE DELETE>;

method distribution-add ( :$user, :$archive! ) {

  my $build = DistributionStorage::Build.new( :$archive, :$!db, :$user, event-supplier => $!supplier );

  start $build.build;

  my %data = build-id => $build.id;

}

method select-build ( ) {

  $!db.select-build;
}

submethod BUILD( DB::Pg :$pg! ) {

  $!db = DistributionStorage::Database.new: :$pg;
}

my sub status( Str:D :$status! --> Str:D ) {

  my %status
}
