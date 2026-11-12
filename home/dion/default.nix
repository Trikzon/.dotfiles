{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./git.nix
    ./librewolf.nix
    ./neovim.nix
    ./shell.nix
  ];

  programs.kitty = {
    enable = true;
    autoThemeFiles = {
      light = "tokyo_night_day";
      dark = "tokyo_night_night";
      noPreference = "tokyo_night_night";
    };
  };

  # nix-direnv caches dev shells so entering is fast and `nix-collect-garbage`
  # keeps them.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # Pre-approves every .envrc under the project, so new worktrees don't each
    # need `direnv allow`.
    config.whitelist.prefix = [ "/home/dion/Projects/dashboard" ];
  };

  programs.fastfetch.enable = true;

  programs.gh.enable = true;

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
    # Base theme for Noctalia's GTK templates: Noctalia recolours it and
    # switches between its light and dark variants with the system theme.
    adw-gtk3
    chromium
    dashboard
    dnsutils
    ffmpeg
    libreoffice
    mpv
    # Plain `nemo` ignores extensions. This wrapper loads Linux Mint's default
    # set, including nemo-fileroller for the Compress/Extract menu entries.
    nemo-with-extensions
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
    unstable.claude-code
    # Discord refuses to start when outdated, so take it from unstable.
    unstable.discord
    # 26.05 only has 5.0.1, so take it from unstable.
    unstable.noctalia
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

  # Nix can't apply Discord's self-updates, so stop it from asking for them.
  # Discord replaces this link with its own copy, so force relinks it on switch.
  xdg.configFile."discord/settings.json" = {
    text = builtins.toJSON {
      SKIP_HOST_UPDATE = true;
    };
    force = true;
  };

  # Without these, xdg-open picks whichever installed app lists the type first.
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      lib.genAttrs [
        "video/mp4"
        "video/webm"
        "video/x-matroska"
        "audio/flac"
        "audio/mpeg"
        "audio/ogg"
      ] (_: "mpv.desktop")
      // lib.genAttrs [
        "text/html"
        "application/xhtml+xml"
        "application/pdf"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "text/xml"
        "application/xml"
        "application/rss+xml"
      ] (_: "librewolf.desktop")
      // lib.genAttrs [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
      ] (_: "dev.noctalia.Noctalia.Annotator.desktop")
      // {
        # Claude Code registered this itself; Home Manager now owns the file.
        "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
        "inode/directory" = "nemo.desktop";
      };
  };

  # Nemo's "Open in Terminal" reads Cinnamon's setting, which defaults to
  # gnome-terminal.
  dconf.settings."org/cinnamon/desktop/applications/terminal".exec = "kitty";

  # No icon theme is installed by default, so GTK apps like Nemo fall back to
  # GTK's few built-in generic icons.
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  # No cursor theme is installed by default, so niri falls back to a large
  # static arrow without hover states.
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

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
