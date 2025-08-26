{ config }:

{
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    powerManagement.enable = true;
    powerManagement.finegrained = true;

    prime = {
      nvidiaBusId = "PCI:6:0:0";
      amdgpuBusId = "PCI:1:0:0";
    };
  };
}