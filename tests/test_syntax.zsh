#!/usr/bin/env zsh
source "${0:A:h}/lib.zsh"

typeset -a shell_files
shell_files=("$REPO_DIR"/**/*.zsh(N) "$REPO_DIR"/rootfs/.zshenv(N) \
  "$REPO_DIR"/rootfs/.zshrc(N))

for file in $shell_files; do
  if zsh -n "$file"; then
    pass "syntax: ${file#$REPO_DIR/}"
  else
    fail "syntax: ${file#$REPO_DIR/}"
  fi
done

if command -v python3 >/dev/null; then
  python3 - "$REPO_DIR/rootfs/.config/zsh/docs.html" <<'PY'
from html.parser import HTMLParser
import sys
class Parser(HTMLParser):
    pass
p = Parser()
with open(sys.argv[1], encoding="utf-8") as f:
    p.feed(f.read())
PY
  pass "HTML parses"
else
  skip "HTML parses (python3 unavailable)"
fi

finish

