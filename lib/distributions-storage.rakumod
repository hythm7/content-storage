use File::Temp;
use Libarchive::Simple;
use EventSource::Server;

use DB::Pg;

use distributions-storage-database;

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

  my %data = %( :target<BUILD>, :operation<ADD>, :%build );

  my $message = EventSource::Server::Event.new( data => to-json %data );

  $!supplier.emit( $message );


  my $type = $id.Str;

  start {
  
    my $workdir = tempdir;

    .extract for archive-read( $archive.body-blob, destpath => $workdir );


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
