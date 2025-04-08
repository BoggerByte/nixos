{ config, pkgs, ... }:

{
  boot.loader.grub = {
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    minegrub-world-sel = {
      enable = true;
      customIcons = [{
        name = "nixos";
        lineTop = "NixOS (01/12/1970, 00:00)";
        lineBottom = "Survival Mode, No Cheats, Version: ${config.system.nixos.release}";
        imgName = "nixos";
      }];
    };
  };

  boot.loader.efi.canTouchEfiVariables = true;

  boot.plymouth = {
    enable = true;
    theme = "fade-in";
    extraConfig = ''
      DeviceScale=an-integer-scaling-factor
    '';
  };
  environment.systemPackages = with pkgs; [ plymouth-minecraft-theme ];
  boot.kernelParams = [ "quiet" ];

  boot.initrd.systemd.enable = true;
  boot.initrd.verbose = false;
}