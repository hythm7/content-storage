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
my enum Status    <SUCCESS ERROR UNKNOWN RUNNING>;

method add-distribution ( :$user, :$archive! ) {

  my $filename = $archive.filename;

  my $id = $!db.new-build( :$filename, userid => $user.id, status => 'UNKNOWN' );

  my %build = $!db.get-build( :$id );

  my %data = %( :target<BUILD>, :operation<ADD>, ID => $id, :%build );

  my $message = EventSource::Server::Event.new( data => to-json %data );

  $!supplier.emit( $message );


  my $type = $id.Str;

  start {
  
    my $work-directory = tempdir.IO;


    my $build = DistributionStorage::Build.new( :$type, :$work-directory, event-supplier => $!supplier );

    my $status = 'RUNNING';

    $!db.update-build-status: :$id, :$status; 

    my %data = %( :target<BUILD>, :operation<UPDATE>,ID => $id,  build => :$status );

    my $message = EventSource::Server::Event.new( data => to-json %data );

    $!supplier.emit( $message );



    my $extract = $build.extract: archive => $archive.body-blob;


    $build.meta( distribution => $work-directory.add( 'distribution' ) );

    #eager $archive.body-text.lines.map( -> $line {
    #  sleep((^4).rand);

    #  my $event = EventSource::Server::Event.new( :$type, data => to-json({ :$filename, :$type } ) );

    #  $!supplier.emit($event)

    #} );

  }


  %data;

}

method get-builds ( ) {

  $!db.get-builds;
}

submethod BUILD( DB::Pg :$pg! ) {

  $!db = DistributionsStorage::Database.new: :$pg;
}
