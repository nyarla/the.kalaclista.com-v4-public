use strict;
use warnings;
use utf8;

use Test2::V0;
use XML::DOM::Lite qw(Parser);

use Kalaclista::Path;

sub main {
  my $file = Kalaclista::Path->build_dir->child('sitemap.xml');
  my $xml  = Parser->parse( $file->slurp );

  for my $node ( $xml->getElementsByTagName('url')->@* ) {
    like(
      $node->getElementsByTagName('loc')->[0]->firstChild->nodeValue,
qr<^https://the.kalaclista.com/(?:(?:nyarla|policies|licenses)/|[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/))$>,
    );

    like( $node->getElementsByTagName('lastmod')->[0]->firstChild->nodeValue,
      , qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$> );
  }

  done_testing;
}

main;
