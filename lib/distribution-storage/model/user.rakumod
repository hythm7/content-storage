use JSON::Class:auth<zef:vrurg>;

use distribution-storage;

unit class DistributionStorage::Model::User;
  also is json;

has UUID  $.id;
has Str   $.username;
has Bool  $.is-admin = False;
