{ inputs, config, pkgs, self, ... }: 

{
  nixpkgs.overlays = let
    additions = final: _: import ./additions { pkgs = final; };
    
    patches = _: prev: {
      ags = prev.ags.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ pkgs.libdbusmenu-gtk3 ];
      });
    };
  in [ additions patches ];
}