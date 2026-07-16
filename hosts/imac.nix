# imac — Apple-silicon iMac running nix-darwin.
{ ... }:

{
  imports = [
    ../configuration.nix
    ../modules/darwin.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.variables.MAKEFLAGS = "-j8";

  homebrew.casks = [
    "adobe-creative-cloud"
    "anki"
    "antigravity-cli"
    "balenaetcher"
    "helium-browser"
    "microsoft-office"
    "nordvpn"
    "spotify"
    "zoom"
  ];
}
