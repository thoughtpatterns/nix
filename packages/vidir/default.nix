{
  lib,
  stdenv,
  fetchgit,
  perl,
}:

stdenv.mkDerivation rec {
  pname = "vidir";
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

    install -Dm755 vidir "$out/bin/vidir"
    patchShebangs "$out/bin/vidir"

    install -Dm644 /dev/null "$out/share/man/man1/vidir.1"
    '${perl}/bin/pod2man' --center=moreutils "--release=${version}" --section=1 vidir > "$out/share/man/man1/vidir.1"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Edit a directory in your text editor";
    homepage = "https://joeyh.name/code/moreutils";
    license = licenses.gpl2Plus;
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
