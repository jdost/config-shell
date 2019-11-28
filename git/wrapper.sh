#!/bin/sh

# This is just a small wrapper on top of git to allow for overriding some of the
#  built-in commands

set -euo pipefail

# Use `ripgrep` rather than the built in grep, note: tried to use a high precedence
#  `git-grep` binary but the `grep` command is built into git itself
if [[ "${1:-}" == "grep"  && ! -z "$(which rg 2>/dev/null)" ]]; then
   shift  # Don't want to pass in the "grep" part
   exec rg "$@"
fi

exec git "$@"
