use strict;
use warnings;
use utf8;

use Test2::V0;
use JSON::Tiny qw( decode_json );

use Kalaclista::Path;

sub testing_feed {
  my ( $data, $section ) = @_;

  is( $data->{'version'}, 'https://jsonfeed.org/version/1.1' );
  ok( $data->{'title'} );
  ok( $data->{'description'} );

  is( $data->{'icon'},    'https://the.kalaclista.com/icon-512.png' );
  is( $data->{'favicon'}, 'https://the.kalaclista.com/favicon.ico' );

  my $URI = "https://the.kalaclista.com";
  if ( $section ne q{} ) {
    $URI = "${URI}/${section}";
  }

  is( $data->{'home_page_url'}, "${URI}/" );
  is( $data->{'feed_url'},      "${URI}/jsonfeed.json" );

  is(
    $data->{'authors'},
    [
      {
        name   => 'OKAMURA Naoki aka nyarla',
        url    => 'https://the.kalaclista.com/nyarla/',
        avatar => 'https://the.kalaclista.com/assets/avatar.png',
      }
    ]
  );

  is( $data->{'language'}, 'ja_JP' );

  ok( $data->{'items'}->@* <= 5 );

  for my $item ( $data->{'item'}->@* ) {
    is( $item->{'id'}, $item->{'url'} );

    if ( $section ne q{} ) {
      like(
        $item->{'url'},
qr<^https://the.kalaclista.com/[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/)$>,
      );
    }
    else {
      if ( $section ne 'notes' ) {
        like( $item->{'url'},
          qr<^https://the.kalaclista.com/${section}/\d{4}/\d{2}/\d{2}/\d{6}/$>
        );
      }
      else {
        like( $item->{'url'},
          qr<^https://the.kalaclista.com/${section}/[^/]+/$> );
      }
    }

    ok( $item->{'title'} );
    ok( $item->{'content_html'} );
    ok( $item->{'summary'} );

    is(
      $item->{'authors'},
      [
        {
          name   => 'OKAMURA Naoki aka nyarla',
          url    => 'https://the.kalaclista.com/nyarla/',
          avatar => 'https://the.kalaclista.com/assets/avatar.png',
        }
      ]
    );

    is( $item->{'language'}, 'ja_JP' );

    like( $data->{'date_published'},
      qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$> );
    like( $data->{'date_lastmod'},
      qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[-+]\d{2}:\d{2}|Z)$> );
  }

}

sub main {
  for my $section (qw[ posts echos notes ]) {
    my $json =
      Kalaclista::Path->build_dir->child( $section, 'jsonfeed.json' )->slurp;
    my $data = decode_json($json);

    testing_feed( $data, $section );
  }

  my $json = Kalaclista::Path->build_dir->child('jsonfeed.json')->slurp;
  my $data = decode_json($json);

  testing_feed( $data, q{} );

  done_testing;
}

main;
