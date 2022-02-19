use strict;
use warnings;
use utf8;

package Kalaclista::Test;

use HTML5::DOM;
use URI::Escape;
use JSON::XS qw(decode_json);

use Test2::V0;

use Exporter 'import';

our @EXPORT_OK = qw(
  parse

  description_ok
  feeds_ok
  icons_ok
  jsonld_ok
  manifest_ok
  ogp_ok
  preload_ok
  twcard_ok
  utf8_ok

  archive_ok
  entry_ok
  footer_ok
  header_ok
  related_ok

  relpath_is
  title_is

  is_date
  is_datetime
  is_echos
  is_entries
  is_notes
  is_pages
  is_posts
  is_section
);

my $parser = HTML5::DOM->new( { utf8 => 1 } );

sub parse ($) {
  my $html = shift;
  return $parser->parse($html);
}

sub attr ($$$) {
  my ( $dom, $selector, $attr ) = @_;

  my $elm = $dom->at($selector);
  if ( !defined $elm ) {
    diag($selector);
    return q{};
  }

  return $elm->getAttribute($attr);
}

sub attrs ($$$) {
  my ( $dom, $selector, $attr ) = @_;
  return map { $_->getAttribute($attr) } $dom->find($selector)->@*;
}

sub content ($$) {
  my ( $dom, $selector ) = @_;

  my $elm = $dom->at($selector);
  if ( !defined $elm ) {
    diag($selector);
    return q{};
  }

  return $elm->textContent;
}

sub description_ok ($) {
  my $dom = shift;

  my $ogp  = attr $dom, 'meta[property="og:description"]'  => 'content';
  my $tw   = attr $dom, 'meta[name="twitter:description"]' => 'content';
  my $meta = attr $dom, 'meta[name="description"]'         => 'content';

  is( $ogp, $tw );
  is( $ogp, $meta );
  is( $tw,  $meta );
}

sub feeds_ok ($;$) {
  my ( $dom, $section ) = @_;

  my %tests = (
    'atom+xml'  => 'atom.xml',
    'rss+xml'   => 'index.xml',
    'feed+json' => 'jsonfeed.json',
  );

  for my $type ( sort keys %tests ) {
    my $href = attr $dom,
      qq<link[rel="alternate"][type="application/${type}"]>, 'href';

    my $path = '/' . $tests{$type};

    if ( defined $section && $section ne q{} ) {
      $path = "/${section}" . $path;
    }

    relpath_is( $href, $path );
  }
}

sub icons_ok ($) {
  my $dom = shift;

  my @icons = attrs $dom, 'link[rel="icon"]', 'href';

  relpath_is( $icons[0], '/favicon.ico' );
  relpath_is( $icons[1], '/icon.svg' );

  my $apple = attr $dom, 'link[rel="apple-touch-icon"]', 'href';

  relpath_is( $apple, '/apple-touch-icon.png' );
}

