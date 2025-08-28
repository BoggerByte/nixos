{ pkgs, config, ... }:
let
  theme = config.theme.md3.contents;
in
{
  programs.vscode.enable = true;
  programs.vscode.profiles.default = {
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    extensions = pkgs.nix4vscode.forVscode [
      "rakib13332.material-code"
      "beardedbear.beardedicons"
      "miguelsolorio.fluent-icons"

      "ms-vscode-remote.remote-ssh-edit"
      "ms-vscode-remote.remote-ssh"
      "ms-vscode.remote-explorer"

      "ms-python.python"
      "ms-python.pylint"
      "ms-toolsai.jupyter-keymap"
      "wholroyd.jinja"
      "jnoortheen.nix-ide"
      "yzhang.markdown-all-in-one"
      "tamasfe.even-better-toml"
      "ecmel.vscode-html-css"

      "github.copilot"
    ] ++ pkgs.nix4vscode.forVscodeExt {
      "ewen-lbh.hyprland" = { pkgs, ... }: {
        runtimeInputs = with pkgs; [ hyprls patchelf ];
      };
    } [
      "ewen-lbh.hyprland"
    ] ++ pkgs.nix4vscode.forVscodeExt {
      "continue.continue" = { pkgs, ... }: {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ stdenv.cc.cc.lib patchelf ];
          LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib";
        };
      };
    } [
      "continue.continue"
    ];
    userSettings = {
      "workbench.colorTheme" = "Material Code";
      "workbench.productIconTheme" = "fluent-icons";
      "workbench.iconTheme" = "bearded-icons";
      "material-code.syntaxTheme" = "Dark Modern";
      "material-code.primaryColor" = "#${theme.colors.dark.primary}";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
      "nix.serverSettings" = {
        "nixd" = {
          "formatting" = {
            "command" = ["${pkgs.nixfmt}/bin/nixfmt"];
          };
        };
      };
    };
  };

  # Required lsp by hyprland extension (lsp path is not configurable)
  # home.packages = with pkgs; [
  #   pkgs.hyprls
  # ];
}