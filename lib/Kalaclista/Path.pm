use strict;
use warnings;

package Kalaclista::Path;

use FindBin;
use Path::Tiny;
use Path::Tiny::Glob;

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

sub entries ($$$) {
  my ( $section, $glob, $fn ) = @_;
  return pathglob(
    [ Kalaclista::Path->build_dir->stringify, $section, $glob, $fn ] );
}

sub posts {
  return entries 'posts', '*/*/*/*', 'index.html';
}

sub echos {
  return entries 'echos', '*/*/*/*', 'index.html';
}

sub notes {
  return entries 'notes', '*', 'index.html';
}

1;