sub jsonld_ok {
  my ( $dom, $section ) = @_;

  my $permalink = $dom->at('link[rel="canonical"]')->getAttribute('href');
  my $json      = $dom->at('script[type="application/ld+json"]')->textContent;

  utf8::encode($json);

  my $data = decode_json($json);
  my $self = $data->[0];
  my $tree = $data->[1];

  # .image
  is(
    $self->{'image'},
    {
      '@type' => 'URL',
      'url'   => 'https://the.kalaclista.com/assets/avatar.png',
    }
  );

  # .author
  is(
    $self->{'author'},
    {
      '@type' => 'Person',
      'name'  => 'OKAMURA Naoki aka nyarla',
      'email' => 'nyarla@kalaclista.com',
    }
  );

  # .publisher
  is(
    $self->{'publisher'},
    {
      '@type' => 'Organization',
      'name'  => 'the.kalaclista.com',
      'logo'  => {
        '@type' => 'ImageObject',
        'url'   => {
          '@type' => 'URL',
          'url'   => 'https://the.kalaclista.com/assets/avatar.png',
        }
      },
    }
  );

  # .headline
  is( $self->{'headline'},
    attr( $dom, 'meta[property="og:title"]', 'content' ) );

  my @tree = ();
  push @tree,
    +{
    '@type'    => 'ListItem',
    'position' => 1,
    'name'     => 'カラクリスタ',
    'item'     => 'https://the.kalaclista.com/',
    };

  if ( defined $section && $section ne q{} ) {
    if ( $section eq q{posts} || $section eq q{echos} ) {
      push @tree,
        +{
        '@type'    => 'ListItem',
        'position' => 2,
        'item'     => $self->{'mainEntryOfPage'}->{'@id'},
        'name'     => 'カラクリスタ・' . ( $section eq 'posts' ? 'ブログ' : 'エコーズ' ),
        };

      if ( $permalink =~ m{/[^/]+/\d{4}/} ) {
        push @tree,
          +{
          '@type'    => 'ListItem',
          'position' => 3,
          'item'     => $permalink,
          'name'     => $self->{'headline'},
          };
      }
    }
    elsif ( $section eq 'notes' ) {
      push @tree,
        +{
        '@type'    => 'ListItem',
        'position' => 2,
        'item'     => $self->{'mainEntryOfPage'}->{'@id'},
        'name'     => 'カラクリスタ・ノート'
        };
      if ( $permalink =~ m{/notes/[^/]+/$} ) {
        push @tree,
          +{
          '@type'    => 'ListItem',
          'position' => 3,
          'item'     => $permalink,
          'name'     => $self->{'headline'},
          };
      }
    }
  }
  else {
    push @tree,
      +{
      '@type'    => 'ListItem',
      'position' => 2,
      'item'     => $permalink,
      'name'     => $self->{'headline'},
      };
  }

  is(
    $tree,
    {
      '@context'        => 'https://schema.org',
      '@type'           => 'BreadcrumbList',
      'itemListElement' => \@tree,
    }
  );

  if ( $self->{'@type'} eq 'BlogPosting'
    || $self->{'@type'} eq 'Article'
    || $self->{'@type'} eq 'WebPage' )
  {
    is_datetime( $self->{'datePublished'} );
    is_datetime( $self->{'dateModified'} );
  }

  if ( defined $section && $section ne q{} ) {
    relpath_is( $self->{'mainEntryOfPage'}->{'@id'}, "/${section}/" );
    if ( $section eq q{posts} ) {
      is( $self->{'@type'},
        ( $permalink =~ m{\d{6}/$} ? 'BlogPosting' : 'Blog' ) );
    }
    elsif ( $section eq q{echos} ) {
      is( $self->{'@type'},
        ( $permalink =~ m{\d{6}/$} ? 'BlogPosting' : 'Blog' ) );
    }
    elsif ( $section eq q{notes} ) {
      is( $self->{'@type'},
        ( $permalink =~ m{notes/[^/]+/$} ? 'Article' : 'WebSite' ) );
    }
  }
  else {
    relpath_is( $self->{'mainEntryOfPage'}->{'@id'}, "/" );
    is( $self->{'@type'}, 'WebPage' );
  }
}

sub _jsonld_selfnode_ok {
  my $data    = shift;
  my $section = shift;

  is_datetime( $data->{'datePublished'} );
  is_datetime( $data->{'dateModified'} );
}

sub manifest_ok ($) {
  my $dom = shift;

  my $href = attr $dom, 'link[rel="manifest"]', 'href';

  relpath_is( $href, '/manifest.webmanifest' );
}

