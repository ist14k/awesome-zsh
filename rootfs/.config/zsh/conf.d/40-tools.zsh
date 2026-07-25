# fnm remains the Node.js version manager. Its environment setup is local and
# does not contact the network.
if (( ${+commands[fnm]} )); then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

if (( ${+commands[atuin]} )); then
  export ATUIN_CONFIG_DIR="$AWESOME_ZSH_CONFIG/atuin"
  export ATUIN_NOBIND=true
  eval "$(atuin init zsh)"
  bindkey -M viins '^R' _atuin_search_widget
  bindkey -M vicmd '^R' _atuin_search_widget
fi

if (( ${+commands[starship]} )); then
  export STARSHIP_CONFIG="$AWESOME_ZSH_CONFIG/starship.toml"
  export STARSHIP_CACHE="$AWESOME_ZSH_CACHE/starship"
  eval "$(starship init zsh)"
else
  PROMPT='%F{#cba6f7}%n%f@%F{#89b4fa}%m%f %F{#94e2d5}%~%f %# '
fi

