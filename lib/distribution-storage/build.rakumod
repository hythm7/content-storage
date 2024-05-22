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


method build ( --> Bool:D ) {

  my $datetime;
  my $started;
  my $completed;

  my $status;
  my $meta;
  my $test;

  my $user     = $!user.username;
  my $filename = $!archive.filename;

  $!db.update-build-started: :$!id;
  $!db.update-build-status:  :$!id, status => RUNNING.key;

  $datetime = $!db.select-build-started: :$!id;

  $started = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

  $status   = RUNNING.value;
  $meta     = UNKNOWN.value;
  $test     = UNKNOWN.value;
  
  self!server-message: :$!id, operation => 'ADD', build => %( :$status, :$user, :$filename, :$meta, :$test, :$started );


  my $distribution-directory = $!work-directory.add( 'distribution' );

  .extract for archive-read( $!archive.body-blob, destpath => ~$distribution-directory );


  my $meta-file = $distribution-directory.add: 'META6.json';

  unless $meta-file.e {

    $!db.update-build-meta: :$!id, meta => ERROR.key;

    $!db.update-build-status: :$!id, status => ERROR.key;

    $!db.update-build-completed: :$!id;

    $datetime = $!db.select-build-completed: :$!id;

    $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    self!server-message: :$!id, build => %( test => $test.value, status => $test.value, :$completed );

    return False;

  }


  my %meta = from-json $meta-file.slurp;

  my Str:D $name    = %meta<name>;
  my Str:D $version = %meta<version>;
  my Str:D $auth    = %meta<auth>;
  my Any   $api     = %meta<api>;

  my $identity = identity :$name, :$version, :$auth, :$api;

  $!db.update-build-meta: :$!id,   meta => SUCCESS.key;

  $!db.update-build-name:    :$!id, :$name;
  $!db.update-build-version: :$!id, :$version;
  $!db.update-build-auth:    :$!id, :$auth;
  $!db.update-build-api:     :$!id, :$api if $api;

  $!db.update-build-identity: :$!id, :$identity;

  self.log: :debug, 'meta: success';
  self.log: :debug, "identity: $identity";


  self!server-message: :$!id, build => %( :$identity, meta => SUCCESS.value );


  $test = RUNNING;

  $!db.update-build-test:   :$!id, test   => $test.key;

  self!server-message: :$!id, build => %( test => $test.value );

  my $install-directory = $distribution-directory.add( 'install' );

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



  $test = $exitcode ?? ERROR !! SUCCESS;

  $!db.update-build-test:   :$!id, test   => $test.key;
  $!db.update-build-status: :$!id, status => $test.key;

  $!db.update-build-completed: :$!id;

  $datetime = $!db.select-build-completed: :$!id;

  $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

  self!server-message: :$!id, build => %( test => $test.value, status => $test.value, :$completed );

  # TODO Add logs to db

  return False if $exitcode;

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

my sub identity ( Str:D :$name!, Str:D :$version!, Str:D :$auth!, Any :$api! --> Str:D ) {

  "$auth:{ $name.subst( '::', '-', :g ) }:$version:$api";

}
