# ADR-0003 — Profile-Based Harness & Skill Enablement Model

**Status:** Accepted
**Date:** 2026-06-04 (updated 2026-06-05)
**Related:** ADR-0001 (Claude Code Framework Architecture) — this ADR supersedes ADR-0001's rejected alternative *"per-project skill enable/disable is unsupported"*.

---

## Context

A grill-me session began as "draft a `decision-record` skill" but exploration revealed:

- `record-adr` **already exists and is complete** (bilingual, numbered, indexed, CLAUDE.md-update step). The original task was based on a stale mental model.
- Two physical clones of the same repos exist: `~/skills` + `~/Unitial` (canonical, deployed, newer) and `mono_config/skills` + `mono_config/Unitial` (older working copies). Global config is split-brained: `~/.claude/CLAUDE.md` → `mono_config/Unitial`, `~/.claude/settings.json` → `~/skills`.
- The global `settings.json` enables **~18 plugins for every project**, contradicting the goal of lean, per-project skill sets and risking context bloat.
- Authoritative Claude Code facts (verified against docs): project `.claude/settings.json` can only **add** plugins (union merge), never **disable** a globally-enabled one; enabled skills inject their description into context every turn (body loads on demand); `disable-model-invocation: true` (SKILL.md frontmatter) keeps a manual skill's description out of context until invoked; there is **no native profile/bundle feature**.
- Daily work splits into four project types (Company / Learning / Personal / Personal-brand), each wanting a *different* harness.

## Decision

| # | Decision |
|---|----------|
| 1 | **No new `decision-record` skill.** `record-adr` already covers it; task closed as done. |
| 2 | **Canonical = `~/skills` + `~/Unitial`.** `mono_config/*` are working clones of the same repos, kept in sync via `git pull`. Symlink split-brain is harmless as long as clones stay git-synced. |
| 3 | **Enablement model = minimal global baseline + per-project additive opt-in.** Forced by union-merge semantics: to scope per project, global must be lean and projects only *add*. "3–5 per project" = "global baseline + 0–2 profile extras". |
| 4 | **Auto-trigger vs manual per skill**, decided by the test *"without a proactive nudge, would I miss the moment to use it?"* Yes → model-invocable (pays description cost). No → `disable-model-invocation: true` (~0 cost). |
| 5 | **Global set:** `grill-me`, `record-adr`, `to-prd`, `architecture-diagram` (manual, ~0); `diagnose` (model-invocable — the one exception); `checkpoint` (hook-driven); `commit-splitter` (manual skill + a PreToolUse commit-reminder **hook** that nudges, since splitting needs model judgment and cannot itself be a hook). |
| 6 | **record-adr proactivity via prose, not auto-trigger.** record-adr stays global+manual (~0); the "decision locked → suggest /record-adr" nudge lives in the **P1 project CLAUDE.md**, so it fires only where it matters at zero global cost. |
| 7 | **Four profiles** (additive on top of global). init enables only **existing** skills; unbuilt ones are TODO. |
| 8 | **No fork, no third repo.** Superpowers = install + layer (full trial in P1). Profile config lives in `Unitial`; `skills` = capabilities. |
| 9 | **init-project rewrite:** manual single-choice (1–4) → writes profile `enabledPlugins` + profile hooks + a `## Claude Code Framework` section in project CLAUDE.md carrying a `Profile: N` marker. No auto-detection. |
| 10 | **Provenance/dedup:** `mattpocock/skills` is a **plugin-type repo (no marketplace.json)**, so native marketplace live-sync is impossible. Direction chosen: move Matt Pocock skills to upstream and remove vendored duplicates from `leayeh-skills` — execution deferred (see Open Questions). `leayeh-skills` should shrink to Lea-original skills (`record-adr`, `init-project`, `checkpoint`, `commit-splitter`) plus any genuinely customized. |

### Profile blueprint

| Profile | Adds (existing) | Adds (TODO) | Hooks / CLAUDE.md |
|---------|-----------------|-------------|-------------------|
| **1 Company** | superpowers (full trial), `tdd`, `improve-codebase-architecture`, `grill-with-docs` | `spec-align` | tests-before-commit, ADR-check-before-PR; CLAUDE.md: "decision locked → suggest /record-adr" |
| **2 Learning** | — | `learning-mentor` | first-hand-source rule inside skill body |
| **3 Personal** | none (global only) | — | none |
| **4 Brand** | `zoom-out` | `voice-consistency`, `blog-integration` | optional markdown-lint; avoid official `frontend-design` |

