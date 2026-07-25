# Suggestions prefer real history, then fall back to completion results (which
# includes filesystem candidates).
typeset -ga ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#6c7086'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
awesome-zsh-source-plugin zsh-autosuggestions zsh-autosuggestions.zsh 2>/dev/null || true

# zsh-syntax-highlighting must be sourced after widgets are defined.
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets cursor)
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES['path']='fg=#94e2d5,underline'
ZSH_HIGHLIGHT_STYLES['path_prefix']='fg=#cba6f7,underline'
ZSH_HIGHLIGHT_STYLES['unknown-token']='fg=#f38ba8'
ZSH_HIGHLIGHT_STYLES['reserved-word']='fg=#cba6f7,bold'
awesome-zsh-source-plugin zsh-syntax-highlighting zsh-syntax-highlighting.zsh 2>/dev/null || true
