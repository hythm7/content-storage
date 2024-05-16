use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distribution-storage;
use distribution-storage-routes-user;
use distribution-storage-routes-distribution;
use distribution-storage-routes-build;

sub routes(DistributionStorage $ds) is export {
  template-location 'templates/';

  route {
    after { redirect '/user/login', :see-other if .status == 401 };

    include user => user-routes( $ds );

    include distribution-routes( $ds );

    include build-routes( $ds );

    get -> DistributionStorage::Session $session, 'server-sent-events' {
      content 'text/event-stream', $ds.build-supply;
    }

    get -> 'static', *@path {
      static 'static', @path
    } 
  }
}
