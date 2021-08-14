use strict;
use warnings;
use utf8;

use Test2::V0;

use Kalaclista::Test;
use Kalaclista::Path;

sub main {
  for my $section (qw(posts echos notes)) {
    my $entries = Kalaclista::Path->$section;
    while ( defined( my $entry = $entries->next ) ) {
      my $dom = Kalaclista::Test->parse_html( $entry->slurp );

      my $related = $dom->find('.entry__related .entry__content ul li');

      ok( scalar( $related->@* ) <= 6 );

      for my $item ( $related->@* ) {
        like( $item->at('time')->getAttribute('datetime'),
          qr{^\d{4}-\d{2}-\d{2}} );
        like( $item->at('time')->textContent, qr{^\d{4}-\d{2}-\d{2}} );

        like(
          $item->at('a')->getAttribute('href'),
qr<^https://the.kalaclista.com/[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/)$>,
        );
      }
    }
  }

  done_testing;
}

main;
