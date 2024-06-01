use LibUUID;
use JSON::Class:auth<zef:vrurg>;

unit class DistributionStorage::Model::Build;
  also is json( :implicit );

has UUID:D $.id is json( :serializer( *.Str ) );

has Str       $.identity;
has Str       $.name;
has Version() $.version;
has Str       $.auth;
has Version() $.api;
has Str       $.meta;
