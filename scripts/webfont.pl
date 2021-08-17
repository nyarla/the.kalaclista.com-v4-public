#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Path::Tiny;
use Path::Tiny::Glob;
use YAML::XS qw( LoadFile Dump );

sub sans {
  my $html = shift;

  $html =~ s{<pre[^>]*>.+?</pre>}{}g;
  $html =~ s{<code[^>]*>.+?</code>}{}g;
  $html =~ s{</?[^>]+>}{}g;
  $html =~ s{\s}{}gm;

  return split q{}, $html;
}

sub mono {
  my $html = shift;

  my @pre  = ( $html =~ m{<pre[^>]*>(.+?)</pre>} );
  my @code = ( $html =~ m{<code[^>]*>(.+?)</code>} );

  my $out = "";

  for $_ ( @pre, @code ) {
    $_ =~ s{</?code[^>]+>}{}g;
    $_ =~ s{</?span[^>]+>}{}g;
    $_ =~ s{\s}{}gm;
    $out .= $_;
  }

  return split q{}, $out;
}

sub main {
  my $files = pathglob( [ 'build', '**', 'fixture.yaml' ] );
  my %sans;
  my %mono;

  while ( defined( my $file = $files->next ) ) {
    my $data = LoadFile( $file->stringify );
    $sans{$_}++ for ( sans( $data->{'content'} ) );
    $mono{$_}++ for ( mono( $data->{'content'} ) );
  }

  my $sans = path('resources/_webfont/sans.txt');
  my $mono = path('resources/_webfont/mono.txt');

  for my $asset ( [ $sans, \%sans ], [ $mono, \%mono ] ) {
    $asset->[0]->parent->mkpath;
    my $fh = $asset->[0]->openw_utf8;
    print $fh join( q{}, sort keys $asset->[1]->%* );
    close($fh);
  }
}

main;
