# RetroArch with the libretro cores for each emulated system.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  # RetroArch and its cores all come from unstable: 26.05 lacks FreeChaF and
  # PokeMini, and cores must link against the same glibc as RetroArch.
  inherit (pkgs.unstable.libretro) mkLibretroCore;

  emulation = "${config.home.homeDirectory}/Documents/Emulation/Configs/RetroArch";

  # Ardens, QUASI88 and WASM-4 aren't in nixpkgs.
  ardens = mkLibretroCore {
    core = "ardens";
    version = "0-unstable-2026-10-19";
    src = pkgs.fetchFromGitHub {
      owner = "tiberiusbrown";
      repo = "Ardens";
      rev = "e811cc6be72c8a802bd3265a84daf4165c177b93";
      hash = "sha256-Ii4Wc708vtV+V9OHN0Kki2yEGkKYW3Quz2JXK9g9/60=";
      fetchSubmodules = true;
    };
    extraNativeBuildInputs = [ pkgs.cmake ];
    makefile = "Makefile";
    cmakeFlags = [ (lib.cmakeBool "ARDENS_LIBRETRO" true) ];
    meta.license = lib.licenses.mit;
  };

  quasi88 = mkLibretroCore {
    core = "quasi88";
    version = "0-unstable-2026-10-06";
    src = pkgs.fetchFromGitHub {
      owner = "libretro";
      repo = "quasi88-libretro";
      rev = "7884be5277776a5d8c4fdc4e574e9b5b589945c9";
      hash = "sha256-VIoe1XNBatAlm1OOhReUiWt9Eww5eCAUc/G5Vl4JUus=";
    };
    makefile = "Makefile";
    # Its debug messages pass non-literal format strings to printf.
    hardeningDisable = [ "format" ];
    meta.license = lib.licenses.bsd3;
  };

  wasm4 = mkLibretroCore {
    core = "wasm4";
    version = "0-unstable-2026-09-11";
    src = pkgs.fetchFromGitHub {
      owner = "aduros";
      repo = "wasm4";
      rev = "9d6c962785cfe3719d0245fd279ecbe98a4dbb63";
      hash = "sha256-01ELJp3bYittaDE1mvNrcp8xWKEFwuckmWZzfWypYEY=";
      fetchSubmodules = true;
    };
    extraNativeBuildInputs = [ pkgs.cmake ];
    makefile = "Makefile";
    cmakeFlags = [ (lib.cmakeBool "LIBRETRO" true) ];
    preConfigure = "cd runtimes/native";
    meta.license = lib.licenses.isc;
  };
in
{
  home.packages = [
    (pkgs.unstable.retroarch-bare.wrapper {
      cores = with pkgs.unstable.libretro; [
        ardens
        beetle-psx-hw
        beetle-saturn
        bluemsx
        dolphin
        fbneo
        fceumm
        flycast
        freechaf
        gambatte
        genesis-plus-gx
        mgba
        mupen64plus
        pokemini
        prosystem
        quasi88
        snes9x
        stella
        wasm4
      ];
      # Passed with --appendconfig, so they override retroarch.cfg on every launch.
      settings = {
        rgui_browser_directory = "${config.home.homeDirectory}/Documents/Emulation";
        system_directory = "${emulation}/BIOS";
        video_filter_dir = "${emulation}/Filters/video";
        savefile_directory = "${emulation}/Saves";
        video_shader_dir = "${emulation}/Shaders";
        # Core options, per-game overrides and remaps, kept in the Syncthing folder.
        rgui_config_directory = "${emulation}/Config";
        input_remapping_directory = "${emulation}/Config/remaps";
      };
    })
  ];
}
