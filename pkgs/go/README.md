# Go Overlay

**Fully automated** Go releases that update faster than nixpkgs-unstable.

## 🎉 Zero Maintenance

This overlay is **completely maintenance-free**:

- ✅ **Auto-detects** all available Go minor versions (1.24, 1.25, 1.26, etc.)
- ✅ **Auto-updates** daily via GitHub Actions
- ✅ **Auto-creates** packages (`go_1_24`, `go_1_25`, etc.) dynamically
- ✅ **Auto-commits** when new versions are available

**When Go 1.26 is released, it will automatically appear as `go_1_26` with zero manual intervention!**

## Available Packages

All packages are created dynamically from the latest available Go versions:

- `go` - Latest Go version (automatically uses the highest minor version)
- `go_1_25` - Go 1.25.x (latest patch)
- `go_1_24` - Go 1.24.x (latest patch)
- `go_1_26` - Will appear automatically when Go 1.26 is released!
- _(and so on for future versions...)_

Check current versions:
```bash
cat pkgs/go/versions.json
```

## How It Works

### Daily Automation

A GitHub Actions workflow runs daily at 2 AM UTC:

1. Scrapes go.dev for all available Go versions
2. Finds the latest patch version for each minor version (1.24.x, 1.25.x, etc.)
3. Downloads and generates SRI hashes for all platforms
4. Commits changes to `versions.json` and `hashes.json`

### Dynamic Package Creation

The flake automatically:
- Reads `versions.json` to find all available versions
- Creates `go_1_XX` packages for each version
- Sets `go` to always point to the latest version

**No code changes needed when new versions are released!**

## Usage

### In a project flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mattrobenolt-nixpkgs.url = "github:mattrobenolt/nixpkgs";
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
          pkgs.go         # Latest (automatically updated)
          # or
          pkgs.go_1_24    # Specific version
        ];
      };
    };
}
```

### Manual Updates (Optional)

You can manually trigger updates:

```bash
just update-go
```

Or directly:

```bash
./pkgs/go/update.py
```

## Files

- `default.nix` - Package builder (accepts version and hashes)
- `versions.json` - Maps minor versions to latest patch versions
- `hashes.json` - SRI hashes for all versions and platforms
- `update.py` - Automated update script that auto-detects all versions
- `README.md` - This file

## That's It!

No more manual updates. When Go 1.26 drops, it just appears. 🎉
