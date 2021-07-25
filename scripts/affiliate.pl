#!/usr/bin/env perl

use strict;
use warnings;

use HTML5::DOM;
use URI;
use URI::QueryParam;
use URI::Escape;

my $parser = HTML5::DOM->new;
my $r_prefix =
  "https://hb.afl.rakuten.co.jp/hgc/0d591c80.1e6947ee.197d1bf7.7a323c41/?pc=";

sub make_amazon {
  my $html = shift;

  my $dom  = $parser->parse($html);
  my $href = $dom->at('a')->getAttribute('href');
  my $url  = URI->new($href);

  my $domain   = $url->host;
  my $linkId   = $url->query_param('linkId');
  my $linkCode = $url->query_param('linkCode');
  my $language = $url->query_param('language');
  my $ref      = $url->query_param('ref_');
  my $tag      = $url->query_param('tag');

  my $path = $url->path;
  my $asin = ( $path =~ m{dp/([a-zA-Z0-9]+)} )[0];

  my $link =
"https://${domain}/dp/${asin}?&linkCode=${linkCode}&tag=${tag}&linkId=${linkId}&language=${language}&ref_=${ref}";

  my $title = uri_unescape( ( $path =~ m{/([^/]+)/dp} )[0] );

  my $image  = $dom->at('a > img')->getAttribute('src');
  my $beacon = $dom->at('a + img')->getAttribute('src');

  print <<"_OUT_";
"${title}":
  - provider: amazon
    link: ${link}
    image: https:${image}
    size: 
    beacon: ${beacon}
_OUT_
}

sub make_rakuten {
  my $link = shift;
  chomp($link);

  print <<_OUT_;
  - provider: rakuten
    link: ${r_prefix}@{[ uri_escape($link) ]}
_OUT_
}

sub main {
  my $provider = shift;
  my $html     = join q{}, @_;

  if ( $provider eq q{amazon} ) {
    make_amazon($html);
  }
  elsif ( $provider eq q{rakuten} ) {
    make_rakuten($html);
  }
}

main( $ARGV[0], <STDIN> );
