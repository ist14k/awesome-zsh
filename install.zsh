#!/usr/bin/env zsh
emulate -LR zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL

typeset -r VERSION=1.0.0
typeset dry_run=0 assume_yes=0 force=0 bootstrap=1
typeset arg
usage() {
  cat <<'EOF'
Awesome Zsh installer
Usage: install.zsh [--dry-run] [--yes] [--force] [--no-bootstrap] [--help]

  --dry-run       validate and print actions without changing files
  --yes           do not ask for confirmation
  --force         reinstall even when v1.0.0 is already installed
  --no-bootstrap  install configuration without fetching dependencies
EOF
}
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    --yes) assume_yes=1 ;;
    --force) force=1 ;;
    --no-bootstrap) bootstrap=0 ;;
    --help|-h) usage; exit 0 ;;
    *) print -u2 "install.zsh: unknown option: $arg"; usage >&2; exit 2 ;;
  esac
done

typeset config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
typeset state_home="${XDG_STATE_HOME:-$HOME/.local/state}/awesome-zsh"
typeset cache_home="${XDG_CACHE_HOME:-$HOME/.cache}/awesome-zsh"
typeset data_home="${XDG_DATA_HOME:-$HOME/.local/share}/awesome-zsh"
typeset target="$config_home/zsh"
typeset script_dir="${0:A:h}"
typeset work="" source_root="" lock_dir="$state_home/install.lock"
typeset backup="" committed=0

cleanup() {
  (( committed )) || {
    if [[ -n "$backup" && -d "$backup" ]]; then
      print -u2 "Installation interrupted; restoring backup."
      rm -rf -- "$target" "$HOME/.zshenv" "$HOME/.zshrc"
      [[ ! -e "$backup/config-zsh" ]] || mv -- "$backup/config-zsh" "$target"
      [[ ! -e "$backup/.zshenv" ]] || mv -- "$backup/.zshenv" "$HOME/.zshenv"
      [[ ! -e "$backup/.zshrc" ]] || mv -- "$backup/.zshrc" "$HOME/.zshrc"
    fi
  }
  [[ -z "$work" ]] || rm -rf -- "$work"
  rmdir -- "$lock_dir" 2>/dev/null || true
}
trap cleanup EXIT INT TERM HUP

work="$(mktemp -d "${TMPDIR:-/tmp}/awesome-zsh.XXXXXXXX")"

if [[ -d "$script_dir/rootfs/.config/zsh" ]]; then
  source_root="$script_dir/rootfs"
else
  typeset repo="${AWESOME_ZSH_REPOSITORY:-ist14k/awesome-zsh}"
  typeset base="${AWESOME_ZSH_RELEASE_URL:-https://github.com/$repo/releases/download/v$VERSION}"
  command -v curl >/dev/null || { print -u2 "curl is required for standalone installation"; exit 69; }
  curl -fsSL "$base/SHA256SUMS" -o "$work/SHA256SUMS"
  curl -fsSL "$base/awesome-zsh-v$VERSION.tar.gz" -o "$work/archive.tar.gz"
  typeset expected="${$(awk '$2=="awesome-zsh-v1.0.0.tar.gz"{print $1}' "$work/SHA256SUMS"):-}"
  [[ ${#expected} -eq 64 && "$expected" != *[^0-9a-f]* ]] ||
    { print -u2 "Archive checksum is missing or invalid"; exit 65; }
  print "$expected  $work/archive.tar.gz" | sha256sum -c - >/dev/null
  mkdir "$work/release"
  tar -xzf "$work/archive.tar.gz" -C "$work/release"
  source_root="$work/release/rootfs"
fi

[[ -f "$source_root/.zshenv" && -f "$source_root/.zshrc" &&
   -f "$source_root/.config/zsh/init.zsh" &&
   -f "$source_root/.config/zsh/lib/lifecycle.zsh" ]] ||
  { print -u2 "Release payload is incomplete"; exit 65; }
for f in "$source_root"/.zshenv "$source_root"/.zshrc "$source_root"/.config/zsh/**/*.zsh(N); do
  zsh -n "$f"
done

if (( ! force )) && [[ -r "$target/.awesome-zsh-version" ]] &&
   [[ "$(<"$target/.awesome-zsh-version")" == "$VERSION" ]]; then
  print "Awesome Zsh v$VERSION is already installed (use --force to reinstall)."
  committed=1
  exit 0
fi
print "Install Awesome Zsh v$VERSION into $target"
(( dry_run )) && { print "Dry run complete: payload and shell syntax are valid."; committed=1; exit 0; }
if (( ! assume_yes )) && [[ -t 0 ]]; then
  read -q "REPLY?Continue? [y/N] " || { print; exit 1; }
  print
fi

mkdir -p -- "$state_home" "$cache_home" "$data_home"
if ! mkdir -- "$lock_dir" 2>/dev/null; then
  print -u2 "Another Awesome Zsh install or update is running ($lock_dir)."
  exit 75
fi
typeset stamp="$(date -u +%Y%m%dT%H%M%SZ)-$$"
backup="$state_home/backups/$stamp"
mkdir -p -- "$backup" "$target:h"
[[ ! -f "$target/local.zsh" ]] || cp -- "$target/local.zsh" "$work/local.zsh"
[[ ! -e "$target" ]] || mv -- "$target" "$backup/config-zsh"
[[ ! -e "$HOME/.zshenv" ]] || mv -- "$HOME/.zshenv" "$backup/.zshenv"
[[ ! -e "$HOME/.zshrc" ]] || mv -- "$HOME/.zshrc" "$backup/.zshrc"

cp -R -- "$source_root/.config/zsh" "$target"
[[ ! -f "$work/local.zsh" ]] || cp -- "$work/local.zsh" "$target/local.zsh"
cp -- "$source_root/.zshenv" "$HOME/.zshenv"
cp -- "$source_root/.zshrc" "$HOME/.zshrc"
print -r -- "$VERSION" > "$target/.awesome-zsh-version"
print -r -- "$stamp" > "$state_home/current-backup"
chmod -R go-w -- "$target"
committed=1
print "Installed Awesome Zsh v$VERSION. Backup: $backup"
if (( bootstrap )); then
  AWESOME_ZSH_NONINTERACTIVE=1 zsh -c "source ${(q)target}/lib/lifecycle.zsh; zsh-bootstrap" ||
    print -u2 "Dependency bootstrap could not complete; configuration remains installed. Run zsh-bootstrap later."
fi
