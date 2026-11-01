{ pkgs }:
let
  inherit (pkgs) lib;
in
(import ./defaults.nix { inherit pkgs; })
// {
  actions = {
    audioSettings = lib.getExe pkgs.pavucontrol;
    bluetoothSettings = lib.getExe' pkgs.blueman "blueman-manager";
    lockScreen = "${lib.getExe (pkgs.callPackage ./cli.nix { })} lock";
    systemMonitor = "${lib.getExe pkgs.kitty} ${lib.getExe pkgs.btop}";
  };
}
