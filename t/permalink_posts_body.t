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
    Kalaclista::Test->header_links_ok( $dom, $section );
    Kalaclista::Test->entry_structure_ok( $dom, $section );
    Kalaclista::Test->footer_links_ok($dom);
  }

  done_testing;
}

main;
