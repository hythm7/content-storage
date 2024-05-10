use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distributions-storage;
use distributions-storage-session;


sub build-routes(DistributionsStorage $ds) is export {

  route {

    include <build> => route {

      get -> DistributionsStorage::Session $session {

        my $user =  $session.user;

        my @builds = $ds.get-builds( );

        template 'build.crotmp', { :$user, :@builds };
      }

      #sub validate( $archive) { say $archive.archive ~ ' validated!' }

      sub start-build( $archive) { sleep 4 }

      post -> LoggedIn $session {

        my $user =  $session.user;

        request-body -> (:$file-input) {

          my @data = $file-input.map( -> $archive { $ds.add-distribution( :$user, :$archive ) } );

          content 'application/json', @data;

        }
      }
    }
  }
}
