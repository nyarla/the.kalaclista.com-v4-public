use strict;
use warnings;

package Kalaclista::Test;

use HTML5::DOM;
use URI::Escape;
use JSON::Tiny qw(decode_json);

use Test2::V0;

my $parser = HTML5::DOM->new;

sub parse_html {
  my ( $class, $html ) = @_;
  return $parser->parse($html);
}

sub header_links_ok {
  my ( $class, $dom, $section ) = @_;

  is( $dom->at('#website__name strong a')->getAttribute('href'),
    'https://the.kalaclista.com/' );

  if ( $section ne 'home' ) {
    is( $dom->at('#website__contents em a')->getAttribute('href'),
      "https://the.kalaclista.com/${section}/" );
  }

  is(
    $dom->at('#website__contents *:nth-child(1) a')->getAttribute('href'),
    "https://the.kalaclista.com/posts/",
  );

  is(
    $dom->at('#website__contents *:nth-child(2) a')->getAttribute('href'),
    "https://the.kalaclista.com/echos/",
  );

  is(
    $dom->at('#website__contents *:nth-child(3) a')->getAttribute('href'),
    "https://the.kalaclista.com/notes/",
  );
}

sub footer_links_ok {
  my ( $class, $dom ) = @_;
  is(
    $dom->at('#website__informations *:first-child span a')
      ->getAttribute('href'),
    'https://cse.google.com/cse?cx=018101178788962105892:toz3mvb2bhr#gsc.tab=0'
  );

  is(
    $dom->at('#website__informations *:last-child *:nth-child(1) a')
      ->getAttribute('href'),
    "https://the.kalaclista.com/nyarla/",
  );

  is(
    $dom->at('#website__informations *:last-child *:nth-child(2) a')
      ->getAttribute('href'),
    "https://the.kalaclista.com/policies/",
  );

  is(
    $dom->at('#website__informations *:last-child *:nth-child(3) a')
      ->getAttribute('href'),
    "https://the.kalaclista.com/licenses/",
  );
}

sub entry_structure_ok {
  my ( $class, $dom, $section ) = @_;

  like( $dom->at('.entry header p time')->getAttribute('datetime'),
    qr(^\d{4}-\d{2}-\d{2}$) );

  like( $dom->at('.entry header p time')->textContent(),
    qr(^\d{4}-\d{2}-\d{2}$) );

  is( $dom->at('.entry header p span a')->getAttribute('href'),
    'https://the.kalaclista.com/nyarla/' );

  is( $dom->at('.entry header p span a')->textContent(), '@nyarla' );

  like(
    $dom->at('.entry header h1 a')->getAttribute('href'),
    qr<^https://the.kalaclista.com/[^/]+/(?:\d{4}/\d{2}/\d{2}/\d{6}/|[^/]+/)$>,
  );

  ok( scalar( $dom->find('.entry__ad')->@* ) > 0 );

  ok( $dom->at('.entry__content') );
}

sub meta_utf8_ok {
  my ( $class, $dom ) = @_;

  is( $dom->at('meta[charset]')->getAttribute('charset'), 'utf-8' );
}

sub meta_icons_ok {
  my ( $class, $dom ) = @_;

  is(
    $dom->at('link[rel="icon"]')->getAttribute('href'),
    'https://the.kalaclista.com/favicon.ico'
  );

  my $icons = $dom->find('link[rel="icon"]');

  is(
    $icons->[0]->getAttribute('href'),
    'https://the.kalaclista.com/favicon.ico'
  );

  is( $icons->[1]->getAttribute('href'),
    'https://the.kalaclista.com/icon.svg' );

  is(
    $dom->at('link[rel="apple-touch-icon"]')->getAttribute('href'),
    'https://the.kalaclista.com/apple-touch-icon.png'
  );
}

sub meta_canonical_ok {
  my ( $class, $dom, $basedir, $path ) = @_;

  utf8::decode($basedir);
  utf8::decode($path);

  $path =~ s{^$basedir/}{};
  $path =~ s{index\.html$}{};

  if ( $path =~ m{^notes} ) {
    $path =~ s{notes/([^/]+)/}{"notes/" . uri_escape_utf8($1) . "/"}e;
  }

  my $permalink = "https://the.kalaclista.com/${path}";

  is( $dom->at('link[rel="canonical"]')->getAttribute('href'), $permalink );
}

sub meta_manifest_ok {
  my ( $class, $dom ) = @_;
  is(
    $dom->at('link[rel="manifest"]')->getAttribute('href'),
    'https://the.kalaclista.com/manifest.webmanifest'
  );
}

