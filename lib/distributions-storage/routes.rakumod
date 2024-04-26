use Cro::HTTP::Router;
use Cro::WebApp::Template;

use distributions-storage;
use distributions-storage-routes-user;
use distributions-storage-routes-distribution;

sub routes(DistributionsStorage $ds) is export {
  template-location 'templates/';

  route {
    after { redirect '/user/login', :see-other if .status == 401 };

    include user => user-routes( $ds );

    include distribution-routes( $ds );

    get -> 'css', 'main.css' {
      static 'static/main.css'
    }
    get -> 'js', 'main.js' {
      static 'static/main.js'
    }
  }
}
