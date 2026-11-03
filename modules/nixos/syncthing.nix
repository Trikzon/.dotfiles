# Firewall ports for Syncthing, which runs as a Home Manager user service.
{ ... }: {
  # Home Manager can't open ports, and services.syncthing.openDefaultPorts
  # would start a second, system-wide instance.
  networking.firewall = {
    # Transfers (QUIC uses UDP 22000) and local discovery.
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [
      22000
      21027
    ];
  };
}
