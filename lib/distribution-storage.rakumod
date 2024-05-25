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

  my $id = $!db.insert-build: user => $user.id, :$filename;

  my $status = UNKNOWN.value;
  my $meta   = UNKNOWN.value;
  my $test   = UNKNOWN.value;

  self!server-message: :$id, operation => 'ADD', build => %( :$status, user => $user.username, :$filename, :$meta, :$test );

  start {

    self!build: :$id, :$archive, :$distribution-directory, user => $user.username;

  }

  my %data = build-id => $id;

}


method !build ( Int:D :$id!, :$archive, IO::Path:D :$distribution-directory! ) {

  my $build-log-source = BuildLogSource.new: log-source-name => $id.Str;

  my $logger = Log::Dispatch.new;

  $logger.add: $build-log-source;
  $logger.add: ServerSentEventsDestination, max-level => LOG-LEVEL::DEBUG, :$!event-supplier, type => $id.Str;


  my $status;
  my $test;
  my $datetime;
  my $started;
  my $completed;

  $!db.update-build-started: :$id;
  $!db.update-build-status:  :$id, status => RUNNING.key;

  $datetime = $!db.select-build-started: :$id;

  $started = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

  $status = RUNNING.value;

  self!server-message: :$id, build => %( :$status, :$started );

  sleep 2;

  for archive-read( $archive, destpath => ~$distribution-directory ) -> $entry {

    $build-log-source.log: :debug, 'extract: ' ~ $entry.pathname;

    $entry.extract;

  }

  my $meta-file = $distribution-directory.add: 'META6.json';

  unless $meta-file.e {

    $!db.update-build-meta: :$id, meta => ERROR.key;

    $!db.update-build-status: :$id, status => ERROR.key;

    $!db.update-build-completed: :$id;

    $datetime = $!db.select-build-completed: :$id;

    $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    self!server-message: :$id, build => %( test => $test.value, status => $test.value, :$completed );

    return False;

  }


  my %meta = from-json $meta-file.slurp;

  my Str:D $name    = %meta<name>;
  my Str:D $version = %meta<version>;
  my Str:D $auth    = %meta<auth>;
  my Any   $api     = %meta<api>;

  my $identity = identity :$name, :$version, :$auth, :$api;

  $!db.update-build-meta: :$id,   meta => SUCCESS.key;

  $!db.update-build-name:    :$id, :$name;
  $!db.update-build-version: :$id, :$version;
  $!db.update-build-auth:    :$id, :$auth;
  $!db.update-build-api:     :$id, :$api if $api;

  $!db.update-build-identity: :$id, :$identity;

  $build-log-source.log: :debug, 'meta: success';
  $build-log-source.log: :debug, "identity: $identity";


  self!server-message: :$id, build => %( :$identity, meta => SUCCESS.value );


  $test = RUNNING;

  $!db.update-build-test: :$id, test   => $test.key;

  self!server-message: :$id, build => %( test => $test.value );

  my $install-directory = $distribution-directory.add( 'install' );

  my @cmd = <<pakku nobar nospinner verbose all force add contained to $install-directory $distribution-directory>>;

  my $proc = Proc::Async.new: @cmd;

  my $exitcode;

  react {

    whenever $proc.stdout { $build-log-source.log: $^out }
    whenever $proc.stderr { $build-log-source.log: $^err }

    whenever $proc.start( :%*ENV ) {
      $exitcode = .exitcode;
      done;
    }
  }



  $test = $exitcode ?? ERROR !! SUCCESS;

  $!db.update-build-test:   :$id, test   => $test.key;
  $!db.update-build-status: :$id, status => $test.key;

  $!db.update-build-completed: :$id;

  $datetime = $!db.select-build-completed: :$id;

  $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

  self!server-message: :$id, build => %( test => $test.value, status => $test.value, :$completed );

  # TODO Add logs to db

  return False if $exitcode;

  True;

}

method !server-message ( Str:D :$target = 'BUILD', Str:D :$operation = 'UPDATE', Int:D :$id!, :%build! ) {

  $!event-supplier.emit( EventSource::Server::Event.new( data => to-json %( :$target, :$operation, :%build, ID => $id ) ) );

}


my sub identity ( Str:D :$name!, Str:D :$version!, Str:D :$auth!, Any :$api! --> Str:D ) {

  "$auth:{ $name.subst( '::', '-', :g ) }:$version:$api";

}