sub ogp_ok {
  my $dom = shift;

  # og:image
  my $image = attr $dom, 'meta[property="og:image"]', 'content';
  relpath_is( $image, '/assets/avatar.png' );

  # og:title, og:site_name
  my $title    = attr $dom,    'meta[property="og:title"]',     'content';
  my $siteName = attr $dom,    'meta[property="og:site_name"]', 'content';
  my $combined = content $dom, 'title';

  if ( $title ne $siteName ) {
    is( $combined, join( q{ - }, $title, $siteName ) );
  }
  else {
    is( $combined, $title );
    is( $combined, $siteName );
  }

  # og:profile
  is( attr( $dom, 'meta[property="og:profile:first_name"]', 'content' ),
    'Naoki' );
  is( attr( $dom, 'meta[property="og:profile:last_name"]', 'content' ),
    'OKAMURA' );
  is( attr( $dom, 'meta[property="og:profile:username"]', 'content' ),
    'kalaclista' );

  if ( $title eq '404 page not found' ) {
    return;
  }

  is(
    attr( $dom, 'meta[property="og:url"]', 'content' ),
    attr( $dom, 'link[rel="canonical"]',   'href' ),
  );

  # og:type, og:article
  my $canonical = attr $dom, 'link[rel="canonical"]',    'href';
  my $type      = attr $dom, 'meta[property="og:type"]', 'content';

  if ( $type eq 'article' ) {
    is_datetime(
      attr( $dom, 'meta[property="og:article:published_time"]', 'content' ) );
    is_datetime(
      attr( $dom, 'meta[property="og:article:modified_time"]', 'content' ) );

    is( attr( $dom, 'meta[property="og:article:author"]', 'content' ),
      'OKAMURA Naoki aka nyarla' );

    my $section = attr $dom, 'meta[property="og:article:section"]', 'content';

    if ( $canonical =~ m{/posts/} ) {
      is( $section, 'ブログ' );
      is_entries($canonical);
    }
    elsif ( $canonical =~ m{/echos/} ) {
      is( $section, '日記' );
      is_entries($canonical);
    }
    elsif ( $canonical =~ m{/notes/} ) {
      is( $section, 'メモ帳' );
      is_entries($canonical);
    }
  }
  else {
    is( $type, 'website' );
    is_section($canonical);
  }
}

sub preload_ok {
  my $dom = shift;

  my $font = attr $dom, 'link[rel="preload"][as="font"][crossorigin]', 'href';
  relpath_is( $font, '/assets/Inconsolata.subset.woff2' );

  my $prefetch = attr $dom, 'meta[http-equiv="x-dns-prefetch-control"]',
    'content';
  is( $prefetch, 'on' );
}

sub twcard_ok {
  my $dom = shift;

  is( attr( $dom, 'meta[name="twitter:card"]', 'content' ), 'summary' );

  is( attr( $dom, 'meta[name="twitter:site"]', 'content' ), '@kalaclista' );

  is(
    attr( $dom, 'meta[name="twitter:title"]', 'content' ),
    attr( $dom, 'meta[property="og:title"]',  'content' )
  );

  is(
    attr( $dom, 'meta[name="twitter:description"]', 'content' ),
    attr( $dom, 'meta[property="og:description"]',  'content' )
  );

  relpath_is( attr( $dom, 'meta[name="twitter:image"]', 'content' ),
    '/assets/avatar.png', );
}

sub utf8_ok {
  my $dom = shift;
  is( attr( $dom, 'meta[charset]', 'charset' ), 'utf-8' );
}

sub archive_ok {
  my ( $dom, $section ) = @_;

  my $article = $dom->at('.entry');

  if ( $section eq q{posts} ) {
    is( content( $article, 'header h1 a' ), 'カラクリスタ・ブログ' );
    relpath_is( attr( $article, 'header h1 a', 'href' ), "/${section}/" );
  }
  elsif ( $section eq q{echos} ) {
    is( content( $article, 'header h1 a' ), 'カラクリスタ・エコーズ' );
    relpath_is( attr( $article, 'header h1 a', 'href' ), "/${section}/" );
  }
  elsif ( $section eq q{notes} ) {
    is( content( $article, 'header h1 a' ), 'カラクリスタ・ノート' );
    relpath_is( attr( $article, 'header h1 a', 'href' ), "/${section}/" );
  }

  for my $item ( $dom->find('.entry__content .archives li')->@* ) {
    is_date( $item->at('time')->getAttribute('datetime') );
    if ( $section eq q{posts} ) {
      is_posts( attr( $item, 'a', 'href' ) );
    }
    elsif ( $section eq q{echos} ) {
      is_echos( attr( $item, 'a', 'href' ) );
    }
    if ( $section eq q{notes} ) {
      is_notes( attr( $item, 'a', 'href' ) );
    }

    if ( $section ne q{notes} ) {
      for my $link ( attrs $item, '.entry__content p:last-child a', 'href' ) {
        is_section($link);
      }
    }
  }
}

