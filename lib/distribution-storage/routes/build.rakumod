use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distribution-storage;
use distribution-storage-session;
use distribution-storage-database;
use distribution-storage-build;

sub build-routes( DistributionStorage::Database:D :$db!, Supplier:D :$event-supplier! ) is export {

    route {

      get -> DistributionStorage::Session $session {

        my $user =  $session.user;

        my @build = $db.select-build.map( -> %build { DistributionStorage::Model::Build.new( |%build ) } );

        template 'builds.crotmp', { :$user, :@build };

      }

      get -> DistributionStorage::Session $session, UUID:D $id {

        my %build = $db.select-build: :$id;

        content 'application/json', DistributionStorage::Model::Build.new( |%build ).to-json;

      }

      post -> LoggedIn $session {

        my $user =  $session.user;

        request-body -> (:$file) {

          my $build = DistributionStorage::Build.new: :$db, :$event-supplier, user => $user.id, :$file;

          start $build.build;

          my %data = %( id => $build.id.Str );

          content 'application/json', %data;

        }
      }
    }
}
