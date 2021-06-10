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
    Kalaclista::Test->meta_utf8_ok($dom);
    Kalaclista::Test->meta_icons_ok($dom);
    Kalaclista::Test->meta_manifest_ok($dom);

    Kalaclista::Test->meta_canonical_ok( $dom,
      Kalaclista::Path->build_dir->stringify,
      $entry->stringify );

    Kalaclista::Test->meta_twittercard_ok($dom);
    Kalaclista::Test->meta_jsonld_ok( $dom, $section, 1 );
  }

  done_testing;
}

main;
