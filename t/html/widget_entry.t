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

        like( $dom->at('.entry header p time')->getAttribute('datetime'),
          qr(\d{4}-\d{2}-\d{2}) );

        like( $dom->at('.entry header p time')->textContent(),
          qr(\d{4}-\d{2}-\d{2}) );

        is( $dom->at('.entry header p span a')->getAttribute('href'),
          'https://the.kalaclista.com/nyarla/' );

        is( $dom->at('.entry header p span a')->textContent(), '@nyarla' );

        like(
          $dom->at('.entry header h1 a')->getAttribute('href'),
          qr{^https://the.kalaclista.com/${section}/}
        );

        ok( scalar( $dom->find('.entry__ad')->@* ) == 2 );

        ok( $dom->at('.entry__content') );
      }
    }
  }

  done_testing;
}

main;
