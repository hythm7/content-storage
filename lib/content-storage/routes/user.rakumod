use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage-session;
use content-storage-database;

sub user-routes( ContentStorage::Database:D :$db! ) is export {

  route {

    get -> ContentStorage::Session $session, $username, 'distribution' {

      my $user =  $session.user;

      template 'distributions.crotmp', { :$user };
    }
  }
}
