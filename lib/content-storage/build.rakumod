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

enum Status  is export  (
  UNKNOWN   => '<i class="bi bi-exclamation-triangle text-warning"></i>',
  ERROR     => '<i class="bi bi-x text-danger"></i>',
  SUCCESS   => '<i class="bi bi-check text-success"></i>',
  RUNNING   => '<div class="spinner-grow spinner-grow-sm text-primary" role="status"><span class="visually-hidden">Loading...</span></div>',
);

class BuildLogSource does Log::Dispatch::Source is export { }

class ServerSentEventsDestination does Log::Dispatch::Destination is export {

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
    my $datetime;
    my $started;
    my $completed;

    $!db.update-build-started: :$!id;
    $!db.update-build-status:  :$!id, status => RUNNING.key;

    $datetime = $!db.select-build-started: :$!id;

    $started = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    $status = RUNNING.value;

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
       

      $!db.update-build-meta:   :$!id, test   => ERROR.key;

      self!server-message: :$!id, build => %( test => ERROR.value );

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

    $!db.update-build-meta: :$!id,   meta => SUCCESS.key;

    $!db.update-build-name:    :$!id, :$name;
    $!db.update-build-version: :$!id, :$version;
    $!db.update-build-auth:    :$!id, :$auth;
    $!db.update-build-api:     :$!id, :$api if $api;

    $!db.update-build-identity: :$!id, :$identity;

    $build-log-source.log: :debug, 'meta: success';
    $build-log-source.log: :debug, "identity: $identity";


    self!server-message: :$!id, build => %( :$identity, meta => SUCCESS.value );


    $test = RUNNING;

    $!db.update-build-test: :$!id, test   => $test.key;

    self!server-message: :$!id, build => %( test => $test.value );

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



    $test = $exitcode ?? ERROR !! SUCCESS;

    $!db.update-build-test:   :$!id, test   => $test.key;

    self!server-message: :$!id, build => %( test => $test.value );

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
    
    my $install-archive = $distribution-directory.dirname.IO.add( 'changeme.tar.gz' );

    my @install-file = find $install-directory;

    with archive-write( $install-archive.Str ) -> $archive-write {

      $build-log-source.log: :debug, 'install-archive: ' ~ $install-archive;

      @install-file.map( -> $file {

        $archive-write.write: $file.IO.relative( $install-directory ), $file;

      } );

      $archive-write.close;

    }

    $!db.insert-distribution: :$!user, build => $!id, meta => $meta-content;

    #for archive-read( $install-archive ) -> $entry {

    #  $build-log-source.log: :debug, 'extract: ' ~ $entry.pathname;

    #}

    $status = SUCCESS;

    $!db.update-build-status: :$!id, status => $status.key;

    $!db.update-build-log: :$!id, log => $log-file.slurp;

    $!db.update-build-completed: :$!id;

    $datetime = $!db.select-build-completed: :$!id;

    $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    self!server-message: :$!id, build => %( status => $status.value, :$completed );

    True;

  }

  method !fail-build ( UUID:D :$!id! ) {

    my $status = ERROR;

    $!db.update-build-status: :$!id, status => $status.key;

    $!db.update-build-completed: :$!id;

    my $datetime = $!db.select-build-completed: :$!id;

    my $completed = "$datetime.yyyy-mm-dd() $datetime.hh-mm-ss()";

    self!server-message: :$!id, build => %( status => $status.value, :$completed );

  }

  method !server-message ( Str:D :$target = 'BUILD', Str:D :$operation = 'UPDATE', UUID:D :$!id!, :%build! ) {

    $!event-supplier.emit( EventSource::Server::Event.new( data => to-json %( :$target, :$operation, :%build, ID => ~$!id ) ) );

  }

}
