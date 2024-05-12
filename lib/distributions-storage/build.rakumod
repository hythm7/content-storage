use File::Temp;
use Libarchive::Simple;

use Log::Dispatch;
use Log::Dispatch::TTY;
use Log::Dispatch::Destination;
use Log::Dispatch::Source;

unit class DistributionStorage::Build;
  also does Log::Dispatch::Source;


my class ServerSentEventsDestination {
  also does Log::Dispatch::Destination;

  has $!id is built;

  method report(Log::Dispatch::Msg:D $message) {

   say '-----SS-----';
   say $message.msg;
   say '------------';

  }

}

has IO::Path:D  $!work-directory is required;

has Int:D  $!id is required;


has Log::Dispatch $!logger;

has IO::Path $!log-file;


method extract ( Blob:D :$archive! --> Bool:D ) {

  my $distribution = $!work-directory.add( 'distribution' ).Str;

  .extract for archive-read( $archive, destpath => $distribution );

  True;

}

method meta ( IO::Path:D :$distribution! --> Bool:D ) {

  return False unless $distribution.add( 'META6.json' ).e;

  True;

}

method logs ( --> Str ) { slurp $!log-file; }
   
submethod BUILD( Int:D :$!id!, IO::Path:D :$!work-directory! ) {

  $!logger = Log::Dispatch.new;

  $!log-file = $!work-directory.add: 'build.log';

  $!logger.add: Log::Dispatch::TTY,                       max-level => LOG-LEVEL::DEBUG;
  $!logger.add: ServerSentEventsDestination.new( :$!id ), max-level => LOG-LEVEL::DEBUG;
  #$!logger.add: DatabaseDestination.new( :$id ),         max-level => LOG-LEVEL::DEBUG;
  $!logger.add: self;

  self.log: :critical, "Something is wrong! Cause: ", 'kokokoko';

}  

