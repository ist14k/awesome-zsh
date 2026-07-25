alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias c='clear'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias mkdir='mkdir -p'

if (( ${+commands[eza]} )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias la='eza -a --icons=auto --group-directories-first'
  alias ll='eza -al --icons=auto --group-directories-first --git'
fi
if (( ${+commands[bat]} )); then
  alias cat='bat --paging=never'
fi

alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph'
alias gp='git push'
alias gs='git status --short --branch'

