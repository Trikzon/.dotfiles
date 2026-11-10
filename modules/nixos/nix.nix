# Nix itself: flakes, nixpkgs settings, and store maintenance.
{ inputs, lib, ... }: {
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs = {
    # Unfree packages allowed by name, instead of allowing all of them.
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
        "discord"
        "discord-unwrapped"
        "steam"
        "steam-unwrapped"
        "steam-run"
        "unityhub"
        # Unity Hub bundles these fonts for the editor tools.
        "corefonts"
      ];

    overlays = [
      # pkgs.dashboard is the private dashboard app, built from its release branch.
      (final: prev: {
        dashboard = inputs.dashboard.packages.${final.stdenv.hostPlatform.system}.default;
      })

      # pkgs.unstable.<name> gives packages from nixos-unstable; everything
      # else stays on 26.05. Shares this nixpkgs config (unfree list included).
      (final: prev: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          config = prev.config;
        };
      })
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise.automatic = true;
}
