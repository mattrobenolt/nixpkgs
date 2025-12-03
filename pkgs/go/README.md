# Go Overlay

Provides the latest upstream Go releases, updated faster than nixpkgs-unstable.

## Available Packages

- `go` - Latest Go version (currently 1.25)
- `go_1_25` - Go 1.25.x (latest patch)
- `go_1_24` - Go 1.24.x (latest patch)

## Updating

To fetch the latest Go versions and update hashes:

```bash
just update-go
```

Or directly:

```bash
./pkgs/go/update.py
```

This will:
1. Fetch the latest patch versions for Go 1.24 and 1.25
2. Download and generate SRI hashes for all platforms
3. Update `versions.json` and `hashes.json`

## Usage

### In a project flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mattrobenolt-nixpkgs.url = "github:mattrobenolt/nixpkgs";  # or path:/Users/matt/code/nixpkgs
  };

  outputs = { nixpkgs, mattrobenolt-nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ mattrobenolt-nixpkgs.overlays.default ];
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.go       # Latest (1.25.5)
          # or
          pkgs.go_1_24  # Specific version (1.24.9)
        ];
      };
    };
}
```

### In nix-darwin

Add to your `flake.nix` inputs and apply the overlay in your system configuration.

## Adding New Versions

To track a new Go minor version (e.g., 1.26 when released):

1. Edit `update.py` and add the new version to the regex patterns
2. Update the `versions` dict in `fetch_latest_versions()`
3. Update the flake.nix overlay to expose `go_1_26`

## Files

- `default.nix` - Package builder (accepts version and hashes)
- `versions.json` - Maps minor versions to latest patch versions
- `hashes.json` - SRI hashes for all versions and platforms
- `update.py` - Automated update script
