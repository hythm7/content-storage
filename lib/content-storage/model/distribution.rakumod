use JSON::Class:auth<zef:vrurg>;

use content-storage;

unit class ContentStorage::Model::Distribution;
  also is json;

has UUID  $.id;
has Str     $.identity;
has Str     $.name;
has Version() $.version;
has Str     $.auth;
has Version() $.api;
has Str     $.meta;

has Str $.dependencies;

has @.provides;
has @.excludes;

has Str @.resources;
has Str @.authors;
has Str @.tags;

has Str %.emulates;
has Str %.supersedes;
has Str %.superseded;
