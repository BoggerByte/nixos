{ pkgs, ... }:
{
    environment.systemPackages = with pkgs; [ nvtopPackages.amd ];
    hardware.amdgpu.opencl.enable = true;
    hardware.amdgpu.amdvlk.enable = true;
}