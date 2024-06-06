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

    add-column "provides", arr( text() );

    add-column "tags",     arr( text() );

    add-column "description", text();

    add-column "created", timestamp(), :default(now), :!null;

    add-column "user", type( 'UUID' ), :!null;

    add-column "build", type( 'UUID' ), :!null;

    foreign-key :from<build>, :to<id>, :table<build>;

  }

}
