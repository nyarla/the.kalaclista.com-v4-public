use strict;
use warnings;
use utf8;

use HTML5::DOM;
use Test2::V0;

use Kalaclista::Path;

sub main {
  my $parser = HTML5::DOM->new;

  for my $section (qw( posts echos notes )) {
    for my $entries ( Kalaclista::Path->$section() ) {
      while ( defined( my $entry = $entries->next ) ) {
        my $path = $entry->stringify;
        utf8::decode($path);

        my $dom = $parser->parse( $entry->slurp );

        is( $dom->at('link[rel="icon"]')->getAttribute('href'),
          'https://the.kalaclista.com/favicon.ico', $path );

        my $icons = $dom->find('link[rel="icon"]');

        is( $icons->[0]->getAttribute('href'),
          'https://the.kalaclista.com/favicon.ico', $path );

        is( $icons->[1]->getAttribute('href'),
          'https://the.kalaclista.com/icon.svg', $path );

        is( $dom->at('link[rel="apple-touch-icon"]')->getAttribute('href'),
          'https://the.kalaclista.com/apple-touch-icon.png', $path );
      }
    }
  }

  done_testing;
}

main;
