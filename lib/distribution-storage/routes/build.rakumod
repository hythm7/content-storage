use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distribution-storage;
use distribution-storage-session;


sub build-routes( DistributionStorage $ds ) is export {

  route {

    include <build> => route {

      get -> DistributionStorage::Session $session {

        my $user =  $session.user;

        my @build = $ds.get-builds( );

        template 'builds.crotmp', { :$user, :@build };
      }

      post -> LoggedIn $session {

        my $user =  $session.user;

        request-body -> (:$file-input) {

          my @data = $file-input.map( -> $archive { $ds.distribution-add( :$user, :$archive ) } );

          content 'application/json', @data;

        }
      }
    }
  }
}
