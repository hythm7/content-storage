-- sub select-user-username-by-id(:$id! --> %)
SELECT "id", "username"
FROM   "user"
WHERE  "id" = $id

-- sub select-user-password-by-username(Str :$username! --> %)
SELECT "id", "password"
FROM   "user"
WHERE  "username" = $username


-- sub select-user-by-id(:$id! --> %)
SELECT "id", "username", "is-admin"
FROM  "user"
WHERE "id" = $id


-- sub select-user-by-username(Str :$username! --> %)
SELECT "id", "username", "is-admin"
FROM  "user"
WHERE "username" = $username

-- sub select-user( --> @)
SELECT "id", "username", "is-admin"
FROM  "user"


-- sub insert-into-user(Str :$username!, Str :$password! --> +)
INSERT
INTO   "user" (  "username",  "password" )
values       ( $username, $password )


-- sub insert-into-distribution(:$user!, Str :$name!, :$version!, :$auth!, :$api, :$identity!, :$description!, :$provides!, :$tags!, :$meta!, :$build! --> +)
INSERT
INTO   "distribution" ( "user", "name", "version", "auth", "api", "identity", "meta", "description", "provides", "tags", "build" )
VALUES                ( $user,  $name,  $version,  $auth,  $api,  $identity,  $meta,  $description,  $provides,  $tags,  $build  )

-- sub insert-into-build(:$user! --> $)
INSERT
INTO   "build" ( "status", "user", "meta", "test" )
VALUES         (  3,       $user,   3,      3     )
RETURNING "id"


-- sub update-build-status(:$id!, Int :$status! --> +)
UPDATE "build"
set    "status" = $status
WHERE  "id"     = $id

-- sub update-build-meta(:$id!, Int :$meta! --> +)
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


-- sub update-build-test(:$id!, Int :$test! --> +)
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

-- sub select-build(Int :$offset!, Int :$limit! --> @)
SELECT "b"."id",       "b"."status",  "b"."meta",
       "b"."name",     "b"."version", "b"."auth",     "b"."api",
       "b"."identity", "b"."test",    "b"."started",  "b"."completed",
       ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
ORDER BY started DESC
LIMIT $limit OFFSET $offset


-- sub select-build-by-id(:$id! --> %)
SELECT "b"."id",       "b"."status",  "b"."meta",
       "b"."name",     "b"."version", "b"."auth",     "b"."api",
       "b"."identity", "b"."test",    "b"."started",  "b"."completed",
       ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
WHERE  "b"."id" = $id

-- sub select-build-log-by-id(:$id! --> %)
SELECT "id", "log"
FROM   "build"
WHERE  "id" = $id

-- sub select-build-count(--> $)
SELECT COUNT(*) FROM "build"

-- sub search-build(Str :$name!, Int :$offset!, Int :$limit! --> @)
SELECT "b"."id",       "b"."status",  "b"."meta",
       "b"."name",     "b"."version", "b"."auth",     "b"."api",
       "b"."identity", "b"."test",    "b"."started",  "b"."completed",
       ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
WHERE  "b"."name" = $name
ORDER BY started DESC
LIMIT $limit OFFSET $offset


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
