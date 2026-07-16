{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libdrm,
  libGL,
  libgbm,
  libglvnd,
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  pipewire,
  systemd,
  vulkan-loader,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "helium";
  version = "0.14.6.1";

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${finalAttrs.version}/helium-${finalAttrs.version}-x86_64_linux.tar.xz";
    hash = "sha256-JxeluCe6x9eF1hp4PRII5S0dl4ScVW9oHJaoNbVxv7A=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libdrm
    libgbm
    libxkbcommon
    nspr
    nss
    pango
    (lib.getLib systemd)
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    stdenv.cc.cc.lib
  ];

  # Chromium dlopens these, so autoPatchelf cannot discover them from DT_NEEDED.
  runtimeDependencies = [
    libGL
    libglvnd
    libva
    pipewire
    vulkan-loader
  ];

  # The Qt shims are only dlopened for Qt platform-theme integration, which is
  # unused under a GTK/wayland session. Leaving them unsatisfied avoids pulling
  # in both Qt5 and Qt6 for a code path that never runs.
  autoPatchelfIgnoreMissingDeps = [
    "libQt5Core.so.5"
    "libQt5Gui.so.5"
    "libQt5Widgets.so.5"
    "libQt6Core.so.6"
    "libQt6Gui.so.6"
    "libQt6Widgets.so.6"
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/helium
    cp -r . $out/opt/helium

    install -Dm644 helium.desktop $out/share/applications/helium.desktop
    install -Dm644 product_logo_256.png \
      $out/share/icons/hicolor/256x256/apps/helium.png

    mkdir -p $out/bin
    makeWrapper $out/opt/helium/helium $out/bin/helium \
      --set CHROME_VERSION_EXTRA "nixos" \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libGL
          libva
          vulkan-loader
        ]
      }" \
      "''${gappsWrapperArgs[@]}"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Private, fast, and honest web browser";
    homepage = "https://helium.computer";
    downloadPage = "https://github.com/imputnet/helium-linux/releases";
    license = licenses.gpl3Only;
    mainProgram = "helium";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ mackeye ];
  };
})
