use strict;
use warnings;
use utf8;

use Test2::V0;

use Kalaclista::Test qw(
  parse

  description_ok
  icons_ok
  manifest_ok
  ogp_ok
  preload_ok
  twcard_ok
  utf8_ok

  footer_ok
  header_ok

  title_is
);

use Kalaclista::Path;

sub main {
  my $page = Kalaclista::Path->build_dir->child('404.html');
  my $dom  = parse( $page->slurp );

  description_ok($dom);
  icons_ok($dom);
  manifest_ok($dom);
  ogp_ok($dom);
  preload_ok($dom);
  twcard_ok($dom);
  utf8_ok($dom);

  footer_ok($dom);
  header_ok($dom);

  title_is( $dom, "404 page not found - カラクリスタ" );

  done_testing;
}

main;
