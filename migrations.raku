use DB::Migration::Declare;

migration 'Setup', {

  create-table 'sessions', {

    add-column 'id',         text(),     :primary;
    add-column 'state',      text();
    add-column 'expiration', timestamp();

  }

  create-table 'users', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'username', text(),    :!null, :unique;
    add-column 'password', text(),    :!null, :unique;
    add-column 'is-admin', boolean();

  }

  create-table 'distributions', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'identity', text(), :!null, :unique;

    add-column 'name',     text(), :!null;
    add-column 'version',  text(), :!null;
    add-column 'auth',     text(), :!null;
    add-column 'api',      text();

    add-column 'meta', text(), :!null;

    add-column 'created', timestamp(), :default(now), :!null;

    add-column 'userid', integer(), :!null;

  }

  create-table 'builds', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'status', integer(), :default(3), :!null;

    add-column 'filename',  text(), :!null;

    add-column 'name',     text();
    add-column 'version',  text();
    add-column 'auth',     text();
    add-column 'api',      text();

    add-column 'identity', text();

    add-column 'build',  text();

    add-column 'started', timestamp(), :default(now);
    add-column 'completed', timestamp(), :default(now);

    add-column 'userid', integer(), :!null;


  }


  create-table 'provides', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'use',  text(), :!null;
    add-column 'file', text(), :!null;

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }


  create-table 'resources', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'resources', arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table 'emulates', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'unit', text();
    add-column 'use',  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table 'supersedes', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'unit', text();
    add-column 'use',  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table 'superseded', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'unit', text();
    add-column 'use',  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table 'excludes', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'unit', text();
    add-column 'use',  text();

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table 'authors', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'authors', arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

  create-table 'tags', { 

    add-column 'id', integer(), :increments, :primary;

    add-column 'distribution', integer(), :!null;

    add-column 'tags', arr( text() );

    foreign-key :from<distribution>, :to<id>, :table<distributions>, :cascade;

  }

}
