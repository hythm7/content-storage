unit class ContentStorage::Pager;

has UInt:D $.total is required;
has UInt:D $.page  is required;

has UInt   $.limit;


method limit  ( --> UInt ) { $!limit }

method offset ( --> UInt ) { $!limit ?? ( $!page - 1 ) * $!limit !! UInt }

method pages ( --> UInt:D ) { $!limit ?? ( $!total - 1 ) div $!limit + 1 !! 1 }

method first    ( --> UInt:D ) { 1 }

method previous ( --> UInt:D ) { $!page > 1 ?? $!page - 1 !! $!page }

method current  ( --> UInt:D ) { $!page }

method next     ( --> UInt:D ) { $!page < self.last ?? $!page + 1 !! $!page }

method last     ( --> UInt:D ) { max 1, self.pages }
