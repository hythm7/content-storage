use EventSource::Server;

use Cro::HTTP::Router;
use Cro::WebApp::Template;
use Cro::WebApp::Form;

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

    get -> LoggedIn $session, 'my-distributions' {

      
      my $user =  $session.user;
      my @dists = $ds.get-user-dists( userid => $user.id ).map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });

      template 'my-distributions.crotmp', { :$user, :@dists };
    }
  }
}
