use DB::Pg;

use distributions-storage-database;

unit class DistributionsStorage;

has DistributionsStorage::Database $!db handles <add-user get-user add-dist get-dists delete-dist>;


submethod BUILD( DB::Pg :$pg! ) {

  $!db = DistributionsStorage::Database.new: :$pg;
}
