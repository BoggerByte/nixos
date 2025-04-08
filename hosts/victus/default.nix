{ inputs, config, ... }:

{
  imports = [
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-nvidia
    ./hardware-configuration.nix

    (inputs.self + "/hosts/common")
    (inputs.self + "/users/bogger-byte")
  ];

  swapDevices = [{
    device = "/swapfile";
    size = 32 * 1024; # 32GB
  }];

  nix.settings.max-jobs = 16;

  networking.hostName = "victus";

  services.xserver.enable = false;
  
  hardware.brillo.enable = true;
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # powerManagement.enable = true;
    # powerManagement.finegrained = true;

    prime = {
      nvidiaBusId = "PCI:6:0:0";
      amdgpuBusId = "PCI:1:0:0";
    };
  };
  
  system.stateVersion = "23.11";
}
