use strict;
use warnings;
use utf8;

use Test2::V0;
use XML::DOM::Lite qw(Parser);

use Kalaclista::Path;
use Kalaclista::Test qw(relpath_is is_entries is_notes is_posts is_echos);

sub testing_feed {
  my ( $xml, $section ) = @_;

  ok( $xml->selectSingleNode('//rss/channel/title')->firstChild->nodeValue );
  ok( $xml->selectSingleNode('//rss/channel/description')
      ->firstChild->nodeValue );

  is(
    $xml->selectSingleNode('//rss/channel/managingEditor')
      ->firstChild->nodeValue,
    $xml->selectSingleNode('//rss/channel/webMaster')->firstChild->nodeValue
  );

  is( $xml->selectSingleNode('//rss/channel/copyright')->firstChild->nodeValue,
    '(c) 2006-2021 OKAMURA Naoki' );

  is(
    $xml->selectSingleNode('//rss/channel/link')->firstChild->nodeValue,
    $xml->selectSingleNode('//rss/channel/atom:link')->getAttribute('href'),
  );

  if ( $section eq q{} ) {
    relpath_is(
      $xml->selectSingleNode('//rss/channel/link')->firstChild->nodeValue,
      '/', );
    relpath_is(
      $xml->selectSingleNode('//rss/channel/atom:link[@rel="self"]')
        ->getAttribute('href'),
      '/index.xml'
    );
  }
  else {
    relpath_is(
      $xml->selectSingleNode('//rss/channel/link')->firstChild->nodeValue,
      '/' . $section . '/',
    );
    relpath_is(
      $xml->selectSingleNode('//rss/channel/atom:link[@rel="self"]')
        ->getAttribute('href'),
      '/' . $section . '/index.xml',
    );
  }

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

  ok( $xml->selectSingleNode('//title')->firstChild->nodeValue );
  ok( $xml->selectSingleNode('//link')->firstChild->nodeValue );

  like(
    $xml->selectSingleNode('//pubDate')->firstChild->nodeValue,
    qr<[^ ]+?, \d{2} [^ ]+? \d{4} \d{2}:\d{2}:\d{2} [-+]\d{4}>
  );

  is(
    $xml->selectSingleNode('//author')->firstChild->nodeValue,
    'nyarla@kalaclista.com (OKAMURA Naoki aka nyarla)'
  );

  is(
    $xml->selectSingleNode('//link')->firstChild->nodeValue,
    $xml->selectSingleNode('//guid')->firstChild->nodeValue,
  );

  if ( $section eq q{} ) {
    is_entries( $xml->selectSingleNode('//link')->firstChild->nodeValue );
  }
  elsif ( $section eq q{posts} ) {
    is_posts( $xml->selectSingleNode('//link')->firstChild->nodeValue );
  }
  elsif ( $section eq q{echos} ) {
    is_echos( $xml->selectSingleNode('//link')->firstChild->nodeValue );
  }
  elsif ( $section eq q{notes} ) {
    is_notes( $xml->selectSingleNode('//link')->firstChild->nodeValue );
  }
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
