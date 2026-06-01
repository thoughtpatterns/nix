{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation rec {
  pname = "spork";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "janet-lang";
    repo = "spork";
    rev = "v${version}";
    hash = "sha256-aAM9USwh3ZifupHVPqu/aFyaLrTGlYnzV/88RDkpLjE=";
  };

  nativeBuildInputs = with pkgs; [ janet ];

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out"
    JANET_PREFIX='${pkgs.janet}' JANET_PATH="$out" janet --install .
    mkdir -p "$out/share"
    mv "$out/man" "$out/share/man"
  '';

  meta = with lib; {
    description = "Official Janet 'contrib' library";
    homepage = "https://github.com/janet-lang/spork";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
