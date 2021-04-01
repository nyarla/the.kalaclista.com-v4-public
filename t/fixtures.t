use strict;
use warnings;

use Test2::V0;
use Path::Tiny::Glob;
use YAML::Tiny qw( LoadFile );

use Kalaclista::Path;

sub fixtures () {
  my $distdir = Kalaclista::Path->distdir;
  return pathglob([ $distdir->stringify, '**', 'fixtures.yaml' ]);
}

sub load ($) {
  my $file = shift;
  return (LoadFile($file->stringify))[0];
}

sub section ($) {
  my $path = shift;
  while ($path->parent->basename ne 'dist') {
    $path = $path->parent;
  }

  return $path->basename;
}

sub testing_fixtures () {
  my $files = fixtures;

  while (defined(my $file = $files->next)) {
    my $data = load $file;
    my $section = (section $file);

    if ( $file->parent->basename eq $section ) {
      next;
    }

    # testing `section`
    if ( $section eq 'nyarla' || $section eq 'licenses' || $section eq 'policies' ) {
      is( $data->{'section'}, 'home' );
    } else {
      is( $data->{'section'},  $section );
    }
  }
}

sub testing_markup () {
  for my $section (qw(posts echos notes)) {
    my $file = Kalaclista::Path->distdir->child($section, 'fixtures.yaml');
    my $data = load $file;
    my $content = $data->{'content'};

    for my $el (qw( pre code a )) {
      is( $content->{$el}->{'in'}, $content->{$el}->{'out'} );
    }
  }
}

sub main {
  testing_fixtures;
  testing_markup;
  done_testing;
}

main();
