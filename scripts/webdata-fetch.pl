#!/usr/bin/env perl

use strict;
use warnings;

use Encode::Detect::Detector;
use Encode::Guess;
use Encode;
use LWP::UserAgent;
use Path::Tiny::Glob;
use URI::Fetch;
use URI;
use YAML::XS qw( LoadFile Dump DumpFile );
use JSONLD;
use JSON::XS qw();

my $ua =
'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0';
my $client = LWP::UserAgent->new( agent => $ua );
my $parser = HTML5::DOM->new;

sub domains {
  my $files = pathglob( [ 'resources/_website/links', '**', '*.yaml' ] );
  my %domains;

  while ( defined( my $file = $files->next ) ) {
    my $links = LoadFile( $file->stringify );

    for my $link ( $links->@* ) {
      if ( $link =~ m{^/} ) {
        $link = "https://the.kalaclista.com" . $link;
      }

      next if ( $link !~ m{https?://} );

      my $uri    = URI->new($link);
      my $domain = $uri->host;

      $domains{$domain} //= {};
      $domains{$domain}->{ $uri->as_string }++;
    }
  }

  return \%domains;
}

sub decode_content {
  my ($res) = @_;

  my $content = $res->content;

  print( ( utf8::is_utf8($content) ? "utf8" : "non" ), "\n" );

  my $decoder = undef;

  # by header
  if (
    defined( my $charset = ( $res->content_type =~ m{charset=([^ ;]+)} )[0] ) )
  {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  # by content
  if ( defined( my $charset = ( $content =~ m{charset="([^"]+)"} )[0] ) ) {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  if ( defined( my $charset = ( $content =~ m{charset='([^']+)'} )[0] ) ) {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  if ( defined( my $charset = ( $content =~ m{charset=([^ ;>]+)} )[0] ) ) {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  if ( defined( my $charset = ( $content =~ m{encoding="([^"]+)"} )[0] ) ) {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  if ( defined( my $charset = ( $content =~ m{encoding='([^']+)'} )[0] ) ) {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  if ( defined( my $charset = ( $content =~ m{encoding=([^ ?]+)} )[0] ) ) {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  # by content data
  if ( defined( my $charset = detect($content) ) ) {
    if ( defined( $decoder = Encode::find_encoding($charset) ) ) {
      goto DECODE;
    }
  }

  if (
    defined(
      my $decoder = guess_encoding( $content, Encode->encodings(':all') )
    )
    )
  {
    goto DECODE;
  }

DECODE:

  return $decoder->decode($content);
}

sub fill {
  my ( $data, $res ) = @_;
  my $content = decode_content($res);
  my $dom     = $parser->parse($content);

  if ( defined( my $e = $dom->at('script[type="application/ld+json"]') ) ) {
    my $json = $e->textContent;
    print( $json, "\n" );
  }

}

sub fetch {
  my $url     = shift;
  my $updated = 0;

  my $data = {
    Title           => q{},
    Description     => q{},
    Permalink       => q{},
    Gone            => 0,
    LastUpdated     => 0,
    LastModified    => 0,
    UpdatedRequired => 0,
  };

  my $dest = $url;
  $dest =~ s{^https?://}{};
  $dest =~ s{[^a-zA-Z0-9\-.]}{}g;
  $dest = "private/data/website/${dest}.yaml";

  if ( -e $dest ) {
    $data = LoadFile($dest);
  }

  if ( $data->{'Gone'} ) {
    goto LAST;
  }

  if ( $data->{'LastUpdated'} != 0
    && ( $data->{'LastUpdated'} + 60 * 60 * 24 * 30 ) > scalar(time) )
  {
    goto LAST;
  }

  my %options = ( UserAgent => $client );
  $options{'LastModified'} = $data->{'LastModified'}
    if ( $data->{'LastModified'} != 0 );

  $updated++;
  my $res = URI::Fetch->fetch( $url, %options );
  if ( !defined $res ) {
    $data->{'Gone'} = 1;
    goto LAST;
  }

  if ( $res->status == 404 || $res->status == 410 || $res->status == 451 ) {
    $data->{'Gone'} = 1;
    goto LAST;
  }

  if ( ( 301 <= $res->status <= 303 )
    || ( 307 <= $res->status <= 308 ) )
  {
    my $count = 0;
    while ( $count < 5
      && ( defined( $res = URI::Fetch->fetch( $res->uri, %options ) ) ) )
    {
      if ( !( 301 <= $res->status <= 303 )
        && !( 307 <= $res->status <= 308 ) )
      {
        last;
      }
    }

    if ( !defined $res ) {
      $data->{'Gone'} = 1;
    }

    if ( $res->status == 200 || $res->status == 304 ) {
      $data->{'Permaklink'}      = $res->uri;
      $data->{'UpdatedRequired'} = 1;
    }
  }

  if ( $res->status == 200 ) {
    $data->{'LastModified'} = $res->last_modified;
    $data->{'LastUpdated'}  = time;
  }
  elsif ( $res->status == 304 ) {
    $data->{'LastUpdated'} = time;
  }

  fill( $data, $res );

LAST:

  if ( 0 && $updated > 0 ) {
    path($dest)->parent->mkpath;
    DumpFile( $dest, data );
  }

  return $updated > 0;
}

sub main {

}

fetch("https://the.kalaclista.com");
