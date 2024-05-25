use distribution-storage-model-user;
use distribution-storage-model-distribution;

use Badger <sql/badger-queries.sql>;


unit class DistributionStorage::Database;

has $.pg;

method insert-user( Str:D :$username!,  Str:D :$password! ) {

  insert-user $!pg, :$username, :$password;

}

multi method select-user( Int:D :$id! ) {
  my DistributionStorage::Model::User $user = select-user-by-id $!pg, :$id;
}

multi method select-user( Str:D :$username! ) {
  my DistributionStorage::Model::User $user = select-user-by-username $!pg, :$username;
}

multi method select-user( --> Seq:D ) {
  select-user $!pg;
}

multi method select-user-username( Int:D :$id! ) {
  select-user-username-by-id $!pg, :$id;
}

multi method select-user-password( Str:D :$username! ) {
  select-user-password-by-username $!pg, :$username;
}

method add-distribution( Str:D :$content!, :$user! ) {

  my $meta = $content;

  distribution-add( db =>$!pg.db, :$meta, userid => $user )

}


multi method select-distribution ( ) { select-distribution( $!pg ) }

multi method select-distribution ( Int:D :$id!     ) { select-distribution-by-id     $!pg, :$id     }
multi method select-distribution ( Int:D :$userid! ) { select-distribution-by-userid $!pg, :$userid }

method delete-dist(:$identity!) { delete-dist $!pg, :$identity }

method insert-build( Int:D :$user, Str:D :$filename! ) {

  my $build-id = insert-build $!pg, :$user, :$filename;

}


method select-build( )                   { select-build $!pg             }
method select-build-by-id( Int:D :$id! ) { select-build-by-id $!pg, :$id }

method update-build-status( Int:D :$id!, Str:D :$status! ) {
  update-build-status $!pg, :$id, :$status;
}

method update-build-meta ( Int:D :$id!, Str:D :$meta! ) { update-build-meta    $!pg, :$id, :$meta }

method update-build-name    ( Int:D :$id!, Str:D :$name!    ) { update-build-name    $!pg, :$id, :$name    }
method update-build-version ( Int:D :$id!, Str:D :$version! ) { update-build-version $!pg, :$id, :$version }
method update-build-auth    ( Int:D :$id!, Str:D :$auth!    ) { update-build-auth    $!pg, :$id, :$auth    }
method update-build-api     ( Int:D :$id!, Str:D :$api!     ) { update-build-api     $!pg, :$id, :$api     }

method update-build-identity ( Int:D :$id!, Str:D :$identity! ) { update-build-identity $!pg, :$id, :$identity }


method update-build-test ( Int:D :$id!, Str:D :$test! ) { update-build-test  $!pg, :$id, :$test  }

method update-build-started(   Int:D :$id! ) { update-build-started $!pg,   :$id }
method update-build-completed( Int:D :$id! ) { update-build-completed $!pg, :$id }


method select-build-started(   Int:D :$id! ) { select-build-started $!pg,   :$id }
method select-build-completed( Int:D :$id! ) { select-build-completed $!pg, :$id }

my sub distribution-add ( :$db!, :$meta!, :$user! ) {

  my %meta = Rakudo::Internals::JSON.from-json($meta);


  my $name = %meta<name>;
  my $version = %meta<version>;
  my $auth = %meta<auth>;
  #my $owner = %meta<auth>.split(':').tail;
  my $api = %meta<api>;

  my $identity = "$auth:$name:$version:$api";

  my $dependencies = %meta<depends>;

  my @provides = |%meta<provides>;
  my @emulates = |%meta<emulates>;
  my @resourcs = |%meta<resourcs>;
  
  $db.begin;
  
  $db.query(q:to/END/, $name, $version, $auth, $api, $identity, $meta, $user );
    INSERT INTO distribution
           ( name, version, auth, api, identity, meta, user )
    values (   $1,      $2,   $3,  $4,       $5,   $6,     $7 )
    END

  my $id = $db.query('SELECT id from distribution where identity = $1', $identity).value;

  
  if @provides {

    my $sth = $db.prepare('insert into provides (distribution, use, file ) values ($1,$2, $3)');
    @provides.map({ $sth.execute($id, .key, .value) });
  }

  $db.commit;

  $db.finish;
  #insert-into-distribution($!pg, :$user, :$meta,
  #  :$name, :$version, :$auth, :$api, :$identity
  #);

  #my @provides = (1, 'okokoko', 'sosososo');
  #my @provides = %meta<provides>;
  #
  #insert-into-provides($!pg, @provides);

}