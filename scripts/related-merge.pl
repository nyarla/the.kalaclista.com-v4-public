#!/usr/bin/env perl

use strict;
use warnings;

use YAML::XS qw( LoadFile DumpFile );
use Path::Tiny::Glob;

sub linkify {
  my $path = shift;
  $path =~ s{^resources/_tfidf/score}{};
  $path =~ s{.yaml}{/};

  return $path;
}

sub main {
  my $files = pathglob( [ 'resources/_tfidf/score', '*/**', '*.yaml' ] );
  my $out   = {};

  while ( defined( my $file = $files->next ) ) {
    my $data = LoadFile( $file->stringify );
    my $link = linkify( $file->stringify );

    $out->{$link} = [
      sort {
             $b->{'UnixTime'} <=> $a->{'UnixTime'}
          || $a->{'Title'} cmp $b->{'Title'}
      } $data->@*
    ];
  }

  DumpFile( "private/data/related.yaml", $out );
}

main;
