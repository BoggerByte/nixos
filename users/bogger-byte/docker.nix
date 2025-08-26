{ username }: { pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
    extraPackages = with pkgs; [ 
      docker-buildx 
      docker-sbom
    ];
  };
  users.extraGroups.docker.members = [ username ];
}