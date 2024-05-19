use Crypt::Argon2;
use Cro::WebApp::Template;
use Cro::HTTP::Router;
use Cro::OpenAPI::RoutesFromDefinition;

use distribution-storage;
use distribution-storage-session;

sub api-routes(DistributionStorage $ds) is export {

  openapi 'openapi.json'.IO, :ignore-unimplemented, :!validate-responses, {

    #operation 'userRead', -> Admin $session {
    operation 'userRead', -> LoggedIn $session {

      my @user = $ds.select-user;

      content 'application/json', @user ;
    }

    operation 'logout', -> DistributionStorage::Session $session {
      $session.set-logged-in-user( Nil );
    }

    operation 'login', -> DistributionStorage::Session $session {

      request-body -> (:$username!, :$password!, *%) {
        
        my $user = $ds.select-user-password( :$username );

        with $user {
          if (argon2-verify(.<password>, $password)) {
            $user = $ds.select-user( :$username );
            $session.set-logged-in-user( $user );
            say $user;
            content 'application/json', $user.to-json;
          } else {
            content 'application/json', { error => 'Incorrect password.' };
          }
        } else {
            content 'application/json', { error => 'Incorrect username.' };
        }
      }
    }

    operation 'register', -> DistributionStorage::Session $session {

      request-body -> (:$username!, :$password!, *%) {
        
        if $ds.select-user( :$username ) {
          content 'application/json', { error => "User $username is already registered" };
        } else {
          $ds.insert-user(:$username, :password(argon2-hash($password)));
          content 'application/json', { };
        }
      }
    }


  }
}
