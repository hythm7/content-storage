use distributions-storage-model-user;
use distributions-storage-model-distribution;

use Badger <sql/badger-queries.sql>;


unit class DistributionsStorage::Database;

has $.pg;

has %.dist;

method add-user(:$username!, :$password! ) {

  add-user($!pg, :$username, :$password );

}

multi method get-user(Int :$id!) {

  get-user( $!pg, :$id );

}

multi method get-user( Str :$username! ) {
  my DistributionsStorage::Model::User $user = get-user( $!pg, :$username );
}

method add-dist(:$name!, :$, :$user!) {

  my $meta = slurp '/home/helganiny/dev/Pakku/META6.json';

  say '-------------';
  dd $meta;
  dd  '-------------';
  add-dist( db =>$!pg.db, :$name, :$meta, userid => $user )

}

method get-dist(UInt $id) {
  #%!dist{$id}
}

method get-dists {
  
  my @dist = get-dists( $!pg );

  dd @dist.map(*.<identity>);
  @dist;

}

method delete-dist(:$identity!) {
  delete-dist( $!pg, :$identity )
}

my sub add-dist ( :$db!, :$name!, :$meta!, :$userid! ) {

  my %meta = Rakudo::Internals::JSON.from-json($meta);


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
  
  $db.query(q:to/END/, $name, $version, $auth, $api, $identity, $meta, $userid );
    INSERT INTO distributions
           ( name, version, auth, api, identity, meta, userid )
    values (   $1,      $2,   $3,  $4,       $5,   $6,     $7 )
    END

  my $id = $db.query('SELECT id from distributions where identity = $1', $identity).value;

  
  if @provides {

    my $sth = $db.prepare('insert into provides (distribution, use, file ) values ($1,$2, $3)');
    @provides.map({ $sth.execute($id, .key, .value) });
  }

  $db.commit;

  $db.finish;
  #insert-into-distributions($!pg, userid => $user, :$meta,
  #  :$name, :$version, :$auth, :$api, :$identity
  #);

  #my @provides = (1, 'okokoko', 'sosososo');
  #my @provides = %meta<provides>;
  #
  #insert-into-provides($!pg, @provides);

}
