{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../shared/desktop.nix
    ../shared/dev.nix
    ../shared/git.nix
    ../shared/librewolf.nix
    ../shared/shell.nix
    ./neovim.nix
  ];

  # Pre-approves every .envrc under the project, so new worktrees don't each
  # need `direnv allow`.
  programs.direnv.config.whitelist.prefix = [ "/home/dion/Projects/dashboard" ];

  programs.fastfetch.enable = true;

  services.syncthing = {
    enable = true;
    settings = {
      devices.Thor.id = "7255NBD-MNUGNGO-GERV4NE-NE26IRK-J26RUIS-HSU3J6X-YYIP545-3M4EAQO";
      # Real paths: ~/Documents is a symlink and Syncthing dislikes symlinked roots.
      folders = {
        "/mnt/storage/Documents/Emulation/Configs" = {
          id = "emulation-configs";
          devices = [ "Thor" ];
        };
        "/mnt/storage/Documents/Emulation/Games" = {
          id = "emulation-games";
          devices = [ "Thor" ];
        };
      };
    };
  };

  home.packages = with pkgs; [
    chromium
    dnsutils
    ffmpeg
    openssl
    pandoc
    poppler-utils
    # Java's AWT needs these, and the wrapper doesn't include them. Without
    # them, GTNH's FalsePatternLib crashes when it opens its download window.
    (prismlauncher.override {
      additionalLibs = [
        fontconfig
        freetype
        libxi
        libxrender
        libxtst
        zlib
        # SDL needs it for native Wayland (GTNH sets SDL_VIDEO_DRIVER=wayland).
        libxkbcommon
      ];
    })
    (python3.withPackages (ps: [
      ps.pypdf
      ps.openpyxl
    ]))
    qpdf
    satdump
    shellcheck
    sqlite
    _7zz
    # SatDump's Open/Save buttons run zenity from PATH; the package doesn't bring it.
    zenity
    tree
    unityhub
    uv
    # Clipboard CLI (wl-copy/wl-paste) that terminal tools look for on Wayland.
    wl-clipboard
    yq-go
    # Sets up the bare-clone-plus-worktrees layout described in AGENTS.md.
    (writeShellApplication {
      name = "clone-bare";
      runtimeInputs = [ git ];
      text = builtins.readFile ./scripts/clone-bare.sh;
    })
    # nixos-rebuild and sudo come from the system: sudo must be the setuid
    # wrapper, not a store copy.
    (writeShellApplication {
      name = "nixos-upgrade";
      runtimeInputs = [
        git
        nix
      ];
      text = builtins.readFile ./scripts/nixos-upgrade.sh;
    })
  ];

  # Symlinked to the working tree instead of copied into the Nix store, so
  # edits to config.kdl apply (niri live-reloads) without a rebuild.
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/home/dion/niri/config.kdl";

  home.file = {
    "Storage".source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage";
  }
  // lib.genAttrs [ "Applications" "Documents" "Music" "Pictures" "Videos" ] (name: {
    source = config.lib.file.mkOutOfStoreSymlink "/mnt/storage/${name}";
  });

  # Home Manager's equivalent of system.stateVersion. Never change it.
  home.stateVersion = "26.05";
}
