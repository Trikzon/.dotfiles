# Language toolchains available everywhere, outside project dev shells.
{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nodejs
    gcc
    gnumake
    go
    rustc
    cargo
    rustfmt
    clippy
  ];
}
