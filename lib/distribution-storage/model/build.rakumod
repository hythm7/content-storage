use JSON::Class:auth<zef:vrurg>;

use distribution-storage;

unit class DistributionStorage::Model::Build;
  also is json;

has UUID $.id;

has Str $.status;
has Str $.filename;
has Str $.user;
has Str $.test;

has DateTime $.started;
has DateTime $.completed;

has Str $.meta;
has Str $.identity;
has Str $.name;
has Str $.version;
has Str $.auth;
has Str $.api;
