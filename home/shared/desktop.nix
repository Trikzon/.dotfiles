# Desktop apps and settings for every user with a niri session.
{ lib, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    autoThemeFiles = {
      light = "tokyo_night_day";
      dark = "tokyo_night_night";
      noPreference = "tokyo_night_night";
    };
  };

  # Not ~/Music: that is a symlink to this path, and scanners may skip a symlinked root.
  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/storage/Music";
  };
  programs.rmpc.enable = true;

  home.packages = with pkgs; [
    # Base theme for Noctalia's GTK templates: Noctalia recolours it and
    # switches between its light and dark variants with the system theme.
    adw-gtk3
    dashboard
    # Noctalia runs this to set external monitors' brightness over DDC/CI.
    ddcutil
    gnome-text-editor
    libreoffice
    mpv
    # Plain `nemo` ignores extensions. This wrapper loads Linux Mint's default
    # set, including nemo-fileroller for the Compress/Extract menu entries.
    nemo-with-extensions
    # Bound to Mod+Shift+S in niri: the first press records an area, the second stops.
    (writeShellApplication {
      name = "record-area";
      runtimeInputs = [
        procps
        slurp
        wl-screenrec
      ];
      text = ''
        # SIGINT lets wl-screenrec finish writing the MP4.
        pkill -INT -x wl-screenrec && exit
        # Without the trailing newline, read fails and errexit stops the script.
        read -r x y w h < <(slurp -d -f $'%x %y %w %h\n')
        sw=()
        # The GPU encoder crashes on frames under ~120px; x264 handles them but needs even sizes.
        if ((w < 128 || h < 128)); then
          sw=(--no-hw)
          w=$((w / 2 * 2))
          h=$((h / 2 * 2))
        fi
        mkdir -p ~/Videos
        exec wl-screenrec --low-power=off "''${sw[@]}" -g "$x,$y ''${w}x$h" \
          -f ~/Videos/clip-"$(date +%F_%H-%M-%S)".mp4
      '';
    })
    # Discord refuses to start when outdated, so take it from unstable.
    unstable.discord
    # 26.05 only has 5.0.1, so take it from unstable.
    unstable.noctalia
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
      # kitty-open.desktop claims all of text/*, so it wins these otherwise.
      // lib.genAttrs [
        "text/plain"
        "text/markdown"
        "text/x-python"
        "application/json"
        "application/x-shellscript"
      ] (_: "org.gnome.TextEditor.desktop")
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
}
