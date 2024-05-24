use File::Temp;
use JSON::Fast;
use Libarchive::Simple;
use EventSource::Server;

use Log::Dispatch;


use distribution-storage-utils;
use distribution-storage-database;

unit class DistributionStorage;

has Supplier:D            $!event-supplier      is required; 
has EventSource::Server:D $.event-source-server is required; 


has DistributionStorage::Database:D $!db  is required handles <
  insert-user
  select-user
  select-user-password
  select-distribution
  delete-dist
  >;


my enum Target    <BUILD DISTRIBUTION>;
my enum Operation <ADD UPDATE DELETE>;
method select-build ( ) {

  $!db.select-build;
}


submethod BUILD( :$pg! ) {

  $!db = DistributionStorage::Database.new: :$pg;

  $!event-supplier  = Supplier.new;

  $!event-source-server = EventSource::Server.new: supply => $!event-supplier.Supply; 

}

method distribution-add ( :$user, :$file! ) {

  my $work-directory = tempdir.IO;

  my $filename = $file.filename;

  my $archive = $work-directory.add( $filename );

  my $distribution-directory = $work-directory.add( 'distribution' );


  $archive.spurt( $file.body-blob, :close );

  .extract for archive-read( $archive, destpath => ~$distribution-directory );

  my $id = $!db.insert-build: :$user, :$filename;

  start {

    self.build: :$id, :$distribution-directory;

  }

  my %data = build-id => $id;

}


method build ( Int:D :$id!, IO::Path:D :$distribution-directory! ) {

  #sleep 3;
  #$build-log-source.log: :debug, 'building......' ~ $id;
  #self!server-message: :$id, build => %( test => RUNNING.value );

  my $build-log-source = BuildLogSource.new: log-source-name => $id.Str;

  my $logger = Log::Dispatch.new;

  $logger.add: $build-log-source;
  $logger.add: ServerSentEventsDestination, max-level => LOG-LEVEL::DEBUG, :$!event-supplier, type => $id.Str;


}

method !server-message ( Str:D :$target = 'BUILD', Str:D :$operation = 'UPDATE', Int:D :$id!, :%build! ) {

  $!event-supplier.emit( EventSource::Server::Event.new( data => to-json %( :$target, :$operation, :%build, ID => $id ) ) );

}


