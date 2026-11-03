{
  description = "Dion's NixOS config and dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Private, so fetched over SSH; `main` is its release branch. No `follows`:
    # it needs Electron 44 and pnpm 11 from unstable.
    dashboard.url = "git+ssh://git@github.com/Trikzon/dashboard?ref=main";

    # Fork of the HD60 S driver; it ships its own NixOS module.
    hd60s.url = "github:Trikzon/hd60s-linux-driver";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # No `follows`: Nixvim is tested against its own pinned nixpkgs and warns
    # when it is forced onto another one.
    nixvim.url = "github:nix-community/nixvim/nixos-26.05";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      nixosConfigurations.explorer = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/explorer
          home-manager.nixosModules.home-manager
        ];
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
