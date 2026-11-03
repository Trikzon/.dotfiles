# AGENTS.md

NixOS flake and Home Manager config for Dion's machines. The owner is learning
NixOS: the goal is a clean, understandable config, not just a working one.

## Layout

- `flake.nix`: inputs (`nixpkgs` nixos-26.05, `nixpkgs-unstable`, `home-manager`
  release-26.05) and one `nixosConfigurations.<host>` per machine.
- `hosts/<host>/`: what makes a machine unique (disks, LUKS, GPU, `stateVersion`).
  `hardware-configuration.nix` is generated; don't edit it by hand.
- `modules/nixos/`: system settings any machine could share, one file per topic.
- `users/<name>.nix`: accounts; links to `home/<name>`.
- `home/<name>/`: Home Manager config for that user.
- Packages from unstable: `pkgs.unstable.<name>` (overlay in `modules/nixos/nix.nix`).
- Unfree packages: add the name to `allowUnfreePredicate` in `modules/nixos/nix.nix`.

## Commands

- Format: `nix fmt`
- Evaluate: `nix eval --raw .#nixosConfigurations.explorer.config.system.build.toplevel`
- Build without applying: `nixos-rebuild build --flake .#explorer` (delete `./result` after)
- Compare builds: `nix store diff-closures /run/current-system <new-path>`
- Apply: `nixos-rebuild switch --sudo` (the owner runs this, not the agent)

New files must be `git add`ed before evaluating; flakes only see tracked files.

## Project dev environments

Per-project tooling (Node, pnpm, ...) is not installed system-wide. Each
project gets a flake dev shell, loaded by direnv (`programs.direnv` with
`nix-direnv` in `home/dion/default.nix`).

- Projects are cloned bare: `<project>/.bare`, a `.git` file containing
  `gitdir: ./.bare`, and one worktree directory per branch beside it.
- The flake lives outside the project, in `~/dev-envs/<project>/`, so nothing
  is staged or committed upstream. Flakes only see git-tracked files, which is
  why an untracked `flake.nix` inside the project doesn't work.
- `<project>/.envrc` (in the container, not in a worktree) is
  `use flake ~/dev-envs/<project>`. direnv searches parent directories, so it
  covers every present and future worktree after one `direnv allow`.
- Rejected: `path:.` (copies worktrees and `node_modules` into the store), a
  flake in `.bare` (needs `path:` or removing the `.git` file, and copies the
  whole git dir), `git add -N` plus `assume-unchanged` (fragile).
- pnpm: `npm_config_manage_package_manager_versions=false` is set in the shell,
  because pnpm otherwise downloads the version pinned in `package.json`, which
  NixOS can't run. nixpkgs' `pnpm_12` may be older than the pinned version.
- Prisma has no prebuilt engine for NixOS and fails with a 404 for
  `linux-nixos`. Put `unstable.prisma-engines` in the dev shell: its setup hook
  sets `PRISMA_SCHEMA_ENGINE_BINARY`. Match its version to the project's
  `prisma` version. `prisma generate` is not run by `pnpm install`; the
  generated client is gitignored, so run it once per worktree.
- The Supabase CLI from npm is a generic-linux binary, so it needs `nix-ld`
  (`modules/nixos/nix-ld.nix`); a Nix-packaged copy wouldn't help because
  `pnpm run` puts `node_modules/.bin` first. It needs Docker
  (`modules/nixos/docker.nix`, user in the `docker` group).
- Worktrees share Docker images but each gets its own Supabase containers and
  volumes (named after the directory). Host ports are fixed, so stop one
  worktree's stack (`supabase stop`) before starting another's.
- `~/dev-envs/` is deliberately kept out of this repo (the owner's decision)
  and is not backed up.

## Research before acting

- Don't rely on memory for option names, defaults, or behavior. They change
  between releases (e.g. `programs.git.userName` became `settings.user.name`).
- Check, in order: `man configuration.nix` / `man home-configuration.nix`, the
  module source in the pinned nixpkgs or Home Manager, the NixOS manual and
  release notes, wiki.nixos.org.
- When something is set but not in this repo, find which module sets it and at
  what priority (`mkDefault`, `mkOverride`) before changing it.
- Free-form options (`settings`, `extraConfig`) accept anything. After changing
  one, inspect the generated file.
- Verify results on the live system (`systemctl`, `journalctl`, `nix eval`)
  rather than assuming a change worked.

## Making changes

- Only edit files when asked. Otherwise explain the change for the owner to make.
- Make the smallest change that solves the problem. Don't refactor, reformat,
  rename, or reorganize unrelated code.
- Don't add abstractions (custom options, `mkEnableOption`, helper functions)
  until a second machine or user actually needs them.
- Match the surrounding style: a one-line header comment per module and
  `{ pkgs, ... }: {` on one line.
- For refactors, the system toplevel path should be unchanged; if it changes,
  find out why with `diff-closures`.
- Never change `system.stateVersion` or `home.stateVersion`.
- No secrets in this repo: it is public, and everything in `/nix/store` is
  world-readable.
- Don't commit, push, or run `sudo` unless asked. Commits are GPG-signed and use
  `feat:`, `refactor:`, `chore:` prefixes.

## Comments

- Comment *why*, not *what*: option names already say what they do.
- Keep comments brief: one line where possible, two at most. Leave usage
  details to the plugin's docs.
- Worth commenting: workarounds, non-obvious defaults, things done by hand
  outside Nix (e.g. the ACLs on `/mnt/storage`).
- Don't leave template comments, commented-out code, or TODOs without a reason.

## Explaining to the owner

- Explain what you changed and why in brief paragraphs. Introduce NixOS
  concepts as they come up (module merging, overlays, priorities, generations).
- Give one recommendation with its trade-off instead of a list of options.
- Cite the docs or source you checked. Say plainly when something is unverified
  or when you were wrong.
- Follow-up work goes in `TODO.md` as checklist items; remove items once done.
