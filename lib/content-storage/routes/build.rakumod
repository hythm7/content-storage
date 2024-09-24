use JSON::Fast;
use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage-config;
use content-storage-session;
use content-storage-database;
use content-storage-build;

sub build-routes( ) is export {

  my Str:D $api-version = Version.new( config.get( 'api.version' ) ).raku;

  route {

    get -> ContentStorage::Session $session {

      my $user  =  $session.user;
      my $title = 'Builds';
      my $api   = "/api/$api-version/builds";

      template 'builds.crotmp', { :$user , :$title, :$api };

    }

  }
}
