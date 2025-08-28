{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    minegrub-world-sel = {
      enable = true;
      customIcons = [
        {
          name = "nixos";
          lineTop = "NixOS (01/12/1970, 00:00)";
          lineBottom = "Creative Mode, Cheats, Version: ${config.system.nixos.release}";
          imgName = "nixos";
        }
      ];
    };
  };

  boot.plymouth = {
    enable = true;
    theme = "fade-in";
    extraConfig = ''
      DeviceScale=an-integer-scaling-factor
    '';
  };
  environment.systemPackages = with pkgs; [ plymouth-minecraft-theme ];

  boot.initrd.systemd.enable = true;

  # Silent boot
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [ 
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];
}
