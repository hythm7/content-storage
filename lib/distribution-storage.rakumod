unit module DistributionStorage;

subset UUID is export of Str where /^
  <[0..9 a..f A..F]> ** 8 "-"
  [ <[0..9 a..f A..F]> ** 4 "-" ] ** 2
  <[8 9 a b A B]><[0..9 a..f A..F]> ** 3 "-"
  <[0..9 a..f A..F]> ** 12
$/;

