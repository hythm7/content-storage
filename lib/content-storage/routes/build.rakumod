use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage;
use content-storage-session;
use content-storage-database;
use content-storage-build;

sub build-routes( ContentStorage::Database:D :$db!, Supplier:D :$event-supplier! ) is export {

    route {

      get -> ContentStorage::Session $session {

        my $user =  $session.user;

        my @build = $db.select-build.map( -> %build { ContentStorage::Model::Build.new( |%build ) } );

        template 'builds.crotmp', { :$user, :@build };

      }

      get -> ContentStorage::Session $session, UUID:D $id {

        my %build = $db.select-build: :$id;

        content 'application/json', ContentStorage::Model::Build.new( |%build ).to-json;

      }

      post -> LoggedIn $session {

        my $user =  $session.user;

        request-body -> (:$file) {

          my $build = ContentStorage::Build.new: :$db, :$event-supplier, user => $user.id, :$file;

          start $build.build;

          my %data = %( id => $build.id.Str );

          content 'application/json', %data;

        }
      }
    }
}
