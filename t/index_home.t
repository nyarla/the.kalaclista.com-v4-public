use strict;
use warnings;
use utf8;

use Test2::V0;

use Kalaclista::Test;
use Kalaclista::Path;

sub main {
  my $home = Kalaclista::Path->build_dir->child('index.html');
  my $dom  = Kalaclista::Test->parse_html( $home->slurp );

  Kalaclista::Test->header_links_ok( $dom, 'home' );
  Kalaclista::Test->footer_links_ok($dom);

  Kalaclista::Test->meta_utf8_ok($dom);
  Kalaclista::Test->meta_canonical_ok( $dom,
    Kalaclista::Path->build_dir->stringify,
    $home->stringify );
  Kalaclista::Test->meta_icons_ok($dom);
  Kalaclista::Test->meta_manifest_ok($dom);
  Kalaclista::Test->meta_preload_scripts_ok($dom);

  Kalaclista::Test->meta_ogp_ok( $dom, 'home', 0 );
  Kalaclista::Test->meta_twittercard_ok($dom);
  Kalaclista::Test->meta_jsonld_ok( $dom, 'home', 0 );

  is( $dom->at('.entry__content p:first-child a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/' );

  my $nodes = $dom->find('hr + strong a');
  is( $nodes->[0]->getAttribute('href'), 'https://the.kalaclista.com/posts/' );
  is( $nodes->[1]->getAttribute('href'), 'https://the.kalaclista.com/echos/' );
  is( $nodes->[2]->getAttribute('href'), 'https://the.kalaclista.com/notes/' );

  my $lists = $dom->find('dl dd ul');

  for my $item ( $lists->[0]->find('li a')->@* ) {
    like( $item->getAttribute('href'),
      qr(^https://the.kalaclista.com/posts/\d{4}/\d{2}/\d{2}/\d{6}/) );
  }

  for my $item ( $lists->[1]->find('li a')->@* ) {
    like( $item->getAttribute('href'),
      qr(^https://the.kalaclista.com/echos/\d{4}/\d{2}/\d{2}/\d{6}/) );
  }

  for my $item ( $lists->[2]->find('li a')->@* ) {
    like( $item->getAttribute('href'),
      qr(^https://the.kalaclista.com/notes/[^/]+/) );
  }

  done_testing;
}

main;
