{
  description = "mattrobenolt's nixpkgs";

  nixConfig = {
    extra-substituters = [ "https://mattrobenolt.cachix.org" ];
    extra-trusted-public-keys = [
      "mattrobenolt.cachix.org-1:sn1IDSC4OxQvWaOVD4RRcqyKlket5wgb11nd1QII6i8="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Load Go versions and hashes
      goVersions = builtins.fromJSON (builtins.readFile ./pkgs/go/versions.json);
      goHashes = builtins.fromJSON (builtins.readFile ./pkgs/go/hashes.json);

      # Helper to create a Go package for a specific version
      makeGo =
        prev: majorMinor:
        let
          version = goVersions.${majorMinor};
          hashes = goHashes.${version};
        in
        prev.callPackage ./pkgs/go {
          inherit version hashes;
        };

      # Get the latest Go version (highest minor version)
      # Filter out "next" to only consider stable versions
      latestGoVersion = builtins.head (
        builtins.sort (a: b: a > b) (builtins.filter (v: v != "next") (builtins.attrNames goVersions))
      );

      # Overlay that adds our custom packages
      overlay =
        _final: prev:
        let
          # Create all go-bin_1_XX packages dynamically
          dynamicGoPackages = builtins.listToAttrs (
            map (majorMinor: {
              name = "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor);
              value = makeGo prev majorMinor;
            }) (builtins.attrNames goVersions)
          );
        in
        {
          uvShellHook = prev.callPackage ./pkgs/uv/venv-shell-hook.nix { };
          inbox = prev.callPackage ./pkgs/inbox { };
          zigdoc = prev.callPackage ./pkgs/zigdoc { };
          ziglint = prev.callPackage ./pkgs/ziglint { };
          tracy = prev.callPackage ./pkgs/tracy { };

          # Latest Go version as go-bin (automatically uses the highest version)
          go-bin = makeGo prev latestGoVersion;
        }
        // dynamicGoPackages;

      # Per-system derivations, evaluated lazily per system
      perSystem =
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ overlay ];
          };

          treefmtEval = treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";

            programs = {
              nixfmt.enable = true; # Uses nixfmt-rfc-style by default
              deadnix.enable = true;
              statix.enable = true;
            };

            settings = {
              global.excludes = [
                ".direnv/**"
              ];

              formatter = {
                deadnix.priority = 1; # Remove unused code first
                statix.priority = 2; # Fix anti-patterns second
                nixfmt.priority = 3; # Format last
              };
            };
          };

          # Get all go-bin_1_XX package names dynamically
          goPackageNames = map (
            majorMinor: "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor)
          ) (builtins.attrNames goVersions);
        in
        {
          packages =
            builtins.listToAttrs (
              map (name: {
                inherit name;
                value = pkgs.${name};
              }) goPackageNames
            )
            // {
              inherit (pkgs)
                go-bin
                uvShellHook
                inbox
                zigdoc
                ziglint
                tracy
                ;
              default = pkgs.ziglint;
            };

          # Formatter for `nix fmt`
          formatter = treefmtEval.config.build.wrapper;

          # Formatting check for CI
          checks = {
            formatting = treefmtEval.config.build.check self;
          };

          # Development shell with Nix tooling
          devShells.default = pkgs.mkShell {
            packages = [
              # Task runner
              pkgs.just

              # For update scripts
              pkgs.python3
              pkgs.zon2nix # Zig dependency generator

              # Unified formatting via treefmt-nix (includes nixfmt, deadnix, statix)
              treefmtEval.config.build.wrapper

              # Nix utilities
              pkgs.nix-tree # Visualize dependency trees
              pkgs.nix-diff # Diff derivations
            ];

            shellHook = ''
              just --list --unsorted
            '';
          };
        };

      allSystems = forAllSystems perSystem;
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

        rust = {
          path = ./templates/rust;
          description = "Rust development environment";
        };

        python = {
          path = ./templates/python;
          description = "Python development environment";
        };
      };

      # Default template
      defaultTemplate = self.templates.go;

      packages = builtins.mapAttrs (_: s: s.packages) allSystems;
      formatter = builtins.mapAttrs (_: s: s.formatter) allSystems;
      checks = builtins.mapAttrs (_: s: s.checks) allSystems;
      devShells = builtins.mapAttrs (_: s: s.devShells) allSystems;
    };
}
