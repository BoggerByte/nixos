{ pkgs }:

{
  programs.vscode.enable = true;
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    # remote development
    ms-vscode-remote.vscode-remote-extensionpack

    # jupyter notebook shortcuts
    ms-toolsai.jupyter-keymap

    # file extensions
    tamasfe.even-better-toml    # .toml
    jnoortheen.nix-ide          # .nix
    yzhang.markdown-all-in-one  # .md
    
  ];
}