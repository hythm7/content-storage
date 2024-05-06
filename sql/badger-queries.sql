-- use distributions-storage-model-user

-- sub add-user(Str :$username!, Str :$password! --> +)
INSERT
INTO   users (  username,  password )
values       ( $username, $password )

-- sub get-user(Int :$id! --> DistributionsStorage::Model::User $)
SELECT id username, password, 'is-admin'
FROM users
WHERE id = $id

-- sub get-user(Str :$username! --> DistributionsStorage::Model::User $)
SELECT id, username, password, 'is-admin'
FROM users
WHERE username = $username

-- sub insert-into-distributions(Str :$name!, :$version!, :$auth!, :$api, :$identity!, :$meta!, :$userid! --> +)
INSERT
INTO   distributions ( 'name', 'version', 'auth', 'api', 'identity', 'meta', 'userid' )
VALUES       ( $name, $version, $auth, $api, $identity, $meta, $userid )

-- sub create-build(Str :$filename! --> $)
INSERT
INTO   builds ( filename, userid )
VALUES        ( $filename, 1  )
RETURNING id


-- sub select-builds(--> @)
SELECT * FROM builds

-- sub select-build(Int :$id! --> %)
SELECT * FROM builds
WHERE id = $id

-- sub insert-into-provides(@provides --> +)
INSERT
INTO   provides ( distribution, use, file )
values       ({@provides.map({ 1, .key, .value}})


-- sub get-dists(--> @)
SELECT * FROM distributions

-- sub get-user-dists(Int :$userid! --> @)
SELECT * FROM distributions
WHERE userid = $userid

-- sub delete-dist(Str :$identity! --> +)
DELETE FROM distributions WHERE identity = $identity

-- sub insert-into-deps(Str $identity, Str $phase, Str $need, Str $use -->+)
INSERT INTO 'deps' ('identity', 'phase', 'need', 'use' )
  VALUES ( $identity, $phase, $need, $use )
  ON CONFLICT DO NOTHING


-- sub insert-into-resources(Str $identity, Str $resource -->+)
INSERT INTO 'resources' ('identity', 'resource' )
  VALUES ( $identity, $resource )
  ON CONFLICT DO NOTHING

-- sub insert-into-emulates(Str $identity, Str $unit, Str $use -->+)
INSERT INTO 'emulates' ('identity', 'unit', 'use' )
  VALUES ( $identity, $unit, $use )
  ON CONFLICT DO NOTHING

-- sub insert-into-supersedes(Str $identity, Str $unit, Str $use -->+)
INSERT INTO 'supersedes' ('identity', 'unit', 'use' )
  VALUES ( $identity, $unit, $use )
  ON CONFLICT DO NOTHING

-- sub insert-into-superseded(Str $identity, Str $unit, Str $use -->+)
INSERT INTO 'superseded-by' ('identity', 'unit', 'use' )
  VALUES ( $identity, $unit, $use )
  ON CONFLICT DO NOTHING

-- sub insert-into-excludes(Str $identity, Str $unit, Str $use -->+)
INSERT INTO 'excludes' ('identity', 'unit', 'use' )
  VALUES ( $identity, $unit, $use )
  ON CONFLICT DO NOTHING

-- sub insert-into-authors(Str $identity, Str $author -->+)
INSERT INTO 'authors' ('identity', 'author' )
  VALUES ( $identity, $author )
  ON CONFLICT DO NOTHING

-- sub insert-into-tags(Str $identity, Str $tag -->+)
INSERT INTO 'tags' ('identity', 'tag' )
  VALUES ( $identity, $tag )
  ON CONFLICT DO NOTHING


-- sub select(Str $name! --> @)
SELECT distributions.identity, name, ver, auth, api
  FROM      distributions
  LEFT JOIN provides
  ON        provides.identity = distributions.identity
  WHERE     name = $name or unit = $name
  GROUP BY  distributions.identity

-- sub search(Str $name! --> @)
SELECT distributions.identity, name, ver, auth, api
  FROM      distributions
  LEFT JOIN provides
  ON        provides.identity = distributions.identity
  WHERE     name = $name COLLATE NOCASE or unit = $name COLLATE NOCASE
  GROUP BY  distributions.identity

-- sub select-meta(Str $identity! --> $)
SELECT meta
  FROM     distributions
  WHERE    identity = $identity

-- sub everything( --> @)
SELECT meta FROM distributions

