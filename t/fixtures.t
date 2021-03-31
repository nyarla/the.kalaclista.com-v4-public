use strict;
use warnings;

use FindBin;

use Test2::V0;
use Path::Tiny;
use Path::Tiny::Glob;
use YAML::Tiny qw( LoadFile );

sub files () {
  my $rootdir = path($FindBin::Bin);
  while (! $rootdir->child('dist')->is_dir) {
    $rootdir = $rootdir->parent;
  }

  return pathglob([ $rootdir->stringify, 'dist', '**', 'fixtures.yaml' ]);
}

sub load ($) {
  my $path = shift;
  return (LoadFile($path->stringify))[0];
}

sub section ($) {
  my $path = shift;
  while ($path->parent->basename ne 'dist') {
    $path = $path->parent;
  }

  return $path->basename;
} 

sub testing_section ($$) {
  my ( $path, $data ) = @_;
  my $section = section $path;

  ok( exists $data->{'section'} );
  if ( $section ne 'nyarla' && $section ne 'licenses' && $section ne 'policies' ) {
    is( $data->{'section'}, $section );
  } else {
    is( $data->{'section'}, 'home' );
  }
}

sub main {
  my $files = files;

  while (defined(my $file = $files->next)) {
    my $data = load $file;
    
    testing_section $file, $data;
  }

  done_testing;
}

main();
