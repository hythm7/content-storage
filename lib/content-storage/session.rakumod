use JSON::Class:auth<zef:vrurg>;
use Cro::HTTP::Auth;

use content-storage-model-user;

class ContentStorage::Session is json does Cro::HTTP::Auth {

  has ContentStorage::Model::User $.user;


  method set-logged-in-user($!user --> Nil) { }

  method is-admin(     --> Bool ) { $!user.is-admin }
  method is-logged-in( --> Bool ) { $!user.defined }

}


subset Admin    of ContentStorage::Session is export where .is-admin;
subset LoggedIn of ContentStorage::Session is export where .is-logged-in;
