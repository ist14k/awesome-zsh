# Awesome Zsh

Awesome Zsh is a self-installing, pinned Zsh environment with history-first
suggestions, path-aware highlighting, Vi editing, fzf-tab, Starship, and
local-only Atuin. Installation is transactional and existing dotfiles are
backed up before replacement.

## Install

For a checked-out release:

```zsh
zsh install.zsh
```

The installer accepts `--dry-run`, `--yes`, `--force`, `--no-bootstrap`, and
`--help`. A published release should be downloaded together with
`SHA256SUMS`, verified with `sha256sum -c`, and only then executed. Never pipe
an unverified network response directly into a shell.

The installer writes `.zshenv`, `.zshrc`, and the Zsh configuration below
`${XDG_CONFIG_HOME:-$HOME/.config}`. It does not symlink this checkout.
Machine-specific settings belong in `~/.config/zsh/local.zsh`; start from
`local.zsh.example`. That file, shell history, credentials, caches, and Atuin
data are excluded from releases.

On first use, `zsh-bootstrap` installs pinned optional dependencies. Pass
`--no-bootstrap` during installation for an entirely local config-only
install. If the network is unavailable, the shell remains usable and
bootstrap can be retried later.

## Operate

```text
zsh-bootstrap [--force]
zsh-update [all|config|plugins|tools|rollback]
zsh-doctor [--benchmark]
zsh-reload
zsh-doc [--path|--check]
```

Updates are explicit—interactive startup never accesses the network. Use
`zsh-update rollback` to restore the most recent configuration backup.
`zsh-doctor --benchmark` adds startup timing to its health report.
`zsh-doc` opens the bundled offline manual, while `zsh-doc --path` prints it.

## Documentation and tests

Open `~/.config/zsh/docs.html` in any browser; it is a single offline HTML
file with no remote assets. In a checkout, run:

```zsh
zsh tests/run.zsh
```

The suite checks syntax, documentation parity, release hygiene, absence of
startup network access, and installation into an isolated home. Individual
tests skip only when the implementation file they exercise has not yet been
created.

## Recovery

If startup is broken, launch `zsh -f`, inspect the latest directory under
`${XDG_STATE_HOME:-$HOME/.local/state}/awesome-zsh`, and run
`zsh-update rollback`. Installer failures restore replaced files
automatically. The backup can also be copied manually while in `zsh -f`.

Licensed under the [MIT License](LICENSE).

