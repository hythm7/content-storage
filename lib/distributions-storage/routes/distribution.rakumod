use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distributions-storage;
use distributions-storage-routes-user;
use distributions-storage-session;

sub distribution-routes(DistributionsStorage $ds) is export {
  route {
    get -> DistributionsStorage::Session $session {

      my $user =  $session.user;
      my @dists = $ds.get-dists.map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });
      template 'index.crotmp', { :$user, :@dists };
    }

    get -> LoggedIn $session, 'my' {

      
      my $user =  $session.user;
      my @dists = $ds.get-user-dists( userid => $user.id ).map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });
      template 'index.crotmp', { :$user, :@dists };
    }

    include <distribution> => route {
      get -> LoggedIn $session, 'add' {
        my $user =  $session.user;
        template 'add-distribution.crotmp', { :$user };
      }

      post -> LoggedIn $session, 'add' {
        request-body -> (:$name!, :$dist!, *%) {
          $ds.add-dist(:$name, :$dist, user => $session.user.id);
          redirect :see-other, '/';
        }
      }

      post -> LoggedIn $session, 'delete', $identity {
        # TODO Check user permission
        $ds.delete-dist(:$identity);
        redirect :see-other, '/';
      }


      sub process-dist($session, $id, &process) {
        with $ds.get-dist($id) -> $dist {
          if $dist<user> == $session.user.id {
            &process($dist);
          } else {
            forbidden;
          }
        } else {
          not-found;
        }
      }

      get -> LoggedIn $session, UInt $id, 'update' {
        process-dist($session, $id, -> $dist { template 'update.crotmp', $dist });
      }

      post -> LoggedIn $session, UInt $id, 'update' {
        process-dist($session, $id, -> $ {
          request-body -> (:$name!, :$dist!) {
            $ds.update-dist($id, $name, $dist);
            redirect :see-other, '/';
          }
        });
      }

      post -> LoggedIn $session, UInt $id, 'delete' {
        process-dist($session, $id, -> $ {
          $ds.delete-dist($id);
          redirect :see-other, '/';
        });
      }
    }
  }
}
