{ username }: { pkgs, ... }:

{
  programs.zsh.enable = true;
  users.users.${username}.shell = pkgs.zsh;
}
