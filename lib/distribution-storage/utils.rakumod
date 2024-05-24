use EventSource::Server;
use Log::Dispatch::Source;
use Log::Dispatch::Destination;

unit module Distribution::Storage::Utils;

enum Target    <BUILD DISTRIBUTION>;
enum Operation <ADD UPDATE DELETE>;

enum Status  is export  (
  UNKNOWN   => '<i class="bi bi-exclamation-triangle text-warning"></i>',
  ERROR     => '<i class="bi bi-x text-danger"></i>',
  SUCCESS   => '<i class="bi bi-check text-success"></i>',
  RUNNING   => '<div class="spinner-grow spinner-grow-sm text-primary" role="status"><span class="visually-hidden">Loading...</span></div>',
);

class BuildLogSource does Log::Dispatch::Source is export {
  has Str:D $.log-source-name is required;

  method log-source-name { $!log-source-name }
}

class ServerSentEventsDestination does Log::Dispatch::Destination is export {

  has Str      $!type           is built;
  has Supplier $!event-supplier is built is required;

  method report( Log::Dispatch::Msg:D $message ) {

    my $event = EventSource::Server::Event.new( :$!type, data => $message.msg );

    $!event-supplier.emit( $event );

  }

}
