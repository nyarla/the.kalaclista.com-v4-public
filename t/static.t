use strict;
use warnings;
use utf8;

use Test2::V0;
use HTML5::DOM;
use JSON::XS qw( decode_json );

use Kalaclista::Path;

sub main {
  my $dir = Kalaclista::Path->build_dir;

  ok( $dir->child('assets/avatar.svg')->is_file );
  ok( $dir->child('assets/avatar.png')->is_file );

  ok( $dir->child('apple-touch-icon.png')->is_file );
  ok( $dir->child('favicon.ico')->is_file );
  ok( $dir->child('icon-192.png')->is_file );
  ok( $dir->child('icon-512.png')->is_file );
  ok( $dir->child('icon.svg')->is_file );

  ok( $dir->child('manifest.webmanifest')->is_file );

  is(
    decode_json( $dir->child('manifest.webmanifest')->slurp ),
    {
      name  => 'カラクリスタ',
      icons => [
        {
          src   => 'https://the.kalaclista.com/icon-192.png',
          type  => 'image/png',
          sizes => '192x192'
        },
        {
          src   => 'https://the.kalaclista.com/icon-512.png',
          type  => 'image/png',
          sizes => '512x512'
        }
      ],
    }
  );

  done_testing;
}

main;
