{ inputs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    ./hardware-configuration.nix
    ./networking.nix
    ./nix.nix

    (inputs.self + "/hosts/common")
    (inputs.self + "/users/bogger-byte")
  ];

  services.xserver.enable = false;
  system.stateVersion = "25.05";
}
