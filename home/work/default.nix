{ ... }: {
  imports = [
    ../shared/desktop.nix
    ../shared/dev.nix
    ../shared/git.nix
    ../shared/librewolf.nix
    ../shared/shell.nix
  ];

  # A store copy of dion's niri config: /home/dion is private, so a symlink
  # into its checkout wouldn't be readable. Edits apply after a rebuild.
  xdg.configFile."niri/config.kdl".source = ../dion/niri/config.kdl;

  # Home Manager's equivalent of system.stateVersion. Never change it.
  home.stateVersion = "26.05";
}