## Alternatives Considered

| Option | Verdict | Reason |
|--------|---------|--------|
| Draft a new `decision-record` skill | Rejected | `record-adr` already exists and is complete |
| Treat `mono_config` as a consolidation monorepo | Rejected | It is just a Claude Code workspace folder; clones share one remote |
| Keep all ~18 skills enabled globally | Rejected | Context bloat; every project pays for every description |
| Per-project *disable* of globally-enabled skills | Rejected | Claude Code merges `enabledPlugins` additively; no subtractive override |
| Fork Superpowers / create a third repo for harness | Rejected | Merge hell on a fast upstream; install+layer is the supported pattern; profiles are config, they belong in `Unitial` |
| Make global skills model-invocable for proactivity | Rejected | Pays description cost in every project, including Personal/Learning |
| Live-sync Matt Pocock skills via marketplace | Not possible | `mattpocock/skills` is plugin-type (no marketplace.json) |

## Consequences

**We gain:**
- Lean global context (only `diagnose` description + hooks always loaded); per-project skill sets scoped by profile.
- A blueprint that works today even where profile skills are unbuilt (graceful TODO).
- Single capability source per skill once dedup lands; the duplication ADR-0001 flagged is finally addressed.
- Proactive nudges exactly where they matter (P1) at zero global cost.

**We sacrifice:**
- Every project needs `/init-project` (or a hand-edit) to gain profile extras; baseline-only otherwise.
- Skills referenced from upstream cannot carry local customizations (e.g. `disable-model-invocation`); those few must stay vendored.
- Discipline required to keep the multiple clones git-synced.

## Open Questions

1. **Matt Pocock upstream sync — RESOLVED: B-1.** Install `mattpocock/skills` as a single multi-skill plugin via `claude plugin install`, let CC manage updates, delete the vendored copies from `leayeh-skills`. **Caveat to settle at execution:** `mattpocock/skills` is one plugin bundling *all* his skills (single root `plugin.json`) — install is all-or-nothing, model-invocable, with no per-skill `disable-model-invocation`. This collides with keeping `grill-me`/`to-prd` manual-only: either (a) accept those two as model-invocable from upstream (lose the ~0-cost flag), or (b) keep just those two vendored and do **not** enable their upstream duplicates. **Chosen: (a)** — accept the upstream bundle's skills as model-invocable; do not keep any Matt Pocock skill vendored. (Lea-original `record-adr`/`commit-splitter` and Cocoon `architecture-diagram` already carry `disable-model-invocation: true` and stay vendored.)
2. **`diagnose` global model-invocable** — confirmed as the single exception? (assumed yes)
3. **Landing sequence** of the change list below; remove the dangling `mattpocock-skills` registration from `known_marketplaces.json` regardless of path chosen.

### Landing checklist (deferred to fresh context)

1. Slim global `~/skills/settings.json` enabledPlugins → the 7 global items.
2. ~~Add `disable-model-invocation: true`~~ — **DONE** for `record-adr`, `commit-splitter`, `architecture-diagram` (the vendored-for-keeps set). `grill-me`/`to-prd` excluded: under B-1 (a) they come from the upstream bundle (model-invocable), not vendored.
3. Add commit-reminder hook to global settings.json.
4. Adjust the in-progress CLAUDE.md edit: record-adr = global available (manual); move the proactive nudge into the P1 template.
5. Define the four profile templates (enabledPlugins + hooks + CLAUDE.md).
6. Rewrite `init-project` per decision #9.
7. Resolve Open Question #1 (Matt Pocock upstream) and dedup `leayeh-skills`.
8. `git pull` to sync the `mono_config` clones.

---

---

# ADR-0003 — 以 Profile 為基礎的 Harness 與 Skill 啟用模型

**狀態：** 已採納
**日期：** 2026-06-04（更新於 2026-06-05）
**相關：** ADR-0001（Claude Code 框架架構）— 本 ADR 推翻 ADR-0001 中被否決的備選方案「不支援專案級 skill 啟用/停用」。

