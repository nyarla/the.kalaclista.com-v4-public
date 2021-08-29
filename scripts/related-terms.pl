#!/usr/bin/env perl

use strict;
use warnings;

use YAML::XS qw( LoadFile DumpFile );
use Path::Tiny;
use Path::Tiny::Glob;

sub main {
  my $files = pathglob( [ 'resources/_tokens', '*/**', '*.yaml' ] );

  my %terms  = ();
  my %termTo = ();

  while ( defined( my $file = $files->next ) ) {
    my $data = LoadFile( $file->stringify );
    my $link = $data->{'link'};
    utf8::decode($link);

    for my $term ( sort keys $data->{'terms'}->%* ) {
      $terms{$term} //= 0;
      $terms{$term}++;

      $termTo{$term} //= [];
      push $termTo{$term}->@*, $link;
    }
  }

  for my $term ( keys %termTo ) {
    $termTo{$term} = [ sort { $b cmp $a } $termTo{$term}->@* ];
  }

  path("resources/_tfidf")->mkpath;
  DumpFile( "resources/_tfidf/terms.yaml",  \%terms );
  DumpFile( "resources/_tfidf/termTo.yaml", \%termTo );
}

main(@ARGV);
