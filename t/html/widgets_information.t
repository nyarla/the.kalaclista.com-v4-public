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

        is(
          $dom->at('#website__informations *:first-child span a')
            ->getAttribute('href'),
'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0'
        );

        is(
          $dom->at('#website__informations *:last-child *:nth-child(1) a')
            ->getAttribute('href'),
          "https://the.kalaclista.com/nyarla/",
        );

        is(
          $dom->at('#website__informations *:last-child *:nth-child(2) a')
            ->getAttribute('href'),
          "https://the.kalaclista.com/policies/",
        );

        is(
          $dom->at('#website__informations *:last-child *:nth-child(3) a')
            ->getAttribute('href'),
          "https://the.kalaclista.com/licenses/",
        );
      }
    }
  }

  done_testing;
}

main;
