# Developer tools: per-project dev shells, GitHub CLI, Claude Code.
{ pkgs, ... }: {
  # nix-direnv caches dev shells so entering is fast and `nix-collect-garbage`
  # keeps them.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gh.enable = true;

  home.packages = [ pkgs.unstable.claude-code ];
}
