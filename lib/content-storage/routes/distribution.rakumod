use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage-config;
use content-storage-session;
use content-storage-database;

sub distribution-routes( ) is export {

  my Str:D $api-version = Version.new( config.get( 'api.version' ) ).raku;

  route {

    get -> ContentStorage::Session $session {

      my $user  =  $session.user;
      my $title = 'Distributions';
      my $api   = "/api/$api-version/distributions";


      template 'distributions.crotmp', { :$user , :$title, :$api };
    }
  }
}
