#!/usr/bin/env zsh
source "${0:A:h}/lib.zsh"

for file in install.zsh README.md LICENSE .gitignore \
  rootfs/.zshenv rootfs/.zshrc rootfs/.config/zsh/docs.html; do
  assert_file "$REPO_DIR/$file" "release input: $file"
done

for command in \
  'zsh-bootstrap [--force]' \
  'zsh-update [all|config|plugins|tools|rollback]' \
  'zsh-doctor [--benchmark]' \
  'zsh-reload' \
  'zsh-doc [--path|--check]'; do
  assert_contains "$REPO_DIR/rootfs/.config/zsh/docs.html" "$command" \
    "manual documents $command"
done

finish