sub meta_preload_scripts_ok {
  my ( $class, $dom ) = @_;

  is( $dom->at('meta[http-equiv]')->getAttribute('content'), 'on' );

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

sub meta_ogp_ok {
  my ( $class, $dom, $section, $isPermalink ) = @_;

  # og:image
  is( $dom->at('meta[property="og:image"]')->getAttribute('content'),
    'https://the.kalaclista.com/assets/avatar.png' );

  # og:url
  is(
    $dom->at('meta[property="og:url"]')->getAttribute('content'),
    $dom->at('link[rel="canonical"]')->getAttribute('href'),
  );

  # og:description
  is(
    $dom->at('meta[property="og:description"]')->getAttribute('content'),
    $dom->at('meta[name="description"]')->getAttribute('content'),
  );

  # og:title, og:site_name
  my $title = $dom->at('meta[property="og:title"]')->getAttribute('content');
  my $name = $dom->at('meta[property="og:site_name"]')->getAttribute('content');
  my $combined = $dom->at('title')->textContent;

  utf8::decode($title);
  utf8::decode($name);
  utf8::decode($combined);

  if ( $title ne $name ) {
    is( $combined, "${title} - ${name}" );
  }
  else {
    ok( $combined eq $title && $combined eq $name );
  }

  # og:type, og:article:*
  if ($isPermalink) {
    is( $dom->at('meta[property="og:type"]')->getAttribute('content'),
      'article' );

    like(
      $dom->at('meta[property="og:article:published_time"]')
        ->getAttribute('content'),
      qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)$>
    );

    like(
      $dom->at('meta[property="og:article:modified_time"]')
        ->getAttribute('content'),
      qr<^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:[+-]\d{2}:\d{2}|Z)$>
    );

    is( $dom->at('meta[property="og:article:author"]')->getAttribute('content'),
      'OKAMURA Naoki aka nyarla' );

    my $article =
      $dom->at('meta[property="og:article:section"]')->getAttribute('content');
    utf8::decode($article);

    if ( $section eq 'posts' ) {
      is( $article, 'ブログ' );
    }
    elsif ( $section eq 'echos' ) {
      is( $article, '日記' );
    }
    elsif ( $section eq 'notes' ) {
      is( $article, 'ノート' );
    }
  }
  else {
    is( $dom->at('meta[property="og:type"]')->getAttribute('content'),
      'website' );
  }

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

sub meta_twittercard_ok {
  my ( $class, $dom ) = @_;

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

  is(
    $dom->at('meta[name="twitter:image"]')->getAttribute('content'),
    'https://the.kalaclista.com/assets/avatar.png',
  );
}

