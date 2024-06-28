use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage-session;
use content-storage-database;

sub distribution-routes( ContentStorage::Database:D :$db! ) is export {

  route {

    get -> LoggedIn $session {

      my $user =  $session.user;

      template 'distributions.crotmp', { :$user };
    }
  }
}
