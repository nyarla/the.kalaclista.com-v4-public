#!/usr/bin/env perl

use strict;
use warnings;

use Encode::Detect::Detector;
use Encode::Guess;
use Encode;
use HTML5::DOM;
use JSON::XS qw( decode_json );
use LWP::Protocol::Net::Curl;
use LWP::UserAgent;
use Parallel::Fork::BossWorkerAsync;
use Path::Tiny::Glob;
use Path::Tiny;
use URI::Fetch;
use URI;
use YAML::XS qw( LoadFile Dump DumpFile );

my $ua =
'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0';
my $client = LWP::UserAgent->new(
  agent        => $ua,
  timeout      => 10,
  max_redirect => 10,
);
my $parser =
  HTML5::DOM->new( { encoding => 'utf8', utf8 => 0, ignore_doctype => 1 } );

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

sub fix_encoding {
  my $name = shift;

  if ( $name =~ m{shift.*?jis}i ) {
    return 'cp932';
  }

  if ( $name =~ m{sjis}i ) {
    return 'cp932';
  }

  if ( $name =~ m{euc-jp}i ) {
    return 'euc-jp';
  }

  if ( $name =~ m{utf.*?8}i ) {
    return 'utf8';
  }

  if ( $name =~ m{us-ascii}i ) {
    return 'iso-8859-1';
  }

  if ( $name =~ m{ISO-*}i ) {
    return lc $name;
  }

  return $name;
}

