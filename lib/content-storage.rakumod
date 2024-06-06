unit module ContentStorage;

sub identity ( Str:D :$name!, Str:D :$version!, Str:D :$auth!, Any :$api! --> Str:D ) is export {

  "$auth:{ $name.subst( '::', '-', :g ) }:$version:{ $api if $api }";
      
}

subset UUID is export of Str where /^
  <[0..9 a..f A..F]> ** 8 "-"
  [ <[0..9 a..f A..F]> ** 4 "-" ] ** 2
  <[8 9 a b A B]><[0..9 a..f A..F]> ** 3 "-"
  <[0..9 a..f A..F]> ** 12
$/;

