unit module ContentStorage;

sub identity ( Str:D :$name!, Any :$version!, Any :$auth!, Any :$api! --> Str:D ) is export {

  "$auth:$name:$version:$api";
      
}

subset UUID is export of Str where /^
  <[0..9 a..f A..F]> ** 8 "-"
  [ <[0..9 a..f A..F]> ** 4 "-" ] ** 2
  <[8 9 a b A B]><[0..9 a..f A..F]> ** 3 "-"
  <[0..9 a..f A..F]> ** 12
$/;

# TODO: use better regex
subset Identity is export of Str where / ^ [ <-[ : ]>* ]+ %% ":" $ /;

