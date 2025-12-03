{
  description = "mattrobenolt's nixpkgs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # Load Go versions and hashes
      goVersions = builtins.fromJSON (builtins.readFile ./pkgs/go/versions.json);
      goHashes = builtins.fromJSON (builtins.readFile ./pkgs/go/hashes.json);

      # Helper to create a Go package for a specific version
      makeGo = prev: majorMinor:
        let
          version = goVersions.${majorMinor};
          hashes = goHashes.${version};
        in
        prev.callPackage ./pkgs/go {
          inherit version hashes;
        };

      # Overlay that adds our custom packages
      overlay = _final: prev: {
        zlint = prev.callPackage ./pkgs/zlint { };

        # Latest Go version (currently 1.25)
        go = makeGo prev "1.25";

        # Specific minor versions
        go_1_25 = makeGo prev "1.25";
        go_1_24 = makeGo prev "1.24";
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
          inherit (pkgs) zlint go go_1_24 go_1_25;
          default = self.packages.${system}.zlint;
        };

        # Development shell with Nix tooling
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Task runner
            just

            # For update scripts
            python3

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
