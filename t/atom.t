use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;

use Kalaclista::Path;

my $parser = HTML5::DOM->new( { ignore_doctype => 1 } );

sub testing_feed {
  my ( $dom, $section ) = @_;

  ok( $dom->at('feed title') );
  ok( $dom->at('feed summary') );

  my $URI = "https://the.kalaclista.com";

  if ( $section ne q{} ) {
    $URI = "${URI}/${section}";
  }

  is( $dom->find('feed > link')->[0]->getAttribute('href'), "${URI}/", );
  is( $dom->find('feed > link')->[1]->getAttribute('href'),
    "${URI}/atom.xml", );

  is( $dom->at('feed > id')->textContent, "${URI}/" );

  is(
    $dom->at('feed > icon')->textContent,
    "https://the.kalaclista.com/assets/avatar.png"
  );

  is( $dom->at('feed > author > name')->textContent,
    "OKAMURA Naoki aka nyarla" );

  is( $dom->at('feed > author > email')->textContent, 'nyarla@kalaclista.com' );

  is(
    $dom->at('feed > author > uri')->textContent,
    'https://the.kalaclista.com/nyarla/'
  );

  my $entries = $dom->find('feed > entry');

  is( scalar( $entries->@* ), 5 );

  for my $entry ( $entries->@* ) {
    testing_entry( $entry, $section );
  }
}

sub testing_entry {
  my ( $entry, $section ) = @_;
  ok( $entry->at('title') );
  ok( $entry->at('content') );

  if ( $section eq q{} ) {
    like(
      $entry->at('link')->getAttribute('href'),
qr<^https://the.kalaclista.com/[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/)$>,
    );
  }
  else {
    if ( $section ne 'notes' ) {
      like( $entry->at('link')->getAttribute('href'),
        qr<^https://the.kalaclista.com/${section}/\d{4}/\d{2}/\d{2}/\d{6}/$> );
    }
    else {
      like(
        $entry->at('link')->getAttribute('href'),
        qr<^https://the.kalaclista.com/${section}/[^/]+/$>
      );
    }
  }

  is( $entry->at('author > name')->textContent, "OKAMURA Naoki aka nyarla" );

  is( $entry->at('author > email')->textContent, 'nyarla@kalaclista.com' );

  is(
    $entry->at('author > uri')->textContent,
    'https://the.kalaclista.com/nyarla/'
  );

  like( $entry->at('published')->textContent,
    qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$> );
  like( $entry->at('lastmod')->textContent,
    qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$> );

}

sub main {
  for my $section (qw[ posts echos notes ]) {
    my $feed = Kalaclista::Path->build_dir->child( $section, 'atom.xml' );
    my $dom  = $parser->parse( $feed->slurp );

    testing_feed( $dom, $section );
  }

  my $feed = Kalaclista::Path->build_dir->child('atom.xml');
  my $dom  = $parser->parse( $feed->slurp );

  testing_feed( $dom, q{} );

  done_testing;
}

main;
