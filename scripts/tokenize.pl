#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use Lingua::JA::NormalizeText;
use Text::TinySegmenter;
use YAML::XS qw(LoadFile Dump DumpFile);
use Path::Tiny;
use IPC::Open2 qw(open2);

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

  my $pid =
    open2( my $out, my $in, q{ mecab -d "${HOME}/.config/mecab" -F '%m\n'} );

  utf8::encode($text);

  $in->print($text);
  close($in);

  my @terms;
  while ( defined( my $term = <$out> ) ) {
    utf8::decode($term);
    chomp($term);

    if ( $term eq q{EOS} ) {
      next;
    }

    push @terms, $term;
  }

  close($out);

  return @terms;
}

sub main {
  my ( $path, $dest ) = @_;
  print $path, "\n";

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

  exit 0;
}

main(@ARGV);
