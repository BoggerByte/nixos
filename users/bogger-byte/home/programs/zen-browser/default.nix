{ pkgs }:
{
  home.packages = [
    pkgs.zen-browser
  ];
  
  home.activation.linkZenTheme = 
  let
    nebula = pkgs.runCommand ''
      archive_name = "chrome.zip"
      ${pkgs.curl}/bin/curl -L -o $archive_name https://github.com/<OWNER>/<REPO>/releases/download/<TAG>/chrome.zip
      ${pkgs.unzip}/bin/unzip $archive_name -d $out
    '';
  in  
  pkgs.lib.hm.dag.entryAfter ["writeBoundary"] ''
    zenProfilesDir = $HOME/.zen
    for profile in $zenProfilesDir/*.default; do
      mkdir -p "$profile/chrome"
      ln -sf "${nebula}" "$profile/chrome"
    done
  '';
}