use Config;
use JSON::Fast;

unit module ContentStorage::Config;

sub config is export {

  Config.new(
    host => Str,
    port => UInt,
    storage => {
      id => Str,
    },
    api => {
      page-limit => UInt,
    },
    build => {
      test-command => Str,
    },
  ).read: from-json slurp 'config.json';

}

