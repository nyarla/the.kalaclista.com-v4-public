use strict;
use warnings;
use utf8;

use Test2::V0;
use Kalaclista::Test qw(parse description_ok ogp_ok twcard_ok);
use Kalaclista::Path;

sub main {
  my $entries = Kalaclista::Path->notes;

  while ( defined( my $entry = $entries->next ) ) {
    my $dom = parse( $entry->slurp );

    description_ok($dom);
    ogp_ok($dom);
    twcard_ok($dom);
  }

  done_testing;
}

main;
