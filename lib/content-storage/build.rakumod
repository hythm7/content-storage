use File::Temp;
use Concurrent::File::Find;
use JSON::Fast;
use Digest::SHA1::Native;
use Libarchive::Simple;
use EventSource::Server;

use Log::Dispatch;
use Log::Dispatch::Source;
use Log::Dispatch::Destination;
use Log::Dispatch::TTY;

use content-storage;
use content-storage-config;
use content-storage-database;

enum Status  <SUCCESS ERROR RUNNING UNKNOWN>;


class ServerSentEventsDestination does Log::Dispatch::Destination {

  use Terminal::ANSI::OO 'ansi';

  has Str      $!type           is built;
  has Supplier $!event-supplier is built is required;
  has Bool:D   $!color = config.get( 'build.log.color' );


  method report( Log::Dispatch::Msg:D $message ) {

      my $prefix = "";
      my $suffix = "";

    if $!color {
      with $message.level.key {
        $prefix = %Log::Dispatch::TTY::L2C{$_};
        $suffix = ansi.text-reset;
      }
    }

    $message.fmt-lines.map( -> $line {
      my $event = EventSource::Server::Event.new( :$!type, data => $prefix ~ $line ~ $suffix );

      $!event-supplier.emit( $event );

    });

  }

}

class ContentStorage::Build does Log::Dispatch::Source {


  has IO::Path $!work-directory;

  has Log::Dispatch $!logger;

  has IO::Path $!log-file;

  has            $!archive        is required;
  has            $!db             is required;
  has UUID:D     $!user           is required;
  has UUID:D     $.id             is required;
  has Supplier:D $!event-supplier is required;

  my enum Target    <BUILD DISTRIBUTION>;
  my enum Operation <ADD UPDATE DELETE>;

  submethod BUILD( ContentStorage::Database:D :$!db!, Supplier:D :$!event-supplier!, UUID:D :$!user!, :$!archive! ) {


    $!work-directory = tempdir.IO;

    $!id = $!db.insert-build: :$!user;

    $!log-file = $!work-directory.add( $!id ).extension( 'log' );

    $!logger = Log::Dispatch.new;

    $!logger.add: self;
    $!logger.add: Log::Dispatch::TTY,          max-level => LOG-LEVEL::DEBUG, :console, tty => $!log-file.open( :create, :rw ), color => config.get( 'build.log.color' );
    $!logger.add: ServerSentEventsDestination, max-level => LOG-LEVEL::DEBUG, :$!event-supplier, type => $!id.Str;
  }


