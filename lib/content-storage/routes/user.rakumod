use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage;
use content-storage-config;
use content-storage-session;
use content-storage-database;

sub user-routes( ContentStorage::Database:D :$db! ) is export {

  my Str:D $api-version = Version.new( config.get( 'api.version' ) ).raku;

  route {

    get -> Admin $session {

      my $user  =  $session.user;
      my $title = 'Users';
      my $api   = "/api/$api-version/user";


      template 'users.crotmp', { :$user , :$title, :$api };
    }

    get -> ContentStorage::Session $session, Str:D $id, 'distribution' {

      my UUID $userid;
      my Str  $username;

      if $id ~~ UUID {

        $userid   = $id;
        $username = $db.select-user-username: :$id;

      } else {

        $userid   = $db.select-user-id: username => $id;
        $username = $id;
      }

      my $user  =  $session.user;
      my $title = "$username Distributions";
      my $api   = "/api/$api-version/user/" ~ $userid ~ '/distribution';

      template 'distributions.crotmp', { :$user , :$title, :$api };

    }

    get -> ContentStorage::Session $session, Str:D $id, 'build' {

      my UUID $userid;
      my Str  $username;

      if $id ~~ UUID {

        $userid   = $id;
        $username = $db.select-user-username: :$id;

      } else {

        $userid   = $db.select-user-id: username => $id;
        $username = $id;
      }


      my $user  =  $session.user;
      my $title = "$username Builds";
      my $api   = "/api/$api-version/user/" ~ $userid ~ '/build';

      template 'builds.crotmp', { :$user , :$title, :$api };

    }
    
  }
}
