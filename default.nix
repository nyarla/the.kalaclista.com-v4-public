{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let cpanModules = import ./cpan.nix { };
in mkShell rec {
  name = "the.kalaclista.com";
  packages = [
    curlFull
    gnumake
    hugo
    perl
    python3Packages.brotli
    python3Packages.fonttools
  ] ++ cpanModules;
}
