# mattrobenolt's nixpkgs

Custom Nix packages and overlays that provide faster updates than nixpkgs-unstable.

## 🎉 Zero Maintenance Philosophy

This repository is designed to be **completely maintenance-free**. All packages are automatically updated via GitHub Actions without any manual intervention.

## Packages

### Go (Fully Automated ✨)

**Latest upstream Go releases, automatically updated daily.**

The Go overlay is **completely zero-maintenance**:
- Automatically detects all available Go versions (1.24, 1.25, 1.26+)
- Automatically creates packages for each version (`go_1_24`, `go_1_25`, etc.)
- Automatically updates daily via GitHub Actions
- **When Go 1.26 is released, `go_1_26` will appear automatically!**

Available packages:
- `go` - Latest Go (always points to the highest version)
- `go_1_25` - Go 1.25.x
- `go_1_24` - Go 1.24.x
- _(Future versions appear automatically)_

See [`pkgs/go/README.md`](./pkgs/go/README.md) for details.

### zlint

Latest zlint releases.

## Usage

### Using the overlay in your flake

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    mattrobenolt-nixpkgs = {
      url = "github:mattrobenolt/nixpkgs";
      # Optional: reduce closure size
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          pkgs.go      # Latest Go (auto-updated!)
          pkgs.zlint   # Latest zlint
        ];
      };
    };
}
```

### Local development

```bash
# Enter dev shell
nix develop

# Update Go versions (optional - GitHub Actions does this daily)
just update-go

# Build packages
nix build .#go
nix build .#go_1_24
nix build .#zlint

# Run packages
nix run .#go -- version
```

## Project Templates

Quick-start templates for common development environments:

```bash
# Go project
nix flake init -t github:mattrobenolt/nixpkgs#go

# Zig project
nix flake init -t github:mattrobenolt/nixpkgs#zig

# Bun project
nix flake init -t github:mattrobenolt/nixpkgs#bun
```

## Automation

### Go Updates

Go versions are **automatically updated daily at 2 AM UTC** via GitHub Actions:

1. 🔍 Scrapes go.dev for all available Go versions
2. 📦 Finds the latest patch for each minor version (1.24.x, 1.25.x, etc.)
3. 🔐 Generates SRI hashes for all platforms (Linux, macOS, x86_64, ARM64)
4. 💾 Commits changes to `versions.json` and `hashes.json`
5. 🎉 New `go_1_XX` packages appear automatically in the flake

**When Go 1.26 is released:** It will automatically appear as `pkgs.go_1_26` the next day!

You can also manually trigger the workflow from the Actions tab on GitHub.

## Development

```bash
# Format Nix files
just fmt

# Run linters
just lint

# Check everything
just check
```

## License

MIT
