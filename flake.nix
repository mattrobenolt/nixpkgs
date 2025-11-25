{
  description = "mattrobenolt's nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          zlint = pkgs.callPackage ./pkgs/zlint { };
          default = self.packages.${system}.zlint;
        };

        # Development shell with Nix tooling
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Task runner
            just

            # Nix formatter
            nixpkgs-fmt # Official nixpkgs formatter

            # Nix linters
            statix # Lints and suggests anti-patterns
            deadnix # Find and remove unused code

            # Nix utilities
            nix-tree # Visualize dependency trees
            nix-diff # Diff derivations
          ];

          shellHook = ''
            just --list --unsorted
            echo ""
          '';
        };
      }
    );
}
