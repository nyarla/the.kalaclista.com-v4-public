use strict;
use warnings;
use utf8;

use Test2::V0;
use Kalaclista::Test qw[
  parse

  archive_ok
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
  for my $section (qw<posts echos notes>) {
    for my $page ( 2006 .. ( (localtime)[5] + 1900 ) ) {
      my $entry = Kalaclista::Path->build_dir->path(
        $section . '/' . $page . '/index.html' );

      next if ( !$entry->is_file );

      my $dom = parse( $entry->slurp );

      archive_ok( $dom, $section );
      footer_ok($dom);
      header_ok($dom);

      description_ok($dom);
      ogp_ok($dom);
      twcard_ok($dom);

      feeds_ok( $dom, $section );
      icons_ok($dom);
      manifest_ok($dom);
      preload_ok($dom);
      utf8_ok($dom);

      jsonld_ok( $dom, $section );
    }
  }
  done_testing;
}

main;
