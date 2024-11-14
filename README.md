Name
====

content-storage - Raku distributions storage.



Running
=======

Please note that this application is still under early development and the API may change.

### Clone the repository:

```bash
git clone https://github.com/hythm7/content-storage.git

# Change directory to cloned repository
cd content-storage
```

### Run using docker compose:

```bash
docker-compose up

```

### Run manually:

```bash
# Install dependencies
zef   install --deps-only --/test . #    using zef
pakku add       deps only  notest . # or using pakku

# Setup frontend
npm install   # install modules
npm run build # webpack build

# Run service - needs Postgres connection info
CONTENT_STORAGE_DB_CONN_INFO=<conninfo> raku -I. service.raku

# Or run development environment
RAKULIB=. ./devenv.raku run cro run

```

Configs
=======

[Config file](https://github.com/hythm7/content-storage/blob/main/config.json).

`storage.name` the storage name.

`storage.host` the storage host.

`storage.port` the storage port.

`storage.archives-directory` where to store distributions archives.

`build.log.color` enable colors in logs

`build.concurrent.max` max number of concurrent builds.

`build.concurrent.delay` how many seconds to wait after reaching max concurrent builds before retrying a build.

`build.test.command` command to test distributions.

API
=======

[OpenAPI endpoints](https://github.com/hythm7/content-storage/blob/main/openapi.json).



Author
======

Haytham Elganiny <elganiny.haytham@gmail.com>

Copyright and License
=====================

Copyright 2024 Haytham Elganiny

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

