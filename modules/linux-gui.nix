# NixOS desktop configuration: the niri/Wayland session, audio, Bluetooth, and
# login manager. Layered on top of ./linux-cli.nix by any graphical host.
{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  environment.systemPackages = with pkgs; [
    brightnessctl
    foot
    fuzzel
    grim
    helium
    ironbar
    mako
    pavucontrol
    playerctl
    slurp
    spotify
    swaybg
    swayidle
    swaylock
    waybar
    wl-clipboard
    xwayland-satellite
  ];

  hardware = {
    graphics.enable = true;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General = {
        Experimental = true;
      };
    };
  };

  programs.niri.enable = true;

  security = {
    polkit.enable = true;
    rtkit.enable = true;
    pam.services.swaylock = { };
  };

  services = {
    greetd = {
      enable = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    blueman.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
