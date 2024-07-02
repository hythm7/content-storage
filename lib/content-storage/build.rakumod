use File::Temp;
use Concurrent::File::Find;
use JSON::Fast;
use Libarchive::Simple;
use EventSource::Server;

use Log::Dispatch;
use Log::Dispatch::Source;
use Log::Dispatch::Destination;
use Log::Dispatch::File;

use content-storage;
use content-storage-database;

enum Status  <SUCCESS ERROR RUNNING UNKNOWN>;

class BuildLogSource does Log::Dispatch::Source { }

class ServerSentEventsDestination does Log::Dispatch::Destination {

  has Str      $!type           is built;
  has Supplier $!event-supplier is built is required;

  method report( Log::Dispatch::Msg:D $message ) {

    $message.fmt-lines.map( -> $line {

      my $event = EventSource::Server::Event.new( :$!type, data => $line );

      $!event-supplier.emit( $event );

    });

  }

}

class ContentStorage::Build {

  has            $!archive        is required;
  has            $!db             is required;
  has UUID:D     $!user           is required;
  has UUID:D     $.id             is required;
  has Supplier:D $!event-supplier is required;

  my enum Target    <BUILD DISTRIBUTION>;
  my enum Operation <ADD UPDATE DELETE>;

  submethod BUILD( ContentStorage::Database:D :$!db!, Supplier:D :$!event-supplier!, UUID:D :$!user!, :$!archive! ) {

    $!id = $!db.insert-build: :$!user;

  }


  method build ( ) {

    my $work-directory = tempdir.IO;

    my $source-archive = $work-directory.add: 'source-archive.tar.gz';

    my $distribution-directory = $work-directory.add( 'distribution' );


    my $log-file = $distribution-directory.dirname.IO.add( $!id ~ '.log' );

    my $build-log-source = BuildLogSource.new;

    my $logger = Log::Dispatch.new;

    $logger.add: $build-log-source;
    $logger.add: Log::Dispatch::File,         max-level => LOG-LEVEL::DEBUG,   file => $log-file;
    $logger.add: ServerSentEventsDestination, max-level => LOG-LEVEL::DEBUG, :$!event-supplier, type => $!id.Str;

    $source-archive.spurt( $!archive, :close );

    my $status;
    my $test;

    $!db.update-build-started: :$!id;
    $!db.update-build-status:  :$!id, status => +RUNNING;

    my $started = $!db.select-build-started: :$!id;

    $status = +RUNNING;

    self!server-message: :$!id, build => %( :$status, :$started );

    sleep 2;

    for archive-read( $source-archive, destpath => ~$distribution-directory ) -> $entry {

      $build-log-source.log: :debug, 'extract: ' ~ $entry.pathname;

      $entry.extract;

    }

    my $meta-file = $distribution-directory.add: 'META6.json';

    unless $meta-file.e {

      #TODO: Enforce META
      #  Distribution Identity:
      #  based on S22 Identity format should be "<storage>:<auth>:<name>:<version>:<api>"
      #  So it makes sense to have no colons in distribution name (modules too, may be!), version, auth or api

      #  Content storage name matches auth
      #  User/Owner matches auth

      #  Dependencies:
      #  phases (runtime, test, build, development too may be!)
      #  requirement (required, recommended, optional)
       

      $!db.update-build-meta:   :$!id, test   => +ERROR;

      self!server-message: :$!id, build => %( test => +ERROR );

      self!fail-build: :$!id;

      return False;

    }


    my $meta-content = $meta-file.slurp;

    my %meta = from-json $meta-content;

    my Str:D $name    = %meta<name>;
    my Str:D $version = %meta<version>;
    my Str:D $auth    = %meta<auth>;
    my Any   $api     = %meta<api>;

    my $identity = identity :$name, :$version, :$auth, :$api;

    $!db.update-build-meta: :$!id,   meta => +SUCCESS;

    $!db.update-build-name:    :$!id, :$name;
    $!db.update-build-version: :$!id, :$version;
    $!db.update-build-auth:    :$!id, :$auth;
    $!db.update-build-api:     :$!id, :$api if $api;

    $!db.update-build-identity: :$!id, :$identity;

    $build-log-source.log: :debug, 'meta: success';
    $build-log-source.log: :debug, "identity: $identity";


    self!server-message: :$!id, build => %( :$identity, meta => +SUCCESS );


    $test = +RUNNING;

    $!db.update-build-test: :$!id, :$test;

    self!server-message: :$!id, build => %( :$test );

    my $test-directory = $distribution-directory.add( 'test' );

    my @test-command = <<pakku nobar nospinner verbose all force add noprecompile notest contained to $test-directory $distribution-directory>>;

    my $proc = Proc::Async.new: @test-command;

    my $exitcode;

    react {

      whenever $proc.stdout { $build-log-source.log: $^out.chop }
      whenever $proc.stderr { $build-log-source.log: $^err.chop }

      whenever $proc.start( :%*ENV ) {
        $exitcode = .exitcode;
        done;
      }
    }



    $test = $exitcode ?? +ERROR !! +SUCCESS;

    $!db.update-build-test:   :$!id, test   => $test;

    self!server-message: :$!id, build => %( test => $test );

    # TODO Add logs to db

    if $exitcode {

      self!fail-build: :$!id;

      return False;

    }

    my $install-directory = $distribution-directory.dirname.IO.add( 'install' );
    my @install-command = <<pakku nobar nospinner verbose all force add noprecompile nodeps notest to $install-directory $distribution-directory>>;


    $proc = Proc::Async.new: @install-command;

    react {

      whenever $proc.stdout { $build-log-source.log: $^out.chop }
      whenever $proc.stderr { $build-log-source.log: $^err.chop }

      whenever $proc.start( :%*ENV ) {
        $exitcode = .exitcode;

        done;
      }
    }

    if $exitcode {

      self!fail-build: :$!id;

      return False;

    }


    # TODO: Make sure no archives exist
    
    my $readme-file  = $distribution-directory.add: 'README.md';
    my $changes-file = $distribution-directory.add: 'Changes';

    my Str $readme = $readme-file.slurp   if $readme-file.e;
    my Str $changes = $changes-file.slurp if $changes-file.e;

    $!db.insert-distribution: :$!user, build => $!id, meta => $meta-content, :$readme, :$changes;


    $!db.update-build-status: :$!id, status => +SUCCESS;

    $!db.update-build-log: :$!id, log => $log-file.slurp;

    $!db.update-build-completed: :$!id;

    my $completed = $!db.select-build-completed: :$!id;

    self!server-message: :$!id, build => %( status => +SUCCESS, :$completed );

    True;

  }

  method !fail-build ( UUID:D :$!id! ) {

    $!db.update-build-status: :$!id, status => +ERROR;

    $!db.update-build-completed: :$!id;

    my $completed = $!db.select-build-completed: :$!id;

    self!server-message: :$!id, build => %( status => +ERROR, :$completed );

  }

  method !server-message ( Str:D :$target = 'BUILD', Str:D :$operation = 'UPDATE', UUID:D :$!id!, :%build! ) {

    $!event-supplier.emit( EventSource::Server::Event.new( data => to-json %( :$target, :$operation, :%build, ID => ~$!id ) ) );

  }

}
