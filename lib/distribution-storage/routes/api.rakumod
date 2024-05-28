use Crypt::Argon2;
use Cro::WebApp::Template;
use Cro::HTTP::Router;
use Cro::OpenAPI::RoutesFromDefinition;

use distribution-storage;
use distribution-storage-session;
use distribution-storage-database;

sub api-routes( DistributionStorage::Database:D :$db!, Supplier:D :$event-supplier! ) is export {

  openapi 'openapi.json'.IO, :ignore-unimplemented, :!validate-responses, {

    operation 'readBuild', -> DistributionStorage::Session $session {

      my @build = $db.select-build;

      content 'application/json', @build ;
    }

    operation 'readBuildById', -> DistributionStorage::Session $session, Int $id  {

      my %build = $db.select-build: :$id;

      content 'application/json', %build;

    }

    operation 'readBuildLogById', -> DistributionStorage::Session $session, Int $id  {

      my %build = $db.select-build-log: :$id;

      content 'application/json', %build;

    }



    operation 'buildUploadDistribution', -> LoggedIn $session {

      my $user =  $session.user;

      request-body -> (:$file) {

        #my @data = $file.map( -> $archive { $db.distribution-add( :$user, :$archive ) } );

        #content 'application/json', @data;

      }
    }


    operation 'userLogout', -> DistributionStorage::Session $session {
      $session.set-logged-in-user( Nil );
    }

    operation 'userLogin', -> DistributionStorage::Session $session {

      request-body -> (:$username!, :$password!, *%) {
        
        my $user = $db.select-user-password( :$username );

        with $user {
          if (argon2-verify(.<password>, $password)) {
            $user = $db.select-user( :$username );
            $session.set-logged-in-user( $user );
            content 'application/json', $user.to-json;
          } else {
            bad-request 'application/json', { error => 'Incorrect password.' };
          }
        } else {
            bad-request 'application/json', { error => 'Incorrect username.' };
        }
      }
    }

    operation 'userCreate', -> DistributionStorage::Session $session {

      request-body -> (:$username!, :$password!, *%) {
        
        if $db.select-user( :$username ) {
          content 'application/json', { error => "User $username is already registered" };
        } else {
          $db.insert-user(:$username, :password(argon2-hash($password)));
          content 'application/json', { };
        }
      }
    }

    operation 'userLogout', -> DistributionStorage::Session $session {

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
