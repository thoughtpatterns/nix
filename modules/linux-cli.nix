# Base NixOS configuration shared by any Linux host: networking, nix, the user
# account, and the dotfile render daemon. The niri/Wayland desktop lives in
# ./linux-gui.nix; machine-specific pieces (disk, ZFS, hostId, hardware) live
# under ../hosts.
{
  pkgs,
  user,
  host,
  home,
  ...
}:

let
  flakeDir = "${home}/.config/nix";
in
{
  console.keyMap = "us";

  networking.networkmanager.enable = true;

  nix.gc.dates = "weekly";
  nix.settings.trusted-users = [ "root" ];

  services.syncthing = {
    enable = true;
    user = user;
    dataDir = home;
    configDir = "${home}/.config/syncthing";
  };

  # Watch the dotfile sources + manifest and re-render on change (as the user).
  systemd.user.services.tppd = {
    description = "Render tpp-templated dotfiles on change";
    wantedBy = [ "default.target" ];
    environment = {
      HOST = host;
      FLAKE = flakeDir;
    };
    serviceConfig = {
      ExecStart = "${pkgs.watchexec}/bin/watchexec --watch ${flakeDir}/home --postpone -- ${pkgs.tppd}/bin/tppd --daemon";
      Restart = "on-failure";
    };
  };

  # Initial render on activation, as the user so copies are user-owned.
  system.activationScripts.dotfiles = {
    text = ''
      ${pkgs.util-linux}/bin/runuser -u ${user} -- \
        env HOST=${host} FLAKE=${flakeDir} ${pkgs.tppd}/bin/tppd
    '';
    deps = [ "users" ];
  };

  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    initialPassword = "password";
  };
}
