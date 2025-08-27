{ inputs, pkgs, ... }:
let 
  username = "bogger-byte";
in
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./hyprland.nix
    ./thunar.nix
    (import ./docker.nix { inherit username; })
    (import ./zsh.nix { inherit username; })
  ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  users.users.${username} = {
    isNormalUser = true;
    description = "Nikita Troshnev";
    extraGroups = [ "networkmanager" "wheel" "video" "nixos-admins" ];
  };

  systemd.packages = [ pkgs.dconf ];
  services.envfs.enable = true;

  home-manager.backupFileExtension = "hm-backup";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users.${username} = import ./home;
  };
}
