#!/bin/bash
# UserPromptSubmit hook: warn when session file size suggests ~70% context usage.
# Threshold is approximate; tune THRESHOLD_KB based on your model's context window.

THRESHOLD_KB=500
THRESHOLD=$((THRESHOLD_KB * 1024))

PROJECTS_DIR="$HOME/.claude/projects"
[ -d "$PROJECTS_DIR" ] || exit 0

LATEST=$(find "$PROJECTS_DIR" -name "*.jsonl" -type f 2>/dev/null \
  | xargs ls -t 2>/dev/null \
  | head -1)
[ -z "$LATEST" ] && exit 0

SIZE=$(wc -c < "$LATEST" 2>/dev/null || echo 0)

if [ "$SIZE" -gt "$THRESHOLD" ]; then
  echo "⚠️  Context 可能已達 70%，建議執行 /checkpoint 再繼續。"
fi
