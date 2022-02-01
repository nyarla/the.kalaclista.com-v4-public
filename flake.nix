{
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/master"; };

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      cpanModules = (import ./cpan.nix) { inherit pkgs; };
    in {
      devShell.${system} = with pkgs;
        mkShell rec {
          name = "the.kalaclista.com";
          packages = [
            curlFull
            fzy
            gnumake
            google-cloud-sdk
            hugo
            perl
            python3Packages.brotli
            python3Packages.fonttools
          ] ++ cpanModules ++ (with perlPackages; [
            LWPProtocolhttps
            IOSocketSSL
            NetSSLeay
            PerlTidy
          ]);
        };
    };
}
