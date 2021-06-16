use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Path;

my $parser = HTML5::DOM->new( { ignore_doctype => 1 } );

sub main {
  my $xml = Kalaclista::Path->build_dir->child('sitemap.xml');
  my $dom = $parser->parse( $xml->slurp );

  for my $url ( $dom->find('urlset > url')->@* ) {
    like(
      $url->at('loc')->textContent,
qr<^https://the.kalaclista.com/(?:(?:nyarla|policies|licenses)/|[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/))$>,
    );

    like( $url->at('lastmod')->textContent,
      qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$> );
  }

  done_testing;
}

main;
