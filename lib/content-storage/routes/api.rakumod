use Crypt::Argon2;
use Cro::WebApp::Template;
use Cro::HTTP::Router;
use Cro::OpenAPI::RoutesFromDefinition;

use content-storage;
use content-storage-session;
use content-storage-database;
use content-storage-build;
use content-storage-model-build;

sub api-routes( IO::Path:D :$openapi-schema!, ContentStorage::Database:D :$db!, Supplier:D :$event-supplier! ) is export {

  openapi $openapi-schema, :ignore-unimplemented, :!validate-responses, {

    operation 'readBuild', -> ContentStorage::Session $session {

      my @build = $db.select-build;

      content 'application/json', @build;
    }

    operation 'readBuildById', -> ContentStorage::Session $session, UUID:D $id  {

      my %build = $db.select-build: :$id;

      content 'application/json', %build;

    }

    operation 'readBuildLogById', -> ContentStorage::Session $session, UUID:D $id  {

      my %build =  $db.select-build-log: :$id;

      if %build {
        content 'application/json', %build;
      } else {
        not-found 'application/json', %build;
      }

    }



    operation 'buildDistribution', -> LoggedIn $session {

      my $user =  $session.user;

      request-body -> (:$file) {

        my $build = ContentStorage::Build.new: :$db, :$event-supplier, user => $user.id, :$file;

        start $build.build;

        my %data = %( id => $build.id );

        content 'application/json', %data;

      }
    }


    operation 'userLogout', -> ContentStorage::Session $session {
      $session.set-logged-in-user( Nil );
    }

    operation 'userLogin', -> ContentStorage::Session $session {

      request-body -> ( :$username!, :$password! ) {
        
        my %password = $db.select-user-password( :$username );

        if  %password {

          if ( argon2-verify( %password<password>, $password ) ) {

            my %user = $db.select-user( :$username );

            my $user = ContentStorage::Model::User.new: |%user;

            $session.set-logged-in-user( $user );

            content 'application/json', %user;

          } else {
            bad-request 'application/json', { error => 'Incorrect password.' };
          }
        } else {
            bad-request 'application/json', { error => 'Incorrect username or password.' };
        }
      }
    }

    operation 'userCreate', -> ContentStorage::Session $session {

      request-body -> ( :$username!, :$password! ) {
        
        if $db.select-user( :$username ) {

          content 'application/json', { error => "User $username is already registered" };

        } else {

          $db.insert-user( :$username, password => argon2-hash( $password ) );

          content 'application/json', {};

        }
      }
    }

    operation 'userLogout', -> ContentStorage::Session $session {

      $session.set-logged-in-user( Nil );
      content 'application/json', { description => "successful operation" };

    }

    #operation 'userRead', -> Admin $session {
    operation 'userRead', -> LoggedIn $session {

      my @user = $db.select-user;

      content 'application/json', @user ;
    }


  }
}
