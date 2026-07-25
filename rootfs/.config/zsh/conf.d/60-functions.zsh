mkcd() {
  (( $# == 1 )) || { print -u2 'usage: mkcd DIRECTORY'; return 2; }
  mkdir -p -- "$1" && cd -- "$1"
}

take() {
  (( $# == 1 )) || { print -u2 'usage: take URL|DIRECTORY'; return 2; }
  if [[ "$1" == (git@*|*.git|http(|s)://*) ]]; then
    command git clone -- "$1" || return
    cd -- "${${1:t}%.git}"
  else
    mkcd "$1"
  fi
}

extract() {
  (( $# )) || { print -u2 'usage: extract ARCHIVE...'; return 2; }
  local archive
  for archive in "$@"; do
    [[ -f "$archive" ]] || { print -u2 "extract: not a file: $archive"; continue; }
    case "$archive" in
      *.tar.bz2|*.tbz2) tar xjf "$archive" ;;
      *.tar.gz|*.tgz)   tar xzf "$archive" ;;
      *.tar.xz|*.txz)   tar xJf "$archive" ;;
      *.tar.zst)        tar --zstd -xf "$archive" ;;
      *.tar)            tar xf "$archive" ;;
      *.bz2)            bunzip2 "$archive" ;;
      *.gz)             gunzip "$archive" ;;
      *.xz)             unxz "$archive" ;;
      *.zip)            unzip "$archive" ;;
      *.7z)             7z x "$archive" ;;
      *) print -u2 "extract: unsupported archive: $archive"; return 1 ;;
    esac
  done
}

zsh-reload() {
  exec zsh
}

zsh-doc() {
  local docs="$AWESOME_ZSH_CONFIG/docs.html"
  case "${1:-}" in
    --path) print -r -- "$docs" ;;
    --check) [[ -r "$docs" ]] ;;
    '') if (( ${+commands[xdg-open]} )); then
          xdg-open "$docs" >/dev/null 2>&1
        else
          print -r -- "$docs"
        fi ;;
    *) print -u2 'usage: zsh-doc [--path|--check]'; return 2 ;;
  esac
}

