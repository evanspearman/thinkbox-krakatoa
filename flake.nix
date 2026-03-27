{
  description = "Krakatoa volumetric particle renderer";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    thinkboxlibrary.url = "github:evanspearman/thinkbox-library";
  };

  outputs = { self, nixpkgs, flake-utils, thinkboxlibrary }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        llvm = pkgs.llvmPackages_latest;
        tbl = thinkboxlibrary.packages.${system}.thinkboxlibrary;

        krakatoa = pkgs.callPackage ./Krakatoa/package.nix {
          stdenv = pkgs.clangStdenv;
          src = self;
          thinkboxlibrary = tbl;
        };

        krakatoasr = pkgs.callPackage ./KrakatoaSR/package.nix {
          stdenv = pkgs.clangStdenv;
          src = self;
          thinkboxlibrary = tbl;
          krakatoa = krakatoa;
        };
      in {
        packages = {
          default = krakatoasr;
          inherit krakatoa krakatoasr;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ krakatoa krakatoasr ];
          packages = with pkgs; [
            llvm.clang
            llvm.lld
            cmake
            ninja
            pkg-config
            pkgs.clang-tools
            pkgs.just
          ];
          shellHook = ''
            export CC="${llvm.clang}/bin/clang"
            export CXX="${llvm.clang}/bin/clang++"
          '';
        };
      }
  );
}
