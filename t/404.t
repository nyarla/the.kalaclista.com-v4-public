use strict;
use warnings;
use utf8;

use Test2::V0;

use Kalaclista::Test;
use Kalaclista::Path;

sub testing_metadata {
  my $dom = shift;

  my $title = $dom->at('title')->textContent;
  utf8::decode($title);

  is( $title, "404 page not found - カラクリスタ" );

  is(
    $dom->at('meta[name="description"]')->getAttribute('content'),
    $dom->at('meta[property="og:description"]')->getAttribute('content')
  );

  is(
    $dom->at('meta[property="og:profile:first_name"]')->getAttribute('content'),
    'Naoki'
  );

  is(
    $dom->at('meta[property="og:profile:last_name"]')->getAttribute('content'),
    'OKAMURA'
  );

  is( $dom->at('meta[property="og:profile:username"]')->getAttribute('content'),
    'kalaclista' );
}

sub main {
  my $page = Kalaclista::Path->build_dir->child('404.html');
  my $dom  = Kalaclista::Test->parse_html( $page->slurp );

  Kalaclista::Test->meta_utf8_ok($dom);
  Kalaclista::Test->meta_icons_ok($dom);
  Kalaclista::Test->meta_manifest_ok($dom);
  Kalaclista::Test->meta_preload_scripts_ok($dom);
  Kalaclista::Test->meta_twittercard_ok($dom);

  Kalaclista::Test->header_links_ok( $dom, q{home} );
  Kalaclista::Test->footer_links_ok($dom);

  testing_metadata($dom);

  done_testing;
}

main;
