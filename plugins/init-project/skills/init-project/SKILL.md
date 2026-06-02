---
name: init-project
description: Bootstrap Claude Code framework config for a new project. Generates a CLAUDE.md framework section and .claude/settings.json with standard harness. Use when starting a new project session and want to configure Claude Code settings interactively.
---

# Init Project

Interactive wizard that configures Claude Code framework for the current project. Asks questions in Traditional Chinese, writes all files in English.

---

## Process

### Step 1 — Gather project information

Ask the user (in Traditional Chinese):

> 讓我來幫你初始化這個專案的 Claude Code 設定。請回答幾個問題：
>
> 1. **專案名稱**是什麼？
> 2. **主要語言 / 技術 stack** 是什麼？（例如：Python、TypeScript/Node、C/C++、Infrastructure、文件/寫作、或其他）
> 3. **專案類型**？（例如：web service、CLI tool、ML/AI、library、infra automation、documentation...）

### Step 2 — Recommend Primary Skills

Based on the language/type, recommend a skill set from the table below and confirm with the user:

> 根據你的 stack，我推薦以下主力 Skills：
> （列出推薦的 skills）
> 是否要調整？

**Skill recommendation table:**

| Stack / Type | Primary Skills |
|---|---|
| Python (general) | `/tdd`, `/diagnose`, `/record-adr`, `/grill-me` |
| Python + ML/AI | `/tdd`, `/diagnose`, `/record-adr`, `/grill-me`, `/prototype` |
| TypeScript/Node | `/tdd`, `/diagnose`, `/record-adr`, `/commit-splitter` |
| C/C++ | `/diagnose`, `/record-adr`, `/grill-me`, `/caveman` |
| Infrastructure | `/record-adr`, `/grill-me`, `/zoom-out` |
| Documentation/Writing | `/to-prd`, `/to-issues`, `/zoom-out`, `/caveman` |
| General | `/record-adr`, `/grill-me`, `/diagnose` |

### Step 3 — Ask about MCP servers

Ask the user (in Traditional Chinese):

> 是否需要加入 MCP server？
> - `code-review-graph`：在每次 Edit/Write/Bash 後自動更新 code review graph（推薦給有 code quality 需求的專案）
> - 其他 MCP server（請說明名稱）
> - 不需要

### Step 4 — Check existing files

Before writing, check for existing files:
```
ls .claude/settings.json 2>/dev/null
cat CLAUDE.md 2>/dev/null
```

- If `CLAUDE.md` exists: append a `## Claude Code Framework` section at the end (do NOT overwrite)
- If `CLAUDE.md` does not exist: create it from scratch
- If `.claude/settings.json` exists: merge carefully (preserve existing hooks and permissions)
- If `.claude/settings.json` does not exist: create it from the standard template

### Step 5 — Generate files

#### 5a. CLAUDE.md framework section

Append (or create) the following section:

```markdown
## Claude Code Framework

### Primary Skills
- `/record-adr`  — after any design decision
- `/diagnose`    — before any bug fix
[list all confirmed skills with their trigger condition]

### Harness  (→ .claude/settings.json)
- SessionStart:     checkpoint-session-start.sh
[list other hooks present in .claude/settings.json]

### Engineering Rules
[Include only if project-specific rules are known; otherwise omit this section]
```

#### 5b. `.claude/settings.json` — standard template

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/scripts/checkpoint-session-start.sh"
          }
        ]
      }
    ]
  },
  "permissions": {
    "allow": []
  }
}
```

If the user opted in to `code-review-graph` MCP, merge in:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "code-review-graph update --silent || true"
          }
        ]
      }
    ]
  },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": ["code-review-graph"]
}
```

#### 5c. `.claude/settings.local.json`

Create an empty placeholder if it does not already exist:

```json
{}
```

Then inform the user:

> `.claude/settings.local.json` 已建立（空檔）。這裡存放 session-only permissions，例如暫時允許某個指令。此檔案應加入 `.gitignore`。

### Step 6 — Ensure .gitignore entries

Check `.gitignore` (or create it). Add if not already present:

```
.claude/settings.local.json
RESUME.md
```

### Step 7 — Summary

Print a summary (in Traditional Chinese) of all files created/modified:

> ✅ 初始化完成！以下是變動摘要：
>
> | 檔案 | 動作 |
> |------|------|
> | `CLAUDE.md` | 新增 `## Claude Code Framework` section |
> | `.claude/settings.json` | 建立（包含 SessionStart hook） |
> | `.claude/settings.local.json` | 建立（空白佔位檔） |
> | `.gitignore` | 加入 `.claude/settings.local.json`, `RESUME.md` |
>
> 建議的下一步：
> - 確認 `CLAUDE.md` 內容符合你的預期
> - 確認 `.claude/settings.json` 的 hooks 路徑正確（`~/.claude/scripts/` 必須存在）
> - 執行 `/checkpoint` 存一個初始 checkpoint

### Do NOT commit — leave files for user review

---

## Notes

- All generated file content is in English; interactive questions to the user are in Traditional Chinese.
- Session-only permissions (e.g. temporary `allow` rules) belong in `.claude/settings.local.json`, not `settings.json`.
- If the project already has a `CLAUDE.md` with a `## Claude Code Framework` section, update that section in place rather than appending a duplicate.
- The `settings.local.json` file must never be committed to version control.
