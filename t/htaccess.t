use strict;
use warnings;

use Test2::V0;
use Path::Tiny::Glob;

use Kalaclista::Path;

sub testing_root {
  my $file = Kalaclista::Path->build_dir->child('.htaccess');
  is( $file->slurp, <<_EOF_);
ErrorDocument 404 /404.html
Header set Cache-Control "max-age=7200"
_EOF_
}

sub testing_assets {
  my $file = Kalaclista::Path->build_dir->child('assets/.htaccess');
  is( $file->slurp, <<_EOF_);
Header set Cache-Control "max-age=31536000"
Header set CDN-Cache-Control "max-age=3153600000"
_EOF_
}

sub testing_images {
  my $file = Kalaclista::Path->build_dir->child('assets/.htaccess');
  is( $file->slurp, <<_EOF_);
Header set Cache-Control "max-age=31536000"
Header set CDN-Cache-Control "max-age=3153600000"
_EOF_
}

sub testing_entries {
  my $date = `date +%Y/%m`;
  chomp($date);

  my $files =
    pathglob( [ Kalaclista::Path->build_dir->stringify, '**', '.htaccess' ] );

  while ( defined( my $file = $files->next ) ) {
    if ( $file->dirname =~ m{build/(?:nyarla|policies|licenses)/} ) {
      is( $file->slurp, <<_EOF_ );
Header set Cache-Control "max-age=86400"
Header set CDN-Cache-Control "max-age=3153600000"
_EOF_
    }

    if ( $file->dirname =~ m{build/(?:posts|echos)} ) {
      if ( $file->dirname =~ m<build/[^/]+/${date}/\d{2}/\d{6}/> ) {
        is( $file->slurp, <<_EOF_ );
Header set Cache-Control "max-age=7200"
Header set CDN-Cache-Control "max-age=3153600000"
_EOF_
      }
      else {
        is( $file->slurp, <<_EOF_ );
Header set Cache-Control "max-age=86400"
Header set CDN-Cache-Control "max-age=3153600000"
_EOF_
      }
    }
    elsif ( $file->dirname =~ m{build/notes/} ) {
      is( $file->slurp, <<_EOF_ );
Header set Cache-Control "max-age=7200"
Header set CDN-Cache-Control "max-age=3153600000"
_EOF_
    }
  }
}

sub main {
  testing_root;
  testing_assets;
  testing_images;
  testing_entries;

  done_testing;
}

main;
