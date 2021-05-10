use strict;
use warnings;

use Test2::V0;
use HTML5::DOM;
use Path::Tiny::Glob;

use Kalaclista::Path;

my $parser = HTML5::DOM->new;

sub entries ($$$) {
  my ( $type, $glob, $fn ) = @_;
  return pathglob(
    [ Kalaclista::Path->build_dir->stringify, $type, $glob, $fn ] );
}

sub dom ($) {
  return $parser->parse(shift);
}

sub testing_header {
  my $dom = shift;

  # encoding
  is( $dom->at('meta[charset]')->getAttribute('charset'), 'utf-8' );

  # TODO
  like( $dom->at('link[rel="canonical"]')->getAttribute('href'),
    qr{^https://the.kalaclista.com/} );

  is(
    $dom->at('link[rel="manifest"]')->getAttribute('href'),
    'https://the.kalaclista.com/manifest.webmanifest'
  );

  # favicon
  is(
    $dom->at('link[rel="icon"]')->getAttribute('href'),
    'https://the.kalaclista.com/favicon.ico'
  );

  is( $dom->find('link[rel="icon"]')->[0]->getAttribute('href'),
    'https://the.kalaclista.com/favicon.ico' );

  is( $dom->find('link[rel="icon"]')->[1]->getAttribute('href'),
    'https://the.kalaclista.com/icon.svg' );

  is(
    $dom->at('link[rel="apple-touch-icon"]')->getAttribute('href'),
    'https://the.kalaclista.com/apple-touch-icon.png'
  );

  # preload
  is( $dom->at('meta[http-equiv]')->getAttribute('content'), 'on' );

  my @domains = (
    '//cdn.ampproject.org',            '//googleads.g.doubleclick.net',
    '//www.google-analytics.com',      '//stats.g.doubleclick.net',
    '//www.google.com',                '//www.google.co.jp',
    '//pagead2.googlesyndication.com', '//tpc.googlesyndication.com',
    '//accounts.google.com',           '//www.googletagmanager.com',
  );

  for my $idx ( 0 .. ( scalar(@domains) - 1 ) ) {
    is( $dom->find('link[rel*="preconnect"]')->[$idx]->getAttribute('href'),
      $domains[$idx] );
    is( $dom->find('link[rel*="dns-prefetch"]')->[$idx]->getAttribute('href'),
      $domains[$idx] );
  }

  my @preloads = (
    'https://cdn.ampproject.org/v0.js',
    'https://cdn.ampproject.org/v0/amp-ad-0.1.js',
    'https://cdn.ampproject.org/v0/amp-analytics-0.1.js',
  );

  for my $idx ( 0 .. ( scalar(@preloads) - 1 ) ) {
    is(
      $dom->find('link[rel="preload"][as="script"]')->[$idx]
        ->getAttribute('href'),
      $preloads[$idx]
    );

    is( $dom->find('script[async]')->[$idx]->getAttribute('src'),
      $preloads[$idx] );
  }
}

sub testing_posts () {
  my $entries = entries 'posts', '*/*/*/*', 'index.html';

  while ( defined( my $post = $entries->next ) ) {
    my $dom = dom $post->slurp;
    testing_header($dom);
  }
}

sub main {
  testing_posts;
  done_testing;
}

main;
