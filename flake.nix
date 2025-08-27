{
  description = "Nixos config flake";

  inputs = {
    # nix
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # hyprland
    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # 3rd party
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    matugen.url = "github:/InioX/Matugen?ref=v2.2.0";
    minegrub-world-sel-theme.url = "github:Lxtharia/minegrub-world-sel-theme";
    zen-browser.url = "github:MarceColl/zen-browser-flake";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
    in
    {
      nixosConfigurations = {
        # laptop for work
        victus = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/victus
            inputs.home-manager.nixosModules.default
            inputs.minegrub-world-sel-theme.nixosModules.default
          ];
        };
        # pc for work
        umbra = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules = [
            ./hosts/umbra
            inputs.home-manager.nixosModules.default
            inputs.minegrub-world-sel-theme.nixosModules.default
          ];
        };
      };
    };
}
