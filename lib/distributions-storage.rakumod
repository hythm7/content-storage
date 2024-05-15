use File::Temp;
use Libarchive::Simple;
use EventSource::Server;

use DB::Pg;

use distributions-storage-database;
use distributions-storage-build;

unit class DistributionsStorage;


has Supplier            $!supplier     = Supplier.new;
has Supply              $!supply       = $!supplier.Supply;
has EventSource::Server $!event-source = EventSource::Server.new: :$!supply; 

has DistributionsStorage::Database $!db handles <
  add-user
  get-user
  get-dists
  get-user-dists
  delete-dist
  >;

method build-supply ( ) { $!event-source.out-supply }

my enum Target    <BUILD DISTRIBUTION>;
my enum Operation <ADD UPDATE DELETE>;

method add-distribution ( :$user, :$archive! ) {

  my $build = DistributionStorage::Build.new( :$archive, :$!db, userid => $user.id, event-supplier => $!supplier );

  start $build.build;

  my %data = build-id => $build.id;


    #$build.extract: archive => $archive.body-blob;


    #my $status-meta = $build.meta( distribution => $work-directory.add( 'distribution' ) );

    #if $status-meta {

    #  $!db.update-build-status-meta: :$id, meta => SUCCESS.key; 

    #  my %data = %( :target<BUILD>, :operation<UPDATE>, ID => $id,  build => { meta => SUCCESS.value } );

    #  my $message = EventSource::Server::Event.new( data => to-json %data );

    #  $!supplier.emit( $message );
    #  
    #} else {

    #}

    #eager $archive.body-text.lines.map( -> $line {
    #  sleep((^4).rand);

    #  my $event = EventSource::Server::Event.new( :$type, data => to-json({ :$filename, :$type } ) );

    #  $!supplier.emit($event)

    #} );

  #}

}

method get-builds ( ) {

  $!db.get-builds;
}

submethod BUILD( DB::Pg :$pg! ) {

  $!db = DistributionsStorage::Database.new: :$pg;
}

my sub status( Str:D :$status! --> Str:D ) {

  my %status
}
