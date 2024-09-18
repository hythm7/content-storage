use Config;
use JSON::Fast;

unit module ContentStorage::Config;

sub config is export {

  Config.new(
    storage => {
      name => Str,
      host => Str,
      port => UInt,
    },
    api => {
      page => {
        limit => UInt,
      },
    },
    build => {
      log => {
        color => Bool,
      },
      concurrent => {
        max => UInt,
      },
      test => {
        command => Str,
      },
    },
  ).read: from-json slurp 'config.json';

}

