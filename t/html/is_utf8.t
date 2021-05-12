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
        is( $dom->at('meta[charset]')->getAttribute('charset'), 'utf-8' );
      }
    }
  }

  done_testing;
}

main;
