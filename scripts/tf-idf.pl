use strict;
use warnings;

use Digest::SHA1 qw(sha1_hex);
use Lingua::JA::NormalizeText;
use Path::Tiny::Glob;
use Text::TinySegmenter;
use YAML::Tiny qw( LoadFile DumpFile Dump);

use AnyEvent;
use Promise::ES6;

Promise::ES6::use_event('AnyEvent');

use Kalaclista::Path;

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

sub fixtures () {
  my $distdir = Kalaclista::Path->distdir;
  return pathglob( [ $distdir->stringify, '**', 'fixture.yaml' ] );
}

sub resource ($) {
  my $file    = shift;
  my $distdir = Kalaclista::Path->distdir->stringify;

  my $path = $file->parent->stringify;
  $path =~ s{$distdir/}{};

  return Kalaclista::Path->rootdir->child("resources/_tf-idf/${path}.yaml");
}

sub tokenize ($) {
  my $content = shift;

  $content =~ s{<aside[^>]+>.+?</aside>}{}g;      # remove aside content
  $content =~ s{<pre[^>]+>.+?</pre>}{}g;          # remove pre content
  $content = $normalizer->normalize($content);    # normalize content
  $content =~ s{[^\w]}{ }g;

  my %w;
  for my $segment ( split q{ }, $content ) {
    next if ( length $segment eq 1 );
    if ( $segment =~ m{[^a-z0-9]}i ) {
      for my $word ( Text::TinySegmenter->segment($segment) ) {
        next if ( length $word eq 1 );
        $w{$word} //= 0;
        $w{$word}++;
      }
    }
    else {
      $w{$segment} //= 0;
      $w{$segment}++;
    }
  }

  return \%w;
}

sub load ($) {
  my $file = shift;
  return Promise::ES6->new(
    sub {
      my ( $resolve, $reject ) = @_;
      my $data    = ( LoadFile( $file->stringify ) )[0];
      my $content = $data->{'content'};
      my $sha1sum = do {
        my $hash;
        utf8::encode($content);
        $hash = sha1_hex($content);
        utf8::decode($content);
        $hash;
      };

      my $key      = $data->{'permalink'};
      my $resource = resource $file;
      my $payload  = undef;

      if ( -e $resource->stringify ) {
        my $cache = ( LoadFile( $resource->stringify ) )[0];
        if ( $cache->{'sha1sum'} eq $sha1sum ) {
          $payload = $cache;
        }
      }

      unless ( defined $payload ) {
        my $total = 0;
        my $terms = tokenize($content);
        $total += $_ for ( values $terms->%* );

        $payload = {
          sha1sum => $sha1sum,
          terms   => $terms,
          key     => $key,
          total   => $total,
        };

        $resource->parent->mkpath;
        DumpFile( $resource->stringify, $payload );
      }

      print $file->stringify, "\n";
      return $resolve->( [ $data, $payload, {} ] );
    }
  );
}

sub calcurate ($$$$$$) {
  my ( $set, $docs, $term2docs, $size, $total, $idx ) = @_;
  return Promise::ES6->new(
    sub {
      my ( $resolve, $reject ) = @_;

      print "${total}: ${idx}: ", $set->[1]->{'key'}, "\n";

      $set->[2]->{$_} = $set->[2]->{$_} / $size for ( keys $set->[2]->%* );

      my @terms =
        sort { $set->[2]->{$b} <=> $set->[2]->{$a} }
        keys $set->[2]->%*;
      @terms = grep { defined($_) } @terms[ 0 .. 50 ];

      my %related = ();
      for my $term (@terms) {
        $related{$_}++
          for (
          grep { $set->[1]->{'key'} ne $_ }
          keys $term2docs->{$term}->%*
          );
      }

      my @ids =
        sort { $related{$b} <=> $related{$a} }
        keys %related;

      @ids = grep { defined($_) } @ids[ 0 .. 100 ];

      my %scores = ();

      for my $id (@ids) {
        for my $term (@terms) {
          next unless ( exists $docs->{$id}->[2]->{$term} );
          $scores{$id} += $set->[2]->{$term} * $docs->{$id}->[2]->{$term};
        }
      }

      my @entries =
        map  { $_->[0] }
        sort { $b->[1] <=> $a->[1] }
        grep { $_->[1] > 0 }
        map  { [ $_, $scores{$_} ] }
        keys %scores;

      @entries = grep { defined($_) } @entries[ 0 .. 9 ];
      return $resolve->( [ $set->[1]->{'key'}, \@entries ] );
    }
  );
}

sub main {

  my $files = fixtures;

  my @promise_data = ();
  while ( defined( my $file = $files->next ) ) {
    my $dirname = $file->parent->basename;

    next if ( $dirname eq 'archives' );
    next if ( $dirname eq 'licenses' );
    next if ( $dirname eq 'nyarla' );
    next if ( $dirname eq 'policies' );

    push @promise_data, load $file;
  }

  my $await_data = AnyEvent->condvar;
  Promise::ES6->all( \@promise_data )->then(
    sub {
      return $await_data->send( (shift)->@* );
    }
  );

  my @dataset       = $await_data->recv;
  my $total_entries = scalar(@dataset);
  my $total_terms   = {};
  my $docs          = {};
  my $term2docs     = {};
  my $tfidf_size    = 0;

  for my $set (@dataset) {
    my $key = $set->[1]->{'key'};
    $docs->{$key} = $set;
    $total_terms->{$_}++ for ( keys $set->[1]->{'terms'}->%* );

    for my $term ( keys $set->[1]->{'terms'}->%* ) {
      $term2docs->{$term} //= {};
      $term2docs->{$term}->{$key} = $set;

      my $tf    = log( $total_terms->{$term} + 1 ) / $set->[1]->{'total'};
      my $idf   = 1 + log( $total_entries / $total_terms->{$term} );
      my $tfidf = $tf * $idf;

      $set->[2]->{$term} = $tfidf;

      $tfidf_size += $tfidf ^ 2;
    }
  }
  $tfidf_size = sqrt $tfidf_size;

  my $await_index   = AnyEvent->condvar;
  my @promise_index = ();
  my $idx           = 0;
  for my $set ( values $docs->%* ) {
    push @promise_index,
      calcurate $set, $docs, $term2docs, $tfidf_size, $total_entries, ++$idx;
  }
  Promise::ES6->all( \@promise_index )->then(
    sub {
      return $await_index->send(shift);
    }
  );

  my $indexes = $await_index->recv;
  my $index   = {};
  for my $data ( $indexes->@* ) {
    $index->{ $data->[0] } = $data->[1];
  }

  DumpFile(
    Kalaclista::Path->rootdir->child('private/data/related.yaml')->stringify,
    $index );

  print "done\n";
  exit 0;
}

main();
