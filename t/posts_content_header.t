use strict;
use warnings;
use utf8;

use Test2::V0;
use Kalaclista::Test qw(parse header_ok);
use Kalaclista::Path;

sub main {
  my $entries = Kalaclista::Path->posts;

  while ( defined( my $entry = $entries->next ) ) {
    my $dom = parse( $entry->slurp );
    header_ok($dom);
  }

  done_testing;
}

main;
