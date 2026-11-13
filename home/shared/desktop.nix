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

  home.packages = with pkgs; [
    # Base theme for Noctalia's GTK templates: Noctalia recolours it and
    # switches between its light and dark variants with the system theme.
    adw-gtk3
    dashboard
    libreoffice
    mpv
    # Plain `nemo` ignores extensions. This wrapper loads Linux Mint's default
    # set, including nemo-fileroller for the Compress/Extract menu entries.
    nemo-with-extensions
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
