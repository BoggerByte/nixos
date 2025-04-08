{
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm = {
  #   wayland.enable = true;
  #   enableHidpi = true;
  #   package = pkgs.kdePackages.sddm; # qt6 sddm version
  #   extraPackages = with pkgs; [
  #     qt6.qtmultimedia
  #   ];
  #   theme = sddm-astronaut-theme-name;
  # };
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.banner = "Welcome! <3";
}
