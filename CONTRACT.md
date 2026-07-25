# Awesome Zsh v1.0.0 Contract

## Baseline

- Captured 2026-07-25 in `/home/istiak`.
- Existing `.zshrc` SHA-256:
  `8efe3e281a4d0a3aab7e5ea6efa04db1290e2bd0fc0fc66094e10ba577101484`.
- `.zshenv` and `.config/zsh` did not exist.
- The installer must preserve the existing `fnm` behavior and must back up
  replaced files.

## Paths

- Source: `/home/istiak/Projects/awesome-zsh`
- Installed config: `${XDG_CONFIG_HOME:-$HOME/.config}/zsh`
- Cache: `${XDG_CACHE_HOME:-$HOME/.cache}/awesome-zsh`
- Data: `${XDG_DATA_HOME:-$HOME/.local/share}/awesome-zsh`
- State/backups: `${XDG_STATE_HOME:-$HOME/.local/state}/awesome-zsh`

## Public commands

- `zsh-bootstrap [--force]`
- `zsh-update [all|config|plugins|tools|rollback]`
- `zsh-doctor [--benchmark]`
- `zsh-reload`
- `zsh-doc [--path|--check]`

## Installer interface

- `install.zsh [--dry-run] [--yes] [--force] [--no-bootstrap] [--help]`
- Installation is transactional: stage, validate, back up, commit, and restore
  on failure.
- Runtime startup performs no network access.
- `local.zsh`, history, cache, credentials, Atuin data, and personal runtime
  state are never release inputs.

## Registries and ownership

- Plugin pins: `rootfs/.config/zsh/plugins.lock`
- Tool pins: `rootfs/.config/zsh/versions.lock` and `mise.lock`
- Shell UX owns `init.zsh`, `conf.d`, Starship, Atuin, and mise configuration.
- Lifecycle owns installer, `lib`, plugin metadata, locks, build scripts, and
  release workflow.
- Documentation owns `docs.html`, tests, README, license, and ignore rules.
