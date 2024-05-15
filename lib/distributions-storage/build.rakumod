use File::Temp;
use Libarchive::Simple;
use EventSource::Server;

use Log::Dispatch;
use Log::Dispatch::TTY;
use Log::Dispatch::Destination;
use Log::Dispatch::Source;


unit class DistributionStorage::Build;
  also does Log::Dispatch::Source;

my enum Status  is export  (
  UNKNOWN   => '<i class="bi bi-exclamation-triangle text-warning"></i>',
  ERROR     => '<i class="bi bi-x text-error"></i>',
  SUCCESS   => '<i class="bi bi-check text-success"></i>',
  RUNNING   => '<div class="spinner-grow spinner-grow-sm text-primary" role="status"><span class="visually-hidden">Loading...</span></div>',
);


my class ServerSentEventsDestination {
  also does Log::Dispatch::Destination;

  has Str      $!type           is built;
  has Supplier $!event-supplier is built;

  method report(Log::Dispatch::Msg:D $message) {

   my $event = EventSource::Server::Event.new( :$!type, data => $message.msg );

   $!event-supplier.emit( $event );

  }

}


has $!db;

has Int:D $.id is required;

has $!archive is required;

has IO::Path:D $!work-directory is required;
has IO::Path:D $!log-file is required;

has Supplier $!event-supplier;

has Log::Dispatch:D $!logger is required;


method extract ( Blob:D :$archive! --> Bool:D ) {

  self.log: 'Extracting';

  my $distribution = $!work-directory.add( 'distribution' ).Str;

  .extract for archive-read( $archive, destpath => $distribution );

  True;

}

method meta ( IO::Path:D :$distribution! --> Bool:D ) {

  self.log: 'META';

  return False unless $distribution.add( 'META6.json' ).e;

  True;

}

method logs ( --> Str ) { slurp $!log-file; }
   
method build ( --> Bool:D ) {

  self.log: :debug, 'Build ' ~ $!archive.filename;
  
  $!db.update-build-status: :$!id, status => RUNNING.key;

  $!db.update-build-started: :$!id;

  my $datetime = $!db.get-build-started: :$!id;

  my $started = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

  my %data = %( :target<BUILD>, :operation<UPDATE>, ID => $!id,  build => { status => RUNNING.value, :$started } );

  my $message = EventSource::Server::Event.new( data => to-json %data );

  $!event-supplier.emit( $message );

  say 'Built!';

}


submethod BUILD( :$!db!, Int:D :$userid, :$!archive!, :$!event-supplier! ) {

  my $filename = $!archive.filename;

  $!id = $!db.new-build: :$filename, :$userid;

  my $type = $!id.Str;

  $!work-directory = tempdir.IO;
  $!log-file       = $!work-directory.add: 'build.log';


  $!logger = Log::Dispatch.new;

  $!logger.add: Log::Dispatch::TTY,                       max-level => LOG-LEVEL::DEBUG;
  $!logger.add: ServerSentEventsDestination.new( :$type, :$!event-supplier ), max-level => LOG-LEVEL::DEBUG;
  $!logger.add: self;

  #self.log: :critical, "Something is wrong! Cause: ", 'kokokoko';

}  

