# Awesome Zsh lifecycle commands. This file is safe to source more than once.
[[ -n "${AWESOME_ZSH_LIFECYCLE_LOADED:-}" ]] && return 0
typeset -g AWESOME_ZSH_LIFECYCLE_LOADED=1
typeset -g AWESOME_ZSH_VERSION=1.0.0
typeset -g AWESOME_ZSH_CONFIG="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
typeset -g AWESOME_ZSH_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/awesome-zsh"
typeset -g AWESOME_ZSH_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/awesome-zsh"
typeset -g AWESOME_ZSH_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/awesome-zsh"

_az_with_lock() {
  emulate -LR zsh
  local name="$1"; shift
  local lock="$AWESOME_ZSH_STATE/$name.lock"
  mkdir -p "$AWESOME_ZSH_STATE"
  mkdir "$lock" 2>/dev/null || { print -u2 "awesome-zsh: $name already running"; return 75; }
  trap 'rmdir -- "$lock" 2>/dev/null' EXIT INT TERM HUP
  "$@"
  local rc=$?
  rmdir -- "$lock" 2>/dev/null
  trap - EXIT INT TERM HUP
  return $rc
}

_az_bootstrap_impl() {
  emulate -LR zsh
  setopt ERR_RETURN PIPE_FAIL
  local force="${1:-}" plugin_dir="$AWESOME_ZSH_DATA/plugins"
  mkdir -p "$plugin_dir" "$AWESOME_ZSH_CACHE"
  local name url revision destination
  while IFS='|' read -r name url revision; do
    [[ -n "$name" && "$name" != \#* ]] || continue
    destination="$plugin_dir/$name"
    if [[ -d "$destination/.git" ]]; then
      [[ "$force" == --force ]] || continue
      git -C "$destination" fetch --quiet origin "$revision" || {
        print -u2 "awesome-zsh: offline; keeping cached $name"; continue
      }
    else
      command git clone --quiet --filter=blob:none "$url" "$destination.tmp" || {
        rm -rf "$destination.tmp"; print -u2 "awesome-zsh: unavailable: $name"; continue
      }
      mv "$destination.tmp" "$destination"
    fi
    git -C "$destination" checkout --quiet --detach "$revision" || return 1
  done < "$AWESOME_ZSH_CONFIG/plugins.lock"
  if command -v mise >/dev/null && [[ -f "$AWESOME_ZSH_CONFIG/mise.toml" ]]; then
    MISE_CONFIG_FILE="$AWESOME_ZSH_CONFIG/mise.toml" mise install --yes || return 1
  fi
}

zsh-bootstrap() {
  [[ $# -le 1 && ( $# -eq 0 || "$1" == --force ) ]] ||
    { print -u2 "usage: zsh-bootstrap [--force]"; return 2; }
  _az_with_lock bootstrap _az_bootstrap_impl "${1:-}"
}

_az_rollback() {
  local stamp="${$(<"$AWESOME_ZSH_STATE/current-backup" 2>/dev/null):-}"
  local backup="$AWESOME_ZSH_STATE/backups/$stamp"
  [[ -n "$stamp" && -d "$backup" ]] || { print -u2 "awesome-zsh: no rollback available"; return 1; }
  local rescue="$AWESOME_ZSH_STATE/backups/pre-rollback-$(date -u +%Y%m%dT%H%M%SZ)"
  mkdir -p "$rescue"
  [[ ! -e "$AWESOME_ZSH_CONFIG" ]] || mv "$AWESOME_ZSH_CONFIG" "$rescue/config-zsh"
  [[ ! -e "$HOME/.zshenv" ]] || mv "$HOME/.zshenv" "$rescue/.zshenv"
  [[ ! -e "$HOME/.zshrc" ]] || mv "$HOME/.zshrc" "$rescue/.zshrc"
  [[ ! -e "$backup/config-zsh" ]] || mv "$backup/config-zsh" "$AWESOME_ZSH_CONFIG"
  [[ ! -e "$backup/.zshenv" ]] || mv "$backup/.zshenv" "$HOME/.zshenv"
  [[ ! -e "$backup/.zshrc" ]] || mv "$backup/.zshrc" "$HOME/.zshrc"
  print "Rolled back; replaced files saved in $rescue"
}

zsh-update() {
  emulate -LR zsh
  local scope="${1:-all}"
  [[ $# -le 1 && "$scope" == (all|config|plugins|tools|rollback) ]] ||
    { print -u2 "usage: zsh-update [all|config|plugins|tools|rollback]"; return 2; }
  [[ "$scope" == rollback ]] && { _az_with_lock update _az_rollback; return; }
  if [[ "$scope" == plugins || "$scope" == all ]]; then zsh-bootstrap --force || return; fi
  if [[ "$scope" == tools ]] && command -v mise >/dev/null; then
    MISE_CONFIG_FILE="$AWESOME_ZSH_CONFIG/mise.toml" mise install --yes
  fi
  if [[ "$scope" == config || "$scope" == all ]]; then
    local repo="${AWESOME_ZSH_REPOSITORY:-ist14k/awesome-zsh}"
    local base="https://github.com/$repo/releases/download/v$AWESOME_ZSH_VERSION"
    local tmp="$(mktemp -d "${TMPDIR:-/tmp}/awesome-zsh-update.XXXXXXXX")"
    curl -fsSL "$base/SHA256SUMS" -o "$tmp/SHA256SUMS" &&
      curl -fsSL "$base/install.zsh" -o "$tmp/install.zsh" || {
        rm -rf "$tmp"; print -u2 "awesome-zsh: update unavailable (offline?)"; return 1
      }
    local expected="${$(awk '$2=="install.zsh"{print $1}' "$tmp/SHA256SUMS"):-}"
    [[ ${#expected} -eq 64 && "$expected" != *[^0-9a-f]* ]] &&
      print "$expected  $tmp/install.zsh" | sha256sum -c - >/dev/null || {
        rm -rf "$tmp"; print -u2 "awesome-zsh: installer verification failed"; return 1
      }
    zsh "$tmp/install.zsh" --yes --force --no-bootstrap
    local rc=$?; rm -rf "$tmp"; return $rc
  fi
}

zsh-doctor() {
  emulate -LR zsh
  local benchmark=0 failures=0
  [[ "${1:-}" == --benchmark ]] && benchmark=1
  [[ $# -le 1 && ( $# -eq 0 || benchmark -eq 1 ) ]] ||
    { print -u2 "usage: zsh-doctor [--benchmark]"; return 2; }
  local file
  for file in "$HOME/.zshenv" "$HOME/.zshrc" "$AWESOME_ZSH_CONFIG/init.zsh" \
    "$AWESOME_ZSH_CONFIG/plugins.lock" "$AWESOME_ZSH_CONFIG/versions.lock"; do
    [[ -r "$file" ]] || { print -u2 "missing: $file"; (( failures++ )); }
  done
  zsh -n "$HOME/.zshenv" "$HOME/.zshrc" "$AWESOME_ZSH_CONFIG"/**/*.zsh(N) || (( failures++ ))
  if (( benchmark )); then
    TIMEFMT='startup: %E'
    time zsh -dfi -c exit
  fi
  (( failures == 0 )) && print "Awesome Zsh doctor: healthy"
  return $(( failures != 0 ))
}

zsh-reload() {
  exec zsh -l
}

zsh-doc() {
  local doc="$AWESOME_ZSH_CONFIG/docs.html"
  case "${1:-}" in
    --path) print -r -- "$doc" ;;
    --check) [[ -r "$doc" ]] ;;
    "") print -r -- "Offline documentation: $doc" ;;
    *) print -u2 "usage: zsh-doc [--path|--check]"; return 2 ;;
  esac
}
