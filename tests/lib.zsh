#!/usr/bin/env zsh

setopt ERR_EXIT NO_UNSET PIPE_FAIL

typeset -gr TEST_DIR=${0:A:h}
typeset -gr REPO_DIR=${TEST_DIR:h}
typeset -gi TEST_FAILURES=0

pass() { print -r -- "ok - $*" }
fail() { print -u2 -r -- "not ok - $*"; (( TEST_FAILURES++ )) || true }
skip() { print -r -- "ok - $* # SKIP" }

assert_file() {
  [[ -f $1 ]] && pass "$2" || fail "$2 (missing $1)"
}

assert_contains() {
  local file=$1 needle=$2 label=$3
  grep -Fq -- "$needle" "$file" && pass "$label" || fail "$label"
}

finish() {
  (( TEST_FAILURES == 0 )) || exit 1
}

