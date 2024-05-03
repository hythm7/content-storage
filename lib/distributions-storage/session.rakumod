use JSON::Class:auth<zef:vrurg>;

use Cro::HTTP::Auth;

use distributions-storage-model-user;

class DistributionsStorage::Session is json does Cro::HTTP::Auth {

  has DistributionsStorage::Model::User $.user;


  method set-logged-in-user($!user --> Nil) { }

  method is-admin(     --> Bool ) { $!user.is-admin }
  method is-logged-in( --> Bool ) { $!user.defined }

}


subset Admin    of DistributionsStorage::Session is export where .is-admin;
subset LoggedIn of DistributionsStorage::Session is export where .is-logged-in;
