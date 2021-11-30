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

sub parse {
  my $html = shift;
  return $parser->parse($html);
}

sub description_ok {
  my $dom = shift;

  my $ogp = $dom->at('meta[name="description"]')->getAttribute('content');
  my $tw = $dom->at('meta[property="og:description"]')->getAttribute('content');
  my $html = $dom->at('meta[name="description"]')->getAttribute('content');

  is( $ogp, $tw );
  is( $ogp, $html );
  is( $tw,  $html );
}

sub feeds_ok {
  my ( $dom, $section ) = @_;

  my $atom = $dom->at('link[rel="alternate"][type="application/atom+xml"]');
  my $rss  = $dom->at('link[rel="alternate"][type="application/rss+xml"]');
  my $json = $dom->at('link[rel="alternate"][type="application/feed+json"]');

  if ( $section ne q{} ) {
    relpath_is( $atom->getAttribute('href'), '/' . $section . '/atom.xml' );
    relpath_is( $rss->getAttribute('href'),  '/' . $section . '/index.xml' );
    relpath_is( $json->getAttribute('href'),
      '/' . $section . '/jsonfeed.json' );
  }
  else {
    relpath_is( $atom->getAttribute('href'), '/atom.xml' );
    relpath_is( $rss->getAttribute('href'),  '/index.xml' );
    relpath_is( $json->getAttribute('href'), '/jsonfeed.json' );
  }

}

sub icons_ok {
  my $dom = shift;

  my $icons = $dom->find('link[rel="icon"]');

  relpath_is( $icons->[0]->getAttribute('href'), '/favicon.ico' );
  relpath_is( $icons->[1]->getAttribute('href'), '/icon.svg' );

  relpath_is( $dom->at('link[rel="apple-touch-icon"]')->getAttribute('href'),
    '/apple-touch-icon.png' );
}

