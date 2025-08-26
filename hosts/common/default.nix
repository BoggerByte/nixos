{ inputs, ... }:

{
  imports = [
    (inputs.self + "/overlays")

    ./boot.nix
    ./locale.nix
    ./sound.nix
    ./networking.nix
    ./printing.nix
    ./bluetooth.nix
    ./display-manager.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  users.groups.nixosmanager = {};
  
  services.envfs.enable = true;
  environment.sessionVariables = {
    NH_FLAKE = "/etc/nixos";
  };
  environment.etc = {
    "nixos" = {
      source = "/etc/nixos";
      user = "root";
      group = "nixosmanager";
      mode = "rwxrwxr--";
    };
  };
}
