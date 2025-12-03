#!/usr/bin/env python3
"""Update Go versions and hashes for the nixpkgs overlay."""

import json
import re
import subprocess
import sys
from pathlib import Path
from urllib.request import urlopen

SCRIPT_DIR = Path(__file__).parent
VERSIONS_FILE = SCRIPT_DIR / "versions.json"
HASHES_FILE = SCRIPT_DIR / "hashes.json"

# ANSI colors
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
RED = "\033[0;31m"
NC = "\033[0m"  # No Color


def fetch_latest_versions():
    """Fetch the latest Go versions from go.dev."""
    print(f"{GREEN}🔍 Fetching latest Go versions...{NC}")

    with urlopen("https://go.dev/dl/") as response:
        html = response.read().decode("utf-8")

    # Extract latest patch version for each minor version
    go_1_25 = max(
        (v for v in re.findall(r"go(1\.25\.\d+)", html)),
        default=None,
    )
    go_1_24 = max(
        (v for v in re.findall(r"go(1\.24\.\d+)", html)),
        default=None,
    )

    if not go_1_25 or not go_1_24:
        print(f"{RED}Error: Could not find Go versions{NC}", file=sys.stderr)
        sys.exit(1)

    print(f"{GREEN}Latest versions found:{NC}")
    print(f"  Go 1.25: {go_1_25}")
    print(f"  Go 1.24: {go_1_24}")
    print()

    # Update versions.json
    versions = {
        "1.25": go_1_25,
        "1.24": go_1_24,
    }

    with open(VERSIONS_FILE, "w") as f:
        json.dump(versions, f, indent=2)
        f.write("\n")

    return versions


def generate_hash(version, platform):
    """Generate hash for a specific version and platform."""
    print(f"{YELLOW}  Fetching hash for go{version}.{platform}.tar.gz...{NC}")

    url = f"https://go.dev/dl/go{version}.{platform}.tar.gz"

    try:
        # Fetch with nix-prefetch-url
        result = subprocess.run(
            ["nix-prefetch-url", "--type", "sha256", url],
            capture_output=True,
            text=True,
            check=True,
        )
        hash_value = result.stdout.strip()

        # Convert to SRI format
        result = subprocess.run(
            ["nix", "hash", "convert", "--hash-algo", "sha256", hash_value],
            capture_output=True,
            text=True,
            check=True,
        )
        sri_hash = result.stdout.strip()

        return sri_hash
    except subprocess.CalledProcessError as e:
        print(f"{RED}Error fetching hash: {e}{NC}", file=sys.stderr)
        sys.exit(1)


def update_version_hashes(version):
    """Update hashes for a specific version."""
    print(f"{GREEN}📦 Updating hashes for Go {version}{NC}")

    platforms = ["linux-amd64", "linux-arm64", "darwin-amd64", "darwin-arm64"]
    hashes = {}

    for platform in platforms:
        hashes[platform] = generate_hash(version, platform)

    # Read existing hashes or create empty dict
    if HASHES_FILE.exists():
        with open(HASHES_FILE) as f:
            all_hashes = json.load(f)
    else:
        all_hashes = {}

    # Update with new version
    all_hashes[version] = hashes

    # Write back to file
    with open(HASHES_FILE, "w") as f:
        json.dump(all_hashes, f, indent=2)
        f.write("\n")

    print(f"{GREEN}✅ Updated hashes for Go {version}{NC}")
    print()


def main():
    """Main execution."""
    # Fetch latest versions
    versions = fetch_latest_versions()

    # Update hashes for each version
    for version in versions.values():
        update_version_hashes(version)

    print(f"{GREEN}✨ All done! Updated versions and hashes.{NC}")
    print(f"{YELLOW}📝 Updated files:{NC}")
    print(f"  - {VERSIONS_FILE}")
    print(f"  - {HASHES_FILE}")


if __name__ == "__main__":
    main()
