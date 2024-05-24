use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distribution-storage;
use distribution-storage-session;


sub build-routes( DistributionStorage $ds ) is export {

  route {

    include <build> => route {

      get -> DistributionStorage::Session $session {

        my $user =  $session.user;

        my @build = $ds.select-build( );

        template 'builds.crotmp', { :$user, :@build };
      }

      post -> LoggedIn $session {

        my $user =  $session.user.id;

        request-body -> (:$file-input) {

          my $file = $file-input[0];

          my %data = $ds.distribution-add( :$user, :$file );

          content 'application/json', %data;

        }
      }
    }
  }
}
