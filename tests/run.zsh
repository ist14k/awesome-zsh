#!/usr/bin/env zsh

setopt ERR_EXIT NO_UNSET PIPE_FAIL
typeset -r here=${0:A:h}
typeset -a tests
tests=("$here"/test_*.zsh(N))

(( ${#tests} )) || { print -u2 "No tests found"; exit 1; }

typeset -i failed=0
for test_file in $tests; do
  print -r -- "\n== ${test_file:t} =="
  zsh "$test_file" || (( failed++ ))
done

print -r -- "\n$(( ${#tests} - failed ))/${#tests} test files passed"
(( failed == 0 ))

