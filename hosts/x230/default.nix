# x230 — ThinkPad X230 running NixOS; root on a striped ZFS pool.
{
  inputs,
  ...
}:

{
  imports = [
    ../../configuration.nix
    ../../modules/linux-cli.nix
    ../../modules/linux-gui.nix

    ./hardware-configuration.nix
    ./disko.nix

    inputs.disko.nixosModules.disko
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  boot = {
    loader.grub = {
      enable = true;
      device = "nodev";
      zfsSupport = true;
    };

    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = true;
  };

  environment.variables.MAKEFLAGS = "-j4";

  networking.hostId = "7d3f9e21"; # For ZFS.

  services.zfs = {
    autoScrub.enable = true;
    trim.enable = true;
  };

  system.stateVersion = "25.05";
}