  method build ( ) {

    LEAVE $!logger.shutdown;

    my $source-archive = $!work-directory.add: 'source-archive.tar.gz';

    my $distribution-directory = $!work-directory.add( 'distribution' );

    self.log: 'build: start!';

    $source-archive.spurt( $!archive, :close );

    $!db.update-build-started: :$!id;
    $!db.update-build-status:  :$!id, status => +RUNNING;

    my $started = $!db.select-build-started: :$!id;

    server-message build => %( status => +RUNNING, :$started );

    return fail-build unless extract-archive;

    return fail-build unless check-meta;

    return fail-build unless test-distribution;

    return fail-build unless store-distribution;

    complete-build;

    CATCH {

      default {

        .say;
        self.log: :error, .message;

        fail-build;
      }
    }

    my sub extract-archive ( ) {

      self.log: "extract: ｢$source-archive｣";

      .extract for archive-read( $source-archive, destpath => ~$distribution-directory );

      return True;
    }


    my sub check-meta ( --> Bool:D ) {

      self.log: 'meta: checking!';

      my $meta-file = $distribution-directory.add: 'META6.json';

      unless $meta-file.e {

        self.log: :error, "meta: ｢$meta-file｣ not found!";

        $!db.update-build-meta:   :$!id, meta   => +ERROR;

        server-message build => %( meta => +ERROR );

        return False;

      }

      my %meta = from-json $meta-file.slurp;

      my Str:D $name    = %meta<name>;
      my Any   $version = %meta<version>;
      my Any   $auth    = %meta<auth>;
      my Any   $api     = %meta<api>;

      my $identity = identity :$name, :$version, :$auth, :$api;

      $!db.update-build-name:    :$!id, :$name;
      $!db.update-build-version: :$!id, :$version if $version;
      $!db.update-build-auth:    :$!id, :$auth    if $auth;
      $!db.update-build-api:     :$!id, :$api     if $api;

      $!db.update-build-identity: :$!id, :$identity;

      self.log: "meta: name     ｢$name｣";
      self.log: "meta: version  ｢$version｣";
      self.log: "meta: auth     ｢$auth｣";
      self.log: "meta: api      ｢$api｣";
      self.log: "meta: identity ｢$identity｣";


      server-message build => %( :$identity );

      unless $version {

        $!db.update-build-meta: :$!id,   meta => +ERROR;

        self.log: :error, "meta: version not found!";
        self.log: :error, 'meta: failed!';

        server-message build => %( meta => +ERROR );

        return False;
      }

      unless $auth {

        $!db.update-build-meta: :$!id,   meta => +ERROR;

        self.log: :error, "meta: auth not found!";
        self.log: :error, 'meta: failed!';

        server-message build => %( meta => +ERROR );

        return False;
      }


      #my $storage-name = config.get( 'storage.name' );
      #my $username = $!db.select-user-username: id => $!user;
      my $storage-name = $auth.split( ':' ).head;
      my $username     = $auth.split( ':' ).tail;

      my $valid-auth = "$storage-name:$username";

      unless $auth ~~ $valid-auth {

        $!db.update-build-meta: :$!id,   meta => +ERROR;

        self.log: :error, "meta: invalid-auth $auth please use $valid-auth";
        self.log: 'meta: failed!';

        server-message build => %( meta => +ERROR );

        return False;
      }


      if $!db.select-distribution( :$identity ) {

        $!db.update-build-meta: :$!id,   meta => +ERROR;

        self.log: :error, "meta: ｢$identity｣ distribution already exists!";
        self.log: :error, "meta: failed!";

        server-message build => %( meta => +ERROR );

        return False;

      }


      $!db.update-build-meta: :$!id,   meta => +SUCCESS;

      self.log: 'meta: success!';

      server-message build => %( meta => +SUCCESS );

      return True;

    }
    
    my sub test-distribution ( --> Bool:D ) {

      self.log: "test: start!";

      $!db.update-build-test: :$!id, test => +RUNNING;

      server-message build => %( test => +RUNNING );

      my @test-command = config.get( 'build.test.command' ).split: / \s+ /;

      my $proc = Proc::Async.new: @test-command;

      self.log: :debug, "test: command  ｢$proc.command()｣";

      my $exitcode;

      react {

        whenever $proc.stdout { self.log: $^out.chop }
        whenever $proc.stderr { self.log: $^err.chop }

        whenever $proc.start( cwd => $distribution-directory, :%*ENV ) {
          $exitcode = .exitcode;
          done;
        }
      }


      if $exitcode {

        $!db.update-build-test:   :$!id, test   => +ERROR;

        server-message build => %( test => +ERROR );

        self.log: :error, "test: failed!";

        return False;

      }

      $!db.update-build-test:   :$!id, test   => +SUCCESS;

      server-message build => %( test => +SUCCESS );

      self.log: "test: success!";

      return True;

    }


    my sub store-distribution ( --> Bool:D ) {

      self.log: "store: start!";
      
      my $meta-file = $distribution-directory.add: 'META6.json';

      my %meta = from-json $meta-file.slurp;

      my Str:D $name    = %meta<name>;
      my Str:D $version = %meta<version>;
      my Str:D $auth    = %meta<auth>;
      my Any   $api     = %meta<api>;

      my $identity = identity :$name, :$version, :$auth, :$api;

      my $name-sha     = sha1-hex $name;
      my $identity-sha = sha1-hex $identity;

      my IO::Path:D $store-archive-directory = 'archive'.IO;

      my $distribution-archive-directory = $store-archive-directory.add( $name-sha );

      my $distribution-archive = $distribution-archive-directory.add( $identity-sha );

      if $distribution-archive.e {

        self.log: :error, "store: ｢$distribution-archive｣ archive already exists, please contact adminstrator!";
        self.log: :error, "store: failed!";

        return False;

      }

      my Any   $description = %meta<description>;

      my @provides = |%meta<provides>.map( *.key ) if %meta<provides>;
      my @tags     = |%meta<tags>                  if %meta<tags>;

      my $readme-file  = $distribution-directory.add: 'README.md';
      my $changes-file = $distribution-directory.add: 'Changes';

      my Str $readme  = $readme-file.slurp  if $readme-file.e;
      my Str $changes = $changes-file.slurp if $changes-file.e;

      self.log: "store: ｢$identity｣";

      $distribution-archive-directory.mkdir;

      $source-archive.copy( $distribution-archive, :createonly );

      my $archive = $distribution-archive.Str;
      my $created = DateTime( now );

      my %content-storage = %( :$identity, :$archive, :$created );

      %meta.push: :%content-storage;

      my $meta = to-json %meta;


      $!db.insert-distribution(
        build => $!id,
        :$!user,
        :$identity,
        :$name,
        :$version,
        :$auth,
        :$api,
        :$meta,
        :$description,
        :@provides,
        :@tags,
        :$readme,
        :$changes,
        :$archive,
        :$created,
    );

      self.log: "store: success!";

      return True;

    }


    my sub complete-build ( --> True ) {

      $!db.update-build-status: :$!id, status => +SUCCESS;

      $!db.update-build-log: :$!id, log => $!log-file.slurp: :close ;

      $!db.update-build-completed: :$!id;

      my $completed = $!db.select-build-completed: :$!id;

      server-message build => %( status => +SUCCESS, :$completed );

    }

    my sub fail-build ( ) {

      self.log: :error, 'build: failed!';

      $!db.update-build-status: :$!id, status => +ERROR;

      $!db.update-build-completed: :$!id;

      $!db.update-build-log: :$!id, log => $!log-file.slurp :close;

      my $completed = $!db.select-build-completed: :$!id;

      server-message build => %( status => +ERROR, :$completed );

    }

    my sub server-message ( :%build! ) {

      my $event = EventSource::Server::Event.new( data => to-json %( :target<BUILD>, :operation<UPDATE>,  ID => ~$!id, :%build ) );

      $!event-supplier.emit( $event );

    }

  }
}
