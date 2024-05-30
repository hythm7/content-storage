use LibUUID;
use JSON::Class:auth<zef:vrurg>;

unit class DistributionStorage::Model::User;
  also is json;

has UUID  $.id is json( :serializer( *.Str ), :deserializer( { UUID.new: .Str } ) );
has Str   $.username is json;
has Bool  $.is-admin is json = False;
