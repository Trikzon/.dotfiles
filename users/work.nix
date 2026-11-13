{ pkgs, ... }: {
  users.users.work = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "docker" ];
  };

  home-manager.users.work = ../home/work;
}
