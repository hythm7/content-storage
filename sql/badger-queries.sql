-- sub select-userid-by-username(:$username! --> $)
SELECT "id"
FROM   "user"
WHERE  "username" = $username

-- sub select-user-username-by-id(:$id! --> %)
SELECT "id", "username"
FROM   "user"
WHERE  "id" = $id

-- sub select-user-password-by-username(Str :$username! --> %)
SELECT "id", "password"
FROM   "user"
WHERE  "username" = $username


-- sub select-user-by-id(:$id! --> %)
SELECT "id", "username", "admin"
FROM  "user"
WHERE "id" = $id


-- sub select-user-by-username(Str :$username! --> %)
SELECT "id", "username", "admin"
FROM  "user"
WHERE "username" = $username

-- sub select-user( --> @)
SELECT "id", "username", "admin"
FROM  "user"


-- sub insert-into-user(Str :$username!, Str :$password! --> %)
INSERT
INTO   "user" (  "username",  "password" )
values       ( $username, $password )
RETURNING "id"

-- sub update-user-password-by-id(:$id!, Str :$password! --> +)
UPDATE "user"
SET    "password" = $password
WHERE  "id"       = $id

-- sub update-user-password-by-username(:$username!, Str :$password! --> +)
UPDATE "user"
SET    "password" = $password
WHERE  "username" = $username


-- sub insert-into-distribution(:$user!, Str :$name!, :$version!, :$auth!, :$api, :$identity!, Str :$description!, Str :$readme, Str :$changes,  :$provides!, :$tags!, :$meta!, :$build! --> +)
INSERT
INTO   "distribution" ( "user", "name", "version", "auth", "api", "identity", "meta", "description", "readme", "changes", "provides", "tags", "build" )
VALUES                ( $user,  $name,  $version,  $auth,  $api,  $identity,  $meta,  $description,  $readme,  $changes,  $provides,  $tags,  $build  )

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

-- sub select-build(UInt :$offset!, UInt :$limit! --> @)
SELECT "b".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
ORDER BY started DESC
LIMIT $limit OFFSET $offset

-- sub select-build-by-name(Str :$name, UInt :$offset!, UInt :$limit! --> @)
SELECT "b".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
WHERE "b"."name" ILIKE $name
ORDER BY started DESC
LIMIT $limit OFFSET $offset


-- sub select-build-by-id(:$id! --> %)
SELECT "b".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
WHERE  "b"."id" = $id

-- sub select-build-log-by-id(:$id! --> %)
SELECT "id", "log"
FROM   "build"
WHERE  "id" = $id

-- sub select-build-by-name-count(Str :$name! --> $)
SELECT COUNT(*) FROM "build" "b"
WHERE "b"."name" ILIKE $name

-- sub select-build-count(--> $)
SELECT COUNT(*) FROM "build"


-- sub select-distribution(UInt :$offset!, UInt :$limit! --> @)
SELECT "d".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "d"."user" )
FROM "distribution" "d"
ORDER BY "d"."created" DESC
LIMIT $limit OFFSET $offset

-- sub select-distribution-by-name(Str :$name!, UInt :$offset!, UInt :$limit! --> @)
SELECT "d".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "d"."user" )
FROM "distribution" "d"
WHERE "d"."name" ILIKE $name
ORDER BY "d"."created" DESC
LIMIT $limit OFFSET $offset


-- sub select-distribution-by-id(:$id! --> %)
SELECT "d".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "d"."user" )
FROM "distribution" "d"
WHERE  "d"."id" = $id

-- sub select-distribution-by-name-count(Str :$name! --> $)
SELECT COUNT(*) FROM "distribution" "d"
WHERE "d"."name" ILIKE $name

-- sub select-distribution-count(--> $)
SELECT COUNT(*) FROM "distribution"

-- sub select-user-distribution(:$user!, UInt :$offset!, UInt :$limit! --> @)
SELECT "d".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "d"."user" )
FROM "distribution" "d"
WHERE "d"."user" = $user
ORDER BY "d"."created" DESC
LIMIT $limit OFFSET $offset

-- sub select-user-distribution-by-name(:$user!, Str :$name!, UInt :$offset!, UInt :$limit! --> @)
SELECT "d".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "d"."user" )
FROM "distribution" "d"
WHERE "d"."user" = $user AND "d"."name" ILIKE $name
ORDER BY "d"."created" DESC
LIMIT $limit OFFSET $offset


-- sub select-user-distribution-count(:$user! --> $)
SELECT COUNT(*) FROM "distribution" "d"
WHERE "d"."user" = $user

-- sub select-user-distribution-by-name-count(:$user!, Str :$name! --> $)
SELECT COUNT(*) FROM "distribution" "d"
WHERE "d"."user" = $user AND "d"."name" ILIKE $name

-- sub delete-distribution-by-id(:$id! --> +)
DELETE
FROM "distribution" "d"
WHERE  "d"."id" = $id

-- sub select-user-build(:$user!, UInt :$offset!, UInt :$limit! --> @)
SELECT "b".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
WHERE "b"."user" = $user
ORDER BY "b"."started" DESC
LIMIT $limit OFFSET $offset

-- sub select-user-build-by-name(:$user!, Str :$name!, UInt :$offset!, UInt :$limit! --> @)
SELECT "b".*, ( SELECT "username" AS "user" FROM "user" WHERE "id" = "b"."user" )
FROM "build" "b"
WHERE "b"."user" = $user AND "b"."name" ILIKE $name
ORDER BY "b"."started" DESC
LIMIT $limit OFFSET $offset


-- sub select-user-build-count(:$user! --> $)
SELECT COUNT(*) FROM "build" "b"
WHERE "b"."user" = $user

-- sub select-user-build-by-name-count(:$user!, Str :$name! --> $)
SELECT COUNT(*) FROM "build" "b"
WHERE "b"."user" = $user AND "b"."name" ILIKE $name

-- sub delete-build-by-id(:$id! --> +)
DELETE
FROM "build" "b"
WHERE  "b"."id" = $id


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
