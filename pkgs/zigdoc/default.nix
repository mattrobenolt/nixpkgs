{ lib
, stdenvNoCC
, fetchFromGitHub
, zigpkgs
,
}:

stdenvNoCC.mkDerivation {
  pname = "zigdoc";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "rockorager";
    repo = "zigdoc";
    rev = "v0.2.2";
    hash = "sha256-bvZnNiJ6YbsoQb41oAWzZNErCcAtKKudQMwvAfa4UEA=";
  };

  nativeBuildInputs = [ zigpkgs."0.15.2" ];

  dontConfigure = true;
  dontInstall = true;

  preBuild = "export HOME=$TMPDIR";

  buildPhase = ''
    runHook preBuild
    zig build --prefix $out -Doptimize=ReleaseSafe
    runHook postBuild
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
