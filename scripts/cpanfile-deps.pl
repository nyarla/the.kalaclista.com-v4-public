#!/usr/bin/env perl

use strict;
use warnings;

use Module::CoreList;

sub main {
  my @mod = map { chomp($_); $_ } `cpanfile-dump`;
  my %pkgs;
  my @pkgs;

  while ( defined( my $module = shift @mod ) ) {
    next if ( $module eq 'perl' );
    if ( !exists $pkgs{$module} ) {
      $pkgs{$module}++;
      unshift @pkgs, $module;
    }

    print "find dependences: ${module}\n";

    for my $dep (`cpanm -q --showdeps $module`) {
      chomp($dep);
      $dep =~ s{~.+$}{};

      if ( !exists $pkgs{$dep} && !Module::CoreList::is_core($dep) ) {
        $pkgs{$dep}++;
        unshift @pkgs, $dep;
        unshift @mod,  $dep;
      }
    }
  }

  if ( !-e "resources/_cpan" ) {
    system('mkdir -p resources/_cpan');
  }

  open( my $fh, '>', 'resources/_cpan/modules.txt' );
  print $fh ( join qq{\n}, @pkgs, '' );
  close($fh);
}

main;
