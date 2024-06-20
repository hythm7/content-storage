use JSON::Fast;

use content-storage;
use content-storage-model-user;
use content-storage-model-distribution;

use Badger <sql/badger-queries.sql>;


unit class ContentStorage::Database;

has $.pg;

method insert-user( Str:D :$username!,  Str:D :$password! ) {

  insert-into-user $!pg, :$username, :$password;

}

multi method select-user( UUID:D :$id! ) { select-user-by-id $!pg, :$id }

multi method select-user( Str:D :$username! ) { select-user-by-username $!pg, :$username }

multi method select-user( --> Seq:D ) { select-user $!pg }

multi method select-user-username( UUID:D :$id! ) { select-user-username-by-id $!pg, :$id }

multi method select-user-password( Str:D :$username! ) { select-user-password-by-username $!pg, :$username }


multi method select-distribution ( ) { select-distribution( $!pg ) }

multi method select-distribution ( UUID:D :$id!   ) { select-distribution-by-id   $!pg, :$id   }
multi method select-distribution ( UUID:D :$user! ) { select-distribution-by-user $!pg, :$user }

method delete-dist(:$identity!) { delete-dist $!pg, :$identity }

method insert-build( UUID:D :$user ) {

  my $build-id = insert-into-build $!pg, :$user;

}


multi method select-build( Int:D :$offset!, Int:D :$limit! ) { select-build $!pg, :$offset, :$limit  }
multi method select-build( UUID:D :$id! ) { select-build-by-id $!pg, :$id }

method select-build-count( ) { select-build-count $!pg }

method update-build-status( UUID:D :$id!, Int:D :$status! ) {
  update-build-status $!pg, :$id, :$status;
}

method update-build-meta ( UUID:D :$id!, Int:D :$meta! ) { update-build-meta    $!pg, :$id, :$meta }

method update-build-name    ( UUID:D :$id!, Str:D :$name!    ) { update-build-name    $!pg, :$id, :$name    }
method update-build-version ( UUID:D :$id!, Str:D :$version! ) { update-build-version $!pg, :$id, :$version }
method update-build-auth    ( UUID:D :$id!, Str:D :$auth!    ) { update-build-auth    $!pg, :$id, :$auth    }
method update-build-api     ( UUID:D :$id!, Str:D :$api!     ) { update-build-api     $!pg, :$id, :$api     }

method update-build-identity ( UUID:D :$id!, Str:D :$identity! ) { update-build-identity $!pg, :$id, :$identity }


method update-build-test ( UUID:D :$id!, Int:D :$test! ) { update-build-test  $!pg, :$id, :$test  }

method update-build-started(   UUID:D :$id! ) { update-build-started $!pg,   :$id }
method update-build-completed( UUID:D :$id! ) { update-build-completed $!pg, :$id }

method update-build-log ( UUID:D :$id!, Str:D :$log! ) { update-build-log $!pg, :$id, :$log }

method select-build-started(   UUID:D :$id! ) { select-build-started $!pg,   :$id }
method select-build-completed( UUID:D :$id! ) { select-build-completed $!pg, :$id }

method select-build-log( UUID:D :$id! ) { select-build-log-by-id $!pg, :$id }

multi method search-build( Str:D :$name!, Int:D :$offset!, Int:D :$limit! ) {
  search-build $!pg, :$name, :$offset, :$limit 
}

method insert-distribution( UUID:D :$user!, UUID:D :$build!, Str:D :$meta! ) {

  my %meta = from-json $meta;

  my Str:D $name    = %meta<name>;
  my Str:D $version = %meta<version>;
  my Str:D $auth    = %meta<auth>;
  my Any   $api     = %meta<api>;

  my Any   $description = %meta<description>;

  my $identity = identity :$name, :$version, :$auth, :$api;

  my $dependencies = %meta<depends>;

  my @provides = |%meta<provides>.map( *.key ) if %meta<provides>;
  my @tags     = |%meta<tags>                  if %meta<tags>;
  
  insert-into-distribution $!pg, :$user, :$name, :$version, :$auth, :$api, :$identity, :$meta, :$description, :@provides, :@tags, :$build;

}
