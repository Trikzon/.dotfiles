# Home Manager as a NixOS module, with settings shared by every user.
{ inputs, ... }: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Makes programs.nixvim available to every user's home config.
    sharedModules = [ inputs.nixvim.homeModules.nixvim ];
  };
}
