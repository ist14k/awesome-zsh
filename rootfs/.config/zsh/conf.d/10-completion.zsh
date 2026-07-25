autoload -Uz compinit
typeset -g _awesome_zsh_compdump="$AWESOME_ZSH_CACHE/zcompdump-${ZSH_VERSION}"
# Recheck completion security once daily, while avoiding repeated startup work.
if [[ -n "$_awesome_zsh_compdump"(#qN.mh+24) ]]; then
  compinit -d "$_awesome_zsh_compdump"
else
  compinit -C -d "$_awesome_zsh_compdump"
fi
unset _awesome_zsh_compdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*:descriptions' format '%F{mauve}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}no matches%f'
zstyle ':completion:*' cache-path "$AWESOME_ZSH_CACHE/completion"
zstyle ':completion:*' use-cache true

# fzf-tab replaces only the completion selection widget. Completion itself
# remains fully functional when the optional plugin or fzf is unavailable.
if (( ${+commands[fzf]} )); then
  awesome-zsh-source-plugin fzf-tab fzf-tab.plugin.zsh 2>/dev/null || true
  zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always -A -- $realpath'
fi

