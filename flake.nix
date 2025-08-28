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

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        inputs.nix4vscode.overlays.default
        (final: prev: { zen-browser = inputs.zen-browser.packages.${system}.specific; })
      ];
      modules = [
        inputs.home-manager.nixosModules.default
        inputs.minegrub-world-sel-theme.nixosModules.default
      ];

      mkHost = hostConfigPath: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = modules ++ [
          hostConfigPath
          ({ config, ... }: { nixpkgs.overlays = overlays; })
        ];
      };
    in
    {
      nixosConfigurations = 
      let
        hostsDir = ./hosts;
        hostNames = builtins.filter (name: name != "common") (builtins.attrNames (builtins.readDir hostsDir));
      in 
      builtins.listToAttrs (map (hostName: { name = hostName; value = mkHost (hostsDir + "/${hostName}"); }) hostNames);
    };
}
