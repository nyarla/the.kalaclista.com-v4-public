#!/usr/bin/env perl

use strict;
use warnings;

sub find {
  my $module = shift;
  $module = "perlPackages.${module}";

  return
    system(
    "sh -c 'nix search -I nixpkgs=/etc/nixpkgs --quiet ${module} >/dev/null'")
    == 0;
}

sub generate {
  my @mod = `cat resources/_cpan/modules.txt`;
  my @outs;
  my @deps;

  my %pkgs;

  for my $module (@mod) {
    chomp($module);

    my $pkg = `cpanm --info $module`;
    chomp($pkg);

    if ( exists $pkgs{$pkg} ) {
      next;
    }
    else {
      $pkgs{$pkg}++;
    }

    my @name = split q{-}, ( split q{/}, $pkg )[1];
    pop @name;
    my $name = join q{}, @name;

    if ( !find($name) ) {
      print "generate: ${module}\n";
      my $out = `nix-generate-from-cpan ${module}`;
      $name = ( $out =~ m{([^ ]+) = buildPerlPackage} )[0];
      push @outs, $out;
    }

    print "added: perlPackage.${name}\n";
    push @deps, $name;
  }

  return \@outs, \@deps;
}

sub main {
  my ( $outs, $deps ) = generate;

  open( my $fh, '>', 'cpan2.nix' );
  print $fh <<_NIX_;
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

with perlPackages;

let
  @{[ join(qq{\n}, $outs->@*) ]}
in [
  @{[ join q{ }, sort $deps->@* ]}
]
_NIX_

  close($fh);
}

main;
