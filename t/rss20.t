use strict;
use warnings;
use utf8;

use Test2::V0;
use XML::DOM::Lite qw(Parser);

use Kalaclista::Path;

sub testing_feed {
  my ( $xml, $section ) = @_;

  ok( $xml->selectSingleNode('//rss/channel/title')->firstChild->nodeValue );
  ok( $xml->selectSingleNode('//rss/channel/description')
      ->firstChild->nodeValue );

  my $URI = "https://the.kalaclista.com";

  if ( $section ne q{} ) {
    $URI = "${URI}/${section}";
  }

  is( $xml->selectSingleNode('//rss/channel/link')->firstChild->nodeValue,
    "${URI}/" );

  is( $xml->selectSingleNode('//rss/channel/atom:link')->getAttribute('href'),
    "${URI}/index.xml" );

  is( $xml->selectSingleNode('//rss/channel/atom:link')->getAttribute('type'),
    "application/rss+xml" );

  is(
    $xml->selectSingleNode('//rss/channel/managingEditor')
      ->firstChild->nodeValue,
    "OKAMURA Naoki aka nyarla"
  );

  is( $xml->selectSingleNode('//rss/channel/webMaster')->firstChild->nodeValue,
    "OKAMURA Naoki aka nyarla" );

  is( $xml->selectSingleNode('//rss/channel/copyright')->firstChild->nodeValue,
    "(c) 2006-2021 OKAMURA Naoki" );

  like(
    $xml->selectSingleNode('//rss/channel/lastBuildDate')
      ->firstChild->nodeValue,
    qr<[^ ]+?, \d{2} [^ ]+? \d{4} \d{2}:\d{2}:\d{2} [-+]\d{4}>
  );

  my $entries = $xml->getElementsByTagName('entry');
  ok( $entries->length <= 5 );

  for my $entry ( $entries->@* ) {
    testing_entry( $entry, $section );
  }
}

sub testing_entry {
  my ( $xml, $section ) = @_;

  ok( $xml->getElementsByTagName('title')->[0]->firstChild->nodeValue );
  ok( $xml->getElementsByTagName('description')->[0]->firstChild->nodeValue );

  is( $xml->getElementsByTagName('author')->[0]->firstChild->nodeValue,
    'OKAMURA Naoki aka nyarla nyarla@kalaclista.com' );

  like(
    $xml->getElementsByTagName('pubDate')->[0]->firstChild->nodeValue,
    qr<[^ ]+?, \d{2} [^ ]+? \d{4} \d{2}:\d{2}:\d{2} [-+]\d{4}>
  );

  if ( $section eq q{} ) {
    like(
      $xml->getElementsByTagName('link')->[0]->firstChild->nodeValue,
qr<^https://the.kalaclista.com/[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/)$>,
    );
  }
  else {
    if ( $section ne 'notes' ) {
      like(
        $xml->getElementsByTagName('link')->[0]->firstChild->nodeValue,
        qr<^https://the.kalaclista.com/${section}/\d{4}/\d{2}/\d{2}/\d{6}/$>
      );
    }
    else {
      like(
        $xml->getElementsByTagName('link')->[0]->firstChild->nodeValue,
        qr<^https://the.kalaclista.com/${section}/[^/]+/$>
      );
    }
  }

  is(
    $xml->getElementsByTagName('link')->[0]->firstChild->nodeValue,
    $xml->getElementsByTagName('guid')->[0]->firstChild->nodeValue
  );
}

sub main {
  for my $section (qw[ posts echos notes ]) {
    my $feed = Kalaclista::Path->build_dir->child( $section, 'index.xml' );
    my $xml  = Parser->parse( $feed->slurp );

    testing_feed( $xml, $section );
  }

  my $feed = Kalaclista::Path->build_dir->child('index.xml');
  my $xml  = Parser->parse( $feed->slurp );

  testing_feed( $xml, q{} );

  done_testing;
}

main;
