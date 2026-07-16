{
  lib,
  ...
}:

{
  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "sd_mod"
      "sdhci_pci"
    ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault true;
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
