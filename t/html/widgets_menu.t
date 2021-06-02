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

        is( $dom->at('#website__name strong a')->getAttribute('href'),
          'https://the.kalaclista.com/' );

        is( $dom->at('#website__contents em a')->getAttribute('href'),
          "https://the.kalaclista.com/${section}/" );

        is(
          $dom->at('#website__contents *:nth-child(1) a')->getAttribute('href'),
          "https://the.kalaclista.com/posts/",
        );

        is(
          $dom->at('#website__contents *:nth-child(2) a')->getAttribute('href'),
          "https://the.kalaclista.com/echos/",
        );

        is(
          $dom->at('#website__contents *:nth-child(3) a')->getAttribute('href'),
          "https://the.kalaclista.com/notes/",
        );
      }
    }
  }

  done_testing;
}

main;
