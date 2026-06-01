{
  lib,
  stdenv,
  fetchurl,
  makeWrapper,
  ncurses,
  rlwrap,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mitscheme-svm";
  version = "12.1";

  src = fetchurl {
    url = "https://ftp.gnu.org/gnu/mit-scheme/stable.pkg/${finalAttrs.version}/mit-scheme-${finalAttrs.version}-svm1-64le.tar.gz";
    hash = "sha256-LFtb8fRMfCRY2nnAlD4IKuN/F1LH2dHOCmH3r8vwQwQ=";
  };

  buildInputs = [ ncurses ];
  enableParallelBuilding = true;
  nativeBuildInputs = [ makeWrapper ];
  sourceRoot = "mit-scheme-${finalAttrs.version}/src";

  # Disable the 'edwin', 'imail', and 'x11(-screen)?' plugins, which are enabled by default.
  configureFlags = [
    "--enable-edwin=no"
    "--enable-imail=no"
    "--enable-x11=no"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Avoid an 'sw_vers' call, as it's unreachable from the Nix sandbox.
    "--with-macos-version=${stdenv.hostPlatform.darwinMinVersion}"
  ];

  # Wrap with 'rlwrap'.
  postInstall = ''
    target="$out/bin/$(readlink "$out/bin/mit-scheme")"
    rm "$out/bin/mit-scheme"
    makeWrapper '${rlwrap}/bin/rlwrap' "$out/bin/mit-scheme" --add-flags "$target"
  '';

  meta = with lib; {
    description = "MIT/GNU Scheme, a portable Scheme VM binary";
    homepage = "https://www.gnu.org/software/mit-scheme/";
    license = licenses.gpl2Plus;
    platforms = platforms.unix;
    maintainers = with maintainers; [ mackeye ];
  };
})
