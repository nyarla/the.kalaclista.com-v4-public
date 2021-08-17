{ pkgs ? import <nixpkgs> { } }:

with pkgs;

with perlPackages;

let
  JSONParse = buildPerlPackage {
    pname = "JSON-Parse";
    version = "0.61";
    src = fetchurl {
      url = "mirror://cpan/authors/id/B/BK/BKB/JSON-Parse-0.61.tar.gz";
      sha256 =
        "ce8e55e70bef9bcbba2e96af631d10a605900961a22cad977e71aab56c3f2806";
    };
    meta = {
      description = "Parse JSON";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  XMLDOMLite = buildPerlPackage {
    pname = "XML-DOM-Lite";
    version = "0.16";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RH/RHUNDT/XML-DOM-Lite-0.16.tar.gz";
      sha256 =
        "12cd5a8f8aabfd3f0c5699a58db55bbfcc4a6e899fde405f05bbf4ac388e526b";
    };
    meta = { };
  };

  ClassErrorHandler = buildPerlPackage {
    pname = "Class-ErrorHandler";
    version = "0.04";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/T/TO/TOKUHIROM/Class-ErrorHandler-0.04.tar.gz";
      sha256 =
        "342d2dcfc797a20bee8179b1b96b85c0ae7a5b48827359523cd8c74c3e704502";
    };
    meta = {
      homepage = "https://github.com/tokuhirom/Class-ErrorHandler";
      description = "Base class for error handling";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  LWP = buildPerlPackage {
    pname = "libwww-perl";
    version = "6.55";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/libwww-perl-6.55.tar.gz";
      sha256 =
        "c1d0d3a44a039b136ebac7336f576e3f5c232347e8221abd69ceb4108e85c920";
    };
    buildInputs = [ HTTPDaemon TestFatal TestNeeds TestRequiresInternet ];
    propagatedBuildInputs = [
      EncodeLocale
      FileListing
      HTMLParser
      HTTPCookies
      HTTPDate
      HTTPMessage
      HTTPNegotiate
      LWPMediaTypes
      NetHTTP
      TryTiny
      URI
      WWWRobotRules
    ];
    meta = {
      homepage = "https://github.com/libwww-perl/libwww-perl";
      description = "The World-Wide Web library for Perl";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  URIFetch = buildPerlPackage {
    pname = "URI-Fetch";
    version = "0.15";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NE/NEILB/URI-Fetch-0.15.tar.gz";
      sha256 =
        "379f39f24c6dae5c536332b17979fd90799dabccdfe8e792e7eead3eb8cda50c";
    };
    buildInputs = [ TestRequiresInternet ];
    propagatedBuildInputs = [ ClassErrorHandler LWP URI ];
    meta = {
      homepage = "https://github.com/neilb/URI-Fetch";
      description = "Smart URI fetching/caching";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TextMeCab = buildPerlPackage {
    pname = "Text-MeCab";
    version = "0.20016";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DM/DMAKI/Text-MeCab-0.20016.tar.gz";
      sha256 =
        "3e6c4f1ad74d9f4dd711584ff405a4cef50a37a4c008d592930a2ecb25e5341b";
    };
    buildInputs = [ DevelChecklib TestRequires ];
    nativeBuildInputs = with pkgs; [ gnused ];
    prePatch = ''
      export PERL_TEXT_MECAB_ENCODING=utf-8;
      sed -i "s|/opt/local/bin|${pkgs.mecab}/bin|" tools/probe_mecab.pl;
    '';
    propagatedBuildInputs = [ ClassAccessor ];
    meta = {
      description = "Alternate Interface To libmecab";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  indirect = buildPerlPackage {
    pname = "indirect";
    version = "0.39";
    src = fetchurl {
      url = "mirror://cpan/authors/id/V/VP/VPIT/indirect-0.39.tar.gz";
      sha256 =
        "71733c4c348e98fdd575b44a52042428c39888a18c25656efe59ef3d7d0d27e5";
    };
    meta = {
      homepage = "http://search.cpan.org/dist/indirect/";
      description =
        "Lexically warn about using the indirect method call syntax";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  multidimensional = buildPerlPackage {
    pname = "multidimensional";
    version = "0.014";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/I/IL/ILMARI/multidimensional-0.014.tar.gz";
      sha256 =
        "12eb14317447bd15ab9799677db9eda20e784d8b113e44a5f6f11f529e862c5f";
    };
    buildInputs = [ ExtUtilsDepends ];
    propagatedBuildInputs = [ BHooksOPCheck ];
    meta = {
      homepage = "https://github.com/ilmari/multidimensional";
      description = "Disables multidimensional array emulation";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  barewordfilehandles = buildPerlPackage {
    pname = "bareword-filehandles";
    version = "0.007";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/I/IL/ILMARI/bareword-filehandles-0.007.tar.gz";
      sha256 =
        "4134533716d87af8fff56e250c488ad06df0a7bff48e7cf7de63ff6bc8d9c17f";
    };
    buildInputs = [ ExtUtilsDepends ];
    propagatedBuildInputs = [ BHooksOPCheck ];
    meta = {
      homepage = "https://github.com/ilmari/bareword-filehandles";
      description = "Disables bareword filehandles";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ListLazy = buildPerlPackage {
    pname = "List-Lazy";
    version = "0.3.2";
    src = fetchurl {
      url = "mirror://cpan/authors/id/Y/YA/YANICK/List-Lazy-0.3.2.tar.gz";
      sha256 =
        "52b53709be0dfb7feae7edf212b8e1843bce72f02afd8dc74fb879305d982832";
    };
    buildInputs = [ TestWarn ];
    propagatedBuildInputs =
      [ Clone ExporterTiny ListMoreUtils Moo MooXHandlesVia ];
    meta = {
      homepage = "https://github.com/yanick/List-Lazy";
      description = "Generate lists lazily";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  PathTinyGlob = buildPerlPackage {
    pname = "Path-Tiny-Glob";
    version = "0.2.0";
    src = fetchurl {
      url = "mirror://cpan/authors/id/Y/YA/YANICK/Path-Tiny-Glob-0.2.0.tar.gz";
      sha256 =
        "f4caed0814efc4a6b481d6a1b57f9eccf2e49a25748c71eb4976785edd6e7265";
    };
    buildInputs = [ Test2Suite ];
    propagatedBuildInputs = [ ExporterTiny ListLazy Moo PathTiny ];
    meta = {
      homepage = "https://github.com/yanick/Path-Tiny-Glob";
      description = "File globbing utility";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ParallelForkBossWorkerAsync = buildPerlPackage {
    pname = "Parallel-Fork-BossWorkerAsync";
    version = "0.09";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/J/JV/JVANNUCCI/Parallel-Fork-BossWorkerAsync-0.09.tar.gz";
      sha256 =
        "76481f21fac3663d357fa369e70cae43e47274d34cf0924d563a3c438c7989a4";
    };
    meta = {
      description =
        "Perl extension for creating asynchronous forking queue processing applications";
    };
  };

  ConvertMoji = buildPerlPackage {
    pname = "Convert-Moji";
    version = "0.11";
    src = fetchurl {
      url = "mirror://cpan/authors/id/B/BK/BKB/Convert-Moji-0.11.tar.gz";
      sha256 =
        "28de563d202fc7cfa229cb7122c9a784a30a3210eb2fe5e6009cfca2130e85d5";
    };
    meta = {
      description = "Convert between alphabets";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TextTestBase = buildPerlModule {
    pname = "Text-TestBase";
    version = "0.13";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOKUHIROM/Text-TestBase-0.13.tar.gz";
      sha256 =
        "25a512d6f64099607bef799a58516524fdbe6e9a458959a4747c4d7443c4d2fa";
    };
    buildInputs = [ TestRequires ];
    propagatedBuildInputs = [ ClassAccessorLite ];
    meta = {
      homepage = "https://github.com/tokuhirom/Text-TestBase";
      description = "Parser for Test::Base format";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  LinguaJARegularUnicode = buildPerlModule {
    pname = "Lingua-JA-Regular-Unicode";
    version = "0.13";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/T/TO/TOKUHIROM/Lingua-JA-Regular-Unicode-0.13.tar.gz";
      sha256 =
        "a81d6caa4c0d9e08a03b6b9028ab38be7370ecef3e7bf97e9810af4d5aa60b2f";
    };
    buildInputs = [ ModuleBuildTiny TextTestBase ];
    meta = {
      homepage = "https://github.com/tokuhirom/Lingua-JA-Regular-Unicode";
      description = "Convert japanese chars";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  LinguaJADakuon = buildPerlModule {
    pname = "Lingua-JA-Dakuon";
    version = "0.01";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/K/KA/KAWAMURAY/Lingua-JA-Dakuon-0.01.tar.gz";
      sha256 =
        "f894625b1c9df56b6777f0d78d84595e7e897e3962991536156281a53e289da9";
    };
    meta = {
      homepage = "https://github.com/kawamuray/p5-Lingua-JA-Dakuon";
      description = "Convert between dakuon/handakuon and seion for Japanese";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  LinguaJAMoji = buildPerlPackage {
    pname = "Lingua-JA-Moji";
    version = "0.59";
    src = fetchurl {
      url = "mirror://cpan/authors/id/B/BK/BKB/Lingua-JA-Moji-0.59.tar.gz";
      sha256 =
        "896cad9a5a01b30daf0f483dabe312119a5cd794490f4f25677a484f9988c2e4";
    };
    propagatedBuildInputs = [ ConvertMoji JSONParse ];
    meta = {
      description = "Handle many kinds of Japanese characters";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  LinguaJANormalizeText = buildPerlModule {
    pname = "Lingua-JA-NormalizeText";
    version = "0.50";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/P/PA/PAWAPAWA/Lingua-JA-NormalizeText-0.50.tar.gz";
      sha256 =
        "6c10a5ade568c628078adf9ec398dfd21d096766c8e0d961167e721aace71b78";
    };
    buildInputs = [ TestFatal TestWarn ];
    propagatedBuildInputs = [
      HTMLParser
      HTMLScrubber
      LinguaJADakuon
      LinguaJAMoji
      LinguaJARegularUnicode
    ];
    meta = {
      homepage = "https://github.com/pawa-/Lingua-JA-NormalizeText";
      description = "All-in-One Japanese text normalizer";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  HTML5DOM = buildPerlPackage {
    pname = "HTML5-DOM";
    version = "1.25";
    src = fetchurl {
      url = "mirror://cpan/authors/id/Z/ZH/ZHUMARIN/HTML5-DOM-1.25.tar.gz";
      sha256 =
        "a815c4bd6bada87203628f8e658d78610fdf9bd6b9dacfd10c437819416cee54";
    };
    meta = {
      description =
        "Super fast html5 DOM library with css selectors (based on Modest/MyHTML)";
      license = lib.licenses.mit;
    };
  };

in [
  AlgorithmDiff
  BCOW
  CanaryStability
  CaptureTiny
  ClassAccessor
  ClassAccessorLite
  ClassErrorHandler
  ClassMethodModifiers
  Clone
  ConvertMoji
  DataPerl
  DevelChecklib
  DevelCycle
  Encode
  EncodeDetect
  EncodeLocale
  ExporterTiny
  ExtUtilsConfig
  ExtUtilsHelpers
  ExtUtilsInstallPaths
  FileListing
  HTML5DOM
  HTMLParser
  HTMLScrubber
  HTMLTagset
  HTTPCookies
  HTTPDaemon
  HTTPDate
  HTTPMessage
  HTTPNegotiate
  IOHTML
  Importer
  JSONParse
  JSONXS
  LWP
  LWPMediaTypes
  LinguaJAMoji
  LinguaJANormalizeText
  ListLazy
  ListMoreUtils
  ListMoreUtilsXS
  MockConfig
  ModuleBuild
  ModuleBuildTiny
  ModulePluggable
  ModuleRuntime
  Moo
  MooXHandlesVia
  MooXTypesMooseLike
  NetHTTP
  PadWalker
  ParallelForkBossWorkerAsync
  PathTiny
  PathTinyGlob
  RoleTiny
  ScopeGuard
  SubInfo
  SubQuote
  SubUplevel
  TermTable
  Test2Suite
  TestDeep
  TestDifferences
  TestException
  TestFatal
  TestLeakTrace
  TestMemoryCycle
  TestNeeds
  TestOutput
  TestRequires
  TestRequiresInternet
  TestWarn
  TextDiff
  TextMeCab
  TimeDate
  TryTiny
  TypesSerialiser
  URI
  URIFetch
  WWWRobotRules
  XMLDOMLite
  YAMLLibYAML
  barewordfilehandles
  commonsense
  indirect
  multidimensional
  strictures
]
