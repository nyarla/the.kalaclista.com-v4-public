use strict;
use warnings;
use utf8;

use Test2::V0;
use Kalaclista::Test qw(parse related_ok);
use Kalaclista::Path;

sub main {
  my $entries = Kalaclista::Path->echos;

  while ( defined( my $entry = $entries->next ) ) {
    my $dom = parse( $entry->slurp );
    related_ok($dom);
  }

  done_testing;
}

main;