use strict;
use warnings;
use utf8;

use Test2::V0;
use XML::DOM::Lite qw(Parser XPath);

use Kalaclista::Path;

sub testing_feed {
  my ( $xml, $section ) = @_;

  ok( $xml->selectSingleNode('//feed/title')->firstChild->nodeValue );
  ok( $xml->selectSingleNode('//feed/summary')->firstChild->nodeValue );

  my $URI = "https://the.kalaclista.com";

  if ( $section ne q{} ) {
    $URI = "${URI}/${section}";
  }

  is( $xml->selectNodes('//feed/link')->[0]->getAttribute('href'), "${URI}/" );
  is( $xml->selectNodes('//feed/link')->[1]->getAttribute('href'),
    "${URI}/atom.xml", );

  is( $xml->selectSingleNode('//feed/icon')->firstChild->nodeValue,
    "https://the.kalaclista.com/assets/avatar.png" );

  is( $xml->selectSingleNode('//feed/author/name')->firstChild->nodeValue,
    "OKAMURA Naoki aka nyarla" );

  is( $xml->selectSingleNode('//feed/author/email')->firstChild->nodeValue,
    'nyarla@kalaclista.com' );

  is( $xml->selectSingleNode('//feed/author/uri')->firstChild->nodeValue,
    'https://the.kalaclista.com/nyarla/' );

  my $entries = $xml->getElementsByTagName('entry');

  ok( $entries->length <= 5 );

  for my $entry ( $entries->@* ) {
    testing_entry( $entry, $section );
  }
}

sub testing_entry {
  my ( $xml, $section ) = @_;

  ok( $xml->getElementsByTagName('title')->[0]->firstChild->nodeValue );
  ok( $xml->getElementsByTagName('content')->[0]->firstChild->nodeValue );

  if ( $section eq q{} ) {
    like(
      $xml->getElementsByTagName('link')->[0]->getAttribute('href'),
qr<^https://the.kalaclista.com/[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/)$>,
    );
  }
  else {
    if ( $section ne 'notes' ) {
      like(
        $xml->getElementsByTagName('link')->[0]->getAttribute('href'),
        qr<^https://the.kalaclista.com/${section}/\d{4}/\d{2}/\d{2}/\d{6}/$>
      );
    }
    else {
      like(
        $xml->getElementsByTagName('link')->[0]->getAttribute('href'),
        qr<^https://the.kalaclista.com/${section}/[^/]+/$>
      );
    }
  }

  is(
    $xml->getElementsByTagName('author')->[0]->getElementsByTagName('name')
      ->[0]->firstChild->nodeValue,
    "OKAMURA Naoki aka nyarla"
  );
  is(
    $xml->getElementsByTagName('author')->[0]->getElementsByTagName('email')
      ->[0]->firstChild->nodeValue,
    'nyarla@kalaclista.com'
  );
  is(
    $xml->getElementsByTagName('author')->[0]->getElementsByTagName('uri')->[0]
      ->firstChild->nodeValue,
    "https://the.kalaclista.com/nyarla/"
  );

  like(
    $xml->getElementsByTagName('published')->[0]->firstChild->nodeValue,
    qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$>
  );
  like(
    $xml->getElementsByTagName('lastmod')->[0]->firstChild->nodeValue,
    qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$>
  );

}

sub main {
  for my $section (qw[ posts echos notes ]) {
    my $feed = Kalaclista::Path->build_dir->child( $section, 'atom.xml' );
    my $xml  = Parser->parse( $feed->slurp );

    testing_feed( $xml, $section );
  }

  my $feed = Kalaclista::Path->build_dir->child('atom.xml');
  my $xml  = Parser->parse( $feed->slurp );

  testing_feed( $xml, q{} );

  done_testing;
}

main;
