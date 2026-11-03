# Boot loader, kernel, and boot splash.
{ pkgs, ... }: {
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        consoleMode = "max";
        # /boot is only 500 MB, so cap the number of generations kept.
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    plymouth.enable = true;

    # Silent boot that hides kernel/udev/systemd output (Press Esc to show).
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
