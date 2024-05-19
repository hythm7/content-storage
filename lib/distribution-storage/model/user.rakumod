use JSON::Class:auth<zef:vrurg>;

unit class DistributionStorage::Model::User;
  also is json;

has Int  $.id;
has Str  $.username;
has Bool $.is-admin = False;
