{
  description = "mattrobenolt's nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Overlay that adds our custom packages
      overlay = _final: prev: {
        zlint = prev.callPackage ./pkgs/zlint { };
      };
    in
    {
      # Export the overlay for others to use
      overlays.default = overlay;

      # Project templates
      templates = {
        go = {
          path = ./templates/go;
          description = "Go development environment";
        };

        zig = {
          path = ./templates/zig;
          description = "Zig development environment";
        };

        bun = {
          path = ./templates/bun;
          description = "Bun development environment";
        };
      };

      # Default template
      defaultTemplate = self.templates.go;
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        packages = {
          inherit (pkgs) zlint;
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
