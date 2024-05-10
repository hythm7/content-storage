use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distributions-storage;
use distributions-storage-routes-user;
use distributions-storage-routes-distribution;
use distributions-storage-routes-build;

sub routes(DistributionsStorage $ds) is export {
  template-location 'templates/';

  route {
    after { redirect '/user/login', :see-other if .status == 401 };

    include user => user-routes( $ds );

    include distribution-routes( $ds );

    include build-routes( $ds );

    get -> DistributionsStorage::Session $session, 'server-sent-events' {
      content 'text/event-stream', $ds.build-supply;
    }

    get -> 'static', *@path {
      static 'static', @path
    } 
  }
}
