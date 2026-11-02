# Neovim, configured through NixVim.
{ pkgs, ... }: {
  programs.nixvim = {
    enable = true;
    # Sets EDITOR and VISUAL to nvim in the session environment.
    defaultEditor = true;

    # NixVim enables these by default, but only old remote plugins need them.
    withRuby = false;
    withPython3 = false;

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      ignorecase = true;
      smartcase = true;
      undofile = true;
      signcolumn = "yes";
      splitright = true;
      splitbelow = true;
      scrolloff = 8;
      tabstop = 4;
      # 0 makes indent commands like >> follow tabstop.
      shiftwidth = 0;
    };

    # Shares the clipboard with Wayland through wl-clipboard.
    clipboard.register = "unnamedplus";

    # Installs every grammar from Nix (about 250 MiB), so no language needs
    # adding by hand and nothing compiles at runtime.
    plugins.treesitter = {
      enable = true;
      highlight.enable = true;
    };

    plugins.telescope = {
      enable = true;
      keymaps = {
        "<leader>ff" = "find_files";
        "<leader>fg" = "live_grep";
        "<leader>fb" = "buffers";
        "<leader>fh" = "help_tags";
      };
    };

    # Default configs (command, file types, root markers) for language servers.
    plugins.lspconfig.enable = true;

    lsp.servers = {
      # Adds about 650 MiB to the closure, mostly LLVM.
      nixd.enable = true;
      bashls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
      tombi.enable = true;
      # Covers Dockerfile, Compose, and Bake files in one server.
      docker_language_server.enable = true;

      # Tied to a project's toolchain, so a version from the project's dev shell
      # takes precedence over these (packageFallback puts them last on PATH).
      basedpyright = {
        enable = true;
        packageFallback = true;
      };
      ruff = {
        enable = true;
        packageFallback = true;
      };
      vtsls = {
        enable = true;
        packageFallback = true;
      };
      ols = {
        enable = true;
        packageFallback = true;
      };
      jdtls = {
        enable = true;
        packageFallback = true;
      };
    };

    # Neovim 0.11 stopped showing diagnostic messages at the end of the line by
    # default, leaving only signs and underlines.
    diagnostic.settings.virtual_text = true;

    # Completion menu: <C-n>/<C-p> select, <C-y> accepts (blink's default keymap).
    plugins.blink-cmp.enable = true;

    plugins.conform-nvim = {
      enable = true;
      settings = {
        # nixfmt matches `nix fmt`. ruff is already on PATH as the LSP's
        # fallback, so a project's own ruff takes precedence.
        formatters_by_ft = {
          nix = [ "nixfmt" ];
          sh = [ "shfmt" ];
          python = [
            "ruff_format"
            "ruff_organize_imports"
          ];
        };
        # "never" restricts saving to the formatters above, so language servers
        # don't reformat other projects' files in a style they don't use.
        format_on_save = {
          timeout_ms = 500;
          lsp_format = "never";
        };
      };
    };

    # Formats on request through the language server where no formatter is set.
    keymaps = [
      {
        mode = "n";
        key = "<leader>cf";
        action.__raw = "function() require('conform').format({ lsp_format = 'fallback' }) end";
        options.desc = "Format buffer";
      }
    ];

    # Maps file names to schemas for jsonls and yamlls (package.json, GitHub
    # workflows, ...). Only the catalog is bundled: the servers still download
    # the schemas themselves, so validation needs network access.
    plugins.schemastore.enable = true;

    # Starts rust-analyzer itself and adds :RustLsp commands, so rust_analyzer
    # must not also be enabled in lsp.servers.
    plugins.rustaceanvim.enable = true;
    dependencies.rust-analyzer.packageFallback = true;

    # Neovim detects Compose files as plain yaml, but docker_language_server
    # only attaches to yaml.docker-compose.
    filetype.filename = {
      "compose.yaml" = "yaml.docker-compose";
      "compose.yml" = "yaml.docker-compose";
      "docker-compose.yaml" = "yaml.docker-compose";
      "docker-compose.yml" = "yaml.docker-compose";
    };

    # Neovim sets 'background' from the terminal, so this follows kitty's
    # light/dark theme. `style` must match kitty's dark theme (default.nix).
    colorschemes.tokyonight = {
      enable = true;
      settings = {
        style = "night";
        light_style = "day";
      };
    };

    plugins.gitsigns.enable = true;
    # git is already installed by Home Manager (git.nix); without this, nvim
    # would put a second copy first on its PATH.
    dependencies.git.enable = false;

    # Shows the keys that can follow a prefix such as <space> or g.
    plugins.which-key.enable = true;

    plugins.lualine.enable = true;

    # File icons for Telescope; enabling it automatically is deprecated.
    plugins.web-devicons.enable = true;

    # Tools nvim shells out to; extraPackages puts them on nvim's PATH only, so
    # they aren't installed system-wide. ripgrep and fd are for Telescope,
    # nixfmt and shfmt for conform.
    extraPackages = with pkgs; [
      ripgrep
      fd
      nixfmt
      shfmt
    ];
  };
}
