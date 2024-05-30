use DB::Migration::Declare;

migration 'Setup', {

  create-table "session", {

    add-column "id",         text(),     :primary;
    add-column "state",      text();
    add-column "expiration", timestamp();

  }

  create-table "user", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "username", text(),    :!null, :unique;
    add-column "password", text(),    :!null, :unique;
    add-column "is-admin", boolean();

  }

  create-table "build", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "status", text(), :default( sql( "'UNKNOWN'" ) );

    add-column "user", type( 'UUID' ), :!null;

    add-column "filename", text(),    :!null;


    add-column "meta",     text(), :default( sql( "'UNKNOWN'" ) );

    add-column "name",     text();
    add-column "version",  text();
    add-column "auth",     text();
    add-column "api",      text();

    add-column "identity", text();


    add-column "test",  text(), :default( sql( "'UNKNOWN'" ) );

    add-column "started",   timestamp(), :default(Any);
    add-column "completed", timestamp(), :default(Any);

    add-column "log",  text();

  }


  create-table "distribution", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "meta",    text(), :!null;

    add-column "name",    text(), :!null;
    add-column "version", text(), :!null;
    add-column "auth",    text(), :!null;
    add-column "api",     text();

    add-column "identity", text(), :!null, :unique;

    add-column "created", timestamp(), :default(now), :!null;

    add-column "user", type( 'UUID' ), :!null;

  }

  create-table "provides", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "use",  text(), :!null;
    add-column "file", text(), :!null;

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }


  create-table "resource", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "resources", arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }

  create-table "emulates", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }

  create-table "supersedes", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }

  create-table "superseded", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }

  create-table "excludes", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }

  create-table "author", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "authors", arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }

  create-table "tag", { 

    add-column "id", type( 'UUID' ), :primary, :default( sql( 'gen_random_uuid()' ) );

    add-column "distribution", type( 'UUID' ), :!null;

    add-column "tags", arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distribution>, :cascade;

  }

}
