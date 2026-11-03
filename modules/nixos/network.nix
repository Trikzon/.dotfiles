# Networking, firewall, and remote access.
{ ... }: {
  networking.networkmanager.enable = true;

  # On by default; kept explicit. Services can open their own ports when needed.
  networking.firewall.enable = true;
}