sub meta_jsonld_ok {
  my ( $class, $dom, $section, $isPermalink ) = @_;

  my $json = $dom->at('script[type="application/ld+json"]')->textContent;

  my $data = decode_json($json);

  is( ref($data), 'ARRAY' );

  my $self = $data->[0];

  my $breadcrumb = $data->[1];

  is( $breadcrumb->{'@context'}, 'https://schema.org' );
  is( $breadcrumb->{'@type'},    'BreadcrumbList' );

  my $tree = $breadcrumb->{'itemListElement'};

  my $title = $dom->at('meta[property="og:title"]')->getAttribute('content');
  utf8::decode($title);

  my $permalink = $dom->at('link[rel="canonical"]')->getAttribute('href');
  utf8::decode($permalink);

  my $published = q{};
  my $lastmod   = q{};
  my $type      = q{};

  my $root = {
    '@type'    => 'ListItem',
    'position' => 1,
    'name'     => 'カラクリスタ',
    'item'     => 'https://the.kalaclista.com/',
  };

  my $branch = {
    '@type'    => 'ListItem',
    'position' => 2,
    'item'     => "https://the.kalaclista.com/${section}/",
  };

  my $leaf = { '@type' => 'ListItem', 'name' => $title, 'item' => $permalink };

  if ($isPermalink) {
    $published = $dom->at('meta[property="og:article:published_time"]')
      ->getAttribute('content');
    $lastmod = $dom->at('meta[property="og:article:modified_time"]')
      ->getAttribute('content');

    utf8::decode($published);
    utf8::decode($lastmod);

    if ( $section eq 'home' ) {
      $type = 'WebPage';
      $leaf->{'position'} = 2;
    }
    elsif ( $section eq 'posts' ) {
      $type               = 'BlogPosting';
      $branch->{'name'}   = 'カラクリスタ・ブログ';
      $leaf->{'position'} = 3;
    }
    elsif ( $section eq 'echos' ) {
      $type               = 'BlogPosting';
      $branch->{'name'}   = 'カラクリスタ・エコーズ';
      $leaf->{'position'} = 3;
    }
    elsif ( $section eq 'notes' ) {
      $type               = 'Article';
      $branch->{'name'}   = 'カラクリスタ・ノート';
      $leaf->{'position'} = 3;
    }

  }
  else {
    if ( $section eq 'home' ) {
      $type = 'WebSite';
    }
    elsif ( $section eq 'posts' ) {
      $type = 'Blog';
      $branch->{'name'} = 'カラクリスタ・ブログ';
    }
    elsif ( $section eq 'echos' ) {
      $type = 'Blog';
      $branch->{'name'} = 'カラクリスタ・エコーズ';
    }
    elsif ( $section eq 'notes' ) {
      $type = 'WebSite';
      $branch->{'name'} = 'カラクリスタ・ノート';
    }
  }

  is(
    $self,
    {
      '@context' => 'https://schema.org',
      '@type'    => $type,
      '@id'      => $dom->at('link[rel="canonical"]')->getAttribute('href'),
      'headline' => $title,
      'image'    => {
        '@type' => 'URL',
        'url'   => 'https://the.kalaclista.com/assets/avatar.png',
      },
      'author' => {
        '@type' => 'Person',
        'name'  => 'OKAMURA Naoki aka nyarla',
        'email' => 'nyarla@kalaclista.com',
      },
      'publisher' => {
        '@type' => 'Organization',
        'name'  => 'the.kalaclista.com',
        'logo'  => {
          '@type' => 'ImageObject',
          'url'   => {
            '@type' => 'URL',
            'url'   => 'https://the.kalaclista.com/assets/avatar.png',
          }
        }
      },
      (
        $isPermalink
        ? (
          'datePublished'   => $published,
          'dateModified'    => $lastmod,
          'mainEntryOfPage' => {
            '@id' => "https://the.kalaclista.com/${section}/",
          },
          )
        : ()
      )
    }
  );

  if ($isPermalink) {
    if ( $section ne 'home' ) {
      ok( scalar( $tree->@* ) == 3 );
      is( $tree, [ $root, $branch, $leaf ], );
    }
    else {
      ok( scalar( $tree->@* ) == 2 );
      is( $tree, [ $root, $leaf ], );
    }
  }
  else {
    if ( $section ne 'home' ) {
      ok( scalar( $tree->@* ) == 2 );
      is( $tree, [ $root, $branch ], );
    }
    else {
      ok( scalar( $tree->@* ) == 1 );
      is( $tree, [$root] );
    }
  }
}

sub meta_alternate_ok {
  my ( $class, $dom, $section ) = @_;

  my $prefix = "/${section}/";
  if ( $section eq q{home} ) {
    $prefix = q{/};
  }

  my $label = q{};

  if ( $section eq q{home} ) {
    $label = q{カラクリスタ};
  }
  elsif ( $section eq q{posts} ) {
    $label = q{カラクリスタ・ブログ};
  }
  elsif ( $section eq q{echos} ) {
    $label = q{カラクリスタ・エコーズ};
  }
  elsif ( $section eq q{notes} ) {
    $label = q{カラクリスタ・ノート};
  }

  my $feed = $dom->at('link[rel="alternate"][type="application/rss+xml"]');

  ok($feed);
  is( $feed->getAttribute('href'),
    "https://the.kalaclista.com${prefix}index.xml" );

  my $title = $feed->getAttribute('title');
  utf8::decode($title);

  is( $title, "${label}の RSS フィード" );

  $feed  = undef;
  $title = undef;
  $feed  = $dom->at('link[rel="alternate"][type="application/atom+xml"]');

  ok($feed);
  is( $feed->getAttribute('href'),
    "https://the.kalaclista.com${prefix}atom.xml" );

  $title = $feed->getAttribute('title');
  utf8::decode($title);

  is( $title, "${label}の Atom フィード" );

  $feed  = undef;
  $title = undef;
  $feed  = $dom->at('link[rel="alternate"][type="application/feed+json"]');

  ok($feed);
  is( $feed->getAttribute('href'),
    "https://the.kalaclista.com${prefix}jsonfeed.json" );

  $title = $feed->getAttribute('title');
  utf8::decode($title);

  is( $title, "${label}の JSON フィード" );
}

1;
