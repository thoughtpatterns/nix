{
  lib,
  stdenvNoCC,
  makeWrapper,
  janet,
  janetPackages,
  tpp,
}:

stdenvNoCC.mkDerivation {
  pname = "tppd";
  version = "0-unstable-2026-07-22";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 tppd.janet "$out/share/tppd/tppd.janet"
    makeWrapper ${janet}/bin/janet "$out/bin/tppd" \
      --add-flags "$out/share/tppd/tppd.janet" \
      --set JANET_PATH ${janetPackages.spork} \
      --prefix PATH : ${lib.makeBinPath [ tpp ]}

    runHook postInstall
  '';

  meta = with lib; {
    description = "Render tpp-templated dotfiles into place, per host/OS (used by the nix config)";
    platforms = platforms.all;
    maintainers = with maintainers; [ mackeye ];
  };
}
