use strict;
use warnings;
use utf8;

use Test2::V0;
use XML::DOM::Lite qw(Parser);

use Kalaclista::Path;
use Kalaclista::Test qw(is_datetime is_pages);

sub main {
  my $file = Kalaclista::Path->build_dir->child('sitemap.xml');
  my $xml  = Parser->parse( $file->slurp );

  for my $node ( $xml->getElementsByTagName('url')->@* ) {
    is_pages( $node->getElementsByTagName('loc')->[0]->firstChild->nodeValue );
    is_datetime(
      $node->getElementsByTagName('lastmod')->[0]->firstChild->nodeValue );
  }

  done_testing;
}

main;
