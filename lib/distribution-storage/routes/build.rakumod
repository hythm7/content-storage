use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distribution-storage-session;
use distribution-storage-database;

sub build-routes( DistributionStorage::Database:D :$db!, Supplier:D :$event-supplier! ) is export {

    route {

      get -> DistributionStorage::Session $session {

        my $user =  $session.user;

        my @build = $db.select-build( );

        template 'builds.crotmp', { :$user, :@build };
      }

      post -> LoggedIn $session {

        my $user =  $session.user;

        request-body -> (:$file-input) {

          #my $file = $file-input[0];

          #my %data = $db.distribution-add( :$user, :$file );

          #content 'application/json', %data;

        }
      }
    }
}
