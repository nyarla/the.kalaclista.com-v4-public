use strict;
use warnings;
use utf8;

use HTML5::DOM;
use Test2::V0;

use Kalaclista::Path;

sub main {
  my $parser = HTML5::DOM->new;

  for my $section (qw( posts echos notes )) {
    my $file = Kalaclista::Path->build_dir->child("${section}/index.html");
    my $dom  = $parser->parse( $file->slurp );

    is(
      $dom->at('header h1 a')->getAttribute('href'),
      "https://the.kalaclista.com/${section}/"
    );

    for my $item ( $dom->find('entry entry__content ul li a')->@* ) {
      if ( $section ne 'notes' ) {
        like( $item->getAttribute('href'),
          qr(https://the.kalaclista.com/${section}/\d{4}/\d{2}/\d{2}/\d{6}/) );
      }
      else {
        like( $item->getAttribute('href'),
          qr(https://the.kalaclista.com/${section}/[^/]+/) );
      }
    }
  }

  done_testing;
}

main;
