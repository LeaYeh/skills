# ADR-0001 — Claude Code Framework Architecture

**Status:** Accepted
**Date:** 2026-06-02
**Related:** —

---

## Context

A grill-me session surfaced that skills, harness, and workflow rules were
scattered across multiple repos without a coherent ownership model. Duplicate
skill registrations caused the skill registry to show each skill 2–3 times,
and different projects had inconsistent or missing Claude Code configuration.

## Decision

Adopt a three-layer framework where each layer owns distinct concerns:

| Layer | Location | Owns |
|-------|----------|------|
| Global | `~/.claude/settings.json`, `~/.claude/CLAUDE.md` | Skill marketplace, global hooks (checkpoint), behavior preferences |
| Project | `.claude/settings.json`, `CLAUDE.md` | Project-specific hooks, MCP servers, primary skills declaration, engineering rules |
| Session | `.claude/settings.local.json` | Temporary allow rules (never committed) |

**Key rules adopted:**

| Decision | Rule |
|---|---|
| Skill source | Marketplace only (`@leayeh-skills`). Never populate `~/.claude/skills/` via copy loop. |
| Hook vs Skill | Needs language understanding → Skill; shell-only, no judgment → Hook |
| Allow list | Permanent permissions → `settings.json` (tracked); session-only → `settings.local.json` (periodic cleanup) |
| CLAUDE.md updates | Triggered by `/record-adr` completion — skill diffs CLAUDE.md and proposes additions |
| New project setup | `/init-project` skill bootstraps CLAUDE.md framework section + `.claude/settings.json` |

**Project CLAUDE.md must contain `## Claude Code Framework` section** declaring:
- Primary Skills (which skills are most relevant for this project type)
- Harness (mirror of `.claude/settings.json` hooks, human-readable)
- Engineering Rules (project-specific constraints)

## Alternatives Considered

| Option | Verdict | Reason |
|--------|---------|--------|
| Per-project skill enable/disable in settings.json | Rejected | Claude Code does not support project-scoped skill toggling today |
| Separate skills repo per project | Rejected | Maintenance overhead; global marketplace is sufficient |
| Harness only in settings.json (no CLAUDE.md mirror) | Rejected | Machine-readable only; Claude cannot reason about it at session start |

## Consequences

**We gain:**
- Single source of truth per layer; no duplication
- Claude reads the framework section at session start and knows which skills to suggest proactively
- New projects bootstrapped consistently via `/init-project`
- CLAUDE.md stays in sync with ADRs automatically

**We sacrifice:**
- Manual effort to add `## Claude Code Framework` section to existing projects
- settings.local.json requires periodic cleanup discipline

---

---

# ADR-0001 — Claude Code 框架架構

**狀態：** 已採納
**日期：** 2026-06-02
**相關：** —

---

## 背景

一次 grill-me 訪談發現 skills、harness、workflow 規則散落在多個 repo，缺乏一致的所有權模型。Skill 重複註冊導致每個 skill 出現 2–3 次，不同專案的 Claude Code 配置也不一致或缺失。

## 決策

採用三層框架，每層負責明確的關注點：

| 層級 | 位置 | 負責 |
|------|------|------|
| 全域 | `~/.claude/settings.json`, `~/.claude/CLAUDE.md` | Skill marketplace、全域 hooks（checkpoint）、行為偏好 |
| 專案 | `.claude/settings.json`, `CLAUDE.md` | 專案 hooks、MCP servers、主力 skill 宣告、工程規則 |
| Session | `.claude/settings.local.json` | 暫時 allow rules（不 commit）|

**專案 CLAUDE.md 必須包含 `## Claude Code Framework` section**，宣告：
- Primary Skills（此專案最相關的 skills）
- Harness（`.claude/settings.json` hooks 的人可讀鏡像）
- Engineering Rules（專案特定約束）

## 備選方案

| 選項 | 結論 | 原因 |
|------|------|------|
| 每個專案各自啟用/停用 skill | 拒絕 | Claude Code 目前不支援專案級 skill 切換 |
| 每個專案各自維護 skills repo | 拒絕 | 維護成本高；全域 marketplace 已足夠 |
| Harness 只放 settings.json | 拒絕 | 只有機器可讀；Claude 在 session 開始無法推理 |

## 後果

**獲得：**
- 每層單一事實來源，無重複
- Claude 在 session 開始讀取 framework section，知道主動建議哪些 skill
- 新專案透過 `/init-project` 一致性初始化
- CLAUDE.md 自動跟 ADR 保持同步

**犧牲：**
- 現有專案需要手動補充 `## Claude Code Framework` section
- settings.local.json 需要定期清理的紀律
