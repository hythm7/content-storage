use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage-session;
use content-storage-database;

sub user-routes( ContentStorage::Database:D :$db! ) is export {

  route {

    get -> Admin $session {

      my $user  =  $session.user;
      my $title = 'Users';
      my $api   = '/api/v1/user';


      template 'users.crotmp', { :$user , :$title, :$api };
    }

    get -> ContentStorage::Session $session, $username, 'distribution' {

      my $user  =  $session.user;
      my $title = "$username Distributions";
      my $api   = '/api/v1/user/' ~ $username ~ '/distribution';

      template 'distributions.crotmp', { :$user , :$title, :$api };

    }

    get -> ContentStorage::Session $session, $username, 'build' {

      my $user  =  $session.user;
      my $title = "$username Builds";
      my $api   = '/api/v1/user/' ~ $username ~ '/build';

      template 'builds.crotmp', { :$user , :$title, :$api };

    }
    
  }
}
