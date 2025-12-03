{ lib
, stdenv
, fetchurl
, version
, hashes
}:

let
  # Map Nix system to Go's target naming
  targets = {
    "x86_64-linux" = "linux-amd64";
    "aarch64-linux" = "linux-arm64";
    "x86_64-darwin" = "darwin-amd64";
    "aarch64-darwin" = "darwin-arm64";
  };

  target = targets.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

in
stdenv.mkDerivation {
  pname = "go";
  inherit version;

  src = fetchurl {
    url = "https://go.dev/dl/go${version}.${target}.tar.gz";
    hash = hashes.${target};
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out/

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Go Programming Language (latest upstream release)";
    homepage = "https://go.dev/";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    maintainers = [ ];
    mainProgram = "go";
  };
}
