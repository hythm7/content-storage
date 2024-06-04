use JSON::Fast;

use distribution-storage;
use distribution-storage-model-user;
use distribution-storage-model-distribution;

use Badger <sql/badger-queries.sql>;


unit class DistributionStorage::Database;

has $.pg;

method insert-user( Str:D :$username!,  Str:D :$password! ) {

  insert-user $!pg, :$username, :$password;

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

method insert-build( UUID:D :$user, Str:D :$filename! ) {

  my $build-id = insert-build $!pg, :$user, :$filename;

}


multi method select-build( )              { select-build $!pg             }
multi method select-build( UUID:D :$id! ) { select-build-by-id $!pg, :$id }

method update-build-status( UUID:D :$id!, Str:D :$status! ) {
  update-build-status $!pg, :$id, :$status;
}

method update-build-meta ( UUID:D :$id!, Str:D :$meta! ) { update-build-meta    $!pg, :$id, :$meta }

method update-build-name    ( UUID:D :$id!, Str:D :$name!    ) { update-build-name    $!pg, :$id, :$name    }
method update-build-version ( UUID:D :$id!, Str:D :$version! ) { update-build-version $!pg, :$id, :$version }
method update-build-auth    ( UUID:D :$id!, Str:D :$auth!    ) { update-build-auth    $!pg, :$id, :$auth    }
method update-build-api     ( UUID:D :$id!, Str:D :$api!     ) { update-build-api     $!pg, :$id, :$api     }

method update-build-identity ( UUID:D :$id!, Str:D :$identity! ) { update-build-identity $!pg, :$id, :$identity }


method update-build-test ( UUID:D :$id!, Str:D :$test! ) { update-build-test  $!pg, :$id, :$test  }

method update-build-started(   UUID:D :$id! ) { update-build-started $!pg,   :$id }
method update-build-completed( UUID:D :$id! ) { update-build-completed $!pg, :$id }

method update-build-log ( UUID:D :$id!, Str:D :$log! ) { update-build-log $!pg, :$id, :$log }

method select-build-started(   UUID:D :$id! ) { select-build-started $!pg,   :$id }
method select-build-completed( UUID:D :$id! ) { select-build-completed $!pg, :$id }

method select-build-log( UUID:D :$id! ) { select-build-log-by-id $!pg, :$id }

method insert-distribution( UUID:D :$user!, UUID:D :$build!, Str:D :$meta! ) {

  my $db = $!pg.db;

  my %meta = from-json $meta;

  my Str:D $name    = %meta<name>;
  my Str:D $version = %meta<version>;
  my Str:D $auth    = %meta<auth>;
  my Any   $api     = %meta<api>;

  my $identity = identity :$name, :$version, :$auth, :$api;

  my $dependencies = %meta<depends>;

  my @provides  = |%meta<provides>;
  my @emulates  = |%meta<emulates>;
  my @resources = |%meta<resources>;
  
  $db.begin;
  
  my $distribution = $db.query(q:to/END/, $user, $name, $version, $auth, $api, $identity, $meta, $build ).value;
    INSERT INTO distribution
           ( "user", "name", "version", "auth", "api", "identity", "meta", "build" )
    values ( $1,     $2,     $3,        $4,     $5,    $6,         $7,     $8      )
    RETURNING "id"
    END

  if @provides {
    my $sth = $db.prepare('insert into provides (distribution, use, file ) values ($1,$2, $3)');
    @provides.map({ $sth.execute($distribution, .key, .value) });
  }

  $db.commit;

  $db.finish;

}
