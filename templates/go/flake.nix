{
  description = "Go development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go_1_25
            gopls
            # Add other tools: gotools, delve, etc.
          ];

          # Environment variables (optional)
          # GOEXPERIMENT = "jsonv2";

          shellHook = ''
            # Add project binaries to PATH
            export PATH="$PWD/bin:$PATH"
          '';
        };
      }
    );
}
