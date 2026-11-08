# Steam, with the 32-bit graphics stack and udev rules it needs.
{ pkgs, ... }: {
  programs.steam = {
    enable = true;
    # Fixes the laggy in-game overlay with GPU web views on:
    # https://github.com/ValveSoftware/steam-for-linux/issues/13513
    package = pkgs.steam.override { extraArgs = "-cef-force-glx"; };
    remotePlay.openFirewall = true;
    # Fixes some games (video codecs, launch problems) that stock Proton doesn't.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };
}
