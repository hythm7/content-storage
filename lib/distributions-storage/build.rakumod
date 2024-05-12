use File::Temp;
use Libarchive::Simple;

use Log::Dispatch;
use Log::Dispatch::TTY;
use Log::Dispatch::Destination;
use Log::Dispatch::Source;

use EventSource::Server;

unit class DistributionStorage::Build;
  also does Log::Dispatch::Source;


my class ServerSentEventsDestination {
  also does Log::Dispatch::Destination;

  has Str      $!type           is built;
  has Supplier $!event-supplier is built;

  method report(Log::Dispatch::Msg:D $message) {

   dd $message;
   my $event = EventSource::Server::Event.new( :$!type, data => $message.msg );

   $!event-supplier.emit( $event );

  }

}

has IO::Path:D  $!work-directory is required;

has Str:D  $!type is built is required ;


has Log::Dispatch $!logger;

has IO::Path $!log-file;

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
   
submethod BUILD( Str:D :$!type!, IO::Path:D :$!work-directory!, :$event-supplier! ) {

  $!logger = Log::Dispatch.new;

  $!log-file = $!work-directory.add: 'build.log';

  $!logger.add: Log::Dispatch::TTY,                       max-level => LOG-LEVEL::DEBUG;
  $!logger.add: ServerSentEventsDestination.new( :$!type, :$event-supplier ), max-level => LOG-LEVEL::DEBUG;
  #$!logger.add: DatabaseDestination.new( :$id ),         max-level => LOG-LEVEL::DEBUG;
  $!logger.add: self;

  self.log: :critical, "Something is wrong! Cause: ", 'kokokoko';

}  

