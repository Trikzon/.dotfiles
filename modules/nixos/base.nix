# Settings every machine gets: locale and core command-line tools.
{ pkgs, ... }: {
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Tools worth having even as root or on a broken system.
  environment.systemPackages = with pkgs; [
    curl
    fd
    file
    git
    htop
    jq
    lsof
    pciutils
    ripgrep
    unzip
    usbutils
    vim
    wget
    zip
  ];

  programs.gnupg.agent.enable = true;

  # Also links /share/zsh so completions for system packages are found.
  programs.zsh.enable = true;
}
