# shellcheck shell=zsh
# Awesome Zsh interactive entry point. This file deliberately performs no
# network access; installation and updates are explicit lifecycle operations.
[[ -o interactive ]] || return 0

typeset -g AWESOME_ZSH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
typeset -g AWESOME_ZSH_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/awesome-zsh"
typeset -g AWESOME_ZSH_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/awesome-zsh"
typeset -g AWESOME_ZSH_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/awesome-zsh"
typeset -g AWESOME_ZSH_PLUGIN_DIR="${AWESOME_ZSH_PLUGIN_DIR:-$AWESOME_ZSH_DATA/plugins}"

mkdir -p -- "$AWESOME_ZSH_CACHE" "$AWESOME_ZSH_DATA" "$AWESOME_ZSH_STATE" 2>/dev/null
[[ -r "$AWESOME_ZSH_CONFIG/lib/lifecycle.zsh" ]] &&
  source "$AWESOME_ZSH_CONFIG/lib/lifecycle.zsh"

# Source a pinned plugin without making its on-disk layout part of the public
# interface. The lifecycle layer may install either a flat or nested checkout.
awesome-zsh-source-plugin() {
  local plugin="$1" file="$2" candidate
  for candidate in \
    "$AWESOME_ZSH_PLUGIN_DIR/$plugin/$file" \
    "$AWESOME_ZSH_PLUGIN_DIR/$plugin/$plugin/$file" \
    "$AWESOME_ZSH_CONFIG/plugins/$plugin/$file"; do
    if [[ -r "$candidate" ]]; then
      source "$candidate"
      return 0
    fi
  done
  return 1
}

local fragment
for fragment in "$AWESOME_ZSH_CONFIG"/conf.d/*.zsh(N); do
  source "$fragment"
done
unset fragment

[[ -r "$AWESOME_ZSH_CONFIG/local.zsh" ]] && source "$AWESOME_ZSH_CONFIG/local.zsh"
