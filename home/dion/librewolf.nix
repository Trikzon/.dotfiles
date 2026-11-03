# LibreWolf browser.
{ lib, ... }:
let
  # Everything the address bar can suggest. Switched off one by one because
  # there is no single pref for it.
  urlbarSuggestions = [
    "addons"
    "amp"
    "bookmark"
    "calculator"
    "clipboard"
    "engines"
    "history"
    "importantDates"
    "mdn"
    "openpage"
    "quickactions"
    "realtimeOptIn"
    "recentsearches"
    "remotetab"
    "searches"
    "sports"
    "topsites"
    "trending"
    "weather"
    "wikipedia"
    "yelp"
    "yelpRealtime"
  ];

  # Status "default" sets the default only, so the UI can still change it.
  defaultPref = Value: {
    inherit Value;
    Status = "default";
  };
in
{
  programs.librewolf = {
    enable = true;

    policies = {
      # Not `settings`: Home Manager writes those to ~/.librewolf, but this
      # LibreWolf reads ~/.config/librewolf. Policies are baked into the package.
      Preferences = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = defaultPref true;

        # 1 is compact, 0 is normal.
        "browser.uidensity" = defaultPref 1;

        # 3 restores the previous windows and tabs; Firefox's default is 1 (home page).
        "browser.startup.page" = defaultPref 3;

        # LibreWolf turns these off. The CDMs are separate downloads, see
        # media.gmp-manager.updateEnabled in LibreWolf's mozilla.cfg.
        "media.gmp-widevinecdm.enabled" = defaultPref true;
        "media.gmp-gmpopenh264.enabled" = defaultPref true;
      }
      // lib.genAttrs (map (name: "browser.urlbar.suggest.${name}") urlbarSuggestions) (
        _: defaultPref false
      );

      # Plain DoH with fallback to the system resolver; the provider stays
      # LibreWolf's default (Quad9).
      DNSOverHTTPS = {
        Enabled = true;
        Locked = false;
      };

      # LibreWolf also asks per site before playing DRM content.
      EncryptedMediaExtensions = {
        Enabled = true;
        Locked = false;
      };

      # nixpkgs has no Bitwarden browser extension package, so install it from
      # addons.mozilla.org via policy. normal_installed lets the user disable it.
      ExtensionSettings."{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
        default_area = "navbar";
      };

      ExtensionSettings."addon@darkreader.org" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
        default_area = "navbar";
      };
    };
  };

  # resistFingerprinting makes every site see a light theme and ignores
  # per-target overrides. The Preferences policy can't set it, hence this file.
  xdg.configFile."librewolf/librewolf/librewolf.overrides.cfg".text = ''
    defaultPref("privacy.resistFingerprinting", false);
    defaultPref("privacy.fingerprintingProtection", true);
    defaultPref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
  '';

  # Home Manager hardcodes ~/.librewolf for this file, which LibreWolf doesn't
  # read here; it is empty, so don't create the directory.
  home.file.".librewolf/native-messaging-hosts".enable = false;
}
