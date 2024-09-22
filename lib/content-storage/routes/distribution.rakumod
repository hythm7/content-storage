use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage-session;
use content-storage-database;

sub distribution-routes( ) is export {

  route {

    get -> ContentStorage::Session $session {

      my $user  =  $session.user;
      my $title = 'Distributions';
      my $api   = '/api/v1/distribution';


      template 'distributions.crotmp', { :$user , :$title, :$api };
    }
  }
}
