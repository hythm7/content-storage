use DB::Migration::Declare;

migration 'Setup', {

  create-table "sessions", {

    add-column "id",         text(),     :primary;
    add-column "state",      text();
    add-column "expiration", timestamp();

  }

  create-table "users", { 

    add-column "id", integer(), :increments, :primary;

    add-column "username", text(),    :!null, :unique;
    add-column "password", text(),    :!null, :unique;
    add-column "is-admin", boolean();

  }

  create-table "distributions", { 

    add-column "id", integer(), :increments, :primary;

    add-column "identity", text(), :!null, :unique;

    add-column "meta",    text(), :!null;
    add-column "name",    text(), :!null;
    add-column "version", text(), :!null;
    add-column "auth",    text(), :!null;
    add-column "api",     text();


    add-column "created", timestamp(), :default(now), :!null;

    add-column "userid", integer(), :!null;

  }

  create-table "builds", { 

    add-column "id", integer(), :increments, :primary;

    add-column "status", text(), :default( sql( "'UNKNOWN'" ) );

    add-column "userid",   integer(), :!null;
    add-column "filename", text(),    :!null;


    add-column "meta",     text(), :default( sql( "'UNKNOWN'" ) );
    add-column "name",     text(), :default( sql( "'UNKNOWN'" ) );
    add-column "version",  text(), :default( sql( "'UNKNOWN'" ) );
    add-column "auth",     text(), :default( sql( "'UNKNOWN'" ) );
    add-column "api",      text(), :default( sql( "'UNKNOWN'" ) );

    add-column "identity", text(), :default( sql( "'UNKNOWN'" ) );


    add-column "test",  text(), :default( sql( "'UNKNOWN'" ) );

    add-column "started",   timestamp(), :default(Any);
    add-column "completed", timestamp(), :default(Any);

    add-column "log",  text(), :default( sql( "'UNKNOWN'" ) );


  }


  create-table "provides", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "use",  text(), :!null;
    add-column "file", text(), :!null;

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }


  create-table "resources", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "resources", arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table "emulates", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table "supersedes", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table "superseded", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table "excludes", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "unit", text();
    add-column "use",  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table "authors", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "authors", arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table "tags", { 

    add-column "id", integer(), :increments, :primary;

    add-column "distribution", integer(), :!null;

    add-column "tags", arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

}
