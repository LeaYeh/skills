# ADR-0002 — grill-graph: a decision-graph grilling skill

**Status:** Proposed
**Date:** 2026-06-05
**Related:** —

---

## Context

Matt Pocock's `grill-me` skill is effective at provoking thought through relentless key questions, but it is **linear**: a grilling session is a transcript. In practice key questions spawn counter-questions and branch the design, and decisions form a **graph**, not a line. `grill-me` does not record *why a branch was rejected*, cannot represent a counter-question that reaches *back* to an earlier decision, and has no notion of *re-assuming* a past decision and invalidating what was built on it.

The repo already has adjacent skills: `grill-me` (throwaway linear stress-test), `grill-with-docs` (domain-language alignment + sparse ADRs), `record-adr` (graduate a decision into an ADR), `architecture-diagram` (polished diagrams), and `to-prd` / `to-issues` (downstream). The goal is a heavyweight grilling skill that preserves decision **topology and evolution** and converges it into a spec, without re-implementing what these skills already do.

## Decision

Build a new skill, **`grill-graph`**, on top of `grill-me`'s grilling core, adding a persisted decision graph and a convergence step.

| Decision point | Option | Verdict | Reason |
|----------------|--------|---------|--------|
| What is a branch node? | Heavyweight ADR per branch | Rejected | ADRs are deliberately sparse; one-ADR-per-branch buries the signal and doubles bilingual cost |
| | **Lightweight node in a single `decision-graph.md`; ADR = graduated node** | **Adopted** | Dense cheap thinking-trace vs sparse durable decisions — each keeps its own philosophy |
| Node / edge semantics | Node = bare question | Rejected | A question carries no "why rejected" — and that reason is the whole point |
| | **Node = resolved decision (adopted + rejected options w/ reasons); edge = dependency carrying `assumed_option`** | **Adopted** | `assumed_option` is what lets re-assumption propagate precisely |
| Re-assumption handling | Manual flag only | Rejected | Contradictions still slip through — doesn't solve the pain |
| | **Auto stale-propagation along `assumed_option` edges → advisory revisit queue, batch-skippable** | **Adopted** | Surfaces invalidated premises without forcing rework; never silently swallows a contradiction |
| Topology source of truth | ADR `parent` links (original idea) | Rejected | Most nodes never graduate; the graph would break at non-graduated nodes |
| | **`decision-graph.md` is SSOT; ADR `Related:` is a sparse projection** | **Adopted** | Detail in the graph, durable decisions in ADRs, no drift |
| Visualization | Time-machine / replay | Rejected | Over-built; sequential ids + supersedes edges already convey evolution |
| | **Live embedded Mermaid (id = time axis, color = status, supersedes dashed); architecture-diagram for final panorama** | **Adopted** | Zero-build overview readable anywhere |
| Convergence output | grill-graph does PRD/issues itself | Rejected | Re-implements existing skills |
| | **Emit `spec.md` (⚠️ Unresolved Premises, not gated) → hand off to to-prd/to-issues** | **Adopted** | Composable; honours "stale is batch-skippable" |
| Packaging / name | Fork grill-with-docs; replace grill-me; name "grill-me-plus" | Rejected | Inherits unneeded glossary machinery; "plus" hides the soul (graph) |
| | **Standalone `grill-graph` on grill-me's core; coexists with grill-me / grill-with-docs** | **Adopted** | Name states the differentiator; clean separation of concerns |

## Alternatives Considered

Recording dead sibling subtrees (rejected option → its own abandoned subtree) was considered first-class, then de-prioritised: in practice rejected siblings rarely sprout subtrees. The real graph complexity is **back-references** (a new question attaching to an arbitrary earlier node) and **re-assumptions** (reopening a node and invalidating dependents) — the model centres on those.

## Consequences

**We gain:** decision evolution is preserved on disk; rejected branches and their reasons survive; reopening a decision auto-flags the downstream premises it invalidates; a live Mermaid overview; a clean three-stage chain `decision-graph.md → spec.md → to-prd/to-issues`.

**We sacrifice:** two artifact granularities to manage (lightweight nodes + graduated ADRs); a heavier session than plain `grill-me`; the skill must actively maintain a file mid-grilling, adding discipline overhead.

## Open Questions

1. How aggressively should the engine auto-detect a re-assumption vs wait for the user to declare "this reopens #N"?
2. Does `decision-graph.md` live at repo root or `docs/` by default when both conventions exist?

---

---

# ADR-0002 — grill-graph：決策圖拷問 skill

