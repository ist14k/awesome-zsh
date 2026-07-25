#!/usr/bin/env zsh
emulate -LR zsh
setopt ERR_EXIT NO_UNSET PIPE_FAIL
typeset root="${0:A:h:h}" version="${1:-1.0.0}"
typeset output="$root/dist" stage
[[ "$version" == 1.0.0 ]] || { print -u2 "Only v1.0.0 is supported"; exit 2; }
for file in "$root/install.zsh" "$root/rootfs/.zshenv" "$root/rootfs/.zshrc"; do
  [[ -f "$file" ]] || { print -u2 "Missing release input: $file"; exit 1; }
done
typeset unsafe
unsafe="$(find "$root/rootfs" \( -type l -o -name local.zsh -o -name '*history*' \
  -o -name '*.pem' -o -name '*.key' -o -name 'credentials*' \) -print)"
[[ -z "$unsafe" ]] || {
  print -u2 "Unsafe release input detected:"
  print -u2 -r -- "$unsafe"
  exit 1
}
for file in "$root/install.zsh" "$root/rootfs"/**/*.zsh(N); do zsh -n "$file"; done
stage="$(mktemp -d "${TMPDIR:-/tmp}/awesome-zsh-release.XXXXXXXX")"
trap 'rm -rf -- "$stage"' EXIT
mkdir -p "$stage/rootfs" "$output"
cp -R "$root/rootfs/." "$stage/rootfs/"
tar --sort=name --mtime='UTC 2020-01-01' --owner=0 --group=0 --numeric-owner \
  -czf "$output/awesome-zsh-v$version.tar.gz" -C "$stage" rootfs
cp "$root/install.zsh" "$output/install.zsh"
( cd "$output"; sha256sum "awesome-zsh-v$version.tar.gz" install.zsh > SHA256SUMS )
print "Built release assets in $output"
