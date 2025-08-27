let
  nixos-config-path = "/etc/nixos";
  nixos-admins-group-name = "nixos-admins";
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  environment.sessionVariables.NH_FLAKE = nixos-config-path;

  # Allow nixos admins to edit /etc/nixos without sudo
  users.groups.${nixos-admins-group-name} = {};
  envitonment.etc.nixos = {
    source = nixos-config-path;
    user = "root";
    group = nixos-admins-group-name;
    mode = "rwxrwxr--";
  };  
}
