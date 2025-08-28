{ pkgs, ... }: 

{
  programs.git.enable = true;
  programs.git = {
    userName = "BoggerByte";
    userEmail = "nik.troshnev@gmail.com";
  };

  home.packages = with pkgs; [
    gh
  ];
}