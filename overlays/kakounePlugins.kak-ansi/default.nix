# Prevent the addition of rc to Kakoune's autoload.

self: super:

{
  kakounePlugins.kak-ansi = super.kakounePlugins.kak-ansi.overrideAttrs (attrs: {
    installPhase = ''
      mkdir -p "$out/bin"
      cp kak-ansi-filter "$out/bin"
    '';
  });
}
