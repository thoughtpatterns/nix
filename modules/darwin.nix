# macOS (nix-darwin) configuration shared by any Apple host. Host-specific
# pieces (platform, Homebrew casks, job count) live in ../hosts/imac.nix.
{
  pkgs,
  inputs,
  user,
  host,
  home,
  ...
}:

let
  flakeDir = "${home}/.config/nix";

  service =
    {
      name,
      command,
      extra ? { },
    }:
    {
      inherit command;
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = "/tmp/${name}/stderr.txt";
        StandardOutPath = "/tmp/${name}/stdout.txt";
      }
      // extra;
    };
in
{
  environment = {
    pathsToLink = [ "/Applications" ];

    systemPackages = with pkgs; [
      aerospace
      ghostty-bin
      libiconv
      skimpdf
      syncthing
    ];

    variables = {
      MallocNanoZone = "0";
      RUSTFLAGS = "-L${pkgs.libiconv}/lib";
    };
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
  };

  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    mutableTaps = false;
    inherit user;
    taps."homebrew/homebrew-cask" = inputs.homebrew-cask;
  };

  nix.gc.interval = {
    Weekday = 0;
    Hour = 2;
    Minute = 0;
  };

  nix.settings.trusted-users = [ "@admin" ];

  launchd.user.agents = {
    aerospace = service {
      name = "aerospace";
      command = "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
      extra.EnvironmentVariables.PATH = "${pkgs.dash}/bin:/bin:/usr/bin";
    };

    # Watch the dotfile sources + manifest and re-render on change.
    tppd = service {
      name = "tppd";
      command = "${pkgs.watchexec}/bin/watchexec --watch ${flakeDir}/home --postpone -- ${pkgs.tppd}/bin/tppd --daemon";
      extra.EnvironmentVariables = {
        HOST = host;
        FLAKE = flakeDir;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    # Initial render on activation (as the user, so copies are user-owned).
    activationScripts.postActivation.text = ''
      sudo -H -u ${user} env HOST=${host} FLAKE=${flakeDir} ${pkgs.tppd}/bin/tppd
    '';
    nixpkgsRelease = "unstable";
    primaryUser = user;
    startup.chime = false;
    stateVersion = 6;
  };

  users.users.${user}.name = user;
}