sub jsonld_ok {
  my ( $dom, $section ) = @_;

  my $permalink = $dom->at('link[rel="canonical"]')->getAttribute('href');
  my $json      = $dom->at('script[type="application/ld+json"]')->textContent;

  utf8::encode($json);

  my $data = decode_json($json);
  my $self = $data->[0];
  my $tree = $data->[1];

  # basical properties
  _jsonld_context_ok($self);
  _jsonld_image_ok( $self->{'image'} );
  _jsonld_author_ok( $self->{'author'} );
  _jsonld_publisher_ok( $self->{'publisher'} );

  # title
  is( $self->{'headline'},
    $dom->at('meta[property="og:title"]')->getAttribute('content'),
  );

  # breadcrumb root
  my $root = {
    '@type'    => 'ListItem',
    'position' => 1,
    'name'     => 'カラクリスタ',
    'item'     => 'https://the.kalaclista.com/',
  };

  if ( $permalink =~
    m{^https://the\.kalaclista\.com/(?:nyarla|policies|licenses)/$} )
  {    # root pages
    is_datetime( $self->{'datePublished'} );
    is_datetime( $self->{'dateModified'} );

    relpath_is( $self->{'mainEntryOfPage'}->{'@id'}, '/' );

    is( $self->{'@type'}, 'WebPage' );

    my $leaf = {
      '@type'    => 'ListItem',
      'position' => 2,
      'item'     => $permalink,
      'name'     => $self->{'headline'},
    };

    is(
      $tree,
      {
        '@context'        => 'https://schema.org',
        '@type'           => 'BreadcrumbList',
        'itemListElement' => [ $root, $leaf, ],
      }
    );
  }
  elsif ( $permalink =~ m{^https://the\.kalaclista\.com/[^/]+/\d{4}/$} )
  {    # archive pages
    relpath_is( $self->{'mainEntryOfPage'}->{'@id'}, '/' . $section . '/' );

    my $branch = {
      '@type'    => 'ListItem',
      'position' => 2,
      'item'     => $self->{'mainEntryOfPage'}->{'@id'},
    };

    my $leaf = {
      '@type'    => 'ListItem',
      'position' => 3,
      'item'     => $permalink,
      'name'     => $self->{'headline'},
    };

    if ( $section eq q{posts} ) {
      $branch->{'name'} = 'カラクリスタ・ブログ';
      is( $self->{'@type'}, 'Blog' );
    }
    elsif ( $section eq q{echos} ) {
      $branch->{'name'} = 'カラクリスタ・エコーズ';
      is( $self->{'@type'}, 'Blog' );
    }
    elsif ( $section eq q{notes} ) {
      $branch->{'name'} = 'カラクリスタ・ノート';
      is( $self->{'@type'}, 'WebSite' );
    }

    is(
      $tree,
      {
        '@context'        => 'https://schema.org',
        '@type'           => 'BreadcrumbList',
        'itemListElement' => [ $root, $branch, $leaf ],
      }
    );
  }
  elsif ( $permalink =~
    m{^https://the\.kalaclista\.com/[^/]+/(?:[^/]+|\d{4}/\d{2}/\d{2}/\d{6})/$} )
  {    # entries page
    is_datetime( $self->{'datePublished'} );
    is_datetime( $self->{'dateModified'} );

    relpath_is( $self->{'mainEntryOfPage'}->{'@id'}, '/' . $section . '/' );

    my $branch = {
      '@type'    => 'ListItem',
      'position' => 2,
      'item'     => $self->{'mainEntryOfPage'}->{'@id'},
    };

    my $leaf = {
      '@type'    => 'ListItem',
      'position' => 3,
      'item'     => $permalink,
      'name'     => $self->{'headline'},
    };

    if ( $section eq q{posts} ) {
      $branch->{'name'} = 'カラクリスタ・ブログ';
      is( $self->{'@type'}, 'BlogPosting' );
    }
    elsif ( $section eq q{echos} ) {
      $branch->{'name'} = 'カラクリスタ・エコーズ';
      is( $self->{'@type'}, 'BlogPosting' );
    }
    elsif ( $section eq q{notes} ) {
      $branch->{'name'} = 'カラクリスタ・ノート';
      is( $self->{'@type'}, 'Article' );
    }

    is(
      $tree,
      {
        '@context'        => 'https://schema.org',
        '@type'           => 'BreadcrumbList',
        'itemListElement' => [ $root, $branch, $leaf ],
      }
    );
  }

  elsif ( $permalink =~ m{^https://the\.kalaclista\.com/[^/]+/$} )
  {    # section page
    relpath_is( $self->{'mainEntryOfPage'}->{'@id'}, '/' . $section . '/' );

    my $leaf = {
      '@type'    => 'ListItem',
      'position' => 2,
      'item'     => $permalink,
      'name'     => $self->{'headline'},
    };

    if ( $section eq q{posts} ) {
      $leaf->{'name'} = 'カラクリスタ・ブログ';
      is( $self->{'@type'}, 'Blog' );
    }
    elsif ( $section eq q{echos} ) {
      $leaf->{'name'} = 'カラクリスタ・エコーズ';
      is( $self->{'@type'}, 'Blog' );
    }
    elsif ( $section eq q{notes} ) {
      $leaf->{'name'} = 'カラクリスタ・ノート';
      is( $self->{'@type'}, 'WebSite' );
    }

    is(
      $tree,
      {
        '@context'        => 'https://schema.org',
        '@type'           => 'BreadcrumbList',
        'itemListElement' => [ $root, $leaf ],
      }
    );
  }
}

sub _jsonld_context_ok {
  my $data = shift;
  is( $data->{'@context'}, 'https://schema.org' );
}

sub _jsonld_image_ok {
  my $data = shift;
  is( $data->{'@type'}, 'URL' );
  is( $data->{'url'},   'https://the.kalaclista.com/assets/avatar.png' );
}

sub _jsonld_author_ok {
  my $data = shift;
  is( $data->{'@type'}, 'Person' );
  is( $data->{'name'},  'OKAMURA Naoki aka nyarla' );
  is( $data->{'email'}, 'nyarla@kalaclista.com' );
}

sub _jsonld_publisher_ok {
  my $data = shift;
  is( $data->{'@type'},                    'Organization' );
  is( $data->{'name'},                     'the.kalaclista.com' );
  is( $data->{'logo'}->{'@type'},          'ImageObject' );
  is( $data->{'logo'}->{'url'}->{'@type'}, 'URL' );
  is( $data->{'logo'}->{'url'}->{'url'},
    'https://the.kalaclista.com/assets/avatar.png' );
}

sub _jsonld_selfnode_ok {
  my $data    = shift;
  my $section = shift;

  is_datetime( $data->{'datePublished'} );
  is_datetime( $data->{'dateModified'} );
}

sub manifest_ok {
  my $dom = shift;
  relpath_is( $dom->at('link[rel="manifest"]')->getAttribute('href'),
    '/manifest.webmanifest', );
}

sub ogp_ok {
  my $dom = shift;

  # og:image
  relpath_is( $dom->at('meta[property="og:image"]')->getAttribute('content'),
    '/assets/avatar.png' );

  # og:title, og:site_name
  my $title = $dom->at('meta[property="og:title"]')->getAttribute('content');
  my $siteTitle =
    $dom->at('meta[property="og:site_name"]')->getAttribute('content');
  my $combinedTitle = $dom->at('title')->textContent;

  # not a section index
  if ( $title ne $siteTitle ) {
    is( $combinedTitle, $title . ' - ' . $siteTitle );
  }
  else {
    is( $combinedTitle, $title );
    is( $combinedTitle, $siteTitle );
  }

  # og:url
  if ( $title ne '404 page not found' ) {
    is(
      $dom->at('meta[property="og:url"]')->getAttribute('content'),
      $dom->at('link[rel="canonical"]')->getAttribute('href'),
    );

    # og:type, og:article
    if ( $dom->at('link[rel="canonical"]')->getAttribute('href') !~
      m{(?:posts|echos|notes)/(?:\d{4}/)?$} )
    {
      is( $dom->at('meta[property="og:type"]')->getAttribute('content'),
        ('article') );

      is_datetime( $dom->at('meta[property="og:article:published_time"]')
          ->getAttribute('content') );
      is_datetime( $dom->at('meta[property="og:article:modified_time"]')
          ->getAttribute('content') );

      is(
        $dom->at('meta[property="og:article:author"]')->getAttribute('content'),
        'OKAMURA Naoki aka nyarla'
      );

      my $article =
        $dom->at('meta[property="og:article:section"]')
        ->getAttribute('content');
      my $permalink = $dom->at('link[rel="canonical"]')->getAttribute('href');

      if ( $permalink =~ m{/posts/} ) {
        is( $article, 'ブログ' );
      }
      elsif ( $permalink =~ m{/echos/} ) {
        is( $article, '日記' );
      }
      elsif ( $permalink =~ m{/notes/} ) {
        is( $article, 'メモ帳' );
      }
    }
    else {
      is( $dom->at('meta[property="og:type"]')->getAttribute('content'),
        'website' );
    }
  }

  # og:profile
  is(
    $dom->at('meta[property="og:profile:first_name"]')->getAttribute('content'),
    'Naoki'
  );

  is(
    $dom->at('meta[property="og:profile:last_name"]')->getAttribute('content'),
    'OKAMURA'
  );

  is( $dom->at('meta[property="og:profile:username"]')->getAttribute('content'),
    'kalaclista' );

}

sub preload_ok {
  my $dom = shift;

  my $font = $dom->at('link[rel="preload"][as="font"][crossorigin]');
  relpath_is( $font->getAttribute('href'), '/assets/Inconsolata.subset.woff2' );

  is(
    $dom->at('meta[http-equiv="x-dns-prefetch-control"]')
      ->getAttribute('content'),
    'on'
  );

  my @domains = (
    '//googleads.g.doubleclick.net', '//www.google-analytics.com',
    '//stats.g.doubleclick.net',     '//www.google.com',
    '//www.google.co.jp',            '//pagead2.googlesyndication.com',
    '//tpc.googlesyndication.com',   '//accounts.google.com',
    '//www.googletagmanager.com',
  );

  my $preConnect  = $dom->find('link[rel*="preconnect"]');
  my $dnsPrefetch = $dom->find('link[rel*="dns-prefetch"]');

  for my $idx ( 0 .. ( scalar(@domains) - 1 ) ) {
    is( $preConnect->[$idx]->getAttribute('href'),  $domains[$idx] );
    is( $dnsPrefetch->[$idx]->getAttribute('href'), $domains[$idx] );
  }

}

sub twcard_ok {
  my $dom = shift;

  is( $dom->at('meta[name="twitter:card"]')->getAttribute('content'),
    'summary' );

  is( $dom->at('meta[name="twitter:site"]')->getAttribute('content'),
    '@kalaclista' );

  is(
    $dom->at('meta[name="twitter:title"]')->getAttribute('content'),
    $dom->at('meta[property="og:title"]')->getAttribute('content'),
  );
  is(
    $dom->at('meta[name="twitter:description"]')->getAttribute('content'),
    $dom->at('meta[property="og:description"]')->getAttribute('content'),
  );

  relpath_is( $dom->at('meta[name="twitter:image"]')->getAttribute('content'),
    '/assets/avatar.png', );
}

sub utf8_ok {
  my $dom = shift;
  is( $dom->at('meta[charset]')->getAttribute('charset'), 'utf-8' );
}

sub archive_ok {
  my $dom     = shift;
  my $section = shift;

  my $article = $dom->at('.entry');

  # header title
  if ( $section eq q{posts} ) {
    is( $article->at('header h1 a')->textContent, 'カラクリスタ・ブログ' );
    relpath_is( $article->at('header h1 a')->getAttribute('href'),
      '/' . $section . '/' );
  }
  elsif ( $section eq q{echos} ) {
    is( $article->at('header h1 a')->textContent, 'カラクリスタ・エコーズ' );
    relpath_is( $article->at('header h1 a')->getAttribute('href'),
      '/' . $section . '/' );
  }
  elsif ( $section eq q{notes} ) {
    is( $article->at('header h1 a')->textContent, 'カラクリスタ・ノート' );
    relpath_is( $article->at('header h1 a')->getAttribute('href'),
      '/' . $section . '/' );
  }

  for my $item ( $dom->find('.entry__content .archives li')->@* ) {
    is_date( $item->at('time')->getAttribute('datetime') );
    if ( $section eq q{posts} ) {
      is_posts( $item->at('a')->getAttribute('href') );
    }
    elsif ( $section eq q{echos} ) {
      is_echos( $item->at('a')->getAttribute('href') );
    }
    if ( $section eq q{notes} ) {
      is_notes( $item->at('a')->getAttribute('href') );
    }
  }

  if ( $section ne q{notes} ) {
    for my $item ( $article->find('.entry__content p:last-child a')->@* ) {
      like( $item->getAttribute('href'),
        qr<^https://the\.kalaclista\.com/${section}/\d{4}/$> );
    }
  }
}

sub entry_ok {
  my $dom = shift;

  my $entry = $dom->at('article.entry');

  is_date( $entry->at('header p time')->getAttribute('datetime') );
  ok( $entry->at('header p span') );
  is_pages( $entry->at('header h1 a')->getAttribute('href') );

  ok( $entry->at('.entry__content') );
}

sub footer_ok {
  my $dom = shift;

  relpath_is( $dom->at('#copyright p a')->getAttribute('href'), '/nyarla/' );
}

sub header_ok {
  my $dom = shift;

  relpath_is( $dom->at('#global p a')->getAttribute('href'), '/' );
  relpath_is( $dom->at('#profile figure p a')->getAttribute('href'),
    '/nyarla/' );

  relpath_is( $dom->at('#profile figure p a img')->getAttribute('src'),
    '/assets/avatar.svg' );

  relpath_is( $dom->at('#profile figure figcaption a')->getAttribute('href'),
    '/nyarla/' );

  my $links = $dom->find('#profile nav p a');

  is( $links->[0]->getAttribute('href'), 'https://github.com/nyarla' );
  is( $links->[1]->getAttribute('href'), 'https://zenn.dev/nyarla' );
  is( $links->[2]->getAttribute('href'), 'https://twitter.com/kalaclista' );
  is( $links->[3]->getAttribute('href'), 'https://raindrop.io/kalaclista' );

  my $kind = $dom->find('#menu .kind a');
  relpath_is( $kind->[0]->getAttribute('href'), '/posts/' );
  relpath_is( $kind->[1]->getAttribute('href'), '/echos/' );
  relpath_is( $kind->[2]->getAttribute('href'), '/notes/' );

  my $internal = $dom->find('#menu .links a');
  relpath_is( $internal->[0]->getAttribute('href'), '/policies/' );
  relpath_is( $internal->[1]->getAttribute('href'), '/licenses/' );

  is(
    $internal->[2]->getAttribute('href'),
    'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0',
  );
}

sub related_ok {
  my $dom = shift;

  my $entries = $dom->find('.entry__related .archives li');

  for my $entry ( $entries->@* ) {
    my $time  = $entry->at('time');
    my $links = $entry->find('a');

    is_date( $time->getAttribute('datetime') );

    my $section = $links->[0];
    is_section( $section->getAttribute('href') );

    my $link = $links->[1];

    is_entries( $link->getAttribute('href') );
  }
}

sub relpath_is {
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
  like( $src, qr<^https://the\.kalaclista\.com/[^/]+/$> );
}

1;
