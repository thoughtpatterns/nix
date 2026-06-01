{
  lib,
  stdenv,
  fetchFromSourcehut,
  gperf,
}:

stdenv.mkDerivation rec {
  pname = "texpand";
  version = "1.0.3";

  src = fetchFromSourcehut {
    owner = "~orchid";
    repo = "texpand";
    rev = "v${version}";
    sha256 = "sha256-9ZhlzDLe6Lfg1Z4v7+bEUf43L25+rz+bNDu30s0KKns=";
    vc = "git";
  };

  nativeBuildInputs = [ gperf ];
  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "-C"
    "./src"
  ];

  meta = with lib; {
    description = "Dumb, fast TeX macro map to Unicode";
    homepage = "https://git.sr.ht/~orchid/texpand";
    license = licenses.bsd0;
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
