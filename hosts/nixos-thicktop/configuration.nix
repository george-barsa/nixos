{ config, pkgs, vars, ... }:

{
  # Lenovo Legion Pro 5 16IRX8: Intel Alder Lake-HX iGPU (00:02.0) +
  # Nvidia RTX 4070 Mobile (01:00.0), BIOS set to Hybrid graphics.
  # PRIME offload keeps the nvidia GPU powered down until something asks
  # for it (via `nvidia-offload <cmd>`), which matters on battery.
  boot.blacklistedKernelModules = [ "nouveau" ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
