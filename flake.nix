{
  inputs = { utils.url = "github:numtide/flake-utils"; };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in rec {
        # `nix build`
        packages.kernel = pkgs.stdenv.mkDerivation {
          pname = "zkernel";
          src = ./.;

          preBuild = ''
            export HOME=$TMPDIR
          '';

          installPhase = ''
            zig build -Drelease-safe --prefix $out install
          '';
        };
        defaultPackage = packages.kernel;

        # `nix run`
        apps.kernel = utils.lib.mkApp { drv = packages.kernel; };
        defaultApp = apps.kernel;

        # `nix develop`
        devShell = pkgs.mkShell {
          # supply the specific rust version
          nativeBuildInputs =
            [ pkgs.xorriso pkgs.llvmPackages_12.bintools pkgs.nasm ];
        };
      });
}
