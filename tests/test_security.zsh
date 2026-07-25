#!/usr/bin/env zsh
source "${0:A:h}/lib.zsh"

typeset -a tracked
if command -v git >/dev/null && git -C "$REPO_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  tracked=("${(@f)$(git -C "$REPO_DIR" ls-files)}")
else
  tracked=("${(@)${REPO_DIR}/**/*(.)}")
fi

typeset -a forbidden
forbidden=('.zsh_history' 'local.zsh' '.local/share/atuin' '.cache/awesome-zsh')
for needle in $forbidden; do
  if print -rl -- $tracked | grep -Fqx -- "$needle"; then
    fail "private runtime file excluded: $needle"
  else
    pass "private runtime file excluded: $needle"
  fi
done

if grep -RIEq --exclude-dir=.git \
  '(BEGIN (RSA |OPENSSH )?PRIVATE KEY|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16})' \
  "$REPO_DIR"; then
  fail "no credential-shaped content"
else
  pass "no credential-shaped content"
fi

if grep -Eq '(https?:)?//[^< ]+\.(css|js)|<(script|link)[^>]+https?://' \
  "$REPO_DIR/rootfs/.config/zsh/docs.html"; then
  fail "manual has no remote assets"
else
  pass "manual has no remote assets"
fi

finish

