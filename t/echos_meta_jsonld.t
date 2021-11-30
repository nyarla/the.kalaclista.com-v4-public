use strict;
use warnings;
use utf8;

use Test2::V0;
use Kalaclista::Test qw(parse jsonld_ok);
use Kalaclista::Path;

sub main {
  my $entries = Kalaclista::Path->echos;

  while ( defined( my $entry = $entries->next ) ) {
    my $dom = parse( $entry->slurp );
    jsonld_ok( $dom, q{echos} );
  }

  done_testing;
}

main;
