---
name: commit-splitter
disable-model-invocation: true
description: Scan all staged/unstaged changes, combine with session context and plan, generate an ordered conventional-commit plan within a token budget. Use when the user says "split commits", "commit plan", wants to organize changes into separate commits before a PR, asks how to structure pending work into git history, or mentions staging files with multiple logical changes.
---

Scan all pending changes and produce a best-practice commit plan. Do NOT execute any git write operation until the user confirms.

---

## Phase 0 — Load Claude Records

**0-A  Session context** (free — no commands needed)
Review this conversation and extract:
- `task_type`: feat | fix | refactor | chore | mixed
- `explicit_groupings`: files the user said should go together
- `explicit_exclusions`: files the user said to skip
- `notes`: any commit message hints from the conversation

**0-B  Plan file** (run, then read first hit)
```
ls plans/*.md plan.md PLAN.md 2>/dev/null | head -3
```
Extract: tasks just checked off as `[x]` (completed this session), their descriptions (commit subject candidates), their phase/milestone.

**0-C  Dev-log** (run, then read latest 1-2 files)
```
ls dev-log/*.md 2>/dev/null | sort | tail -2
```
Extract: what was done this session; anything marked "unfinished / continue next time" -> tag as SKIP.

---

## Phase 1 — Discover Changes (no diff reads)

Run all of these:
```
git diff --stat HEAD
git diff --name-status HEAD
git diff --cached --name-status
git ls-files --others --exclude-standard
git status --short
```

Build `change_inventory`: modified (M), added (A + untracked), deleted (D), renamed (R), staged, total_files.

**If total_files == 0**: output "No changes to commit" and stop.

**If CWD is workspace root and no changes found there**: prompt user to `cd <repo>` then re-invoke.

---

## Phase 2 — Infer Project Structure

Run in order; stop reading a source once you have enough for a scope_map:
```
grep -A 20 -i "layer\|architecture\|structure\|scope\|module" CLAUDE.md 2>/dev/null | head -60
grep -A 30 "\[tool.setuptools\]\|\[packages\]" pyproject.toml setup.cfg 2>/dev/null | head -40
ls src/ app/ 2>/dev/null
```

Build `scope_map`: path-prefix -> scope name. CLAUDE.md wins. Fallback: top-level directory name. Final fallback: "misc".

---

## Phase 3 — Classify & Group

For each changed file:
1. Match against `scope_map` (first hit wins) -> assign scope
2. Apply `session_intent`:
   - explicit_groupings -> override path classification
   - explicit_exclusions -> mark SKIP
3. Determine type using this priority table (no diff needed):

| Priority | Condition | Type |
|---|---|---|
| 1 | scope == test | test |
| 2 | scope in {config, scripts, ci} | chore |
| 3 | scope == docs | docs |
| 4 | task_type != mixed | inherit task_type |
| 5 | plan task contains fix/bug/error/correct | fix |
| 6 | plan task contains refactor/clean/restructure | refactor |
| 7 | all files in group are newly added | feat |
| 8 | none of the above | **AMBIGUOUS -> Phase 4** |

---

## Phase 4 — Selective Diff Read (token-budgeted)

Only for AMBIGUOUS groups. Budget: 6000 tokens total (~24 000 chars), 1500 tokens per file. Read smallest files first.

```
git diff --unified=0 HEAD -- <filepath>
```

Type rules from diff content:

| Diff pattern | Type |
|---|---|
| New function/class definition added | feat |
| Function signature changed | feat or refactor |
| Function body changed, signature unchanged | fix or refactor |
| Only deletions | refactor or fix |
| Only whitespace / formatting / import order | refactor |
| Error handling or guard clause added | fix |
| Logger or comment change only | chore |

Still ambiguous after reading -> type = feat, mark `[type?]`.

Budget exhausted -> remaining AMBIGUOUS -> feat `[unread]`. Add footer warning:
`WARNING: N files not read (budget exhausted); type defaulted to feat, please verify`

---

## Phase 5 — Coupling Detection

Auto-merge groups that must be committed together:

**5-A  Path symmetry** — filename identical except scope segment:
```
orchestrator/calibrate_bias_command.py
executor/calibrate_bias_executor.py   -> merge, mark (coupled)
```

**5-B  Import relationship** — check if file A imports file B:
```
grep -l "from.*<basename_B>\|import.*<basename_B>" <file_A>
```
If A imports B and both are in different groups -> merge.

**5-C  Same plan task** — files from different scopes tied to the same plan task -> merge.

Tests stay independent (Phase 5-B rule does not merge tests); sort tests after their implementation commit.

Merged scope naming: orchestrator+executor -> executor; ui+controller -> controller; 3+ layers -> core (coupled).

---

## Phase 6 — Best Practice Validation

**Minimal** — warn if: group > 8 files, OR group has both obvious feat and fix changes.
Mark: `WARNING: consider splitting further`

**Independent** — if group B's files import group A's changed files, A must come first.
Show dependency order. Circular dependency -> `WARNING: circular dependency, manual resolution required`

**Rollbackable** — warn if: interface changed in one group but implementation is in a separate uncommitted group; or migration without model in same group.
Mark: `WARNING: rolling back this commit may break others; consider merging`

---

## Phase 7 — Generate Plan (display only, no git writes)

Output format:
```
==================================================
Commit plan  N commits  |  source: session + plan + diff
==================================================

[1] fix(executor): correct operator precedence in iteration filter
    Type basis: session(fix) + plan task "fix filter bug"
    Files:
      . src/executor/auto_sample.py
    ok: minimal  ok: independent  ok: rollbackable

[2] feat(executor): add calibrate_bias handler  (coupled)
    Type basis: diff(new function) + plan task "implement CalibrateBias"
    Files:
      . src/orchestrator/commands/calibrate_bias.py  <- coupled
      . src/executor/openspm_executor.py
    ok: minimal  ok: independent  WARNING: rollbackable - depends on [3]

[3] feat(controller): expose calibrate_bias in sampling workflow
    Type basis: session(feat)
    Files:
      . src/controller/auto_sample_controller.py
    depends on: [2] must commit first

==================================================
N warnings require attention

After review, type a command to proceed:
  exec 1 3 4        -> execute only those commits
  merge 2 3         -> merge into one commit, regenerate plan
  split 2           -> prompt git add -p, pause
  skip 5            -> remove from plan
  retype 5 chore    -> change type, regenerate message
==================================================
```

---

## Phase 8 — Confirm & Execute

Wait for user input. Accepted commands: exec, merge, split, skip, retype.

For each commit in the confirmed plan, in order:
```
git add -- <files in group>
git commit -m "<type>(<scope>): <subject>"
```

Print hash after each success. On failure: stop immediately, do not continue.

Final summary:
```
==================================================
Done  N/N commits
abc1234  fix(executor): ...
def5678  feat(executor): ...  (coupled)
==================================================
```

---

## Commit Message Rules

- Format: `<type>(<scope>): <subject>`
- Types: feat fix refactor test chore docs perf ci
- scope: from scope_map only — never invent a scope
- subject source priority: plan task description > session context > filename inference
- subject: lowercase, no period, <= 72 chars
- (coupled) annotation goes after subject, not in type/scope

---

## Hard Constraints (never violate)

- Never run `git add .` or `git add -A`
- Never stage untracked files automatically
- Never read more diff than the budget allows
- Never execute any git write before user confirmation
- Never invent a scope not in scope_map
- Never force-split a grouping the user explicitly asked to keep together
