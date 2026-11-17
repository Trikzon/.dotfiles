# Networking, firewall, and remote access.
{ ... }: {
  networking.networkmanager.enable = true;
  # Tried for MT7922 firmware hangs; didn't fix them alone. Keep until ASPM is ruled in or out.
  networking.networkmanager.wifi.powersave = false;
  # Default WARN hides DHCP and connectivity changes; keep until the Wi-Fi stall is diagnosed.
  networking.networkmanager.logLevel = "INFO";

  # On by default; kept explicit. Services can open their own ports when needed.
  networking.firewall.enable = true;
  # Strict rpfilter drops replies from the VPN server once all traffic routes through the tunnel.
  networking.firewall.checkReversePath = "loose";
}