---

## 背景

一場 grill-me 原本要「draft 一個 `decision-record` skill」，但探索後發現：

- `record-adr` **早已存在且完整**（雙語、編號、索引、含 CLAUDE.md 更新步驟）。原任務建立在過時的認知上。
- 同一組 repo 有兩份實體 clone：`~/skills` + `~/Unitial`（正版、部署中、較新）與 `mono_config/skills` + `mono_config/Unitial`（較舊的工作副本）。全域設定腦裂：`~/.claude/CLAUDE.md` → `mono_config/Unitial`、`~/.claude/settings.json` → `~/skills`。
- 全域 `settings.json` 為**每個專案啟用約 18 個 plugin**，與「精簡、按專案」的目標相違，且有 context bloat 風險。
- 已查證的 Claude Code 事實：專案 `.claude/settings.json` 只能 **加** plugin（union 合併），不能停用全域已啟用者；啟用的 skill 其 description 每回合常駐 context（body 才 on-demand）；`disable-model-invocation: true`（SKILL.md frontmatter）可讓手動 skill 在被呼叫前不佔 context；**無原生 profile/bundle 功能**。
- 日常工作分四類（公司／學習／個人／個人品牌），各要不同的 harness。

## 決策

| # | 決策 |
|---|------|
| 1 | **不做新的 `decision-record` skill。** `record-adr` 已涵蓋，任務結案。 |
| 2 | **正版 = `~/skills` + `~/Unitial`。** `mono_config/*` 是同 repo 的工作 clone，用 `git pull` 同步。只要各 clone git 同步，symlink 腦裂無害。 |
| 3 | **啟用模型 = 極簡全域 baseline + 專案層加法 opt-in。** 受 union 語意所迫：要按專案限縮，全域必須精簡、專案只能加。「每專案 3–5」=「全域 baseline + 0~2 profile 專屬」。 |
| 4 | **逐 skill 決定可觸發 vs 純手動**，依「沒有主動提醒，我會不會漏掉該用它的時機？」會 → 可被模型觸發（付 description 成本）；不會 → `disable-model-invocation: true`（~0 成本）。 |
| 5 | **全域清單：** `grill-me`、`record-adr`、`to-prd`、`architecture-diagram`（手動、~0）；`diagnose`（可觸發 — 唯一例外）；`checkpoint`（hook 驅動）；`commit-splitter`（手動 skill + 一個 PreToolUse commit 提醒 **hook**：切 commit 需要模型判斷、本身不能是 hook，故由 hook 催、skill 切）。 |
| 6 | **record-adr 的主動性用 prose、非 auto-trigger。** record-adr 維持全域+手動（~0）；「決策拍板 → 建議 /record-adr」寫進 **P1 專案 CLAUDE.md**，只在需要處觸發、全域零成本。 |
| 7 | **四個 profile**（疊加在全域之上）。init 只啟用**已存在**的 skill；待建者列 TODO。 |
| 8 | **不 fork、不開第三個 repo。** Superpowers = install + layer（P1 整包試用）。profile 設定放 `Unitial`；`skills` = 能力。 |
| 9 | **init-project 重寫：** 手動單選（1–4）→ 寫入 profile `enabledPlugins` + profile hooks + 專案 CLAUDE.md 的 `## Claude Code Framework` section（含 `Profile: N` 標記）。不自動偵測。 |
| 10 | **來源／去重：** `mattpocock/skills` 是 **plugin-type repo（無 marketplace.json）**，原生 marketplace 即時同步辦不到。方向：改用上游、從 `leayeh-skills` 移除 vendored 重複 — 執行延後（見 Open Questions）。`leayeh-skills` 應縮成 Lea 原創（`record-adr`、`init-project`、`checkpoint`、`commit-splitter`）加少數真正客製者。 |

### Profile 藍圖

| Profile | 加（已存在） | 加（待建） | Hooks / CLAUDE.md |
|---------|--------------|------------|-------------------|
| **1 公司** | superpowers（整包試用）、`tdd`、`improve-codebase-architecture`、`grill-with-docs` | `spec-align` | tests-before-commit、ADR-check-before-PR；CLAUDE.md：「決策拍板 → 建議 /record-adr」 |
| **2 學習** | — | `learning-mentor` | 無重 hook；first-hand-source 守則寫進 skill body |
| **3 個人** | 無（只用全域） | — | 無 |
| **4 品牌** | `zoom-out` | `voice-consistency`、`blog-integration` | 選用 markdown-lint；避免官方 `frontend-design` |

