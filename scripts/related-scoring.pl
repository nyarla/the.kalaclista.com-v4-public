#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use YAML::XS qw( LoadFile DumpFile Dump );
use Path::Tiny;
use Path::Tiny::Glob;
use Parallel::Fork::BossWorkerAsync;

our $termTo;
our $entries;

sub scoring {
  my ( $dest, $data ) = @_;

  my @terms = grep { defined($_) } (
    sort { $data->{'normalized'}->{$b} <=> $data->{'normalized'}->{$a} }
      keys $data->{'normalized'}->%*
  )[ 0 .. 50 ];

  my %entries = ( $data->{'link'} => $data );
  my %shared  = ();

  for my $term (@terms) {
    for my $link ( $termTo->{$term}->@* ) {
      my $entry = $entries->{$link};
      next if ( $link eq $data->{'link'} );
      next if ( $data->{'datetime'} < $entry->{'datetime'} );

      $shared{$link} //= 0;
      $shared{$link}++;
      $entries{$link} = $entry;
    }
  }

  my @keys = grep { defined($_) }
    ( sort { $shared{$b} <=> $shared{$a} } keys %shared )[ 0 .. 100 ];

  my %vec;
  for my $key (@keys) {
    my $entry = $entries{$key};

    for my $term (@terms) {
      next if ( !exists $entry->{'normalized'}->{$term} );
      $vec{$key} +=
        $data->{'normalized'}->{$term} * $entry->{'normalized'}->{$term};
    }
  }

  my @nearly = grep { defined($_) } (
    map    { $entries{$_} }
      sort { $vec{$b} <=> $vec{$a} }
      grep { $vec{$_} > 0 }
      grep { $_ ne $data->{'link'} }
      keys %vec
  )[ 0 .. 5 ];

  path($dest)->parent->mkpath;
  DumpFile( $dest, datafy( \@nearly ) );

  return { key => $data->{'link'} };
}

sub datafy {
  my $nearly = shift;

  my @entries = ();
  for my $entry ( $nearly->@* ) {
    my $path = "build" . $entry->{'link'} . 'fixture.yaml';
    my $data = LoadFile($path);

    push @entries,
      {
      RelPermalink => $data->{'permalink'},
      Title        => $data->{'title'},
      UnixTime     => $data->{'unixtime'},
      };
  }

  return \@entries;
}

sub main {
  my $files = pathglob( [ 'resources/_tfidf/data', '**', '*.yaml' ] );
  $termTo = LoadFile('resources/_tfidf/termTo.yaml');
  while ( defined( my $file = $files->next ) ) {
    my $data = LoadFile( $file->stringify );

    $entries->{ $data->{'link'} } = $data;
  }

  my @tasks;
  for my $key ( sort { $a cmp $b } keys $entries->%* ) {
    my $data = $entries->{$key};
    my $dest = $data->{'link'};
    $dest =~ s{^/|/$}{}g;
    $dest = "resources/_tfidf/score/${dest}.yaml";

    push @tasks, [ $dest, $data ];
  }

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler  => sub { return scoring( $_[0]->@* ) },
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
      print $ref->{'key'}, "\n";
    }
  }

  $bw->shut_down();

  exit 0;
}

main(@ARGV);
