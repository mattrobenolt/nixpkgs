{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchzip,
  zig_0_15,
}:

let
  # Pre-fetch the ziglint dependency required by zigdoc's build system.
  # The hash corresponds to the package hash in build.zig.zon.
  ziglintDep = fetchzip {
    url = "https://github.com/rockorager/ziglint/archive/refs/tags/v0.5.2.tar.gz";
    hash = "sha256-YjFhaA5bv4M9LaMOHWTy4WtHatvcfIOCI6c0/5Lokhs=";
    stripRoot = false;
  };
in
stdenvNoCC.mkDerivation {
  pname = "zigdoc";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "rockorager";
    repo = "zigdoc";
    rev = "v0.3.0";
    hash = "sha256-MhZ7LCsqZhLazDYwDZ/hzk9lYM3Bm1j96HDQ/OrdZFg=";
  };

  nativeBuildInputs = [ zig_0_15 ];

  postPatch = ''
    substituteInPlace build.zig \
      --replace-fail '"../README.md"' '"README.md"'
  '';

  preBuild = ''
    export HOME=$TMPDIR
    mkdir -p "$HOME/.cache/zig/p"
    cp -r ${ziglintDep} "$HOME/.cache/zig/p/1220a87cf8c8d73c1ccb37e3fbcc488b4b6b29a73c2b936aae15f88a12b52c8c76e0"
  '';

  meta = with lib; {
    description = "Generate documentation from Zig source code";
    homepage = "https://github.com/rockorager/zigdoc";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "zigdoc";
    platforms = platforms.all;
  };
}
