use Crypt::Argon2;
use Cro::WebApp::Template;
use Cro::HTTP::Router;

use distribution-storage;
use distribution-storage-session;
use distribution-storage-database;


sub user-routes( DistributionStorage::Database:D :$db! ) is export {

  route {

    get -> DistributionStorage::Session $session, 'register' {
      template 'register.crotmp', { :logged-in($session.user.defined), :!error };
    }

    post -> DistributionStorage::Session $session, 'register' {

      request-body -> (:$username!, :$password!, *%) {
        
        if $db.select-user( :$username ) {
          template 'register.crotmp', { error => "User $username is already registered" };
        } else {
          $db.insert-user(:$username, :password( argon2-hash( $password ) ) );
          redirect :see-other, '/user/login';
        }
      }
    }

    get -> DistributionStorage::Session $session, 'login' {
      template 'login.crotmp', { :logged-in( $session.user.defined ), :!error };
    }

    post -> DistributionStorage::Session $session, 'login' {
      request-body -> ( :$username!, :$password!, *% ) {
        
        my $user = $db.select-user-password( :$username );

        with $user {
          if (argon2-verify( .<password>, $password ) ) {
            $session.set-logged-in-user( $db.select-user( :$username ) );
            redirect :see-other, '/';
          } else {
            template 'login.crotmp', { :!logged-in, error => 'Incorrect password.' };
          }
        } else {
          template 'login.crotmp', { :!logged-in, error => 'Incorrect username.' };
        }
      }
    }

    get -> DistributionStorage::Session $session, 'logout' {
      $session.set-logged-in-user( Nil );
      redirect :see-other, '/';
    }
  }
}
