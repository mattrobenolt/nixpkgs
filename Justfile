# Format all Nix files
fmt:
    @echo "Formatting Nix files with nixpkgs-fmt..."
    nixpkgs-fmt .
    @echo "✓ Done"

# Run linters
lint:
    @echo "Running Nix linters..."
    @echo ""
    @echo "==> Running statix (checking for anti-patterns)..."
    @statix check . && echo "✓ statix: no issues found" || echo "✗ statix found issues (run 'statix fix' to auto-fix)"
    @echo ""
    @echo "==> Running deadnix (finding unused code)..."
    @deadnix --fail . && echo "✓ deadnix: no unused code found" || echo "✗ deadnix found unused code"
    @echo ""
    @echo "Done!"

# Check formatting and run linters
check:
    @echo "Running all checks..."
    @echo ""
    @echo "==> Checking formatting..."
    @nixpkgs-fmt --check . && echo "✓ All files are formatted correctly" || echo "✗ Some files need formatting (run 'just fmt' to fix)"
    @echo ""
    @just lint

# List available commands
default:
    @just --list
