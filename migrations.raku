use DB::Migration::Declare;

migration 'Setup', {

  create-table "session", {

    add-column "id",         text(),     :primary;
    add-column "state",      text();
    add-column "expiration", timestamp();

  }

  create-table "user", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "username",  text(),    :!null, :unique;
    add-column "password",  text(),    :!null;
    add-column "firstname", text();
    add-column "lastname",  text();
    add-column "email",     text();
    add-column "admin",     boolean();
    add-column "created",   timestamp(), :default(now), :!null;

  }

  create-table "distribution", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "meta",    text(), :!null;

    add-column "name",    text(), :!null;
    add-column "version", text(), :!null;
    add-column "auth",    text(), :!null;
    add-column "api",     text();

    add-column "identity", text(), :!null, :unique;

    add-column "provides", arr( text() );

    add-column "tags",     arr( text() );

    add-column "description", text();
    add-column "readme",      text();
    add-column "changes",     text();

    add-column "created", timestamp(),  :!null;

    add-column "user", type( 'UUID' ),  :!null;

    add-column "build", type( 'UUID' ), :!null;

  }

  create-table "build", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "status", integer();

    add-column "user", type( 'UUID' ), :!null;

    add-column "meta",     integer();

    add-column "name",     text();
    add-column "version",  text();
    add-column "auth",     text();
    add-column "api",      text();

    add-column "identity", text();


    add-column "test",  integer();

    add-column "started",   timestamp(), :default(Any);
    add-column "completed", timestamp(), :default(Any);

    add-column "log",  text();

  }


  execute
          up => sql(q<INSERT INTO "user" ("username", "password", "admin") VALUES ('admin', '$argon2i$v=19$m=65536,t=2,p=2$zOReKe3NJiomMwqJkvrKEg$lI2kx+f7ZUEuj0hGRUXrYw', TRUE)>),
          down => sql(q<'DELETE FROM "user" WHERE username = "admin">);

}
