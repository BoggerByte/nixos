{ inputs, ... }:

{
  imports = [
    (inputs.self + "/overlays")
    
    ./nix.nix
    ./boot.nix
    ./locale.nix
    ./sound.nix
    ./networking.nix
    ./printing.nix
    ./bluetooth.nix
    ./display-manager.nix
  ];
}
