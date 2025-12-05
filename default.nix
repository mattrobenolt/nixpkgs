# default.nix - NUR compatibility
{ pkgs ? import <nixpkgs> { } }:

let
  # Load the flake overlay
  flake = builtins.getFlake (toString ./.);

  # Apply the overlay to get all packages
  pkgsWithOverlay = pkgs.extend flake.overlays.default;

  # Load Go versions dynamically (same as flake.nix)
  goVersions = builtins.fromJSON (builtins.readFile ./pkgs/go/versions.json);

  # Create list of all go-bin package names
  goPackageNames = map
    (majorMinor: "go-bin_" + (builtins.replaceStrings [ "." ] [ "_" ] majorMinor))
    (builtins.attrNames goVersions);

  # Extract all go-bin packages dynamically
  goPackages = builtins.listToAttrs (
    map
      (name: { inherit name; value = pkgsWithOverlay.${name}; })
      goPackageNames
  );
in
{
  # Expose individual packages for NUR
  inherit (pkgsWithOverlay) zlint zlint-unstable go-bin;

  # NUR metadata
  modules = [ ];
  overlays = {
    inherit (flake.overlays) default;
  };
} // goPackages
