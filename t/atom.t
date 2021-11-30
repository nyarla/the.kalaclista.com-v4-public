use strict;
use warnings;
use utf8;

use Test2::V0;
use XML::DOM::Lite qw(Parser XPath);

use Kalaclista::Path;
use Kalaclista::Test
  qw(relpath_is is_datetime is_entries is_posts is_notes is_echos);

sub atomfeed_ok {
  my ( $xml, $section ) = @_;

  ok( $xml->selectSingleNode('//feed/title')->firstChild->nodeValue );
  ok( $xml->selectSingleNode('//feed/subtitle')->firstChild->nodeValue );

  my $path = ( $section ne q{} ) ? '/' . $section . '' : '';

  relpath_is( $xml->selectNodes('//feed/link')->[0]->getAttribute('href'),
    $path . '/' );

  relpath_is( $xml->selectNodes('//feed/link')->[1]->getAttribute('href'),
    $path . '/atom.xml' );

  relpath_is( $xml->selectSingleNode('//feed/icon')->firstChild->nodeValue,
    '/assets/avatar.png' );

  is( $xml->selectSingleNode('//feed/author/name')->firstChild->nodeValue,
    'OKAMURA Naoki aka nyarla' );

  is( $xml->selectSingleNode('//feed/author/email')->firstChild->nodeValue,
    'nyarla@kalaclista.com' );

  relpath_is(
    $xml->selectSingleNode('//feed/author/uri')->firstChild->nodeValue,
    '/nyarla/' );

  my $entries = $xml->getElementsByTagName('entry');
  ok( $entries->length <= 5 );

  for my $entry ( $entries->@* ) {
    entry_ok( $entry, $section );
  }
}

sub entry_ok {
  my ( $xml, $section ) = @_;

  ok( $xml->getElementsByTagName('title')->[0]->firstChild->nodeValue );
  ok( $xml->getElementsByTagName('content')->[0]->firstChild->nodeValue );

  my $link = $xml->getElementsByTagName('link')->[0]->getAttribute('href');
  if ( $section eq q{} ) {
    is_entries($link);
  }
  else {
    if ( $section eq q{notes} ) {
      is_notes($link);
    }
    elsif ( $section eq q{posts} ) {
      is_posts($link);
    }
    elsif ( $section eq q{echos} ) {
      is_echos($link);
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

  relpath_is(
    $xml->getElementsByTagName('author')->[0]->getElementsByTagName('uri')->[0]
      ->firstChild->nodeValue,
    "/nyarla/"
  );

  is_datetime(
    $xml->getElementsByTagName('updated')->[0]->firstChild->nodeValue );
}

sub main {
  for my $section (qw[ posts echos notes ]) {
    my $feed = Kalaclista::Path->build_dir->child( $section, 'atom.xml' );
    my $xml  = Parser->parse( $feed->slurp );

    atomfeed_ok( $xml, $section );
  }

  my $feed = Kalaclista::Path->build_dir->child('atom.xml');
  my $xml  = Parser->parse( $feed->slurp );

  atomfeed_ok( $xml, q{} );

  done_testing;
}

main;
