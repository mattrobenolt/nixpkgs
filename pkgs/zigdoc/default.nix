{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  zig_0_15,
}:

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

  patches = [ ./remove-ziglint.patch ];

  postPatch = ''
    substituteInPlace build.zig \
      --replace-fail '"../README.md"' '"README.md"'
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
