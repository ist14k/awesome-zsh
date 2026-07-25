#!/usr/bin/env zsh
source "${0:A:h}/lib.zsh"

typeset -r installer="$REPO_DIR/install.zsh"
[[ -f $installer ]] || { skip "isolated install (installer not present)"; exit 0; }

typeset sandbox
sandbox=$(mktemp -d "${TMPDIR:-/tmp}/awesome-zsh-test.XXXXXXXX")
trap 'rm -rf -- "$sandbox"' EXIT
mkdir -p "$sandbox/home" "$sandbox/bin"

# Network programs fail loudly. A successful config-only installation and warm
# startup therefore prove neither path depends on the network.
for program in curl wget git; do
  print -r -- '#!/bin/sh' 'echo "unexpected network command" >&2' 'exit 97' \
    > "$sandbox/bin/$program"
  chmod +x "$sandbox/bin/$program"
done

typeset -x HOME="$sandbox/home"
typeset -x XDG_CONFIG_HOME="$HOME/.config"
typeset -x XDG_CACHE_HOME="$HOME/.cache"
typeset -x XDG_DATA_HOME="$HOME/.local/share"
typeset -x XDG_STATE_HOME="$HOME/.local/state"
typeset -x PATH="$sandbox/bin:$PATH"

if zsh "$installer" --yes --no-bootstrap; then
  pass "isolated config-only install"
else
  fail "isolated config-only install"
  finish
fi

assert_file "$HOME/.zshenv" "installed .zshenv"
assert_file "$HOME/.zshrc" "installed .zshrc"
assert_file "$XDG_CONFIG_HOME/zsh/docs.html" "installed offline manual"

if ZDOTDIR="$HOME" zsh -lic 'exit 0'; then
  pass "warm startup without network"
else
  fail "warm startup without network"
fi

finish
