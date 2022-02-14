#!/usr/bin/env perl

use strict;
use warnings;

use Kalaclista::Parallel;

use HTML5::DOM;
use YAML::XS qw( LoadFile DumpFile );
use Path::Tiny;

my $parser = HTML5::DOM->new;

sub prepare {
  my ($file) = @_;

  my $path = $file->stringify;
  $path =~ s{^build}{resources/_website/links};
  $path =~ s{/fixture}{};

  return [ $file, path($path) ];
}

sub process {
  my ( $src, $dest ) = $_[0]->@*;

  my $data = LoadFile( $src->stringify );
  my $dom  = $parser->parse( $data->{'content'} );

  my @links;
  my $nodes = $dom->find('.content__card--website a') || [];
  for my $link ( $nodes->@* ) {
    push @links, $link->getAttribute('href');
  }

  $dest->parent->mkpath;

  DumpFile( $dest->stringify, \@links );

  return { message => $dest->stringify };
}

sub main {
  my $parallel = Kalaclista::Parallel->new(
    processor => \&process,
    prepare   => \&prepare,
  );

  return $parallel->run( 'build', '**', 'fixture.yaml' );
}

if ( main(@ARGV) ) {
  exit 0;
}

exit 1;
