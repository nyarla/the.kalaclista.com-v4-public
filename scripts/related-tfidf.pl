#!/usr/bin/env perl

use strict;
use warnings;

use Path::Tiny;
use Path::Tiny::Glob;
use YAML::XS qw( LoadFile DumpFile Dump );
use Parallel::Fork::BossWorkerAsync;

our $terms = LoadFile("resources/_tfidf/terms.yaml");

sub process {
  my $data = LoadFile(shift);
  my $dest = shift;

  my $size = 0;
  for my $term ( sort keys $data->{'terms'}->%* ) {
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

  for my $term ( sort keys $data->{'tfidf'}->%* ) {
    $data->{'normalized'} //= {};
    $data->{'normalized'}->{$term} =
      $data->{'tfidf'}->{$term} / sqrt $size;
  }

  delete $data->{'tfidf'};
  delete $data->{'terms'};

  path($dest)->parent->mkpath;
  DumpFile( $dest, $data );

  return { dest => $dest };
}

sub main {
  my $files = pathglob( [ 'resources/_tokens', '*', '**', '*.yaml' ] );
  my @tasks;

  while ( defined( my $file = $files->next ) ) {
    my $path = $file->stringify;
    my $dest = $path;
    $dest =~ s{_tokens}{_tfidf/data};

    push @tasks, [ $path, $dest ];
  }

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler  => sub { return process( $_[0]->@* ) },
    handle_result => sub { return $_[0] },
    worker_count  => 15,
  );

  $bw->add_work(@tasks);
  while ( $bw->pending ) {
    my $ref = $bw->get_result;
    if ( $ref->{'ERROR'} ) {
      print STDERR $ref->{'ERROR'}, "\n";
    }
    else {
      print $ref->{'dest'}, "\n";
    }
  }

  $bw->shut_down();
}

main(@ARGV);
