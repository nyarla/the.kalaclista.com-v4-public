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
    buildInputs = [ DevelChecklib TestRequires ] ++ (with pkgs; [ mecab ]);
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

  TestAPI = buildPerlPackage {
    pname = "Test-API";
    version = "0.010";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DA/DAGOLDEN/Test-API-0.010.tar.gz";
      sha256 =
        "7e6034f0eb29314d31d3354828106ace2745f2160cd3c1443a29b68f53ca2313";
    };
    meta = {
      homepage = "https://github.com/dagolden/Test-API";
      description = "Test a list of subroutines provided by a module";
      license = lib.licenses.asl20;
    };
  };

  TypesUUID = buildPerlPackage {
    pname = "Types-UUID";
    version = "0.004";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOBYINK/Types-UUID-0.004.tar.gz";
      sha256 =
        "7937e4b74c3137dc9df0e9d691a5eae704164eb6e6088c7ba8e2efcbc0c72237";
    };
    propagatedBuildInputs = [ TypeTiny UUIDTiny ];
    meta = {
      homepage = "https://metacpan.org/release/Types-UUID";
      description = "Type constraints for UUIDs";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TypesPathTiny = buildPerlPackage {
    pname = "Types-Path-Tiny";
    version = "0.006";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/D/DA/DAGOLDEN/Types-Path-Tiny-0.006.tar.gz";
      sha256 =
        "593fc9faedbc69280659c0cce85168f8e7a1714cacdf8e9e6b7489be18dfe280";
    };
    buildInputs = [ Filepushd ];
    propagatedBuildInputs = [ PathTiny TypeTiny ];
    meta = {
      homepage = "https://github.com/dagolden/types-path-tiny";
      description = "Path::Tiny types and coercions for Moose and Moo";
      license = lib.licenses.asl20;
    };
  };

  TypesURI = buildPerlPackage {
    pname = "Types-URI";
    version = "0.007";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOBYINK/Types-URI-0.007.tar.gz";
      sha256 =
        "4c159ff53c5c383eb8eedf93d6310b26bcc83ae0547560968e65c57926df0304";
    };
    buildInputs = [ TestRequires ];
    propagatedBuildInputs =
      [ TypeTiny TypesPathTiny TypesUUID URI URIFromHash ];
    meta = {
      homepage = "https://metacpan.org/release/Types-URI";
      description = "Type constraints and coercions for URIs";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  MooXLogAny = buildPerlPackage {
    pname = "MooX-Log-Any";
    version = "0.004004";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/C/CA/CAZADOR/MooX-Log-Any-0.004004.tar.gz";
      sha256 =
        "2a1afa0f3a411e28a9258ccabe2c5b5d647abc29f2fbf5be9ffaf2286e830534";
    };
    propagatedBuildInputs = [ LogAny Moo ];
    meta = {
      homepage = "https://github.com/cazador481/MooX-Log-Any";
      description = "Role to add Log::Any";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  URINamespaceMap = buildPerlPackage {
    pname = "URI-NamespaceMap";
    version = "1.10";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/K/KJ/KJETILK/URI-NamespaceMap-1.10.tar.gz";
      sha256 =
        "f2a7be7516396df2cbf5609175d4b43459521c56726a428e39aafb7602cb8e6e";
    };
    buildInputs = [ TestDeep TestException TestRequires ];
    propagatedBuildInputs =
      [ IRI Moo SubQuote TryTiny TypeTiny TypesURI URI namespaceautoclean ];
    meta = {
      homepage = "https://metacpan.org/module/URI::NamespaceMap";
      description =
        "Namespace manipulation and prefix mapping for XML, RDF, etc";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  AlgorithmCombinatorics = buildPerlPackage {
    pname = "Algorithm-Combinatorics";
    version = "0.27";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/F/FX/FXN/Algorithm-Combinatorics-0.27.tar.gz";
      sha256 =
        "8378da39ecdb37d5cc89cc130a3b1353fd75d56c7690905673473fe4c25cd132";
    };
    meta = { description = "Efficient generation of combinatorial sequences"; };
  };

  MathCartesianProduct = buildPerlModule {
    pname = "Math-Cartesian-Product";
    version = "1.009";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/P/PR/PRBRENAN/Math-Cartesian-Product-1.009.tar.gz";
      sha256 =
        "d0bf24e56aaebe47c9db6d09c257bc3bf5af2d0d69f060fe33c180a9c7199f32";
    };
    meta = {
      description = "Generate the cartesian product of zero or more lists";
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

  IRI = buildPerlPackage {
    pname = "IRI";
    version = "0.011";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GW/GWILLIAMS/IRI-0.011.tar.gz";
      sha256 =
        "85dc7003e00e2cb236d30f05c918dbc5dec833e631e499ee4d8ea64b12abe89b";
    };
    buildInputs = [ TryTiny URI ];
    propagatedBuildInputs = [ Moo MooXHandlesVia TypeTiny ];
    meta = {
      homepage = "http://search.cpan.org/dist/IRI/";
      description = "Internationalized Resource Identifiers";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  Attean = buildPerlPackage {
    pname = "Attean";
    version = "0.030";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GW/GWILLIAMS/Attean-0.030.tar.gz";
      sha256 =
        "73a5b3ecbb4e1bb8c4d5e0209735e3e22a7e4756e2b97edf9554da4f30181da2";
    };
    buildInputs = [
      ModulePluggable
      Plack
      RegexpCommon
      TestException
      TestLWPUserAgent
      TestRequires
      XMLSimple
    ];
    propagatedBuildInputs = [
      AlgorithmCombinatorics
      DateTimeFormatW3CDTF
      ExporterTiny
      FileSlurp
      HTTPNegotiate
      IRI
      JSON
      LWP
      ListMoreUtils
      MathCartesianProduct
      Moo
      MooXLogAny
      Moose
      PerlIOLayers
      RoleTiny
      SetScalar
      SubInstall
      TestModern
      TestRoo
      TextCSV
      TextTable
      TryTiny
      TypeTiny
      URI
      URINamespaceMap
      UUIDTiny
      XMLSAX
      namespaceclean
    ];
    meta = {
      homepage = "https://metacpan.org/release/Attean";
      description = "A Semantic Web Framework";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestModern = buildPerlPackage {
    pname = "Test-Modern";
    version = "0.013";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOBYINK/Test-Modern-0.013.tar.gz";
      sha256 =
        "63ebc04b761c5748a121006d0e2672a6836d39cfb9e0b42dda80c8161f7a1246";
    };
    propagatedBuildInputs = [
      ExporterTiny
      ImportInto
      ModuleRuntime
      TestAPI
      TestDeep
      TestFatal
      TestWarnings
      TryTiny
    ];
    meta = {
      homepage = "https://metacpan.org/release/Test-Modern";
      description = "Precision testing for modern perl";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  JSONLD = buildPerlPackage {
    pname = "JSONLD";
    version = "0.005";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GW/GWILLIAMS/JSONLD-0.005.tar.gz";
      sha256 =
        "a31beda9e050ade1be5e0fa2ea927e1679853802ab76fd04fa1f3d5b73bf42f1";
    };
    buildInputs = [ Attean TestException TestModern ];
    propagatedBuildInputs =
      [ Clone IRI JSON LWP LWPProtocolhttps Moo namespaceclean ];
    meta = {
      homepage = "http://search.cpan.org/dist/JSONLD/";
      description = "A toolkit for transforming JSON-LD data";
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
  AlgorithmCombinatorics
  AlgorithmDiff
  Attean
  BCOW
  BHooksEndOfScope
  CanaryStability
  CaptureTiny
  ClassAccessor
  ClassAccessorLite
  ClassErrorHandler
  ClassMethodModifiers
  Clone
  ConvertMoji
  DataPerl
  DateTime
  DateTimeFormatW3CDTF
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
  FileSlurp
  Filepushd
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
  IOSocketSSL
  IRI
  ImportInto
  Importer
  JSON
  JSONLD
  JSONParse
  JSONXS
  LWP
  LWPMediaTypes
  LWPProtocolhttps
  LinguaJAMoji
  LinguaJANormalizeText
  ListLazy
  ListMoreUtils
  ListMoreUtilsXS
  LogAny
  MockConfig
  ModuleBuild
  ModuleBuildTiny
  ModuleImplementation
  ModulePluggable
  ModuleRuntime
  Moo
  MooXHandlesVia
  MooXLogAny
  MooXTypesMooseLike
  Moose
  MozillaCA
  NetHTTP
  PackageStash
  PadWalker
  ParallelForkBossWorkerAsync
  ParamsValidate
  PathTiny
  PathTinyGlob
  PerlIOLayers
  Plack
  RegexpCommon
  RoleTiny
  SafeIsa
  ScopeGuard
  SetScalar
  SubExporterProgressive
  SubIdentify
  SubInfo
  SubInstall
  SubQuote
  SubUplevel
  TermTable
  Test2Suite
  TestAPI
  TestDeep
  TestDifferences
  TestException
  TestFatal
  TestLWPUserAgent
  TestLeakTrace
  TestMemoryCycle
  TestModern
  TestNeeds
  TestOutput
  TestRequires
  TestRequiresInternet
  TestRoo
  TestWarn
  TestWarnings
  TextAligner
  TextCSV
  TextDiff
  TextMeCab
  TextTable
  TimeDate
  TryTiny
  TypeTiny
  TypesPathTiny
  TypesSerialiser
  TypesURI
  TypesUUID
  URI
  URIFetch
  URIFromHash
  URINamespaceMap
  UUIDTiny
  VariableMagic
  WWWRobotRules
  XMLDOMLite
  XMLNamespaceSupport
  XMLParser
  XMLSAX
  XMLSAXBase
  XMLSAXExpat
  XMLSimple
  YAMLLibYAML
  barewordfilehandles
  commonsense
  indirect
  multidimensional
  namespaceautoclean
  namespaceclean
  strictures
]
