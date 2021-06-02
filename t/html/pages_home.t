use strict;
use warnings;
use utf8;

use HTML5::DOM;
use Test2::V0;

use Kalaclista::Path;

sub main {
  my $parser = HTML5::DOM->new;
  my $home   = Kalaclista::Path->build_dir->child('index.html');
  my $dom    = $parser->parse( $home->slurp );

  is( $dom->at('.entry__content p:first-child a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/' );

  my $nodes = $dom->find('hr + strong a');
  is( $nodes->[0]->getAttribute('href'), 'https://the.kalaclista.com/posts/' );
  is( $nodes->[1]->getAttribute('href'), 'https://the.kalaclista.com/echos/' );
  is( $nodes->[2]->getAttribute('href'), 'https://the.kalaclista.com/notes/' );

  my $lists = $dom->find('dl dd ul');

  for my $item ( $lists->[0]->find('li a')->@* ) {
    like( $item->getAttribute('href'),
      qr(^https://the.kalaclista.com/posts/\d{4}/\d{2}/\d{2}/\d{6}/) );
  }

  for my $item ( $lists->[1]->find('li a')->@* ) {
    like( $item->getAttribute('href'),
      qr(^https://the.kalaclista.com/echos/\d{4}/\d{2}/\d{2}/\d{6}/) );
  }

  for my $item ( $lists->[2]->find('li a')->@* ) {
    like( $item->getAttribute('href'),
      qr(^https://the.kalaclista.com/notes/[^/]+/) );
  }

  done_testing;
}

main;
