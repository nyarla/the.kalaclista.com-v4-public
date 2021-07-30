#!/usr/bin/env perl

use strict;
use warnings;

use Path::Tiny;
use YAML::XS qw( LoadFile DumpFile Dump );

sub main {
  my $data  = LoadFile(shift);
  my $dest  = shift;
  my $terms = LoadFile("resources/_tfidf/terms.yaml");

  my $size = 0;
  for my $term ( keys $data->{'terms'}->%* ) {
    if ( !exists $terms->{$term} ) {
      next;
    }

    my $tf    = log( $data->{'terms'}->{$term} + 1 ) / $data->{'total'};
    my $idf   = 1 + log( $terms->{$term} / $data->{'terms'}->{$term} );
    my $tfidf = $tf * $idf;

    $data->{'tfidf'} //= {};
    $data->{'tfidf'}->{$term} = $tfidf;

    $size += $tfidf * $tfidf;
  }

  for my $term ( keys $data->{'tfidf'}->%* ) {
    $data->{'normalized'} //= {};
    $data->{'normalized'}->{$term} =
      $data->{'tfidf'}->{$term} / sqrt $size;
  }

  path($dest)->parent->mkpath;
  DumpFile( $dest, $data );

  exit 0;
}

main(@ARGV);
