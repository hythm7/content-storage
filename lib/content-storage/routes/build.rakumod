use JSON::Fast;
use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage;
use content-storage-session;
use content-storage-database;
use content-storage-build;

sub build-routes( ContentStorage::Database:D :$db! ) is export {

  route {

    get -> ContentStorage::Session $session {

      my $user  =  $session.user;
      my $title = 'Builds';
      my $api   = '/api/v1/build';

      template 'builds.crotmp', { :$user , :$title, :$api };

    }

  }
}
