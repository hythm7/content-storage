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
my enum Status    (
  UNKNOWN   => '<i class="bi bi-exclamation-triangle text-warning"></i>',
  ERROR     => '<i class="bi bi-x text-error"></i>',
  SUCCESS   => '<i class="bi bi-check text-success"></i>',
  RUNNING   => '<div class="spinner-grow spinner-grow-sm text-primary" role="status"><span class="visually-hidden">Loading...</span></div>',
);

method add-distribution ( :$user, :$archive! ) {

  my $filename = $archive.filename;

  my $id = $!db.new-build( :$filename, userid => $user.id, status => UNKNOWN.key );

  my %build = $!db.get-build( :$id );

  %build<status meta name version auth api identity test> X= UNKNOWN.value;

  my %data = %( :target<BUILD>, :operation<ADD>, ID => $id, :%build );

  my $message = EventSource::Server::Event.new( data => to-json %data );

  $!supplier.emit( $message );


  my $type = $id.Str;

  start {
  
    my $work-directory = tempdir.IO;

    my $build = DistributionStorage::Build.new( :$type, :$work-directory, event-supplier => $!supplier );

    $!db.update-build-status: :$id, status => RUNNING.key; 

    $!db.update-build-started: :$id; 

    my $datetime = $!db.get-build-started: :$id; 

    my $started = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    my %data = %( :target<BUILD>, :operation<UPDATE>, ID => $id,  build => { status => RUNNING.value, :$started } );

    my $message = EventSource::Server::Event.new( data => to-json %data );

    $!supplier.emit( $message );



    $build.extract: archive => $archive.body-blob;


    my $status-meta = $build.meta( distribution => $work-directory.add( 'distribution' ) );

    if $status-meta {

      $!db.update-build-status-meta: :$id, meta => SUCCESS.key; 

      my %data = %( :target<BUILD>, :operation<UPDATE>, ID => $id,  build => { meta => SUCCESS.value } );

      my $message = EventSource::Server::Event.new( data => to-json %data );

      $!supplier.emit( $message );
      
    } else {

    }

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

my sub status( Str:D :$status! --> Str:D ) {

  my %status
}
