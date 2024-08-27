use JSON::Class:auth<zef:vrurg>;
use Cro::HTTP::Auth;

use content-storage-model-user;

class ContentStorage::Session is json does Cro::HTTP::Auth {

  has ContentStorage::Model::User $.user;


  method set-logged-in-user($!user --> Nil) { }

  method admin(     --> Bool ) { $!user.admin }
  method logged-in( --> Bool ) { $!user.defined }

}


subset LoggedIn of ContentStorage::Session is export where .logged-in;
subset Admin    of LoggedIn                is export where .admin;
