use Cro::HTTP::Auth;

class DistributionsStorage::Session does Cro::HTTP::Auth {

  has $.user;

  method set-logged-in-user($!user --> Nil) { }

  method is-admin(     --> Bool ) { $!user.is-admin }
  method is-logged-in( --> Bool ) { $!user.defined }

  method hash ( ) {

    %( id => $!user.id, username => $!user.username )
  }
}


subset Admin    of DistributionsStorage::Session is export where .is-admin;
subset LoggedIn of DistributionsStorage::Session is export where .is-logged-in;
