use strict;
use warnings;
use utf8;

use Test2::V0;
use Kalaclista::Test qw[
  parse

  entry_ok
  footer_ok
  header_ok

  description_ok
  ogp_ok
  twcard_ok

  feeds_ok
  icons_ok
  manifest_ok
  preload_ok
  utf8_ok

  jsonld_ok
];
use Kalaclista::Path;

sub main {
  for my $page (qw<nyarla policies licenses>) {
    my $entry = Kalaclista::Path->build_dir->path( $page . '/index.html' );
    my $dom   = parse( $entry->slurp );

    entry_ok($dom);
    footer_ok($dom);
    header_ok($dom);

    description_ok($dom);
    ogp_ok($dom);
    twcard_ok($dom);

    feeds_ok( $dom, q{} );
    icons_ok($dom);
    manifest_ok($dom);
    preload_ok($dom);
    utf8_ok($dom);

    jsonld_ok( $dom, q{} );
  }

  done_testing;
}

main;
