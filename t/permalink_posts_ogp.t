use strict;
use warnings;
use utf8;

use Test2::V0;

use Kalaclista::Test;
use Kalaclista::Path;

sub main {
  my $section = 'posts';
  my $entries = Kalaclista::Path->$section;

  while ( defined( my $entry = $entries->next ) ) {
    my $dom = Kalaclista::Test->parse_html( $entry->slurp );
    Kalaclista::Test->meta_ogp_ok( $dom, $section, 1 );
  }

  done_testing;
}

main;
