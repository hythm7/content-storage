use LibUUID;
use JSON::Class:auth<zef:vrurg>;

unit class DistributionStorage::Model::User;
  also is json( :implicit );

has UUID  $.id is json( :serializer( *.Str ), :deserializer( { UUID.new: .Str } ) );
has Str   $.username;
has Bool  $.is-admin = False;
