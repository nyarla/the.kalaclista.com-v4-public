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

        is( $dom->at('meta[http-equiv]')->getAttribute('content'), 'on',
          $path );

        my @domains = (
          '//cdn.ampproject.org',            '//googleads.g.doubleclick.net',
          '//www.google-analytics.com',      '//stats.g.doubleclick.net',
          '//www.google.com',                '//www.google.co.jp',
          '//pagead2.googlesyndication.com', '//tpc.googlesyndication.com',
          '//accounts.google.com',           '//www.googletagmanager.com',
        );

        my $preConnect  = $dom->find('link[rel*="preconnect"]');
        my $dnsPrefetch = $dom->find('link[rel*="dns-prefetch"]');

        for my $idx ( 0 .. ( scalar(@domains) - 1 ) ) {
          is( $preConnect->[$idx]->getAttribute('href'), $domains[$idx],
            $path );
          is( $dnsPrefetch->[$idx]->getAttribute('href'),
            $domains[$idx], $path );
        }

        my @preloads = (
          'https://cdn.ampproject.org/v0.js',
          'https://cdn.ampproject.org/v0/amp-ad-0.1.js',
          'https://cdn.ampproject.org/v0/amp-analytics-0.1.js',
        );

        my $preload     = $dom->find('link[rel="preload"][as="script"]');
        my $scriptAsync = $dom->find('script[async]');

        for my $idx ( 0 .. ( scalar(@preloads) - 1 ) ) {
          is( $preload->[$idx]->getAttribute('href'), $preloads[$idx], $path );
          is( $scriptAsync->[$idx]->getAttribute('src'),
            $preloads[$idx], $path );
        }
      }
    }
  }

  done_testing;
}

main;
