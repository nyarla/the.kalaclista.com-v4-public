use strict;
use warnings;

package Kalaclista::Path;

use FindBin;
use Path::Tiny;

sub rootdir {
  my $class   = shift;
  my $rootdir = path($FindBin::Bin);

  while ( !$rootdir->child('t')->is_dir ) {
    $rootdir = $rootdir->parent;
  }

  return $rootdir;
}

sub distdir {
  my $class = shift;
  return $class->rootdir->child('dist');
}

sub build_dir {
  my $class = shift;
  return $class->rootdir->child('build');
}

1;