**狀態：** 提議中
**日期：** 2026-06-05
**相關：** —

---

## 背景

Matt Pocock 的 `grill-me` 擅長用連珠砲關鍵問題激發思考，但它是**線性**的：一場 session 就是一條逐字稿。實務上關鍵問題會岔出反問、讓設計分枝，決策其實是一張**圖**而非一條線。`grill-me` 不記錄*分枝為何被否決*、無法表現*回頭*接到早先決策的反問、也沒有*重新假設*某個過去決策並使其下游失效的概念。

倉庫已有相鄰 skill：`grill-me`（拋棄式線性壓力測試）、`grill-with-docs`（領域語言對齊＋稀疏 ADR）、`record-adr`（把決策升格成 ADR）、`architecture-diagram`（精美圖）、`to-prd`／`to-issues`（下游）。目標是做一個重型拷問 skill，保留決策**拓樸與演進**並收斂成 spec，且不重造這些既有 skill 的功能。

## 決策

新建 skill **`grill-graph`**，建在 `grill-me` 的拷問核心上，加上一張落地的決策圖與收斂步驟。

| 決策點 | 選項 | 結論 | 理由 |
|--------|------|------|------|
| 分枝節點是什麼 | 每分枝一份完整 ADR | 否決 | ADR 刻意稀疏；一分枝一 ADR 會淹沒訊號、bilingual 雙倍成本 |
| | **單一 `decision-graph.md` 的輕量節點；ADR = 畢業節點** | **採納** | 密集廉價的思考軌跡 vs 稀疏耐久的決策，各守哲學 |
| 節點／邊語意 | 節點 = 純問句 | 否決 | 問句沒有「為何否決」——而那正是重點 |
| | **節點 = 已解決決策（採納＋否決選項含理由）；邊 = 依賴，攜帶 `assumed_option`** | **採納** | `assumed_option` 是精準傳播重新假設的關鍵 |
| 重新假設處理 | 只手動標記 | 否決 | 矛盾仍會漏掉，沒解決痛點 |
| | **沿 `assumed_option` 邊自動標 stale → 提醒型待重審佇列、可批次跳過** | **採納** | 攤出失效前提但不強制返工；絕不靜默吞矛盾 |
| 拓樸真相來源 | ADR `parent` 連結（最初構想） | 否決 | 多數節點不畢業，圖會在未畢業節點處斷掉 |
| | **`decision-graph.md` 為 SSOT；ADR `Related:` 是稀疏投影** | **採納** | 細節在圖、耐久決策在 ADR、兩者不 drift |
| 視覺化 | 時光機／回放 | 否決 | 過度設計；編號順序＋supersedes 邊已能表現演進 |
| | **即時內嵌 Mermaid（編號=時間軸、顏色=狀態、supersedes 虛線）；定稿用 architecture-diagram** | **採納** | 零建置、任何地方都能讀的概覽 |
| 收斂產物 | grill-graph 自己做 PRD/issues | 否決 | 重造既有 skill |
| | **產 `spec.md`（⚠️未解決前提、不 gate）→ 交棒 to-prd/to-issues** | **採納** | 可組合；呼應「stale 可批次跳過」 |
| 打包／命名 | 分叉 grill-with-docs；取代 grill-me；命名 grill-me-plus | 否決 | 背上不需要的詞彙表機制；「plus」沒講出靈魂（圖） |
| | **獨立 `grill-graph` 建在 grill-me 核心上；與 grill-me／grill-with-docs 共存** | **採納** | 名字點出差異；關注點乾淨分離 |

## 備選方案

最初把「死兄弟子樹」（否決選項長出自己的廢棄子樹）當第一公民，後降級：實務上被否決的兄弟很少長子樹。真正的圖複雜度來自**回邊**（新問題接到任意早先節點）與**重新假設**（打開節點使下游失效）——模型以這兩者為核心。

## 後果

**獲得：** 決策演進落地保存；被否決分枝與理由得以存活；重新假設時自動標出被它波及的下游前提；即時 Mermaid 概覽；乾淨的三段鏈 `decision-graph.md → spec.md → to-prd/to-issues`。

**犧牲：** 要管兩種粒度（輕量節點＋畢業 ADR）；session 比純 `grill-me` 更重；skill 必須在拷問途中維護檔案，增加紀律負擔。

## 待釐清問題

1. 引擎該多積極地自動偵測「重新假設」，還是等使用者明說「這打開了 #N」？
2. 當 root 與 `docs/` 慣例並存時，`decision-graph.md` 預設落在哪？