sub entry_ok {
  my $dom = shift;

  my $entry = $dom->at('article.entry');

  is_date( attr( $entry, 'header p time', 'datetime' ) );
  ok( $entry->at('header p span') );

  is_pages( attr( $entry, 'header h1 a', 'href' ) );
  ok( $entry->at('.entry__content') );
}

sub footer_ok {
  my $dom = shift;

  relpath_is( attr( $dom, '#copyright p a', 'href' ), '/nyarla/' );
}

sub header_ok {
  my $dom = shift;

  relpath_is( attr( $dom, '#global p a',         'href' ), '/' );
  relpath_is( attr( $dom, '#profile figure p a', 'href' ), '/nyarla/' );

  relpath_is( attr( $dom, '#profile figure p a img', 'src' ),
    '/assets/avatar.svg' );
  relpath_is( attr( $dom, '#profile figure figcaption a', 'href' ),
    '/nyarla/' );

  my @links = attrs $dom, '#profile nav p a', 'href';

  is( $links[0], 'https://github.com/nyarla' );
  is( $links[1], 'https://zenn.dev/nyarla' );
  is( $links[2], 'https://twitter.com/kalaclista' );

  my @kinds = attrs $dom, '#menu .kind a', 'href';
  relpath_is( $kinds[0], '/posts/' );
  relpath_is( $kinds[1], '/echos/' );
  relpath_is( $kinds[2], '/notes/' );

  my @internal = attrs $dom, '#menu .links a', 'href';
  relpath_is( $internal[0], '/policies/' );
  relpath_is( $internal[1], '/licenses/' );

  is( $internal[2],
    'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0'
  );
}

sub related_ok {
  my $dom = shift;

  my $entries = $dom->find('.entry__related .archives li');

  for my $entry ( $entries->@* ) {
    is_date( attr( $entry, 'time', 'datetime' ) );

    my @links = attrs $entry, 'a', 'href';

    is_section( $links[0] );
    is_entries( $links[1] );
  }
}

sub relpath_is ($$) {
  my ( $target, $suffix ) = @_;

  is( $target, "https://the.kalaclista.com" . $suffix );
}

sub title_is {
  my ( $dom, $text ) = @_;
  is( $dom->at('title')->textContent, $text );
}

sub is_date {
  my $text = shift;
  like( $text, qr<^\d{4}-\d{2}-\d{2}$> );
}

sub is_datetime {
  my $text = shift;
  like( $text, qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)$> );
}

sub is_echos {
  my $src = shift;
  like( $src,
    qr<^https://the\.kalaclista\.com/echos/\d{4}/\d{2}/\d{2}/\d{6}/$> );
}

sub is_entries {
  my $src = shift;

  like( $src,
    qr<^https://the.kalaclista.com/[^/]+/(?:[^/]+/|\d{4}/\d{2}/\d{2}/\d{6}/)> );
}

sub is_notes {
  my $src = shift;
  like( $src, qr<^https://the\.kalaclista\.com/notes/[^/]+/$> );
}

sub is_pages {
  my $src = shift;

  like( $src,
qr<^https://the.kalaclista.com/(?:(?:nyarla|policies|licenses)/|[^/]+/(?:[^/]+|\d{4}/\d{2}/\d{2}/\d{6})/)>
  );
}

sub is_posts {
  my $src = shift;
  like( $src,
    qr<^https://the\.kalaclista\.com/posts/\d{4}/\d{2}/\d{2}/\d{6}/$> );
}

sub is_section {
  my $src = shift;
  like( $src, qr<^https://the\.kalaclista\.com/[^/]+/(?:\d{4}/)?$> );
}

1;
