# Zsh with completion, suggestions, highlighting, and a git-aware prompt.
{ lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history = {
      ignoreAllDups = true;
      # Without this, each kitty window overwrites the history on exit.
      append = true;
    };

    # fzf-tab must load after compinit (order 570) and before autosuggestions
    # (700) and syntax highlighting (1200), which wrap the widgets it binds.
    initContent = lib.mkOrder 600 ''
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      # Modules named here are left out of `$all`, which puts the project name
      # right after the branch instead of at the end of the prompt.
      format = "$username$hostname$directory$git_branch\${custom.project}$all";
      custom.project = {
        # Bare-clone worktrees are named after the branch, so the project name
        # is the folder that holds `.bare`.
        when = ''[ "$(basename "$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)")" = .bare ]'';
        command = ''basename "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"'';
        format = "[\\($output\\)]($style) ";
        style = "bold blue";
      };
    };
  };
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
  # Adds the ls, ll, la, and lt aliases for zsh.
  programs.eza = {
    enable = true;
    git = true;
  };
  programs.bat.enable = true;
}
