# Graphical session: niri on Wayland, audio, printing, and desktop apps.
{ pkgs, ... }: {
  # Also pulls in gnome-keyring, gcr-ssh-agent (the SSH agent), and
  # pinentry-gnome3 via services.graphical-desktop.
  programs.niri.enable = true;
  # Nautilus's save dialog fails on Steam's browser downloads; use GTK's.
  programs.niri.useNautilus = false;
  hardware.graphics.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.printing.enable = true;

  # Noctalia's bluetooth and power-profile features talk to these. upower is
  # left out: it only serves battery status, and this machine has no battery.
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;

  # Loads i2c-dev and lets the logged-in user open /dev/i2c-*, which ddcutil
  # needs to talk DDC/CI to external monitors.
  hardware.i2c.enable = true;

  # Nemo needs this for the trash and for mounting USB drives and network shares.
  services.gvfs.enable = true;

  environment.systemPackages = with pkgs; [
    # niri spawns this on demand to run X11 apps.
    xwayland-satellite
  ];
}
