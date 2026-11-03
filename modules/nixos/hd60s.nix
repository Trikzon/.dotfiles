# Elgato Game Capture HD60 S: the driver comes from the hd60s flake input.
{ inputs, ... }: {
  imports = [ inputs.hd60s.nixosModules.default ];

  # The AMD xHCI controller can't deliver SuperSpeed isochronous data, so
  # video never arrives unless the driver uses bulk transfers.
  boot.extraModprobeConfig = "options hd60s force_bulk=1";
}
