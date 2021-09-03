#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Lingua::JA::NormalizeText;
use Parallel::Fork::BossWorkerAsync;
use Path::Tiny::Glob;
use Path::Tiny;
use Text::MeCab;
use YAML::XS qw(LoadFile Dump DumpFile);

my $mecab = Text::MeCab->new(
  rcfile      => $ENV{'HOME'} . '/.config/mecab/dicrc',
  dicdir      => $ENV{'HOME'} . '/.config/mecab',
  node_format => "%m",
);

my $normalizer = Lingua::JA::NormalizeText->new(
  qw(
    lc nfkc nfc
    decode_entities strip_html
    alnum_z2h space_z2h katakana_h2z
    katakana2hiragana wave2tilde
    nl2space old2new_kana old2new_kanji
    remove_controls remove_DFC
    all_dakuon_normalize square2katakana
    circled2kana circled2kanji
    decompose_parenthesized_kanji
    ),
);

sub permalinkify {
  my $path = shift;
  $path =~ s{resources/_tokens}{};
  $path =~ s{.yaml}{/};

  return $path;
}

sub plainify {
  my $html = shift;

  $html =~ s{<aside[^>]*>.+?</aside>}{}g;
  $html =~ s{<pre[^>]*>.+?</pre>}{}g;
  $html =~ s{<code[^>]*>.+?</code>}{}g;
  $html =~ s{</?[^>]+>}{}g;

  my $text = $normalizer->normalize($html);
  $text =~ s{[、。・]}{ }g;
  $text =~ s{-}{ }g;

  return $text;
}

sub tokenize {
  my $text = shift;

  my %terms = ();
  my $total = 0;

  for my $segment ( split qr{ +}, $text ) {
    next if ( length $segment eq 1 );

    if ( $segment =~ m{[^a-zA-Z0-9\-.]}i ) {
      for my $term ( segment($segment) ) {
        next if ( length $term eq 1 );

        $term =~ s{\\}{}g;

        $terms{$term} //= 0;
        $terms{$term}++;
        $total++;
      }
    }
    else {
      $terms{$segment} //= 0;
      $terms{$segment}++;
      $total++;
    }
  }

  return {
    total => $total,
    terms => \%terms,
  };
}

sub segment {
  my $text = shift;
  return if ( $text eq q{} );

  my @terms;

  for ( my $node = $mecab->parse($text) ; $node ; $node = $node->next ) {
    if ( defined( my $term = $node->surface ) ) {
      utf8::decode($term);
      push @terms, $term;
    }
  }

  return @terms;
}

sub process {
  my ( $path, $dest ) = @_;

  my $src  = LoadFile($path);
  my $text = plainify( $src->{'content'} );
  my $data = tokenize($text);
  my $key  = $dest;
  utf8::decode($key);

  path($dest)->parent->mkpath;
  DumpFile(
    $dest,
    {
      %{$data},
      datetime => $src->{'unixtime'},
      link     => permalinkify($key),
    }
  );

  return { path => $dest };
}

sub main {
  my $files = pathglob( [ 'build/*', '**', 'fixture.yaml' ] );
  my @tasks;
  while ( defined( my $file = $files->next ) ) {
    my $path = $file->stringify;
    my $dest = $path;
    $dest =~ s{build/}{resources/_tokens/};
    $dest =~ s{/fixture}{};

    push @tasks, [ $path, $dest ];
  }

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler  => sub { return process( $_[0]->@* ) },
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

}

main(@ARGV);
