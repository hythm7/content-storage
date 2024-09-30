use Crypt::Argon2;
use Cro::WebApp::Template;
use Cro::HTTP::Router;
use Cro::OpenAPI::RoutesFromDefinition;

use content-storage;
use content-storage-config;
use content-storage-pager;
use content-storage-session;
use content-storage-database;
use content-storage-build;
use content-storage-model-build;

sub api-v1-routes (
  IO::Path:D                 :$openapi-schema!,
  ContentStorage::Database:D :$db!,
  Supplier:D                 :$event-supplier!,
) is export {

  my $page-limit        = config.get( 'api.page.limit' );
  my $archives-directory = config.get( 'storage.archives-directory' ).IO;

  openapi $openapi-schema, :validate-responses, {

    operation 'readDistributions', -> ContentStorage::Session $session, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {

      my Int:D $total = $db.select-distributions-count: :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @distribution = $db.select-distributions: :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @distribution;

    }

    operation 'readBuilds', -> ContentStorage::Session $session, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {
      my Int:D $total = $db.select-builds-count: :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @build = $db.select-builds: :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @build;
    }

    operation 'readUsers', -> Admin $session, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {
      my Int:D $total = $db.select-users-count: :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @user = $db.select-users: :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @user;

    }


    operation 'readUserDistributions', -> ContentStorage::Session $session, UUID:D $user, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {

      my Int:D $total = $db.select-user-distributions-count: :$user, :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @distribution = $db.select-user-distributions: :$user, :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @distribution;

    }

    operation 'readUserBuilds', -> ContentStorage::Session $session, UUID:D $user, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {

      my Int:D $total = $db.select-user-builds-count: :$user, :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @build = $db.select-user-builds: :$user, :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @build;

    }


    operation 'readDistribution', -> ContentStorage::Session $session, Str:D $distribution {

      my %distribution = $db.select-distribution: $distribution;

      if %distribution {

        content 'application/json', %distribution;

      } else {
        not-found 'application/json', %( :404code, message => "Distribution ｢$distribution｣ not found!" );
      }
    }

    operation 'deleteDistribution', -> Admin $session, Str:D :$distribution! is query {

      dd $distribution;
      dd $distribution ~~ Identity;

      my %distribution = $db.select-distribution: $distribution;

      if %distribution {

        $db.delete-distribution: id => %distribution<id>;

        $archives-directory.add( %distribution<archive> ).unlink; 

        content 'application/json', %distribution;

      } else {
        not-found 'application/json', %( :404code, message => "Distribution ｢$distribution｣ not found!" );
      }


    }


    operation 'readBuild', -> ContentStorage::Session $session, UUID:D $build  {

      my %build = $db.select-build: $build;

      if %build {

        content 'application/json', %build;

      } else {
        not-found 'application/json', %( :404code, message => "Build ｢$build｣ not found!" );
      }
    }

    operation 'deleteBuild', -> Admin $session, UUID:D :$build! is query  {

      my %build = $db.select-build: $build;

      if %build {

        $db.delete-build: id => %build<id>;

        content 'application/json', %build;

      } else {
        not-found 'application/json', %( :404code, message => "Build ｢$build｣ not found!" );
      }


    }

    operation 'deleteUser', -> Admin $session, Str:D :$user! is query  {

      my %user = $db.select-user: $user;

      if %user {

        $db.delete-user: id => %user<id>;

        content 'application/json', %user;

      } else {
        not-found 'application/json', %( :404code, message => "User ｢$user｣ not found!" );
      }

    }


    operation 'readUser', -> LoggedIn $session, Str:D $user  {

      my %user = $db.select-user: $user;

      if ( %user and  ( ( %user<id> eq $session.user.id ) or $session.admin ) ) {

        content 'application/json', %user;

      } else {

        not-found 'application/json', %( :404code, message => "User ｢$user｣ not found!" );

      }
    }


    operation 'readBuildLogById', -> ContentStorage::Session $session, UUID:D $id  {

      my %build = $db.select-build-log: :$id;

      if %build {

        content 'application/json', %build;

      } else {
        not-found 'application/json', %( :404code, message => "Build ｢$id｣ not found!" );
      }
    }



    operation 'buildDistribution', -> LoggedIn $session {

      my $user =  $session.user;

      request-body -> ( :$file ) {

        my $build = ContentStorage::Build.new: :$db, :$event-supplier, user => $user.id, archive => $file.body-blob;

        my %data = %( id => $build.id );

        content 'application/json', %data;

        start $build.build;

      }
    }


    operation 'loginUser', -> ContentStorage::Session $session {

      request-body -> ( :$username!, :$password! ) {
        
        my %password = $db.select-user-password( :$username );

        if  %password {

          if ( argon2-verify( %password<password>, $password ) ) {

            my %user = $db.select-user( $username );

            my $user = ContentStorage::Model::User.new: |%user;

            $session.set-logged-in-user( $user );

            content 'application/json', %user;

          } else {
            forbidden 'application/json', %( :403code, message => "Incorrect password for user ｢$username｣!" );
          }
        } else {
            forbidden 'application/json', %( :403code, message => "Incorrect username or password!" );
        }
      }
    }

    operation 'registerUser', -> ContentStorage::Session $session {

      request-body -> ( :$username!, :$firstname!, :$lastname!, :$email!, :$password! ) {

        if $db.select-user( $username ) {

          conflict 'application/json', %( :409code, message => "User ｢$username｣ is already registered!" );

        } else {

          my %user = $db.insert-user( :$username, :$firstname, :$lastname, :$email, password => argon2-hash( $password ) );

          content 'application/json', %user;

        }
      }
    }

    operation 'logoutUser', -> ContentStorage::Session $session {

      if $session.user {

        my $user = $session.user;

        $session.set-logged-in-user( Nil );

        content 'application/json', { id => $user.id, username => $user.username };
      } else {

        not-found 'application/json', %( :404code, message => "No active session!" );
      }
    }

    operation 'updateUserInfo', -> LoggedIn $session, UUID:D $id {


      request-body -> ( :$firstname, :$lastname, :$email ) {
        
        if $id eq $session.user.id {

          $db.update-user-info( :$id, :$firstname, :$lastname, :$email );

          my %user = $db.select-user( :$id );

          content 'application/json', %user;

        } else {

          forbidden 'application/json', %( :403code, message => "Not authorized to modify user ｢$id｣ info!" );
        }
      }
    }


    operation 'updateUserPassword', -> LoggedIn $session, UUID:D $id {

      my %user = $db.select-user( $id );

      request-body -> ( :$password! ) {
        
        if ( %user and  ( ( $id eq $session.user.id ) or $session.admin ) ) {

          $db.update-user-password( :$id, password => argon2-hash( $password ) );

          content 'application/json', %user;

        } else {

          not-found 'application/json', %( :404code, message => "User ID ｢$id｣ not found!" );

        }
      }
    }

    operation 'updateUserAdmin', -> LoggedIn $session, UUID:D $id {


      request-body -> ( Bool(Int()):$admin! ) {

        if $db.select-user( $id ) and $session.admin {

          $db.update-user-admin( :$id, :$admin );

          my %user = $db.select-user( $id );

          content 'application/json', %user;

        } else {

          not-found 'application/json', %( :404code, message => "User ID ｢$id｣ not found!" );

        }
      }
    }

  }
}
