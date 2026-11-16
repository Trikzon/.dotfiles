# Networking, firewall, and remote access.
{ ... }: {
  networking.networkmanager.enable = true;
  # MT7922 can stall traffic while staying associated when power saving is on.
  networking.networkmanager.wifi.powersave = false;
  # Default WARN hides DHCP and connectivity changes; keep until the Wi-Fi stall is diagnosed.
  networking.networkmanager.logLevel = "INFO";

  # On by default; kept explicit. Services can open their own ports when needed.
  networking.firewall.enable = true;
}
