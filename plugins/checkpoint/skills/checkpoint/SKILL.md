---
name: checkpoint
description: Save current session state to a private checkpoints repo so work resumes seamlessly after a Pro quota reset, context window limit, or machine switch. Use when approaching usage limits, switching machines, or when the user says "checkpoint", "save state", "save progress", or "I need to switch".
---

# Checkpoint

Saves session state to `~/.claude.checkpoints/` and restores it automatically on the next session start via `RESUME.md`.

---

## Save — `/checkpoint`

**Step 1 — Verify git remote**
```
git remote get-url origin
```
If no remote exists: print warning `"此專案無 git remote，無法存 checkpoint"` and stop.

**Step 2 — Collect from conversation** (no tools needed)
- Current goal
- What's done / in progress / pending
- Key decisions and constraints made this session
- Environment: hostname, branch, absolute project path

**Step 3 — Write checkpoint file**

Sanitize remote URL to filename key:
`git@github.com:User/repo.git` → `github.com-User-repo`
`https://github.com/User/repo.git` → `github.com-User-repo`

Write to `~/.claude.checkpoints/<key>.md`:

```markdown
# Checkpoint
**Saved:** <YYYY-MM-DD HH:MM> | **Branch:** <branch> | **Machine:** <hostname>
**Project:** <absolute path>

## Task
<one-line goal>

## Progress
- [x] <completed>
- [ ] **Now:** <currently in progress>
- [ ] <pending>

## Key Decisions
- <decision>: <why>

## Resume Prompt
We were working on **<task>** in `<project path>` on branch `<branch>`.
Progress: <one-sentence summary>.
Context: <key decisions in one sentence>.
Next: <specific next action>.
```

**Step 4 — Commit and push**
```
cd ~/.claude.checkpoints
git add <key>.md
git commit -m "checkpoint: <key> <YYYY-MM-DD HH:MM>"
git push
```
On push failure: print warning + the exact push command, do not block.

---

## Resume — automatic on session start

SessionStart hook copies the checkpoint to `RESUME.md` in the project root.
When `RESUME.md` is present at session start:

1. Read it immediately
2. Announce: "Resuming: **<task>**. Next: <next step>."
3. Proceed — no re-planning needed.

---

## Hook setup (managed by Unitial)

Copy scripts from this plugin to `~/.claude/scripts/`, then add to `~/.claude/settings.json`:

```json
"hooks": {
  "SessionStart": [{"matcher": "", "hooks": [{"type": "command", "command": "bash ~/.claude/scripts/checkpoint-session-start.sh"}]}],
  "UserPromptSubmit": [{"matcher": "", "hooks": [{"type": "command", "command": "bash ~/.claude/scripts/checkpoint-warn.sh"}]}]
}
```

Also add to `~/.gitignore_global`:
```
RESUME.md
```

And add to `~/.claude/CLAUDE.md`:
```
If the conversation is very long or the user mentions usage limits, proactively suggest running /checkpoint before continuing.
```
