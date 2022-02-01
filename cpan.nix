{ pkgs }:

with pkgs;

with perlPackages;

let
  YAMLLibYAML = buildPerlPackage {
    pname = "YAML-LibYAML";
    version = "0.83";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TI/TINITA/YAML-LibYAML-0.83.tar.gz";
      sha256 =
        "b47175b4ff397ad75a4f7781d3d83c08637da6ff0bae326af3b389d854bec490";
    };
    meta = {
      homepage = "https://github.com/ingydotnet/yaml-libyaml-pm";
      description = "Perl YAML Serialization using XS and libyaml";
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
    buildInputs = [ DevelChecklib TestRequires ];
    propagatedBuildInputs = [ ClassAccessor ];
    prePatch = ''
      export PERL_TEXT_MECAB_ENCODING=utf-8
      sed -i "s|/opt/local/bin|${pkgs.mecab}/bin|" tools/probe_mecab.pl
    '';
    meta = {
      description = "Alternate Interface To libmecab";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  SubQuote = buildPerlPackage {
    pname = "Sub-Quote";
    version = "2.006006";
    src = fetchurl {
      url = "mirror://cpan/authors/id/H/HA/HAARG/Sub-Quote-2.006006.tar.gz";
      sha256 =
        "6e4e2af42388fa6d2609e0e82417de7cc6be47223f576592c656c73c7524d89d";
    };
    buildInputs = [ TestFatal ];
    meta = {
      description = "Efficient generation of subroutines via string eval";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ModulePluggable = buildPerlPackage {
    pname = "Module-Pluggable";
    version = "5.2";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/SI/SIMONW/Module-Pluggable-5.2.tar.gz";
      sha256 =
        "b3f2ad45e4fd10b3fb90d912d78d8b795ab295480db56dc64e86b9fa75c5a6df";
    };
    meta = {
      description =
        "Automatically give your module the ability to have plugins";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  SubInfo = buildPerlPackage {
    pname = "Sub-Info";
    version = "0.002";
    src = fetchurl {
      url = "mirror://cpan/authors/id/E/EX/EXODIST/Sub-Info-0.002.tar.gz";
      sha256 =
        "ea3056d696bdeff21a99d340d5570887d39a8cc47bff23adfc82df6758cdd0ea";
    };
    propagatedBuildInputs = [ Importer ];
    meta = {
      description = "Tool for inspecting subroutines";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ScopeGuard = buildPerlPackage {
    pname = "Scope-Guard";
    version = "0.21";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CH/CHOCOLATE/Scope-Guard-0.21.tar.gz";
      sha256 =
        "8c9b1bea5c56448e2c3fadc65d05be9e4690a3823a80f39d2f10fdd8f777d278";
    };
    meta = {
      description = "Lexically-scoped resource management";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TermTable = buildPerlPackage {
    pname = "Term-Table";
    version = "0.015";
    src = fetchurl {
      url = "mirror://cpan/authors/id/E/EX/EXODIST/Term-Table-0.015.tar.gz";
      sha256 =
        "d8a18b2801f91f0e5d747147ce786964a76f91d18568652908a3dc06a9b948d5";
    };
    propagatedBuildInputs = [ Importer ];
    meta = {
      description = "Format a header and rows into a table";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  Importer = buildPerlPackage {
    pname = "Importer";
    version = "0.026";
    src = fetchurl {
      url = "mirror://cpan/authors/id/E/EX/EXODIST/Importer-0.026.tar.gz";
      sha256 =
        "e08fa84e13cb998b7a897fc8ec9c3459fcc1716aff25cc343e36ef875891b0ef";
    };
    meta = {
      description =
        "Alternative but compatible interface to modules that export symbols";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ListMoreUtilsXS = buildPerlPackage {
    pname = "List-MoreUtils-XS";
    version = "0.430";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/R/RE/REHSACK/List-MoreUtils-XS-0.430.tar.gz";
      sha256 =
        "e8ce46d57c179eecd8758293e9400ff300aaf20fefe0a9d15b9fe2302b9cb242";
    };
    meta = {
      homepage = "https://metacpan.org/release/List-MoreUtils-XS";
      description = "Provide the stuff missing in List::Util in XS";
      license = lib.licenses.asl20;
    };
  };

  TestLeakTrace = buildPerlPackage {
    pname = "Test-LeakTrace";
    version = "0.17";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LE/LEEJO/Test-LeakTrace-0.17.tar.gz";
      sha256 =
        "777d64d2938f5ea586300eef97ef03eacb43d4c1853c9c3b1091eb3311467970";
    };
    meta = {
      homepage = "https://metacpan.org/release/Test-LeakTrace";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  BCOW = buildPerlPackage {
    pname = "B-COW";
    version = "0.004";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AT/ATOOMIC/B-COW-0.004.tar.gz";
      sha256 =
        "fcafb775ed84a45bc2c06c5ffd71342cb3c06fb0bdcd5c1b51b0c12f8b585f51";
    };
    meta = {
      description = "B::COW additional B helpers to check COW status";
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

  strictures = buildPerlPackage {
    pname = "strictures";
    version = "2.000006";
    src = fetchurl {
      url = "mirror://cpan/authors/id/H/HA/HAARG/strictures-2.000006.tar.gz";
      sha256 =
        "09d57974a6d1b2380c802870fed471108f51170da81458e2751859f2714f8d57";
    };
    meta = {
      description = "Turn on strict and make most warnings fatal";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestDeep = buildPerlPackage {
    pname = "Test-Deep";
    version = "1.130";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RJ/RJBS/Test-Deep-1.130.tar.gz";
      sha256 =
        "4064f494f5f62587d0ae501ca439105821ee5846c687dc6503233f55300a7c56";
    };
    meta = {
      homepage = "http://github.com/rjbs/Test-Deep/";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestOutput = buildPerlPackage {
    pname = "Test-Output";
    version = "1.033";
    src = fetchurl {
      url = "mirror://cpan/authors/id/B/BD/BDFOY/Test-Output-1.033.tar.gz";
      sha256 =
        "f6a8482740b075fad22aaf4d987d38ef927c6d2b452d4ae0d0bd8f779830556e";
    };
    propagatedBuildInputs = [ CaptureTiny ];
    meta = {
      homepage = "https://github.com/briandfoy/test-output";
      description = "Utilities to test STDOUT and STDERR messages";
      license = lib.licenses.artistic2;
    };
  };

  RoleTiny = buildPerlPackage {
    pname = "Role-Tiny";
    version = "2.002004";
    src = fetchurl {
      url = "mirror://cpan/authors/id/H/HA/HAARG/Role-Tiny-2.002004.tar.gz";
      sha256 =
        "d7bdee9e138a4f83aa52d0a981625644bda87ff16642dfa845dcb44d9a242b45";
    };
    meta = {
      description = "Roles: a nouvelle cuisine portion size slice of Moose";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestException = buildPerlPackage {
    pname = "Test-Exception";
    version = "0.43";
    src = fetchurl {
      url = "mirror://cpan/authors/id/E/EX/EXODIST/Test-Exception-0.43.tar.gz";
      sha256 =
        "156b13f07764f766d8b45a43728f2439af81a3512625438deab783b7883eb533";
    };
    propagatedBuildInputs = [ SubUplevel ];
    meta = {
      homepage = "https://github.com/Test-More/test-exception";
      description = "Test exception-based code";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  MooXTypesMooseLike = buildPerlPackage {
    pname = "MooX-Types-MooseLike";
    version = "0.29";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/M/MA/MATEU/MooX-Types-MooseLike-0.29.tar.gz";
      sha256 =
        "1d3780aa9bea430afbe65aa8c76e718f1045ce788aadda4116f59d3b7a7ad2b4";
    };
    buildInputs = [ Moo TestFatal ];
    propagatedBuildInputs = [ ModuleRuntime ];
    meta = {
      description = "Some Moosish types and a type builder";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ClassMethodModifiers = buildPerlPackage {
    pname = "Class-Method-Modifiers";
    version = "2.13";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/E/ET/ETHER/Class-Method-Modifiers-2.13.tar.gz";
      sha256 =
        "ab5807f71018a842de6b7a4826d6c1f24b8d5b09fcce5005a3309cf6ea40fd63";
    };
    buildInputs = [ TestFatal TestNeeds ];
    meta = {
      homepage = "https://github.com/moose/Class-Method-Modifiers";
      description = "Provides Moose-like method modifiers";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ModuleRuntime = buildPerlPackage {
    pname = "Module-Runtime";
    version = "0.016";
    src = fetchurl {
      url = "mirror://cpan/authors/id/Z/ZE/ZEFRAM/Module-Runtime-0.016.tar.gz";
      sha256 =
        "68302ec646833547d410be28e09676db75006f4aa58a11f3bdb44ffe99f0f024";
    };
    meta = {
      description = "Runtime module handling";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  DataPerl = buildPerlPackage {
    pname = "Data-Perl";
    version = "0.002011";
    src = fetchurl {
      url = "mirror://cpan/authors/id/T/TO/TOBYINK/Data-Perl-0.002011.tar.gz";
      sha256 =
        "8d34dbe314cfa2d99bd9aae546bbde94c38bb05b74b07c89bde1673a6f6c55f4";
    };
    buildInputs = [ TestDeep TestFatal TestOutput ];
    propagatedBuildInputs =
      [ ClassMethodModifiers ListMoreUtils ModuleRuntime RoleTiny strictures ];
    meta = {
      homepage = "https://github.com/tobyink/Data-Perl";
      description = "Base classes wrapping fundamental Perl data types";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  MooXHandlesVia = buildPerlPackage {
    pname = "MooX-HandlesVia";
    version = "0.001009";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/T/TO/TOBYINK/MooX-HandlesVia-0.001009.tar.gz";
      sha256 =
        "716353e38894ecb7e8e4c17bc95483db5f59002b03541b54a72c27f2a8f36c12";
    };
    buildInputs = [ MooXTypesMooseLike TestException TestFatal ];
    propagatedBuildInputs =
      [ ClassMethodModifiers DataPerl ModuleRuntime Moo RoleTiny ];
    meta = {
      description = "NativeTrait-like behavior for Moo";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  Clone = buildPerlPackage {
    pname = "Clone";
    version = "0.45";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AT/ATOOMIC/Clone-0.45.tar.gz";
      sha256 =
        "cbb6ee348afa95432e4878893b46752549e70dc68fe6d9e430d1d2e99079a9e6";
    };
    buildInputs = [ BCOW ];
    meta = {
      description = "Recursively copy Perl datatypes";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ListMoreUtils = buildPerlPackage {
    pname = "List-MoreUtils";
    version = "0.430";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RE/REHSACK/List-MoreUtils-0.430.tar.gz";
      sha256 =
        "63b1f7842cd42d9b538d1e34e0330de5ff1559e4c2737342506418276f646527";
    };
    buildInputs = [ TestLeakTrace ];
    propagatedBuildInputs = [ ExporterTiny ListMoreUtilsXS ];
    meta = {
      homepage = "https://metacpan.org/release/List-MoreUtils";
      description = "Provide the stuff missing in List::Util";
      license = lib.licenses.asl20;
    };
  };

  ExporterTiny = buildPerlPackage {
    pname = "Exporter-Tiny";
    version = "1.002002";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/T/TO/TOBYINK/Exporter-Tiny-1.002002.tar.gz";
      sha256 =
        "00f0b95716b18157132c6c118ded8ba31392563d19e490433e9a65382e707101";
    };
    meta = {
      homepage = "https://metacpan.org/release/Exporter-Tiny";
      description =
        "An exporter with the features of Sub::Exporter but only core dependencies";
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

  Test2Suite = buildPerlPackage {
    pname = "Test2-Suite";
    version = "0.000141";
    src = fetchurl {
      url = "mirror://cpan/authors/id/E/EX/EXODIST/Test2-Suite-0.000141.tar.gz";
      sha256 =
        "d1a79383bef83648992e43b8d8e9bcba2b588ae1c0933436e4a1fdc09ab7686f";
    };
    propagatedBuildInputs =
      [ Importer ScopeGuard SubInfo TermTable ModulePluggable ];
    meta = {
      description =
        "Distribution with a rich set of tools built upon the Test2 framework";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  Moo = buildPerlPackage {
    pname = "Moo";
    version = "2.005004";
    src = fetchurl {
      url = "mirror://cpan/authors/id/H/HA/HAARG/Moo-2.005004.tar.gz";
      sha256 =
        "e3030b80bd554a66f6b3c27fd53b1b5909d12af05c4c11ece9a58f8d1e478928";
    };
    buildInputs = [ TestFatal ];
    propagatedBuildInputs = [ ClassMethodModifiers RoleTiny SubQuote ];
    meta = {
      description = "Minimalist Object Orientation (with Moose compatibility)";
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

  PathTiny = buildPerlPackage {
    pname = "Path-Tiny";
    version = "0.118";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DA/DAGOLDEN/Path-Tiny-0.118.tar.gz";
      sha256 =
        "32138d8d0f4c9c1a84d2a8f91bc5e913d37d8a7edefbb15a10961bfed560b0fd";
    };
    meta = {
      homepage = "https://github.com/dagolden/Path-Tiny";
      description = "File path utility";
      license = lib.licenses.asl20;
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

  SubUplevel = buildPerlPackage {
    pname = "Sub-Uplevel";
    version = "0.2800";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DA/DAGOLDEN/Sub-Uplevel-0.2800.tar.gz";
      sha256 =
        "b4f3f63b80f680a421332d8851ddbe5a8e72fcaa74d5d1d98f3c8cc4a3ece293";
    };
    meta = {
      homepage = "https://github.com/Perl-Toolchain-Gang/Sub-Uplevel";
      description = "Apparently run a function in a higher stack frame";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  DevelCycle = buildPerlPackage {
    pname = "Devel-Cycle";
    version = "1.12";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LD/LDS/Devel-Cycle-1.12.tar.gz";
      sha256 =
        "fd3365c4d898b2b2bddbb78a46d507a18cca8490a290199547dab7f1e7390bc2";
    };
    meta = { description = "Find memory cycles in objects"; };
  };

  PadWalker = buildPerlPackage {
    pname = "PadWalker";
    version = "2.5";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RO/ROBIN/PadWalker-2.5.tar.gz";
      sha256 =
        "07b26abb841146af32072a8d68cb90176ffb176fd9268e6f2f7d106f817a0cd0";
    };
    meta = { };
  };

  AlgorithmDiff = buildPerlPackage {
    pname = "Algorithm-Diff";
    version = "1.201";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RJ/RJBS/Algorithm-Diff-1.201.tar.gz";
      sha256 =
        "0022da5982645d9ef0207f3eb9ef63e70e9713ed2340ed7b3850779b0d842a7d";
    };
    meta = { };
  };

  CaptureTiny = buildPerlPackage {
    pname = "Capture-Tiny";
    version = "0.48";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DA/DAGOLDEN/Capture-Tiny-0.48.tar.gz";
      sha256 =
        "6c23113e87bad393308c90a207013e505f659274736638d8c79bac9c67cc3e19";
    };
    meta = {
      homepage = "https://github.com/dagolden/Capture-Tiny";
      description =
        "Capture STDOUT and STDERR from Perl, XS or external programs";
      license = lib.licenses.asl20;
    };
  };

  TextDiff = buildPerlPackage {
    pname = "Text-Diff";
    version = "1.45";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NE/NEILB/Text-Diff-1.45.tar.gz";
      sha256 =
        "e8baa07b1b3f53e00af3636898bbf73aec9a0ff38f94536ede1dbe96ef086f04";
    };
    propagatedBuildInputs = [ AlgorithmDiff ];
    meta = {
      description = "Perform diffs on files and record sets";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestDifferences = buildPerlPackage {
    pname = "Test-Differences";
    version = "0.68";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/D/DC/DCANTRELL/Test-Differences-0.68.tar.gz";
      sha256 =
        "e68547206cb099a2594165ca0adc99fc12adb97c7f02a1222f62961fd775e270";
    };
    propagatedBuildInputs = [ CaptureTiny TextDiff ];
    meta = {
      description =
        "Test strings and data structures and show differences if not ok";
    };
  };

  HTMLParser = buildPerlPackage {
    pname = "HTML-Parser";
    version = "3.76";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/HTML-Parser-3.76.tar.gz";
      sha256 =
        "64d9e2eb2b420f1492da01ec0e6976363245b4be9290f03f10b7d2cb63fa2f61";
    };
    propagatedBuildInputs = [ HTMLTagset HTTPMessage URI ];
    meta = {
      homepage = "https://github.com/libwww-perl/HTML-Parser";
      description = "HTML parser class";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestMemoryCycle = buildPerlPackage {
    pname = "Test-Memory-Cycle";
    version = "1.06";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/P/PE/PETDANCE/Test-Memory-Cycle-1.06.tar.gz";
      sha256 =
        "9d53ddfdc964cd8454cb0da4c695b6a3ae47b45839291c34cb9d8d1cfaab3202";
    };
    propagatedBuildInputs = [ DevelCycle PadWalker ];
    meta = { description = "Verifies code hasn't left circular references"; };
  };

  HTMLScrubber = buildPerlPackage {
    pname = "HTML-Scrubber";
    version = "0.19";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NI/NIGELM/HTML-Scrubber-0.19.tar.gz";
      sha256 =
        "ae285578f8565f9154c63e4234704b57b6835f77a2f82ffe724899d453262bb1";
    };
    buildInputs = [ TestDifferences TestMemoryCycle ];
    propagatedBuildInputs = [ HTMLParser ];
    meta = {
      homepage = "https://github.com/nigelm/html-scrubber";
      description = "Perl extension for scrubbing/sanitizing HTML";
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

  TestWarn = buildPerlPackage {
    pname = "Test-Warn";
    version = "0.36";
    src = fetchurl {
      url = "mirror://cpan/authors/id/B/BI/BIGJ/Test-Warn-0.36.tar.gz";
      sha256 =
        "ecbca346d379cef8d3c0e4ac0c8eb3b2613d737ffaaeae52271c38d7bf3c6cda";
    };
    propagatedBuildInputs = [ SubUplevel ];
    meta = {
      description = "Perl extension to test methods for warnings";
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

  HTMLTagset = buildPerlPackage {
    pname = "HTML-Tagset";
    version = "3.20";
    src = fetchurl {
      url = "mirror://cpan/authors/id/P/PE/PETDANCE/HTML-Tagset-3.20.tar.gz";
      sha256 =
        "adb17dac9e36cd011f5243881c9739417fd102fce760f8de4e9be4c7131108e2";
    };
    meta = { description = "Data tables useful in parsing HTML"; };
  };

  HTTPMessage = buildPerlPackage {
    pname = "HTTP-Message";
    version = "6.33";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/HTTP-Message-6.33.tar.gz";
      sha256 =
        "23b967f71b852cb209ec92a1af6bac89a141dff1650d69824d29a345c1eceef7";
    };
    buildInputs = [ TryTiny ];
    propagatedBuildInputs = [ EncodeLocale HTTPDate IOHTML LWPMediaTypes URI ];
    meta = {
      homepage = "https://github.com/libwww-perl/HTTP-Message";
      description = "HTTP style message (base class)";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  ExtUtilsConfig = buildPerlPackage {
    pname = "ExtUtils-Config";
    version = "0.008";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LE/LEONT/ExtUtils-Config-0.008.tar.gz";
      sha256 =
        "ae5104f634650dce8a79b7ed13fb59d67a39c213a6776cfdaa3ee749e62f1a8c";
    };
    meta = {
      description = "A wrapper for perl's configuration";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  HTTPDaemon = buildPerlPackage {
    pname = "HTTP-Daemon";
    version = "6.12";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/HTTP-Daemon-6.12.tar.gz";
      sha256 =
        "df47bed10c38670c780fd0116867d5fd4693604acde31ba63380dce04c4e1fa6";
    };
    buildInputs = [ ModuleBuildTiny TestNeeds URI ];
    propagatedBuildInputs = [ HTTPDate HTTPMessage LWPMediaTypes ];
    meta = {
      homepage = "https://github.com/libwww-perl/HTTP-Daemon";
      description = "A simple http server class";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  HTTPNegotiate = buildPerlPackage {
    pname = "HTTP-Negotiate";
    version = "6.01";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GA/GAAS/HTTP-Negotiate-6.01.tar.gz";
      sha256 =
        "1c729c1ea63100e878405cda7d66f9adfd3ed4f1d6cacaca0ee9152df728e016";
    };
    propagatedBuildInputs = [ HTTPMessage ];
    meta = {
      description = "Choose a variant to serve";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  HTTPCookies = buildPerlPackage {
    pname = "HTTP-Cookies";
    version = "6.10";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/HTTP-Cookies-6.10.tar.gz";
      sha256 =
        "e36f36633c5ce6b5e4b876ffcf74787cc5efe0736dd7f487bdd73c14f0bd7007";
    };
    buildInputs = [ URI ];
    propagatedBuildInputs = [ HTTPDate HTTPMessage ];
    meta = {
      homepage = "https://github.com/libwww-perl/HTTP-Cookies";
      description = "HTTP cookie jars";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  FileListing = buildPerlPackage {
    pname = "File-Listing";
    version = "6.14";
    src = fetchurl {
      url = "mirror://cpan/authors/id/P/PL/PLICEASE/File-Listing-6.14.tar.gz";
      sha256 =
        "15b3a4871e23164a36f226381b74d450af41f12cc94985f592a669fcac7b48ff";
    };
    propagatedBuildInputs = [ HTTPDate ];
    meta = {
      homepage = "https://metacpan.org/pod/File::Listing";
      description = "Parse directory listing";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  WWWRobotRules = buildPerlPackage {
    pname = "WWW-RobotRules";
    version = "6.02";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GA/GAAS/WWW-RobotRules-6.02.tar.gz";
      sha256 =
        "46b502e7a288d559429891eeb5d979461dd3ecc6a5c491ead85d165b6e03a51e";
    };
    propagatedBuildInputs = [ URI ];
    meta = {
      description = "Database of robots.txt-derived permissions";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  NetHTTP = buildPerlPackage {
    pname = "Net-HTTP";
    version = "6.21";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/Net-HTTP-6.21.tar.gz";
      sha256 =
        "375aa35b76be99f06464089174d66ac76f78ce83a5c92a907bbfab18b099eec4";
    };
    propagatedBuildInputs = [ URI ];
    meta = {
      homepage = "https://github.com/libwww-perl/Net-HTTP";
      description = "Low-level HTTP connection (client)";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestRequiresInternet = buildPerlPackage {
    pname = "Test-RequiresInternet";
    version = "0.05";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/M/MA/MALLEN/Test-RequiresInternet-0.05.tar.gz";
      sha256 =
        "bba7b32a1cc0d58ce2ec20b200a7347c69631641e8cae8ff4567ad24ef1e833e";
    };
    meta = {
      homepage = "https://metacpan.org/dist/Test-RequiresInternet";
      description = "Easily test network connectivity";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestFatal = buildPerlPackage {
    pname = "Test-Fatal";
    version = "0.016";
    src = fetchurl {
      url = "mirror://cpan/authors/id/R/RJ/RJBS/Test-Fatal-0.016.tar.gz";
      sha256 =
        "7283d430f2ba2030b8cd979ae3039d3f1b2ec3dde1a11ca6ae09f992a66f788f";
    };
    propagatedBuildInputs = [ TryTiny ];
    meta = {
      homepage = "https://github.com/rjbs/Test-Fatal";
      description =
        "Incredibly simple helpers for testing code with exceptions";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  URI = buildPerlPackage {
    pname = "URI";
    version = "5.09";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/URI-5.09.tar.gz";
      sha256 =
        "03e63ada499d2645c435a57551f041f3943970492baa3b3338246dab6f1fae0a";
    };
    buildInputs = [ TestNeeds ];
    meta = {
      homepage = "https://github.com/libwww-perl/URI";
      description = "Uniform Resource Identifiers (absolute and relative)";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  LWPMediaTypes = buildPerlPackage {
    pname = "LWP-MediaTypes";
    version = "6.04";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/LWP-MediaTypes-6.04.tar.gz";
      sha256 =
        "8f1bca12dab16a1c2a7c03a49c5e58cce41a6fec9519f0aadfba8dad997919d9";
    };
    buildInputs = [ TestFatal ];
    meta = {
      homepage = "https://github.com/libwww-perl/lwp-mediatypes";
      description = "Guess media type for a file or a URL";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TryTiny = buildPerlPackage {
    pname = "Try-Tiny";
    version = "0.30";
    src = fetchurl {
      url = "mirror://cpan/authors/id/E/ET/ETHER/Try-Tiny-0.30.tar.gz";
      sha256 =
        "da5bd0d5c903519bbf10bb9ba0cb7bcac0563882bcfe4503aee3fb143eddef6b";
    };
    meta = {
      homepage = "https://github.com/p5sagit/Try-Tiny";
      description = "Minimal try/catch with proper preservation of $@";
      license = lib.licenses.mit;
    };
  };

  IOHTML = buildPerlPackage {
    pname = "IO-HTML";
    version = "1.004";
    src = fetchurl {
      url = "mirror://cpan/authors/id/C/CJ/CJM/IO-HTML-1.004.tar.gz";
      sha256 =
        "c87b2df59463bbf2c39596773dfb5c03bde0f7e1051af339f963f58c1cbd8bf5";
    };
    meta = {
      description = "Open an HTML file with automatic charset detection";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  EncodeLocale = buildPerlPackage {
    pname = "Encode-Locale";
    version = "1.05";
    src = fetchurl {
      url = "mirror://cpan/authors/id/G/GA/GAAS/Encode-Locale-1.05.tar.gz";
      sha256 =
        "176fa02771f542a4efb1dbc2a4c928e8f4391bf4078473bd6040d8f11adb0ec1";
    };
    meta = {
      description = "Determine the locale encoding";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestNeeds = buildPerlPackage {
    pname = "Test-Needs";
    version = "0.002009";
    src = fetchurl {
      url = "mirror://cpan/authors/id/H/HA/HAARG/Test-Needs-0.002009.tar.gz";
      sha256 =
        "571c21193ad16195df58b06b268798796a391b398c443271721d2cc0fb7c4ac3";
    };
    meta = {
      description = "Skip tests when modules not available";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TimeDate = buildPerlPackage {
    pname = "TimeDate";
    version = "2.33";
    src = fetchurl {
      url = "mirror://cpan/authors/id/A/AT/ATOOMIC/TimeDate-2.33.tar.gz";
      sha256 =
        "c0b69c4b039de6f501b0d9f13ec58c86b040c1f7e9b27ef249651c143d605eb2";
    };
    meta = { license = with lib.licenses; [ artistic1 gpl1Plus ]; };
  };

  HTTPDate = buildPerlPackage {
    pname = "HTTP-Date";
    version = "6.05";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/HTTP-Date-6.05.tar.gz";
      sha256 =
        "365d6294dfbd37ebc51def8b65b81eb79b3934ecbc95a2ec2d4d827efe6a922b";
    };
    propagatedBuildInputs = [ TimeDate ];
    meta = {
      homepage = "https://github.com/libwww-perl/HTTP-Date";
      description = "HTTP::Date - date conversion routines";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  TestHTTPServer = buildPerlPackage {
    pname = "Test-HTTP-Server";
    version = "0.04";
    src = fetchurl {
      url = "mirror://cpan/authors/id/N/NE/NEILB/Test-HTTP-Server-0.04.tar.gz";
      sha256 =
        "3ad2a469944558cfb704213309ca646348c575e3bd712c3a73a7b2b1895bc815";
    };
    propagatedBuildInputs = [ URI ];
    meta = {
      homepage = "https://github.com/neilb/Test-HTTP-Server";
      description = "Simple forking http server";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  LWP = buildPerlPackage {
    pname = "libwww-perl";
    version = "6.57";
    src = fetchurl {
      url = "mirror://cpan/authors/id/O/OA/OALDERS/libwww-perl-6.57.tar.gz";
      sha256 =
        "30c242359cb808f3fe2b115fb90712410557f0786ad74844f9801fd719bc42f8";
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

  NetCurl = buildPerlPackage {
    pname = "Net-Curl";
    version = "0.49";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/SY/SYP/Net-Curl-0.49.tar.gz";
      sha256 =
        "53b5a367db278adfc8fc83d393064e3d5f3de5682186829ddac0683c07b4a199";
    };
    buildInputs = [ pkgs.curlFull ];
    postPatch = ''
      rm t/51-crash-destroy-with-callbacks.t
      rm t/53-crash-destroy-with-callbacks-multi.t
    '';
    meta = {
      homepage = "https://github.com/sparky/perl-Net-Curl";
      description = "Perl interface for libcurl";
      license = lib.licenses.mit;
    };
  };

  LWPProtocolNetCurl = buildPerlPackage {
    pname = "LWP-Protocol-Net-Curl";
    version = "0.026";
    src = fetchurl {
      url =
        "mirror://cpan/authors/id/S/SY/SYP/LWP-Protocol-Net-Curl-0.026.tar.gz";
      sha256 =
        "eef6fe35152f51e86f4e5d6737d71c78a66495810ea5608b71820698f91011bd";
    };
    buildInputs = [ HTTPMessage TestHTTPServer ];
    propagatedBuildInputs = [ HTTPDate LWP NetCurl URI ];
    meta = {
      homepage = "https://github.com/creaktive/LWP-Protocol-Net-Curl";
      description = "The power of libcurl in the palm of your hands!";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  JSONXS = buildPerlPackage {
    pname = "JSON-XS";
    version = "4.03";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/ML/MLEHMANN/JSON-XS-4.03.tar.gz";
      sha256 =
        "515536f45f2fa1a7e88c8824533758d0121d267ab9cb453a1b5887c8a56b9068";
    };
    buildInputs = [ CanaryStability ];
    propagatedBuildInputs = [ TypesSerialiser commonsense ];
    meta = { };
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

  ModuleBuild = buildPerlPackage {
    pname = "Module-Build";
    version = "0.4231";
    src = fetchurl {
      url = "mirror://cpan/authors/id/L/LE/LEONT/Module-Build-0.4231.tar.gz";
      sha256 =
        "7e0f4c692c1740c1ac84ea14d7ea3d8bc798b2fb26c09877229e04f430b2b717";
    };
    meta = {
      description = "Build and install Perl modules";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

  EncodeDetect = buildPerlPackage {
    pname = "Encode-Detect";
    version = "1.01";
    src = fetchurl {
      url = "mirror://cpan/authors/id/J/JG/JGMYERS/Encode-Detect-1.01.tar.gz";
      sha256 =
        "834d893aa7db6ce3f158afbd0e432d6ed15a276e0940db0a74be13fd9c4bbbf1";
    };
    buildInputs = [ ModuleBuild pkgs.stdenv.cc.cc.lib ];
    meta = {
      description =
        "An Encode::Encoding subclass that detects the encoding of data";
      license = lib.licenses.free;
    };
  };

  Encode = buildPerlPackage {
    pname = "Encode";
    version = "3.12";
    src = fetchurl {
      url = "mirror://cpan/authors/id/D/DA/DANKOGAI/Encode-3.12.tar.gz";
      sha256 =
        "38da5b7f74bc402075f5994557b5f1426636291efea0f39fcdf4b1366b0756fd";
    };
    meta = {
      description = "Character encodings in Perl";
      license = with lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

in [
  AlgorithmDiff
  BCOW
  CaptureTiny
  ClassErrorHandler
  ClassMethodModifiers
  Clone
  ConvertMoji
  DataPerl
  DevelCycle
  Encode
  EncodeDetect
  EncodeLocale
  ExporterTiny
  ExtUtilsConfig
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
  LWPProtocolNetCurl
  LinguaJAMoji
  ListLazy
  ListMoreUtils
  ListMoreUtilsXS
  ModuleBuild
  ModulePluggable
  ModuleRuntime
  Moo
  MooXHandlesVia
  MooXTypesMooseLike
  NetCurl
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
  TestHTTPServer
  TestLeakTrace
  TestMemoryCycle
  TestNeeds
  TestOutput
  TestRequiresInternet
  TestWarn
  TextDiff
  TextMeCab
  TimeDate
  TryTiny
  URI
  URIFetch
  WWWRobotRules
  XMLDOMLite
  YAMLLibYAML
  barewordfilehandles
  indirect
  multidimensional
  strictures
]
