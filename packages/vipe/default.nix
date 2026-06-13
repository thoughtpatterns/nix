{
  lib,
  stdenv,
  fetchgit,
  perl,
}:

stdenv.mkDerivation rec {
  pname = "vipe";
  version = "0.70";

  src = fetchgit {
    url = "git://git.joeyh.name/moreutils";
    tag = version;
    hash = "sha256-71ACHzzk258U4q2L7GJ59mrMZG99M7nQkcH4gHafGP0=";
  };

  buildInputs = [ perl ];
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 vipe "$out/bin/vipe"
    patchShebangs "$out/bin/vipe"

    install -Dm644 /dev/null "$out/share/man/man1/vipe.1"
    '${perl}/bin/pod2man' --center=moreutils "--release=${version}" --section=1 vipe > "$out/share/man/man1/vipe.1"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Insert a text editor into a pipe";
    homepage = "https://joeyh.name/code/moreutils";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
