{ pkgs, lib, ... }:
let
  coresCount = lib.strings.toInt (pkgs.runCommand "cores-count" ''
    ${pkgs.coreutils}/bin/nproc > $out
  '');
  almostAllCores = coresCount - 1;
in
{
  nix.settings.max-jobs = almostAllCores; 
}
