use Crypt::Argon2;
use Cro::WebApp::Template;
use Cro::HTTP::Router;

use distributions-storage;
use distributions-storage-session;

sub user-routes(DistributionsStorage $ds) is export {
  route {
    get -> DistributionsStorage::Session $session, 'register' {
      template 'register.crotmp', { :logged-in($session.user.defined), :!error };
    }

    post -> DistributionsStorage::Session $session, 'register' {
      request-body -> (:$username!, :$password!, *%) {
        with $ds.get-user( :$username ) {
          template 'register.crotmp', { error => "User $username is already registered" };
        } else {
          $ds.add-user(:$username, :password(argon2-hash($password)));
          redirect :see-other, '/user/login';
        }
      }
    }

    get -> DistributionsStorage::Session $session, 'login' {
      template 'login.crotmp', { :logged-in($session.user.defined), :!error };
    }

    post -> DistributionsStorage::Session $session, 'login' {
      request-body -> (:$username!, :$password!, *%) {
        my $user = $ds.get-user( :$username );
        with $user {
          if (argon2-verify(.password, $password)) {
            $session.set-logged-in-user( .id );
            redirect :see-other, '/';
          } else {
            template 'login.crotmp', { :!logged-in, error => 'Incorrect password.' };
          }
        } else {
          template 'login.crotmp', { :!logged-in, error => 'Incorrect username.' };
        }
      }
    }

    get -> DistributionsStorage::Session $session, 'logout' {
      $session.set-logged-in-user( Nil );
      redirect :see-other, '/';
    }
  }
}