sub decode_content {
  my ($res) = @_;

  my $content = $res->content;
  my $charset = q{};

  if ( !defined $content || $content eq q{} ) {
    return "", 1;
  }

  # by header
  if ( defined( $charset = ( $res->content_type =~ m{charset=([^ ;]+)} )[0] ) )
  {
    goto DECODE;
  }

  # by content
  if ( defined( $charset = ( $content =~ m{<meta.+?charset="([^"]+)"} )[0] ) ) {
    goto DECODE;
  }

  if ( defined( $charset = ( $content =~ m{<meta.+?charset='([^']+)'} )[0] ) ) {
    goto DECODE;
  }

  if ( defined( $charset = ( $content =~ m{<meta.+?charset=([^ ;>]+)} )[0] ) ) {
    goto DECODE;
  }

  if ( defined( $charset = ( $content =~ m{<?xml.+?encoding="([^"]+)"} )[0] ) )
  {
    goto DECODE;
  }

  if ( defined( $charset = ( $content =~ m{<?xml.+?encoding='([^']+)'} )[0] ) )
  {
    goto DECODE;
  }

  if (
    defined( my $charset = ( $content =~ m{<?xml.+?encoding=([^ ?]+)} )[0] ) )
  {
    goto DECODE;
  }

  # by content data
  if ( defined( $charset = Encode::Detect::Detector::detect($content) ) ) {
    goto DECODE;
  }

  if (
    defined(
      my $define = guess_encoding( $content, Encode->encodings(':all') )
    )
    )
  {
    $charset = $define->name;
    goto DECODE;
  }

DECODE:

  if ( $charset eq q{} ) {
    $charset = "utf8";
  }

  $charset = fix_encoding($charset);
  my $decoder = Encode::find_encoding($charset);

  my $err = 0;
  if ( !defined $decoder ) {
    $decoder = Encode::find_encoding('utf8');
    $err     = 1;
  }

  return $decoder->decode($content), $err;
}

sub fill {
  my ( $data,    $res ) = @_;
  my ( $content, $err ) = decode_content($res);

  if ($err) {
    $data->{'Error'} = "Failed to detect encoding";
    return 0;
  }
  else {
    delete $data->{'Error'};
  }

  my $dom = $parser->parse($content);

  my $title       = q{};
  my $description = q{};

  if ( defined( my $e = $dom->at('script[type="application/ld+json"]') ) ) {
    eval {
      my $json = $e->textContent;
      my $data = decode_json($json);

      if ( ref($data) ne 'ARRAY' ) {
        $data = [$data];
      }

      for my $src ( $data->@* ) {
        if ( ref($src) eq 'HASH' ) {
          next
            if ( !exists $src->{'@context'}
            && $src->{'@context'} !~ m{^https?://schema.org} );

          if ( $title eq q{}
            && defined $src->{'name'}
            && $src->{'name'} ne q{} )
          {
            $title = $src->{'name'};
          }
          if ( $title eq q{}
            && defined $src->{'headline'}
            && $src->{'headline'} ne q{} )
          {
            $title = $src->{'headline'};
          }

          if ( $description eq q{}
            && defined $src->{'description'}
            && $src->{'description'} ne q{} )
          {
            $description = $src->{'description'};
          }

          if ( $description eq q{}
            && defined $src->{'abstract'}
            && $src->{'abstract'} ne q{} )
          {
            $description = $src->{'abstract'};
          }
        }
      }
    };
  }

  if ( $title ne q{} ) {
    goto DESC;
  }

  if ( defined( my $e = $dom->at('meta[name="twitter:title"]') ) ) {
    $title = Encode::decode_utf8( $e->getAttribute('content') );
    goto DESC;
  }

  if ( defined( my $e = $dom->at('meta[property="og:title"]') ) ) {
    $title = Encode::decode_utf8( $e->getAttribute('content') );
    goto DESC;
  }

  if ( defined( my $e = $dom->at('title') ) ) {
    $title = Encode::decode_utf8( $e->textContent );
    goto DESC;
  }

DESC:

  if ( $description ne q{} ) {
    goto FILL;
  }

  if ( defined( my $e = $dom->at('meta[name="twitter:description"]') ) ) {
    $description = Encode::decode_utf8( $e->getAttribute('content') );
    goto FILL;
  }

  if ( defined( my $e = $dom->at('meta[property="og:description"]') ) ) {
    $description = Encode::decode_utf8( $e->getAttribute('content') );
    goto FILL;
  }

  if ( defined( my $e = $dom->at('meta[name="description"]') ) ) {
    $description = Encode::decode_utf8( $e->getAttribute('content') );
    goto FILL;
  }

FILL:

  if ( $description eq q{} ) {
    $description = $title;
  }

  $data->{'Title'}       = $title;
  $data->{'Description'} = $description;

  return 1;
}

sub fetch {
  my $url     = shift;
  my $updated = 0;

  my $data = {
    Title           => q{},
    Description     => q{},
    Permalink       => $url,
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

    if ( exists $data->{'Error'} ) {
      $data->{'LastModified'} = 0;
    }

    if ( $data->{'Permalink'} ne $url ) {
      $url = $data->{'Permalink'};
      $data->{'UpdatedRequired'} = 1;
    }
  }

  if ( $data->{'Gone'} == 1 ) {
    goto LAST;
  }

  if ( $data->{'LastUpdated'} != 0
    && ( $data->{'LastUpdated'} + 60 * 60 * 24 * 30 ) > scalar(time) )
  {
    goto LAST;
  }

  my %options = ( UserAgent => $client );
  $options{'LastModified'} = $data->{'LastModified'}
    if ( exists $data->{'LastModified'}
    && defined $data->{'LastModified'}
    && $data->{'LastModified'} != 0 );

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

  if ( $res->uri ne $url ) {
    $data->{'UpdatedRequired'} = 1;
    $data->{'Permalink'}       = $res->uri;
  }

  if ( $data->{'Gone'} == 1 ) {
    goto LAST;
  }

  if ( $res->status == 200 ) {
    $data->{'LastModified'} = $res->last_modified;
    $data->{'LastUpdated'}  = time;
    fill( $data, $res );
  }
  elsif ( $res->status =~ m{^3} ) {
    $data->{'LastUpdated'} = time;
    fill( $data, $res );
  }
  else {
    $data->{'Error'} = 'failed to get resource: ' . $res->status;
  }

LAST:

  if ( $updated > 0 ) {
    path($dest)->parent->mkpath;
    DumpFile( $dest, $data );
  }

  return $updated > 0;
}

sub main {
  my $domains = domains;
  my @tasks;
  my $timeout = 0;
  for my $domain ( sort keys $domains->%* ) {
    my @urls = sort keys $domains->{$domain}->%*;
    push @tasks, \@urls;
    $timeout += scalar(@urls) * 10;
  }

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler => sub {
      my @urls = $_[0]->@*;
      for my $url (@urls) {
        if ( fetch($url) ) {
          print $url, "\n";
          sleep 3;
        }
      }

      return {};
    },
    worker_count => 31,
  );

  $bw->add_work(@tasks);
  while ( $bw->pending ) {
    my $ref = $bw->get_result;
    if ( $ref->{'ERROR'} ) {
      warn $ref->{'ERROR'}, "\n";
    }
  }

  $bw->shut_down();

  exit 0;
}

main;
