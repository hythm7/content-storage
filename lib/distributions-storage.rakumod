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

method add-distribution ( :$file! ) {

my $archive = $file.filename;

my $id = $!db.create-build( :$archive );

my $type = $id.Str;


start {
  eager $file.body-text.lines.map( -> $line {
    sleep((^4).rand);

    my $msg   = EventSource::Server::Event.new( data => to-json({ :23update, :2status } ) );

    my $event = EventSource::Server::Event.new( :$type, data => to-json({ :$archive, :$type } ) );

    $!supplier.emit($msg);
    $!supplier.emit($event)

  } );

}

my %data = $!db.select-build( :$id );

%data;

}

method get-builds ( ) {

  $!db.select-builds;
}

submethod BUILD( DB::Pg :$pg! ) {

  $!db = DistributionsStorage::Database.new: :$pg;
}
