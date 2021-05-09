use strict;
use warnings;

use Test2::V0;
use Path::Tiny::Glob;
use YAML::Tiny qw( LoadFile );

use Kalaclista::Path;

sub fixtures () {
  my $distdir = Kalaclista::Path->build_dir;
  return pathglob( [ $distdir->stringify, '**', 'test.yaml' ] );
}

sub dir ($) {
  my $path = shift;
  while ( $path->parent->basename ne 'build' ) {
    $path = $path->parent;
  }

  return $path->basename;
}

sub testing_fixtures () {
  my $files = fixtures;
  while ( defined( my $file = $files->next ) ) {
    my $data = LoadFile( $file->stringify );
    my $dir  = dir $file;

    if ( $dir eq q{nyarla} || $dir eq q{licenses} || $dir eq q{policies} ) {
      is( $data->{'section'}, 'home', $file->stringify );
    }
    else {
      is( $data->{'section'}, $dir, $file->stringify );
    }
  }
}

sub testing_markup () {
  my $file = Kalaclista::Path->build_dir->child('posts/test.yaml');
  my $data = LoadFile($file);
  my $is   = $data->{'is'};

  for my $test ( sort keys $is->%* ) {
    is( $is->{$test}->{'in'}, $is->{$test}->{'out'} );
  }

  my $like = $data->{'like'};
  for my $test ( sort keys $like->%* ) {
    like( $like->{$test}->{'out'}, qr{$like->{$test}->{'re'}} );
  }
}

sub main {
  testing_fixtures;
  testing_markup;
  done_testing;
}

main();
