use EventSource::Server;

use Cro::HTTP::Router;
use Cro::WebApp::Template;
use Cro::WebApp::Form;

use distribution-storage;
use distribution-storage-routes-user;
use distribution-storage-session;

sub distribution-routes( DistributionStorage $ds ) is export {

  route {

    get -> DistributionStorage::Session $session {

      my $user =  $session.user;
      my @dist = $ds.select-distribution.map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });
      template 'index.crotmp', { :$user, :@dist };
    }

    get -> LoggedIn $session, 'distribution' {

      
      my $user =  $session.user;
      my @dist = $ds.select-distribution-by-userid( userid => $user.id ).map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });

      template 'distributions.crotmp', { :$user, :@dist };
    }
  }
}
