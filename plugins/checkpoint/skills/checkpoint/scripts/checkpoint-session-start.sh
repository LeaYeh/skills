#!/bin/bash
# SessionStart hook: clean stale RESUME.md, then load checkpoint if one exists.

rm -f RESUME.md

[ -d "$HOME/.claude.checkpoints" ] || exit 0

REMOTE=$(git remote get-url origin 2>/dev/null) || exit 0

KEY=$(echo "$REMOTE" \
  | sed 's|^https://||; s|^git@||' \
  | sed 's|:|/|' \
  | sed 's|\.git$||' \
  | sed 's|/|-|g; s|[^a-zA-Z0-9._-]|-|g')

CHECKPOINT="$HOME/.claude.checkpoints/${KEY}.md"
[ -f "$CHECKPOINT" ] || exit 0

cp "$CHECKPOINT" RESUME.md
