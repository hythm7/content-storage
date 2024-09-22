use content-storage;
use content-storage-model-user;
use content-storage-model-distribution;

use Badger <sql/badger-queries.sql>;


unit class ContentStorage::Database;

has $.pg;

method insert-user( Str:D :$username!,  Str:D :$password!, Str :$firstname!, Str :$lastname!, Str :$email!) {

  insert-into-user $!pg, :$username, :$password, :$firstname, :$lastname, :$email;

}

multi method select-user( UUID:D :$id! ) { select-user-by-id $!pg, :$id }


multi method select-user( --> Seq:D ) { select-user $!pg }

multi method select-user-username( UUID:D :$id! ) { select-user-username-by-id $!pg, :$id }

multi method select-user-id( Str:D :$username! ) { select-user-id-by-username $!pg, :$username }

multi method select-user-password( Str:D :$username! ) { select-user-password-by-username $!pg, :$username }

multi method update-user-info( UUID:D :$id!, Str:D :$firstname!, Str:D :$lastname!, Str:D :$email! ) {
  update-user-info-by-id $!pg, :$id, :$firstname, :$lastname, :$email;
}

multi method update-user-password( UUID:D :$id!, Str:D :$password! ) {
  update-user-password-by-id $!pg, :$id, :$password;
}

multi method update-user-password( Str:D :$username!, Str:D :$password! ) {
  update-user-password-by-username $!pg, :$username, :$password;
}

multi method update-user-admin( UUID:D :$id!, Bool:D :$admin! ) {
  update-user-admin-by-id $!pg, :$id, :$admin;
}

multi method select-user( Str:D :$name!, UInt :$offset!, UInt :$limit! ) {
  select-user-by-name $!pg, name => $name ~ '%', :$offset, :$limit
}
multi method select-user( UInt :$offset!, UInt :$limit! ) { select-user $!pg, :$offset, :$limit  }
multi method select-user( UUID:D :$id! ) { select-user-by-id $!pg, :$id }
multi method select-user( 'count', Str:D :$name! ) { select-user-by-name-count $!pg, name => $name ~ '%' }
multi method select-user( 'count' ) { select-user-count $!pg  }

multi method select-user( Str:D :$id!       ) { select-user-by-id       $!pg, :$id       }
multi method select-user( Str:D :$username! ) { select-user-by-username $!pg, :$username }

multi method delete-user( UUID:D :$id! ) { delete-user-by-id $!pg, :$id }


multi method select-distribution( Str:D :$identity! ) { select-distribution-by-identity $!pg, :$identity; }

multi method select-distribution( Str:D :$name!, UInt :$offset!, UInt :$limit! ) {
  select-distribution-by-name $!pg, name => $name ~ '%', :$offset, :$limit
}
multi method select-distribution( UInt :$offset!, UInt :$limit! ) { select-distribution $!pg, :$offset, :$limit  }
multi method select-distribution( UUID:D :$id! ) { select-distribution-by-id $!pg, :$id }
multi method select-distribution( 'count', Str:D :$name! ) { select-distribution-by-name-count $!pg, name => $name ~ '%' }
multi method select-distribution( 'count' ) { select-distribution-count $!pg  }

multi method select-distribution-meta( Str:D :$identity! ) { select-distribution-meta-by-identity $!pg, :$identity; }
multi method select-distribution-archive( Str:D :$identity! ) { select-distribution-archive-by-identity $!pg, :$identity; }

multi method select-user-distribution( UUID:D :$user!, Str:D :$name!, UInt :$offset!, UInt :$limit! ) {

  select-user-distribution-by-name $!pg, :$user, name => $name ~ '%', :$offset, :$limit;

}

multi method select-user-distribution( UUID:D :$user!, UInt :$offset!, UInt :$limit! ) {

  select-user-distribution $!pg, :$user, :$offset, :$limit;

}


multi method select-user-distribution( 'count', UUID:D :$user!, Str:D :$name! ) {

  select-user-distribution-by-name-count $!pg, :$user, name => $name ~ '%'; 

}

multi method select-user-distribution( 'count', UUID:D :$user! ) {

  select-user-distribution-count $!pg, :$user;
}

multi method delete-distribution( UUID:D :$id! ) { delete-distribution-by-id $!pg, :$id }

multi method select-user-build( UUID:D :$user!, Str:D :$name!, UInt :$offset!, UInt :$limit! ) {

  select-user-build-by-name $!pg, :$user, name => $name ~ '%', :$offset, :$limit;

}


multi method select-user-build( UUID:D :$user!, UInt :$offset!, UInt :$limit! ) {

  select-user-build $!pg, :$user, :$offset, :$limit;

}

multi method select-user-build( 'count', UUID:D :$user!, Str:D :$name! ) {

  select-user-build-by-name-count $!pg, :$user, name => $name ~ '%';
}

multi method select-user-build( 'count', UUID:D :$user! ) {

  select-user-build-count $!pg, :$user 
}



method insert-build( UUID:D :$user ) {

  my $build-id = insert-into-build $!pg, :$user;

}


multi method select-build( Str:D :$name!, UInt :$offset!, UInt :$limit! ) {
  select-build-by-name $!pg, name => $name ~ '%', :$offset, :$limit
}
multi method select-build( UInt :$offset!, UInt :$limit! ) { select-build $!pg, :$offset, :$limit  }
multi method select-build( UUID:D :$id! ) { select-build-by-id $!pg, :$id }
multi method select-build( 'count', Str:D :$name! ) { select-build-by-name-count $!pg, name => $name ~ '%' }
multi method select-build( 'count' ) { select-build-count $!pg  }

multi method select-build-running( 'count' ) { select-build-running-count $!pg  }

multi method delete-build( UUID:D :$id! ) { delete-build-by-id $!pg, :$id }

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

method insert-distribution(
  UUID:D   :$build!,
  UUID:D   :$user!,
  Str      :$identity!,
  Str      :$name!,
  Str      :$version!,
  Str      :$auth!,
  Any      :$api!,
  Str      :$meta!,
  Any      :$description!,
           :@provides!,
           :@tags!,
  Str      :$readme!,
  Str      :$changes!,
  Str      :$archive!,
  DateTime :$created!,
) {

  insert-into-distribution $!pg, :$user, :$name, :$version, :$auth, :$api, :$identity, :$meta, :$description, :$readme, :$changes, :@provides, :@tags, :$build, :$archive, :$created;

}
