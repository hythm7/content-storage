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
  select-distribution
  select-distribution-by-userid
  delete-dist
  >;

method build-supply ( ) { $!event-source.out-supply }

my enum Target    <BUILD DISTRIBUTION>;
my enum Operation <ADD UPDATE DELETE>;

method distribution-add ( :$user, :$archive! ) {

  my $build = DistributionStorage::Build.new( :$archive, :$!db, :$user, event-supplier => $!supplier );

#  CATCH {
#
#    default {
#      .say;
#
#      my %data = %( :target<BUILD>, :operation<UPDATE>, ID => $build.id,  build => { status => ERROR.value } );
#
#      my $message = EventSource::Server::Event.new( data => to-json %data );
#
#      $!supplier.emit( $message );
#
#    }
#
#  }

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

method select-build ( ) {

  $!db.select-build;
}

submethod BUILD( DB::Pg :$pg! ) {

  $!db = DistributionStorage::Database.new: :$pg;
}

my sub status( Str:D :$status! --> Str:D ) {

  my %status
}
