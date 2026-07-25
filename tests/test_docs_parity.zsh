#!/usr/bin/env zsh
source "${0:A:h}/lib.zsh"

typeset -r docs="$REPO_DIR/rootfs/.config/zsh/docs.html"
typeset -a sources
sources=("$REPO_DIR"/rootfs/.config/zsh/{init.zsh,conf.d/*.zsh,lib/*.zsh}(N))

# Public commands are the stable contract. Their implementations may be split
# across files, so check both implementation presence and manual coverage.
for name in zsh-bootstrap zsh-update zsh-doctor zsh-reload zsh-doc; do
  assert_contains "$docs" "data-command=\"$name\"" "manual indexes $name"
  if (( ${#sources} )); then
    grep -Eq "(^|[^[:alnum:]_-])${name//-/\\-}([[:space:](]|$)" $sources &&
      pass "implementation mentions $name" ||
      fail "implementation mentions $name"
  else
    skip "implementation mentions $name (sources not present)"
  fi
done

# Aliases and user-facing helpers have intentionally narrow source registries.
# Every declared item there must be indexed in the bundled manual.
typeset aliases_file="$REPO_DIR/rootfs/.config/zsh/conf.d/50-aliases.zsh"
if [[ -f $aliases_file ]]; then
  typeset alias_name
  typeset -A seen_aliases=()
  for alias_name in ${(f)"$(sed -nE 's/^[[:space:]]*alias[[:space:]]+([^=]+)=.*/\1/p' "$aliases_file")"}; do
    [[ -n ${seen_aliases[$alias_name]-} ]] && continue
    seen_aliases[$alias_name]=1
    assert_contains "$docs" "data-alias=\"$alias_name\"" "manual indexes alias $alias_name"
  done
fi

typeset functions_file="$REPO_DIR/rootfs/.config/zsh/conf.d/60-functions.zsh"
if [[ -f $functions_file ]]; then
  typeset function_name
  for function_name in ${(f)"$(sed -nE 's/^([[:alnum:]_-]+)\(\).*/\1/p' "$functions_file")"}; do
    [[ $function_name == zsh-* ]] && continue
    assert_contains "$docs" "data-function=\"$function_name\"" \
      "manual indexes function $function_name"
  done
fi

# Any explicitly registered aliases and keybindings must have matching manual
# markers. This avoids guessing at helper aliases used only internally.
for source in $sources; do
  while IFS= read -r line; do
    [[ $line == *'# doc:'* ]] || continue
    typeset marker=${line##*# doc:}
    marker=${marker##[[:space:]]#}
    assert_contains "$docs" "data-doc=\"$marker\"" \
      "manual entry for ${source:t}:$marker"
  done < "$source"
done

finish
