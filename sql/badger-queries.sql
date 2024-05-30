-- use distribution-storage-model-user

-- sub select-user-username-by-id(:$id! --> %)
SELECT "id", "username"
FROM   "user"
WHERE  "id" = $id

-- sub select-user-password-by-username(Str :$username! --> %)
SELECT "id", "password"
FROM   "user"
WHERE  "username" = $username


-- sub select-user-by-id(:$id! --> DistributionStorage::Model::User $)
SELECT "id", "username", "is-admin"
FROM  "user"
WHERE "id" = $id


-- sub select-user-by-username(Str :$username! --> DistributionStorage::Model::User $)
SELECT "id", "username", "is-admin"
FROM  "user"
WHERE "username" = $username

-- sub select-user( --> @)
SELECT "id", "username", "is-admin"
FROM  "user"


-- sub insert-user(Str :$username!, Str :$password! --> +)
INSERT
INTO   "user" (  "username",  "password" )
values       ( $username, $password )


-- sub insert-into-distribution(Str :$name!, :$version!, :$auth!, :$api, :$identity!, :$meta!, :$userid! --> +)
INSERT
INTO   "distribution" ( "name", "version", "auth", "api", "identity", "meta", "userid" )
VALUES                 ( $name,  $version,  $auth,  $api,  $identity,  $meta,  $userid  )

-- sub insert-build(:$user!, Str :$filename! --> $)
INSERT
INTO   "build" (  "status",  "user", "filename", "meta",    "test"    )
VALUES         (  'UNKNOWN', $user,  $filename,  'UNKNOWN', 'UNKNOWN' )
RETURNING "id"


-- sub update-build-status(:$id!, Str :$status! --> +)
UPDATE "build"
set    "status" = $status
WHERE  "id"     = $id

-- sub update-build-meta(:$id!, Str :$meta! --> +)
UPDATE "build"
set    "meta" = $meta
WHERE  "id"   = $id

-- sub update-build-identity(:$id!, Str :$identity! --> +)
UPDATE "build"
set    "identity" = $identity
WHERE  "id"   = $id

-- sub update-build-name(:$id!, Str :$name! --> +)
UPDATE "build"
set    "name" = $name
WHERE  "id"   = $id


-- sub update-build-version(:$id!, Str :$version! --> +)
UPDATE "build"
set    "version" = $version
WHERE  "id"   = $id

-- sub update-build-auth(:$id!, Str :$auth! --> +)
UPDATE "build"
set    "auth" = $auth
WHERE  "id"   = $id

-- sub update-build-api(:$id!, Str :$api! --> +)
UPDATE "build"
set    "api" = $api
WHERE  "id"  = $id


-- sub update-build-test(:$id!, Str :$test! --> +)
UPDATE "build"
set    "test" = $test
WHERE  "id"   = $id


-- sub update-build-started(:$id! --> +)
UPDATE "build"
set    "started" = 'now'
WHERE  "id"      = $id

-- sub update-build-completed(:$id! --> +)
UPDATE "build"
set    "completed" = 'now'
WHERE  "id"        = $id

-- sub update-build-log(:$id!, Str :$log!--> +)
UPDATE "build"
set    "log" = $log
WHERE  "id"  = $id

-- sub select-build-started(:$id! --> $)
SELECT "started"
FROM   "build"
WHERE  "id"     = $id

-- sub select-build-completed(:$id! --> $)
SELECT "completed"
FROM   "build"
WHERE  "id"        = $id

-- sub select-build(--> @)
SELECT "b"."id",       "b"."status",  "b"."filename", "b"."meta",
       "b"."name",     "b"."version", "b"."auth",     "b"."api",
       "b"."identity", "b"."test",    "b"."started",  "b"."completed",
       ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
ORDER BY started DESC


-- sub select-build-by-id(:$id! --> %)
SELECT "b"."id",       "b"."status",  "b"."filename", "b"."meta",
       "b"."name",     "b"."version", "b"."auth",     "b"."api",
       "b"."identity", "b"."test",    "b"."started",  "b"."completed",
       ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
WHERE  "b"."id" = $id

-- sub select-build-log-by-id(:$id! --> %)
SELECT "id", "log"
FROM   "build"
WHERE  "id" = $id


-- sub insert-into-provides(@provides --> +)
INSERT
INTO   "provides" ( "distribution", "use", "file" )
values       ({@provides.map({ 1, .key, .value}})


-- sub select-distribution(--> @)
SELECT * FROM "distribution"

-- sub select-distribution-by-id(:$id! --> $)
SELECT * FROM "distribution"
WHERE "id" = $id

-- sub select-distribution-by-user(:$user! --> @)
SELECT * FROM "distribution"
WHERE "user" = $user

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
