#!/usr/bin/env raku

use Dev::ContainerizedService;

project 'content-storage';
store;

service 'postgres', :tag<14.4>, -> (:$conninfo, *%) {

  env 'DB_CONN_INFO', $conninfo;

}

