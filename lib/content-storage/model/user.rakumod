use JSON::Class:auth<zef:vrurg>;

use content-storage;

unit class ContentStorage::Model::User;
  also is json;

has UUID  $.id;
has Str   $.username;
has Bool  $.admin = False;
