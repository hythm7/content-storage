use JSON::Class:auth<zef:vrurg>;
use Cro::HTTP::Auth;

use distribution-storage-model-user;

class DistributionStorage::Session is json does Cro::HTTP::Auth {

  has DistributionStorage::Model::User $.user;


  method set-logged-in-user($!user --> Nil) { }

  method is-admin(     --> Bool ) { $!user.is-admin }
  method is-logged-in( --> Bool ) { $!user.defined }

}


subset Admin    of DistributionStorage::Session is export where .is-admin;
subset LoggedIn of DistributionStorage::Session is export where .is-logged-in;
