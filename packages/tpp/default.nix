{
  lib,
  stdenv,
  fetchFromSourcehut,
  gambit,
}:

stdenv.mkDerivation {
  pname = "tpp";
  version = "0-unstable-2026-07-21";

  src = fetchFromSourcehut {
    owner = "~orchid";
    repo = "tpp";
    rev = "2efba8c77262230d50eb422bbf164e82191917e3";
    sha256 = "sha256-49cECGxMQQc+e8RFQmxQYu4YFNT2wbRcPF2yFZ4LvME=";
    vc = "git";
  };

  nativeBuildInputs = [ gambit ];

  buildPhase = ''
    runHook preBuild
    gsc -exe tpp.scm
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 tpp "$out/bin/tpp"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Tiny text preprocessor";
    homepage = "https://git.sr.ht/~orchid/tpp";
    license = licenses.bsd0;
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
