{ inputs, config, pkgs, ... }: 

{
  programs.hyprlock.enable = true;

  home.sessionVariables.XDG_CURRENT_DESKTOP = "Hyprland";
  home.sessionVariables.XDG_SESSION_TYPE = "wayland";
  home.sessionVariables.XDG_SESSION_DESKTOP = "Hyprland";
  home.sessionVariables.GDK_BACKEND = "wayland,x11,*";
  home.sessionVariables.QT_QPA_PLATFORM = "wayland;xcb";
  home.sessionVariables.SDL_VIDEODRIVER = "wayland";
  home.sessionVariables.CLUTTER_BACKEND = "wayland";
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  wayland.windowManager.hyprland.systemd.enable = false; # using uwsm
  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.package = null;
  wayland.windowManager.hyprland.portalPackage = null;
  wayland.windowManager.hyprland.settings = {
    source = [
      "./hyprland/autoexec.conf"
      "./system.conf"
      "./hyprland/colors.conf"
      "./hyprland/default.conf"
    ];
  };

  home.file."${config.xdg.configHome}/hypr/hyprland/autoexec.conf".text = ''
    exec-once = ${pkgs.hyprland-per-window-layout}/bin/hyprland-per-window-layout
    exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --type text  --watch cliphist store &
    exec-once = ${pkgs.wl-clipboard}/bin/wl-paste --type image --watch cliphist store &
    exec-once = ${pkgs.swww}/bin/swww-daemon &
    exec-once = ${pkgs.swww}/bin/swww img ${inputs.self + "/theme/wallpaper.png"} &
    exec-once = ${pkgs.waybar}/bin/waybar &
  '';
  home.file."${config.xdg.configHome}/hypr/hyprland/monitors.conf".text = ''
    # https://wiki.hyprland.org/Configuring/Monitors/
    monitor = ,preferred,auto,auto
  '';
  home.file."${config.xdg.configHome}/hypr/hyprland/colors.conf".text = ''
    source = ${config.theme.md3.live.files}/theme/colors.hyprland.conf
  '';
  home.file."${config.xdg.configHome}/hypr/hyprland/default.conf" = {
    source = config.lib.meta.mkMutableSymlink ./default.conf;
  };

  home.file."${config.xdg.configHome}/hypr/system.conf".text = let
    change-volume = pkgs.writeShellScriptBin "change-volume" ''
      if [ -z "$1" ]; then
        echo "Usage: $0 [--toggle-mute | <volume adjustment>]"
        exit 1
      fi

      if [ "$1" = "--toggle-mute" ]; then
        ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      else
        ${pkgs.wireplumber}/bin/wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ "$1"
      fi

      VOLUME=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | \
               ${pkgs.gawk}/bin/awk '{print $2 * 100}')
      MUTED=$(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@ | \
              ${pkgs.gnugrep}/bin/grep -q '\[MUTED\]' && echo "yes" || echo "no")
      
      NOTIFY_FILE="/tmp/volume_notify_id"
      NOTIFY_ID=$([ -s "$NOTIFY_FILE" ] && cat "$NOTIFY_FILE" || echo "0")
      if [ "$MUTED" == "yes" ]; then
          ICON=""
          NEW_ID=$(${pkgs.libnotify}/bin/notify-send -u low -h int:value:0 -t 1500 -p -r "$NOTIFY_ID" -a "volume" "$ICON  Muted")
      else
          if [ "$VOLUME" -eq 0 ]; then
              ICON=""
          elif [ "$VOLUME" -lt 30 ]; then
              ICON=""
          elif [ "$VOLUME" -lt 70 ]; then
              ICON=""
          else
              ICON=""
          fi
          NEW_ID=$(${pkgs.libnotify}/bin/notify-send -u low -h int:value:"''${VOLUME%.*}" -t 1500 -p -r "$NOTIFY_ID" -a "volume" "$ICON  ''${VOLUME%.*}%")
      fi
      echo "$NEW_ID" > "$NOTIFY_FILE"
    '';

    change-brightness = pkgs.writeShellScriptBin "change-brightness" ''
      if [[ ! "$1" =~ ^[0-9]{1,3}%[+-]$ ]]; then
        echo "Usage: $0 <percentage>[+/-]"
        echo "Example: $0 5%+ or $0 10%-"
        exit 1
      fi

      VALUE=$(echo "$1" | grep -oE '^[0-9]{1,3}')
      OPERATION=$(echo "$1" | grep -oE '[+-]$')

      if [[ "$OPERATION" == "+" ]]; then
        ${pkgs.brillo}/bin/brillo -u 150000 -A "$VALUE"
      elif [[ "$OPERATION" == "-" ]]; then
        ${pkgs.brillo}/bin/brillo -u 150000 -U "$VALUE"
      fi

      BRIGHTNESS=$(${pkgs.brillo}/bin/brillo -G | ${pkgs.gawk}/bin/awk '{printf "%d", $1}')
      if [ "$BRIGHTNESS" -lt 30 ]; then
          ICON="󰃜"
      elif [ "$BRIGHTNESS" -lt 70 ]; then
          ICON="󰃛"
      else
          ICON="󰃚"
      fi

      NOTIFY_FILE="/tmp/brightness_notify_id"
      NOTIFY_ID=$([ -s "$NOTIFY_FILE" ] && cat "$NOTIFY_FILE" || echo "0")
      NEW_ID=$(${pkgs.libnotify}/bin/notify-send -u low -h int:value:"$BRIGHTNESS" -t 1500 -p -r "$NOTIFY_ID" -a "brightness" "$ICON  $BRIGHTNESS%")
      echo "$NEW_ID" > "$NOTIFY_FILE"
    '';

    menu = let
      rofiPkg = pkgs.rofi-wayland.override { 
        plugins = [ pkgs.rofi-emoji-wayland ];
      }; 
    in pkgs.writeShellScriptBin "menu" ''
      case $1 in
        "launcher")
          ${rofiPkg}/bin/rofi -show drun
          ;;
        "runner")
          ${rofiPkg}/bin/rofi -show run -no-show-icons
          ;;
        "windows")
          ${rofiPkg}/bin/rofi -show window
          ;;
        "emoji")
          ${rofiPkg}/bin/rofi -modi emoji -show emoji -no-show-icons
          ;;
        "ssh")
          ${rofiPkg}/bin/rofi -show ssh -no-show-icons
          ;;
        "clipboard")
          ${pkgs.cliphist}/bin/cliphist list | \
          ${rofiPkg}/bin/rofi -dmenu -no-show-icons -p " " | \
          ${pkgs.cliphist}/bin/cliphist decode | \
          ${pkgs.wl-clipboard}/bin/wl-copy
          ;;
        *)
          echo "Usage: $0 <applet-name>"
          exit 1
          ;;
      esac
    '';

    screenshot = pkgs.writeShellScriptBin "screenshot" ''
      ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | \
      ${pkgs.imagemagick}/bin/convert - -shave 1x1 PNG:- | ${pkgs.swappy}/bin/swappy -f -
    '';

    colorpicker = pkgs.writeShellScriptBin "colorpicker" ''
      ${pkgs.hyprpicker}/bin/hyprpicker | ${pkgs.wl-clipboard}/bin/wl-copy
    '';
  in ''
    $volume = ${change-volume}/bin/change-volume
    $brightness = ${change-brightness}/bin/change-brightness
    $player = ${pkgs.playerctl}/bin/playerctl
    $screenshot = ${screenshot}/bin/screenshot
    $colorpicker = ${colorpicker}/bin/colorpicker
    $menu = ${menu}/bin/menu
    $lock = ${pkgs.hyprlock}/bin/hyprlock

    $terminal = alacritty
    $file_explorer = thunar
    $browser = brave
  '';

  home.file."${config.xdg.configHome}/hypr/xdph.conf".text = ''
    screencopy {
      max_fps = 60
      allow_token_by_default = true
    }
  '';

  home.file."${config.xdg.configHome}/xdg-desktop-portal/hyprland-portals.conf".text = ''
    [preferred]
    default = hyprland;gtk
    org.freedesktop.impl.portal.FileChooser = kde
  '';
}
