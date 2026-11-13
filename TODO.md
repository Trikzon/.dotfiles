# TODO

- [ ] Add Windows to the systemd-boot menu (its ESP is on the Windows disk, UUID `8451-BA5A`)
  - Afterwards, optionally hide the menu: `boot.loader.timeout = 0;`
- [ ] Encrypt the storage drive with LUKS
  - Back up, reformat, restore, then redo the storage group ACLs (see `hosts/explorer/default.nix`)
  - Unlock at boot with a keyfile on the encrypted root
- [ ] Upgrade to NixOS 26.11 once released (26.05 support ends around the end of December)
  - Read the release notes' incompatibilities, bump `nixos-26.05` and `release-26.05` in `flake.nix`
- [ ] Import the signing key into work's GPG keyring; until then, commits made as work fail to sign
  - As dion (work can't read /home/dion): `gpg --export-secret-keys F2EDF21F8BED59D5 | sudo -u work gpg --import`
