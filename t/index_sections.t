use strict;
use warnings;
use utf8;

use Test2::V0;

use Kalaclista::Test;
use Kalaclista::Path;

sub main {
  for my $section (qw< posts echos notes >) {
    my $path = Kalaclista::Path->build_dir->child("${section}/index.html");
    my $dom  = Kalaclista::Test->parse_html( $path->slurp );

    Kalaclista::Test->header_links_ok( $dom, $section );
    Kalaclista::Test->footer_links_ok($dom);
    Kalaclista::Test->meta_utf8_ok($dom);
    Kalaclista::Test->meta_icons_ok($dom);
    Kalaclista::Test->meta_manifest_ok($dom);
    Kalaclista::Test->meta_preload_scripts_ok($dom);

    Kalaclista::Test->meta_canonical_ok( $dom,
      Kalaclista::Path->build_dir->stringify,
      $path->stringify );

    Kalaclista::Test->meta_ogp_ok( $dom, $section, 0 );
    Kalaclista::Test->meta_twittercard_ok($dom);
    Kalaclista::Test->meta_jsonld_ok( $dom, $section, 0 );

    is(
      $dom->at('header h1 a')->getAttribute('href'),
      "https://the.kalaclista.com/${section}/"
    );

    for my $item ( $dom->find('entry entry__content ul li a')->@* ) {
      if ( $section ne 'notes' ) {
        like( $item->getAttribute('href'),
          qr(^https://the.kalaclista.com/${section}/\d{4}/\d{2}/\d{2}/\d{6}/$)
        );
      }
      else {
        like( $item->getAttribute('href'),
          qr(^https://the.kalaclista.com/${section}/[^/]+/$) );
      }
    }
  }

  done_testing;
}

main;
