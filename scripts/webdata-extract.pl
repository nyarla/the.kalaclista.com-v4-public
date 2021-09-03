#!/usr/bin/env perl

use strict;
use warnings;

use HTML5::DOM;
use Parallel::Fork::BossWorkerAsync;
use Path::Tiny::Glob;
use Path::Tiny;
use YAML::XS qw( LoadFile DumpFile );

my $parser = HTML5::DOM->new;

sub extract {
  my ( $src, $dest ) = @_;

  my $data = LoadFile($src);
  my $dom  = $parser->parse( $data->{'content'} );

  my @links;
  for my $link ( ( $dom->find('.content__card--website a') || [] )->@* ) {
    push @links, $link->getAttribute('href');
  }

  path($dest)->parent->mkpath;

  DumpFile( $dest, \@links );

  return { path => $dest };
}

sub main {
  my $files = pathglob( [ 'build', '**', 'fixture.yaml' ] );

  my @tasks;
  while ( defined( my $file = $files->next ) ) {
    my $src  = $file->stringify;
    my $dest = $src;
    $dest =~ s{^build}{resources/_website/links};
    $dest =~ s{/fixture}{};

    push @tasks, [ $src, $dest ];
  }

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler  => sub { return extract( $_[0]->@* ) },
    handle_result => sub { return $_[0] },
    worker_count  => 31,
  );

  $bw->add_work(@tasks);
  while ( $bw->pending ) {
    my $ref = $bw->get_result;
    if ( $ref->{'ERROR'} ) {
      print STDERR $ref->{'ERROR'}, "\n";
    }
    else {
      print $ref->{'path'}, "\n";
    }
  }

  $bw->shut_down();

  exit 0;
}

main;
