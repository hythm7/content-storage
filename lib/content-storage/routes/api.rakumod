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

sub api-routes(
  IO::Path:D                 :$openapi-schema!,
  ContentStorage::Database:D :$db!,
  Supplier:D                 :$event-supplier!,
) is export {

  my $page-limit        = config.get( 'api.page.limit' );
  my $archive-directory = config.get( 'storage.archive-directory' ).IO;

  openapi $openapi-schema, :validate-responses, {

    operation 'readDistribution', -> ContentStorage::Session $session, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {

      my Int:D $total = $db.select-distribution: 'count', :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @distribution = $db.select-distribution: :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @distribution;

    }

    operation 'readBuild', -> ContentStorage::Session $session, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {
      my Int:D $total = $db.select-build: 'count', :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @build = $db.select-build: :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @build;
    }

    operation 'readUser', -> Admin $session, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {
      my Int:D $total = $db.select-user: 'count', :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @user = $db.select-user: :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @user;

    }


    operation 'readUserDistributions', -> ContentStorage::Session $session, UUID:D $user, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {

      my Int:D $total = $db.select-user-distribution: 'count', :$user, :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @distribution = $db.select-user-distribution: :$user, :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @distribution;

    }

    operation 'readUserBuilds', -> ContentStorage::Session $session, UUID:D $user, Str :$name, UInt:D :$page = 1, UInt :$limit = $page-limit {

      my Int:D $total = $db.select-user-build: 'count', :$user, :$name;

      my $pager = ContentStorage::Pager.new: :$total, :$page, :$limit;

      response.append-header: 'x-first',    $pager.first;
      response.append-header: 'x-previous', $pager.previous;
      response.append-header: 'x-current',  $pager.current;
      response.append-header: 'x-next',     $pager.next;
      response.append-header: 'x-last',     $pager.last;


      my @build = $db.select-user-build: :$user, :$name, offset => $pager.offset, limit => $pager.limit;

      content 'application/json', @build;

    }


    operation 'readDistributionById', -> ContentStorage::Session $session, UUID:D $id  {

      my %distribution = $db.select-distribution: :$id;

      if %distribution {

        content 'application/json', %distribution;

      } else {
        not-found 'application/json', %( :404code, message => "Distribution ID  ｢$id｣ not found!" );
      }
    }

    operation 'deleteDistributionById', -> Admin $session, UUID:D $id  {

      my %distribution = $db.select-distribution: :$id;

      if %distribution {

        $db.delete-distribution: :$id;

        $archive-directory.add( %distribution<archive> ).unlink; 

        content 'application/json', %distribution;

      } else {
        not-found 'application/json', %( :404code, message => "Distribution ID  ｢$id｣ not found!" );
      }


    }


    operation 'readBuildById', -> ContentStorage::Session $session, UUID:D $id  {

      my %build = $db.select-build: :$id;

      if %build {

        content 'application/json', %build;

      } else {
        not-found 'application/json', %( :404code, message => "Build ID ｢$id｣ not found!" );
      }
    }

    operation 'deleteBuildById', -> Admin $session, UUID:D $id  {

      my %build = $db.select-build: :$id;

      if %build {

        $db.delete-build: :$id;

        content 'application/json', %build;

      } else {
        not-found 'application/json', %( :404code, message => "Build ID ｢$id｣ not found!" );
      }


    }

    operation 'deleteUserById', -> Admin $session, UUID:D $id  {

      my %user = $db.select-user: :$id;

      if %user {

        $db.delete-user: :$id;

        content 'application/json', %user;

      } else {
        not-found 'application/json', %( :404code, message => "User ID ｢$id｣ not found!" );
      }


    }


    operation 'readUserById', -> LoggedIn $session, UUID:D $id  {

      my %user = $db.select-user: :$id;

      if ( %user and  ( ( $id eq $session.user.id ) or $session.admin ) ) {

        content 'application/json', %user;

      } else {

        not-found 'application/json', %( :404code, message => "User ID ｢$id｣ not found!" );

      }
    }


    operation 'readBuildLogById', -> ContentStorage::Session $session, UUID:D $id  {

      my %build = $db.select-build-log: :$id;

      if %build {

        content 'application/json', %build;

      } else {
        not-found 'application/json', %( :404code, message => "Build ID ｢$id｣ not found!" );
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

            my %user = $db.select-user( :$username );

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

        if $db.select-user( :$username ) {

          conflict 'application/json', %( :409code, message => "User ｢$username｣ is already registered!" );

        } else {

          my %user = $db.insert-user( :$username, :$firstname, :$lastname, :$email, password => argon2-hash( $password ) );

          content 'application/json', %user;

        }
      }
    }

    operation 'logoutUser', -> ContentStorage::Session $session {

      my $user = $session.user;

      $session.set-logged-in-user( Nil );

      content 'application/json', { id => $user.id, username => $user.username };

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

      my %user = $db.select-user( :$id );

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

        if $db.select-user( :$id ) and $session.admin {

          $db.update-user-admin( :$id, :$admin );

          my %user = $db.select-user( :$id );

          content 'application/json', %user;

        } else {

          not-found 'application/json', %( :404code, message => "User ID ｢$id｣ not found!" );

        }
      }
    }

  }
}
