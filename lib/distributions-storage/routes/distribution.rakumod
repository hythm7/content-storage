use EventSource::Server;

use Cro::HTTP::Router;
use Cro::WebApp::Template;
use Cro::WebApp::Form;

use distributions-storage;
use distributions-storage-routes-user;
use distributions-storage-session;

class DistributionUploadForm does Cro::WebApp::Form {
  has $.distributions-archive-files is file is required;
}


sub distribution-routes(DistributionsStorage $ds) is export {
  route {
    get -> DistributionsStorage::Session $session {

      my $user =  $session.user;
      my @dists = $ds.get-dists.map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });
      template 'index.crotmp', { :$user, :@dists };
    }

    get -> LoggedIn $session, 'my-distributions' {

      
      my $user =  $session.user;
      my @dists = $ds.get-user-dists( userid => $user.id ).map( -> $dist {
        $dist<created> = Date.new($dist<created>).Str;
        $dist;
      });
      template 'my-distributions.crotmp', { :$user, :@dists };
    }


    include <distribution> => route {

      get -> LoggedIn $session, 'add' {
        my $user =  $session.user;

        my @builds = $ds.get-builds( );

        template 'distribution-add.crotmp', { :$user, :@builds };
      }

      sub validate( $archive) { say $archive.filename ~ ' validated!' }

      sub start-build( $archive) { sleep 4 }

      post -> LoggedIn $session, 'add' {
        form-data -> DistributionUploadForm $form {

          my @files = $form.distributions-archive-files;

          #content 'application/json', '[' ~ @files.map({ .body-text }).join(',') ~ ']';

          @files.map( -> $file { $ds.add-distribution( :$file ) } );


          #content 'application/json', @json;

          

          #@files.map( -> $file {
          #  my $content  =  $file.body-text;

          #  $ds.add-distribution( :$content, user => $session.user.id);

          #} );

          

          #redirect :see-other, '/distribution/add';
          redirect :see-other, '/';

        }
      }

      get -> DistributionsStorage::Session $session, 'build' {
        content 'text/event-stream', $ds.build-supply;
      }

      post -> LoggedIn $session, 'delete', $identity {
        # TODO Check user permission
        $ds.delete-dist(:$identity);
        redirect :see-other, '/';
      }


      sub process-dist($session, $id, &process) {
        with $ds.get-dist($id) -> $dist {
          if $dist<user> == $session.user.id {
            &process($dist);
          } else {
            forbidden;
          }
        } else {
          not-found;
        }
      }

      get -> LoggedIn $session, UInt $id, 'update' {
        process-dist($session, $id, -> $dist { template 'update.crotmp', $dist });
      }

      post -> LoggedIn $session, UInt $id, 'update' {
        process-dist($session, $id, -> $ {
          request-body -> (:$name!, :$dist!) {
            $ds.update-dist($id, $name, $dist);
            redirect :see-other, '/';
          }
        });
      }

      post -> LoggedIn $session, UInt $id, 'delete' {
        process-dist($session, $id, -> $ {
          $ds.delete-dist($id);
          redirect :see-other, '/';
        });
      }
    }
  }
}
