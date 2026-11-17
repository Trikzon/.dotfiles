# TODO

- [ ] Add Windows to the systemd-boot menu (its ESP is on the Windows disk, UUID `8451-BA5A`)
  - Afterwards, optionally hide the menu: `boot.loader.timeout = 0;`
- [ ] Encrypt the storage drive with LUKS
  - Back up, reformat, restore, then redo the storage group ACLs (see `hosts/explorer/default.nix`)
  - Unlock at boot with a keyfile on the encrypted root
- [ ] Upgrade to NixOS 26.11 once released (26.05 support ends around the end of December)
  - Read the release notes' incompatibilities, bump `nixos-26.05` and `release-26.05` in `flake.nix`
  - If 26.11 has FreeChaF and PokeMini, take RetroArch from stable instead of unstable (`home/dion/retroarch.nix`)
- [ ] Import the signing key into work's GPG keyring; until then, commits made as work fail to sign
  - As dion (work can't read /home/dion): `gpg --export-secret-keys F2EDF21F8BED59D5 | sudo -u work gpg --import`
- [ ] Watch for another MT7922 firmware hang now that ASPM is off (`hosts/explorer/default.nix`)
  - Power saving off alone didn't fix it; the hang recurred on 2026-11-16 at 20:46
  - If it recurs: try `sudo modprobe -r mt7921e && sudo modprobe mt7921e` before rebooting, then read NetworkManager's INFO logs
  - If ASPM fixes it, test turning `wifi.powersave` back on (`modules/nixos/network.nix`)
  - Once settled, remove `networking.networkmanager.logLevel = "INFO"`
