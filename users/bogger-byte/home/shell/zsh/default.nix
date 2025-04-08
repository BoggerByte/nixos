{ config, pkgs, lib, ... }:
let
  theme = config.theme.md3.contents;
in
{
  programs.zsh.enable = true;  
  programs.zsh = {
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=blue";
    };

    initExtraFirst = ''
      bindkey '^[' history-search-backword
      bindkey '^]' history-search-forward

      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      
      zstyle ':completion:*' menu no
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'colorsls $realpath'
    '';

    initExtra = ''
      ${pkgs.pfetch-rs}/bin/pfetch
    '';

    shellAliases = {
      ls = "${pkgs.colorls}/bin/colorls";
      grep = "${pkgs.ugrep}/bin/ugrep";
    };

    history = {
      findNoDups = true;
      saveNoDups = true;
    };
  };
  programs.zsh.plugins = [
    {
      name = "fzf-tab";
      src = pkgs.zsh-fzf-tab;
      file = "share/fzf-tab/fzf-tab.plugin.zsh";
    }
    {
      name = "zsh-colored-man-pages";
      file = "colored-man-pages.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "ael-code";
        repo = "zsh-colored-man-pages";
        rev = "57bdda68e52a09075352b18fa3ca21abd31df4cb";
        hash = "sha256-087bNmB5gDUKoSriHIjXOVZiUG5+Dy9qv3D69E8GBhs=";
      };
    }
    {
      name = "zsh-thefuck";
      src = pkgs.thefuck;
      file = "zsh-thefuck.plugin.zsh";
    }
  ];

  programs.starship.enable = true;
  programs.starship = {
    enableZshIntegration = true;

    enableTransience = true;

    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  programs.fzf.enable = true;
  programs.fzf = {
    enableZshIntegration = true;

    colors = with theme.colors.dark; {
      fg = "-1";	                   # Text
      bg = "-1";                     # Background
      preview-fg = "";	             # Preview window text
      preview-bg = "";               # Preview window background
      hl = "#${inverse_on_surface}"; # Highlighted substrings
      "fg+" = "#${primary}";         # Text (current line)
      "bg+" = "";                    # Background (current line)
      gutter = "-1";                 # Gutter on the left (defaults to bg+)
      "hl+" = "#${tertiary}";        # Highlighted substrings (current line)
      info = "";            
      border = "#${outline}";        # Border of the preview window and horizontal separators
      prompt = "";          
      pointer =	"#${tertiary}";      # Pointer to the current line
      marker = "";                   # Multi-select marker
      spinner = "";                  # Streaming input indicator
      header = "";
    };
  };

  programs.zoxide.enable = true;
  programs.zoxide = {
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };
}