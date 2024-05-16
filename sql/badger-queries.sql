-- use distribution-storage-model-user

-- sub add-user(Str :$username!, Str :$password! --> +)
INSERT
INTO   "user" (  "username",  "password" )
values       ( $username, $password )

-- sub get-user(Int :$id! --> DistributionStorage::Model::User $)
SELECT "id" "username", "password", "is-admin"
FROM  "user"
WHERE "id" = $id

-- sub get-user(Str :$username! --> DistributionStorage::Model::User $)
SELECT "id", "username", "password", "is-admin"
FROM  "user"
WHERE "username" = $username

-- sub insert-into-distribution(Str :$name!, :$version!, :$auth!, :$api, :$identity!, :$meta!, :$userid! --> +)
INSERT
INTO   "distribution" ( "name", "version", "auth", "api", "identity", "meta", "userid" )
VALUES                 ( $name,  $version,  $auth,  $api,  $identity,  $meta,  $userid  )

-- sub insert-build(Int :$userid!, Str :$filename! --> $)
INSERT
INTO   "build" (  "userid", "filename", "meta", "test" )
VALUES          (  $userid,  $filename, 'UNKNOWN', 'UNKNOWN'   )
RETURNING "id"


-- sub update-build-status(Int :$id!, Str :$status! --> +)
UPDATE "build"
set    "status" = $status
WHERE  "id"     = $id

-- sub update-build-meta(Int :$id!, Str :$meta! --> +)
UPDATE "build"
set    "meta" = $meta
WHERE  "id"   = $id

-- sub update-build-name(Int :$id!, Str :$name! --> +)
UPDATE "build"
set    "name" = $name
WHERE  "id"   = $id


-- sub update-build-version(Int :$id!, Str :$version! --> +)
UPDATE "build"
set    "version" = $version
WHERE  "id"   = $id

-- sub update-build-auth(Int :$id!, Str :$auth! --> +)
UPDATE "build"
set    "auth" = $auth
WHERE  "id"   = $id

-- sub update-build-api(Int :$id!, Str :$api! --> +)
UPDATE "build"
set    "api" = $api
WHERE  "id"  = $id


-- sub update-build-test(Int :$id!, Str :$test! --> +)
UPDATE "build"
set    "test" = $test
WHERE  "id"   = $id


-- sub update-build-started(Int :$id! --> +)
UPDATE "build"
set    "started" = 'now'
WHERE  "id"      = $id

-- sub update-build-completed(Int :$id! --> +)
UPDATE "build"
set    "completed" = 'now'
WHERE  "id"        = $id

-- sub select-build-started(Int :$id! --> $)
SELECT "started"
FROM   "build"
WHERE  "id"     = $id

-- sub select-build-completed(Int :$id! --> $)
SELECT "completed"
FROM   "build"
WHERE  "id"        = $id

-- sub get-user(Str :$username! --> DistributionStorage::Model::User $)
SELECT "id", "username", "password", "is-admin"
FROM   "user"
WHERE  "username" = $username



-- sub select-builds(--> @)
SELECT   "b".*,
       ( SELECT "username" FROM "user" WHERE "id" = "b"."userid" )
FROM     "build" "b"
ORDER BY started DESC

-- sub select-build(Int :$id! --> %)
SELECT "b".*, ( SELECT "username" FROM "user" WHERE "id" = "b"."userid" ) FROM "build" "b"
WHERE  "b"."id" = $id

-- sub insert-into-provides(@provides --> +)
INSERT
INTO   "provides" ( "distribution", "use", "file" )
values       ({@provides.map({ 1, .key, .value}})


-- sub get-dists(--> @)
SELECT * FROM "distribution"

-- sub get-user-dists(Int :$userid! --> @)
SELECT * FROM "distribution"
WHERE "userid" = $userid

-- sub delete-dist(Str :$identity! --> +)
DELETE FROM "distribution" WHERE "identity" = $identity

-- sub insert-into-deps(Str $identity, Str $phase, Str $need, Str $use -->+)
INSERT INTO "deps" ( "identity", "phase", "need", "use" )
VALUES           ( $identity,  $phase,  $need,  $use  )
ON CONFLICT DO NOTHING


-- sub insert-into-resources(Str $identity, Str $resource -->+)
INSERT INTO "resources" ( "identity", "resource" )
VALUES                  ( $identity,  $resource  )
ON CONFLICT DO NOTHING

-- sub insert-into-emulates(Str $identity, Str $unit, Str $use -->+)
INSERT INTO "emulates" ( "identity", "unit", "use" )
VALUES                 ( $identity,  $unit,  $use  )
ON CONFLICT DO NOTHING

-- sub insert-into-supersedes(Str $identity, Str $unit, Str $use -->+)
INSERT INTO "supersedes" ( "identity", "unit", "use" )
VALUES                   ( $identity,  $unit,  $use  )
ON CONFLICT DO NOTHING

-- sub insert-into-superseded(Str $identity, Str $unit, Str $use -->+)
INSERT INTO "superseded-by" ( "identity", "unit", "use" )
VALUES                      ( $identity,  $unit,  $use  )
ON CONFLICT DO NOTHING

-- sub insert-into-excludes(Str $identity, Str $unit, Str $use -->+)
INSERT INTO "excludes" ( "identity", "unit", "use" )
VALUES                 ( $identity,  $unit,  $use  )
ON CONFLICT DO NOTHING

-- sub insert-into-authors(Str $identity, Str $author -->+)
INSERT INTO "authors" ( "identity", "author" )
VALUES                ( $identity,  $author  )
ON CONFLICT DO NOTHING

-- sub insert-into-tags(Str $identity, Str $tag -->+)
INSERT INTO "tags" ( "identity", "tag" )
VALUES             ( $identity,  $tag  )
ON CONFLICT DO NOTHING


-- sub select(Str $name! --> @)
SELECT    "distribution"."identity", "name", "ver", "auth", "api"
FROM      "distribution"
LEFT JOIN "provides"
ON        "provides"."identity" = "distribution"."identity"
WHERE     "name" = $name or "unit" = $name
GROUP BY  "distribution"."identity"

-- sub search(Str $name! --> @)
SELECT    "distribution"."identity", "name", "ver", "auth", "api"
FROM      "distribution"
LEFT JOIN "provides"
ON        "provides"."identity" = "distribution"."identity"
WHERE     "name" = $name COLLATE NOCASE or "unit" = $name COLLATE NOCASE
GROUP BY  "distribution"."identity"

-- sub select-meta(Str $identity! --> $)
SELECT "meta"
  FROM     "distribution"
  WHERE    "identity" = $identity

-- sub everything( --> @)
SELECT "meta" FROM "distribution"
