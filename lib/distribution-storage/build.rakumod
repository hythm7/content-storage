use File::Temp;
use JSON::Fast;
use Libarchive::Simple;
use EventSource::Server;

use Log::Dispatch;
use Log::Dispatch::TTY;
use Log::Dispatch::File;
use Log::Dispatch::Destination;
use Log::Dispatch::Source;


unit class DistributionStorage::Build;
  also does Log::Dispatch::Source;

my enum Status  is export  (
  UNKNOWN   => '<i class="bi bi-exclamation-triangle text-warning"></i>',
  ERROR     => '<i class="bi bi-x text-danger"></i>',
  SUCCESS   => '<i class="bi bi-check text-success"></i>',
  RUNNING   => '<div class="spinner-grow spinner-grow-sm text-primary" role="status"><span class="visually-hidden">Loading...</span></div>',
);


my class ServerSentEventsDestination {
  also does Log::Dispatch::Destination;

  has Str      $!type           is built is required;
  has Supplier $!event-supplier is built is required;

  method report( Log::Dispatch::Msg:D $message ) {

   my $event = EventSource::Server::Event.new( :$!type, data => $message.msg );

   $!event-supplier.emit( $event );

  }

}


has $!db;

has $!user;

has Int:D $.id is required;

has $!archive is required;

has IO::Path:D $!work-directory is required;
has IO::Path:D $!log-file is required;

has Supplier $!event-supplier;

has Log::Dispatch:D $!logger is required;


method meta ( IO::Path:D :$meta! --> Bool:D ) {

  self.log: :debug, 'meta: ' ~ $meta;

  if $meta.e {

    my %meta = from-json $meta.slurp;

    my Str:D $name    = %meta<name>;
    my Str:D $version = %meta<version>;
    my Str:D $auth    = %meta<auth>;
    my Any   $api     = %meta<api>;


    $!db.update-build-meta: :$!id, :$name, :$version, :$auth, :$api, meta => SUCCESS.key;

    self.log: :debug, 'meta: success';

    self!server-message: :$!id, build => %( :$name, :$version, :$auth, :$api, meta => SUCCESS.value );

    True;

  } else {

    $!db.update-build-meta: :$!id, meta => ERROR.key;

    self!server-message: :$!id, build => %(  meta => ERROR.value );

    False;
  }

}

method test ( IO::Path:D :$distribution-directory! --> Bool:D ) {

 my $install-directory = $distribution-directory.add( 'install' );

 #my $proc = run <<pakku nobar nospinner verbose all force add contained to $install-directory $distribution-directory>>, :out, :err;
 #$proc.out.lines.map( -> $line { self.log: $line } ); # OUTPUT: «Raku is Great!␤» 
 #$proc.err.lines.map( -> $line { self.log: $line } ); # OUTPUT: «Raku is Great!␤» 

 my @cmd = <<pakku nobar nospinner verbose all force add contained to $install-directory $distribution-directory>>;

 my $proc = Proc::Async.new: @cmd;

 my $exitcode;

 react {

   whenever $proc.stdout { self.log: $^out }
   whenever $proc.stderr { self.log: $^err }

   whenever $proc.start( :%*ENV ) {
     $exitcode = .exitcode;
     done;
   }
 }


 True;

}


method build ( --> Bool:D ) {

  self.log: :debug, 'build: ' ~ $!archive.filename;
  
  $!db.update-build-started: :$!id;
  $!db.update-build-status:  :$!id, status => RUNNING.key;

  my $user     = $!user.username;
  my $filename = $!archive.filename;

  my $datetime = $!db.select-build-started: :$!id;

  my $started = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

  my $status = RUNNING.value;
  my $meta   = UNKNOWN.value;
  my $test   = UNKNOWN.value;
  
  self!server-message: :$!id, operation => 'ADD', build => %( :$status, :$user, :$filename, :$meta, :$test, :$started );

  sleep 2;

  self.log: 'extract: ' ~ $filename;

  my $distribution-directory = $!work-directory.add( 'distribution' );

  .extract for archive-read( $!archive.body-blob, destpath => ~$distribution-directory );


  my $status-meta = self.meta: meta => $distribution-directory.add: 'META6.json';

  if $status-meta {

    $!db.update-build-status: :$!id, status => SUCCESS.key;

    $!db.update-build-completed: :$!id;

    my $datetime = $!db.select-build-completed: :$!id;

    my $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    self!server-message: :$!id, build => %( status => SUCCESS.value, :$completed );

    True;

  } else {

    $!db.update-build-status: :$!id, status => ERROR.key;

    $!db.update-build-completed: :$!id;

    my $datetime = $!db.select-build-completed: :$!id;

    my $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    self.log: :error, 'meta: error';

    self!server-message: :$!id, build => %( status => ERROR.value, :$completed );

    return False;
  }

  my $status-test = self.test: :$distribution-directory;

  True;
}


method !server-message ( Str:D :$target = 'BUILD', Str:D :$operation = 'UPDATE', Int:D :$id!, :%build! ) {

  $!event-supplier.emit( EventSource::Server::Event.new( data => to-json %( :$target, :$operation, :%build, ID => $id ) ) );

}


submethod BUILD( :$!db!, :$!user, :$!archive!, :$!event-supplier! ) {

  $!id = $!db.insert-build: user => $!user.id, filename => $!archive.filename;

  my $type = $!id.Str;

  $!work-directory = tempdir.IO;
  $!log-file       = $!work-directory.add: 'build.log';


  $!logger = Log::Dispatch.new;

  $!logger.add: Log::Dispatch::TTY,          max-level => LOG-LEVEL::DEBUG;
  $!logger.add: Log::Dispatch::File,         max-level => LOG-LEVEL::DEBUG,   file => $!log-file;
  $!logger.add: ServerSentEventsDestination, max-level => LOG-LEVEL::DEBUG, :$type, :$!event-supplier;
  $!logger.add: self;

  #self.log: :critical, "Something is wrong! Cause: ", 'kokokoko';

}  
