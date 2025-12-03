# mattrobenolt's nixpkgs

Custom Nix packages and overlays that provide faster updates than nixpkgs-unstable.

## Packages

### Go

Latest upstream Go releases, automatically updated daily via GitHub Actions.

- `go` - Latest Go (1.25.x)
- `go_1_25` - Go 1.25.x
- `go_1_24` - Go 1.24.x

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
      # Optional: reduce closure size by not pulling in the whole repo
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
          pkgs.go      # Latest Go from this overlay
          pkgs.zlint   # zlint from this overlay
        ];
      };
    };
}
```

### Local development

```bash
# Enter dev shell
nix develop

# Update Go versions
just update-go

# Build packages
nix build .#go
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

Go versions are automatically updated daily at 2 AM UTC via GitHub Actions. The workflow:

1. Fetches latest Go releases from go.dev
2. Generates SRI hashes for all platforms
3. Commits changes if new versions are available

You can also manually trigger the workflow from the Actions tab.

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
