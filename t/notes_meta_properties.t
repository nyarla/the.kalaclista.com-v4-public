use strict;
use warnings;
use utf8;

use Test2::V0;
use Kalaclista::Test qw(parse utf8_ok preload_ok icons_ok manifest_ok feeds_ok);
use Kalaclista::Path;

sub main {
  my $entries = Kalaclista::Path->notes;

  while ( defined( my $entry = $entries->next ) ) {
    my $dom = parse( $entry->slurp );

    feeds_ok( $dom, q{notes} );
    icons_ok($dom);
    manifest_ok($dom);
    preload_ok($dom);
    utf8_ok($dom);
  }

  done_testing;
}

main;
