use JSON::Fast;
use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::WebApp::Template;

use content-storage;
use content-storage-session;
use content-storage-database;
use content-storage-build;

sub build-routes( Cro::HTTP::Client:D :$api!, ContentStorage::Database:D :$db!, Supplier:D :$event-supplier! ) is export {

  route {

    get -> ContentStorage::Session $session {

      my $user =  $session.user;

      template 'builds.crotmp', { :$user };

    }

    get -> ContentStorage::Session $session, UUID:D $id {

      my %build = $db.select-build: :$id;

      content 'application/json', ContentStorage::Model::Build.new( |%build ).to-json;

    }

    post -> LoggedIn $session {

      my $user =  $session.user;

      request-body -> ( :$file ) {

        my $build = ContentStorage::Build.new: :$db, :$event-supplier, user => $user.id, archive => $file.body-blob;

        start $build.build;

        my %data = %( id => $build.id.Str );

        content 'application/json', %data;

      }
    }
  }
}
