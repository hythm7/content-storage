use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distribution-storage-session;
use distribution-storage-database;

sub distribution-routes( DistributionStorage::Database:D :$db! ) is export {

  route {

    get -> LoggedIn $session {

      my $user =  $session.user;
      my @dist = $db.select-distribution( user => $user.id ).map( -> $dist {
        #$dist<created> = Date.new($dist<created>).Str;
        $dist;
      });

      template 'distributions.crotmp', { :$user, :@dist };
    }
  }
}