## 備選方案

| 選項 | 結論 | 原因 |
|------|------|------|
| 另寫一個 `decision-record` skill | 拒絕 | `record-adr` 已存在且完整 |
| 把 `mono_config` 當合併 monorepo | 拒絕 | 它只是工作目錄；clone 共用同一 remote |
| 維持 18 個 skill 全域啟用 | 拒絕 | context bloat；每個專案都為每段 description 付費 |
| 專案層「停用」全域已啟用的 skill | 拒絕 | CC 對 `enabledPlugins` 是加法合併，無覆蓋停用 |
| Fork Superpowers／開第三個 repo | 拒絕 | 高速上游的 merge 地獄；install+layer 才是官方模式；profile 是設定、屬於 `Unitial` |
| 把全域 skill 設成可觸發以求主動性 | 拒絕 | 每個專案（含個人／學習）都付 description 成本 |
| 透過 marketplace 即時同步 Matt Pocock skill | 不可行 | `mattpocock/skills` 是 plugin-type（無 marketplace.json）|

## 後果

**獲得：**
- 全域 context 精簡（常駐只剩 `diagnose` description + hooks）；各專案 skill 由 profile 限縮。
- 一張即使部分 profile skill 未建也能用的藍圖（優雅 TODO）。
- 去重落地後每個 skill 單一能力來源；ADR-0001 指出的重複終獲處理。
- 主動提醒精準出現在需要處（P1），全域零成本。

**犧牲：**
- 每個專案需 `/init-project`（或手改）才有 profile 專屬；否則只有 baseline。
- 引用自上游的 skill 無法帶本地客製（如 `disable-model-invocation`）；少數需保留 vendored。
- 需紀律維持多個 clone 的 git 同步。

## Open Questions

1. **Matt Pocock 上游同步 —— 已定案：B-1。** 把 `mattpocock/skills` 當單一多-skill plugin 以 `claude plugin install` 安裝、交給 CC 更新、刪掉 `leayeh-skills` 的 vendored 版。**執行時要解的細節：** `mattpocock/skills` 是把*所有* skill 打包成一個 plugin（單一 root `plugin.json`）—— 安裝是全有全無、可被模型觸發、無法逐 skill 設 `disable-model-invocation`。這跟「`grill-me`/`to-prd` 維持純手動」衝突：要嘛 (a) 接受這兩個從上游來、變可觸發（失去 ~0 成本旗標），要嘛 (b) 只把這兩個留 vendored、且**不**啟用它們的上游重複版。**已選 (a)** —— 接受上游 bundle 的 skill 為可觸發；不保留任何 Matt Pocock vendored 版。（Lea 原創 `record-adr`/`commit-splitter` 與 Cocoon `architecture-diagram` 已加 `disable-model-invocation: true`、維持 vendored。）
2. **`diagnose` 全域可觸發** —— 確認為唯一例外？（暫定 yes）
3. **落地順序**；無論走哪條路，都先把 `known_marketplaces.json` 裡那筆懸空的 `mattpocock-skills` 登記移除。

### 落地清單（延後到 fresh context）

1. 瘦身全域 `~/skills/settings.json` enabledPlugins → 7 個全域項目。
2. ~~加 `disable-model-invocation: true`~~ —— **已完成** `record-adr`、`commit-splitter`、`architecture-diagram`（確定留 vendored 的）。`grill-me`/`to-prd` 排除：B-1 (a) 下它們來自上游 bundle（可觸發）、非 vendored。
3. 全域 settings.json 加 commit 提醒 hook。
4. 調整進行中的 CLAUDE.md 編輯：record-adr = 全域可用（手動）；主動提醒移進 P1 模板。
5. 定義四個 profile 模板（enabledPlugins + hooks + CLAUDE.md）。
6. 依決策 #9 重寫 `init-project`。
7. 解決 Open Question #1（Matt Pocock 上游）並對 `leayeh-skills` 去重。
8. `git pull` 同步 `mono_config` 兩個 clone。
