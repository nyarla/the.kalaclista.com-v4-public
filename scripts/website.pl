#!/usr/bin/env perl

use strict;
use warnings;

use Encode::Detect;
use Encode;
use HTML5::DOM;
use HTTP::Tinyish;
use Time::Moment;
use YAML::Tiny qw( LoadFile DumpFile Dump );

use Kalaclista::Path;

my @guess    = qw(utf8 euc-jp shiftjis);
my $interval = 60 * 60 * 24 * 30;
my $sleep    = 3;

my $dom  = HTML5::DOM->new();
my $http = HTTP::Tinyish->new(
  agent        => 'the.kalaclista.com/0.01',
  timeout      => 5,
  max_redirect => 5,
);

sub strftime ($) {
  my $dt = Time::Moment->from_epoch(shift);
  return $dt->at_utc->strftime("%a, %d %b %Y %H:%M:%S GMT");
}

sub path ($) {
  my $dest = shift;

  $dest =~ s{https?://}{};
  $dest =~ s{[^a-zA-Z0-9\-.]}{}g;

  my $path =
    Kalaclista::Path->rootdir->child("private/data/website/${dest}.yaml");
  if ( !-d $path->parent->stringify ) {
    $path->parent->mkpath;
  }

  return $path;
}

sub content ($) {
  my $res = shift;

  my $encoding = undef;
  my $content  = $res->{'content'};

  while ( my ( $key, $val ) = each $res->{'headers'}->%* ) {
    if ( lc $key eq 'content-type' ) {
      $encoding = ( $val =~ m{charset=([a-zA-Z0-9\-_]+)} )[0];
      last;
    }
  }

  if ( !defined $encoding ) {
    $encoding = ( $content =~ m{charset=([a-zA-Z0-9\-_]+)} )[0];
  }

  if ( !defined $encoding ) {
    $encoding = ( $content =~ m{charset='([a-zA-Z0-9\-_]+)'} )[0];
  }

  if ( !defined $encoding ) {
    $encoding = ( $content =~ m{charset="([a-zA-Z0-9\-_]+)"} )[0];
  }

  if ( !defined $encoding ) {
    $encoding =
      ( $content =~ m{<\?xml.*?encoding="([a-zA-Z0-9\-_]+)".*\?>} )[0];
  }

  if ( !defined $encoding ) {
    $encoding = Encode::Detect::Detector::detect($content);
  }

  if ( !defined $encoding ) {
    eval {
      $encoding = Encode::Guess::guess_encoding( $content, @guess )->name;
    }
  }

  if ( !defined $encoding ) {
    $encoding = 'utf8';
  }

  if ( lc $encoding ne 'utf8' && lc $encoding ne 'utf-8' ) {
    return Encode::decode( $encoding, $content );
  }

  return Encode::decode_utf8($content);
}

sub meta ($) {
  my $tree = $dom->parse( content(shift), { encoding => 'UTF-8' } );

  my $title       = undef;
  my $description = undef;

  if ( defined( my $node = $tree->at(q{meta[property="og:title"]}) ) ) {
    $title = $node->getAttribute('content');
  }

  if ( !defined($title) && defined( my $node = $tree->at('title') ) ) {
    $title = $node->textContent;
  }

  if ( defined( my $node = $tree->at(q{meta[property="og:description"]}) ) ) {
    $description = $node->getAttribute('content');
  }

  if (!defined($description)
    && defined( my $node = $tree->at(q{meta[name="description"]}) ) )
  {
    $description = $node->getAttribute('content');
  }

  return {
    title       => $title       // q{},
    description => $description // q{},
  };
}

sub update ($) {
  my ($dest) = @_;

  my $now   = time;
  my $since = $now;
  my $path  = path $dest;
  my $data  = {
    title       => q{},
    description => q{},
    link        => $dest,
    latest      => 0,
    gone        => 0,
    status      => 0,
  };

  if ( -e $path->stringify ) {
    $data = LoadFile( $path->stringify );
  }

  if ( defined($data) ) {
    if ( $now - $data->{'latest'} > $interval ) {
      $since = $data->{'latest'};
      $data->{'latest'} = 0;
    }
  }

  if ( $data->{'latest'} == 0 && $data->{'gone'} != 1 ) {
    print "update: ${dest}\n";

    my $res = $http->get(
      $dest,
      {
        headers => {
          'If-Modified-Since' => strftime($since),
        },
      }
    );

    my $status = $res->{'status'};

    $data->{'latest'} = $now;
    $data->{'status'} = $status;
    if ( $status == 200 ) {
      my $meta = meta $res;
      $data->{'title'}       = $meta->{'title'};
      $data->{'description'} = $meta->{'description'};
    }
    elsif ( $status == 404
      || $status == 410
      || $status == 451
      || $status == 599 )
    {
      $data->{'gone'}   = 1;
      $data->{'latest'} = $now;
    }

    DumpFile( $path->stringify, $data );
    sleep $sleep;
  }
  else {
    print "noop: ${dest}\n";
  }
}

sub main {
  my $file = shift;
  open( my $fh, '<',
    Kalaclista::Path->rootdir->child('resources/_website/links')->stringify )
    or die "open 'links' file failed: $!";

  while ( defined( my $line = <$fh> ) ) {
    chomp $line;
    update($line);
  }
  close($fh) or die "close 'links file failed: $!'";

  print "done", "\n";
}

main(@ARGV);
