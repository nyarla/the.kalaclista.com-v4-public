#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use HTML5::DOM;
use Path::Tiny;
use Path::Tiny::Glob;
use URI;
use YAML::XS qw( LoadFile DumpFile Dump );
use Parallel::Fork::BossWorkerAsync;
use URI::Fetch;
use LWP::UserAgent;

my $parser = HTML5::DOM->new;
my @guess  = qw(utf8 euc-jp shiftjis);
my $ua =
  LWP::UserAgent->new( agent =>
'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:90.0) Gecko/20100101 Firefox/90.0',
  );

sub extract_links {
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

sub extract {
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
    work_handler  => sub { return extract_links( $_[0]->@* ) },
    handle_result => sub { return $_[0] },
    worker_count  => 15,
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

sub merge_domain {
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

sub fetch {
  my $url = shift;

  my $updated = 0;
  my $data    = {
    Title          => q{},
    Description    => q{},
    Permalink      => $url,
    Gone           => 0,
    LastUpdated    => 0,
    Lastmod        => 0,
    UpdateRequired => 0,
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

  if ( $data->{'LastUpdated'}
    && ( $data->{'LastUpdated'} + 60 * 60 * 24 * 30 ) > scalar(time) )
  {
    goto LAST;
  }

  my %opts = ( UserAgent => $ua );
  $opts{'LastModified'} = $data->{'Lastmod'} if ( $data->{'Lastmod'} );

  $updated++;
  my $res = URI::Fetch->fetch( $url, %opts );
  if ( !defined $res ) {
    $data->{'Gone'} = 1;

    goto LAST;
  }

  if ( $res->status == 404 || $res->status == 410 || $res->status == 451 ) {
    $data->{'Gone'} = 1;
    goto LAST;
  }

  if ( $res->status == 301
    || $res->status == 302
    || $res->status == 303
    || $res->status == 307
    || $res->status == 308 )
  {
    for ( my $c = 0 ; $c < 5 ; $c++ ) {
      $res = URI::Fetch->fetch( $res->uri, %opts );
      if ( !defined $res ) {
        $data->{'Gone'} = 1;
        last;
      }

      if ( $res->status == 200 || $res->status == 304 ) {
        $data->{'Permalink'}      = $res->uri;
        $data->{'UpdateRequired'} = 1;

        last;
      }
    }

    if ( !defined $res ) {
      $data->{'Gone'} = 1;
      goto LAST;
    }
  }

  if ( $res->status == 200 ) {
    $data->{'Lastmod'}     = $res->last_modified;
    $data->{'LastUpdated'} = time;

    fill( $data, $res );
  }
  elsif ( $res->status == 304 ) {
    $data->{'LastUpdated'} = time;
  }

LAST:

  if ( $updated > 0 ) {
    path($dest)->parent->mkpath;
    DumpFile( $dest, $data );
  }

  return $updated > 0;
}

sub fill {
  my ( $data, $res ) = @_;
  my $dom = $parser->parse( $res->content );

  my $title       = q{};
  my $description = q{};

  # title
  if ( defined( my $e = $dom->at('meta[property="og:title"]') ) ) {
    $title = $e->getAttribute('content');
    goto DESC;
  }

  if ( defined( my $e = $dom->at('meta[name="twitter:title"]') ) ) {
    $title = $e->getAttribute('content');
    goto DESC;
  }

  if ( defined( my $e = $dom->at('title') ) ) {
    $title = $e->textContent;
  }

DESC:

  # description
  if ( defined( my $e = $dom->at('meta[property="og:description"]') ) ) {
    $description = $e->getAttribute('content');
    goto LAST;
  }

  if ( defined( my $e = $dom->at('meta[name="twitter:description"]') ) ) {
    $description = $e->getAttribute('content');
    goto LAST;
  }

  if ( defined( my $e = $dom->at('meta[name="description"]') ) ) {
    $description = $e->getAttribute('content');
  }

LAST:
  utf8::decode($title);
  utf8::decode($description);

  $data->{'Title'}       = $title;
  $data->{'Description'} = $description;

  return;
}

sub gets {
  my @urls = @_;

  for my $url ( sort @urls ) {
    print $url, "\n";
    if ( fetch($url) ) {
      sleep 3;
    }
  }

  return {};
}

sub main {
  extract;
  my $domains = merge_domain;

  my @tasks;
  for my $domain ( sort keys $domains->%* ) {
    my @urls = sort keys $domains->{$domain}->%*;
    push @tasks, \@urls;
  }

  my $bw = Parallel::Fork::BossWorkerAsync->new(
    work_handler  => sub { return gets( $_[0]->@* ) },
    handle_result => sub { return $_[0] },
    worker_count  => 15,
  );

  $bw->add_work(@tasks);
  while ( $bw->pending ) {
    my $ref = $bw->get_result;
    if ( $ref->{'ERROR'} ) {
      print STDERR $ref->{'ERROR'}, "\n";
    }
  }

  $bw->shut_down();
}

main;
