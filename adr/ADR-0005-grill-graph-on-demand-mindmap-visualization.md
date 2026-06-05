# ADR-0005 — grill-graph visualization: on-demand bilingual HTML mindmap

**Status:** Accepted
**Date:** 2026-06-05
**Related:** [ADR-0002](ADR-0002-grill-graph-decision-graph-skill.md) (supersedes its *Visualization* decision)

---

## Context

ADR-0002 chose a **live embedded Mermaid `graph TD`**, refreshed every turn, as grill-graph's overview. In practice this failed: once the decision graph grew past a handful of nodes with cross-edges (back-references, `feeds`, `supersedes`, failure routes), Mermaid's auto-layout produced unreadable spaghetti — crossing edges, cramped long labels, no layout control. The user's verdict: *"用 mermaid 產生的決策圖完全無法閱讀"*.

Two further forces shaped the fix. (1) Re-rendering any rich diagram **every turn** is expensive and, for hand-placed SVG, error-prone. (2) The repo already has the `architecture-diagram` skill — a polished dark-theme self-contained HTML+SVG design system — but it is semantically about system topology (frontend/backend/db colour palette), carries `disable-model-invocation: true`, and is the wrong vocabulary for decision nodes (adopted / rejected / stale / graduated).

The pain is located **during grilling** (re-orienting mid-session), not only in the final artifact.

## Decision

Replace the live Mermaid with an **on-demand, data-driven, bilingual HTML mindmap**, and keep structured Markdown as the only live artifact. Two templates are bundled under `plugins/grill-graph/skills/grill-graph/resources/`.

| Decision point | Option | Verdict | Reason |
|----------------|--------|---------|--------|
| Representation | Pure mindmap (tree) | Rejected | A tree cannot draw the cross-edges (back-ref, `feeds`, `supersedes`, failure) — which are grill-graph's entire reason to exist over grill-me |
| | **Hybrid: mindmap backbone (single-parent `dependsOn` tree) + DAG cross-edges as a coloured overlay** | **Adopted** | Restores readability without sacrificing DAG semantics |
| Live vs on-demand | Re-render the visual every turn | Rejected | Hand-placed SVG per turn is token-expensive and error-prone; the live Mermaid it replaces was the unreadable thing |
| | **Live SSOT = structured Markdown; visual rendered on demand ("show the graph") + once at convergence** | **Adopted** | Markdown is already readable and cheap to keep live; the visual is pull-based, summonable when the user is lost mid-session |
| Template scope | Only an HTML template | Rejected | If Markdown is the SSOT the renderer parses, its schema must be fixed and machine-parseable too |
| | **Two bundled templates: `node-template.md` (Markdown node schema) + `mindmap-template.html` (visual)** | **Adopted** | Markdown ↔ JSON stay mechanically convertible; both formats sediment a fixed shape |
| Reuse vs fork | Invoke the `architecture-diagram` skill at convergence | Rejected | Wrong semantics (system topology, not decisions); `disable-model-invocation`; needs its own status colour vocabulary |
| | **Fork its design system (dark theme, JetBrains Mono, self-contained, export toolbar); grill-graph owns the decision-semantics encoding** | **Adopted** | Borrow the "skin", own the "bones"; no external-skill dependency |
| Renderer nature | Hand-author SVG coordinates each render | Rejected | Recurring per-render cost; manual coordinates are the original spaghetti cause |
| | **Data-driven renderer: per session inject only a `GRAPH` JSON block; JS does L→R layered-tree auto-layout** | **Adopted** | On-demand render becomes near-free; auto-layout is consistent; JSON schema mirrors `node-template.md` |
| Node detail density | Show rejected options on the diagram face | Rejected | Rejection reasons are long — putting them on the face recreates the spaghetti |
| | **Face shows `#id` + question + ✅ adopted only; hover expands rejected options + premise (HTML tooltip)** | **Adopted** | Clean diagram; full reasons read on hover or in the Markdown SSOT |
| Edge occlusion | Route overlay edges across the canvas | Rejected | Lines were occluded by opaque node boxes and labels were clipped |
| | **Backbone in column gaps; overlay edges routed through a right-side gutter with bordered labels** | **Adopted** | No line is covered by a node; cross-edges stay legible |
| Language | English only (per global default) | Rejected | The user reads the graph during grilling in zh-TW; the decision graph is discussion content, not code |
| | **Bilingual: English canonical + optional `*_zh` parallel layer rendered beneath each line** | **Adopted** | Readable for a zh-TW reader while keeping English as the canonical record |

## Alternatives Considered

A **Mermaid `mindmap`** (auto-layout tree) was considered as a lighter fix than HTML/SVG, but it is still a pure tree — it would drop the cross-edges, collapsing grill-graph back into grill-me. An **auto-refreshed but auto-laid-out** live visual (regenerate the data-driven HTML every turn) was rejected on cost: the Markdown SSOT already serves the live-reading need, so the visual is pull-based instead.

## Consequences

**We gain:** a readable decision panorama (LTR layered tree + gutter-routed coloured cross-edges); a clean diagram face with hover-to-expand detail; bilingual nodes; near-zero-cost on-demand rendering (inject one JSON block); a self-contained artifact with PNG/PDF export; no dependency on the architecture-diagram skill. Verified by headless Chrome render of the sample graph.

**We sacrifice:** there is no longer an always-current visual — the user must ask for it (mitigated: Markdown is the live read surface); the bundled `mindmap-template.html` carries a one-time JS auto-layout implementation to maintain; overlay edges originating from the rightmost column can, in rare row alignments, pass near a node in the gutter return path (acceptable, not occluding in practice).

## Open Questions

1. Should the on-demand render auto-trigger on every re-assumption (stale propagation), or stay strictly pull-based?
2. For very wide graphs (many siblings in one layer), does the LTR layered tree need vertical paging or a zoom affordance?

---

---

# ADR-0005 — grill-graph 視覺化：即時生成的雙語 HTML 心智圖

**狀態：** 已接受
**日期：** 2026-06-05
**相關：** [ADR-0002](ADR-0002-grill-graph-decision-graph-skill.md)（取代其*視覺化*決策）

---

## 背景

ADR-0002 選了**即時內嵌、每回合刷新的 Mermaid `graph TD`** 當 grill-graph 的概覽。實務上失敗了：一旦決策圖長到有數個交叉邊（回邊、`feeds`、`supersedes`、失敗回流），Mermaid 自動排版就變成讀不懂的義大利麵——交叉的邊、擠成一團的長標籤、毫無排版控制權。使用者的判決：*「用 mermaid 產生的決策圖完全無法閱讀」*。

另有兩股力量形塑了解法。(1)**每回合**重畫任何精緻圖都很貴，手刻 SVG 還容易出錯。(2)倉庫已有 `architecture-diagram`——精美深色、自包含 HTML+SVG 的設計系統——但它語意是系統拓樸（frontend/backend/db 色票）、標了 `disable-model-invocation: true`、且對決策節點（採納／否決／stale／畢業）是錯的詞彙。

痛點落在**拷問進行中**（中途回看脈絡），不只在最終產物。

## 決策

用**即時生成、資料驅動、雙語的 HTML 心智圖**取代 live Mermaid，並讓結構化 Markdown 成為唯一的 live 產物。兩個模板 bundle 在 `plugins/grill-graph/skills/grill-graph/resources/`。

| 決策點 | 選項 | 結論 | 理由 |
|--------|------|------|------|
| 呈現方式 | 純心智圖（樹） | 否決 | 樹畫不出交叉邊（回邊、`feeds`、`supersedes`、失敗）——而那正是 grill-graph 勝過 grill-me 的全部理由 |
| | **混血：心智圖主幹（單父 `dependsOn` 樹）＋ DAG 交叉邊作彩色疊層** | **採納** | 救回可讀性又不犧牲 DAG 語意 |
| Live vs 即時生成 | 每回合重畫視覺圖 | 否決 | 每回合手刻 SVG 既貴又易錯；它要取代的 live Mermaid 正是讀不懂的元凶 |
| | **live SSOT＝結構化 Markdown；視覺圖按需生成（喊「看圖」）＋收斂時一次** | **採納** | Markdown 本就好讀且維護 live 便宜；視覺圖改拉取式、中途迷路時隨喊隨有 |
| 模板範圍 | 只做 HTML 模板 | 否決 | 若 Markdown 是 renderer 解析的 SSOT，它的 schema 也必須訂死、可機器解析 |
| | **兩個 bundled 模板：`node-template.md`（Markdown 節點 schema）＋ `mindmap-template.html`（視覺）** | **採納** | Markdown ↔ JSON 可機械互轉；兩種格式都沈澱出固定形狀 |
| 復用 vs 分叉 | 收斂時 invoke `architecture-diagram` | 否決 | 語意錯（系統拓樸非決策）；`disable-model-invocation`；需要自己的狀態色票 |
| | **分叉其設計系統（深色、JetBrains Mono、自包含、export toolbar）；grill-graph 自有決策語意編碼** | **採納** | 借「皮」、自有「骨」；不依賴外部 skill |
| Renderer 本質 | 每次手刻 SVG 座標 | 否決 | 每次渲染的重複成本；手算座標正是義大利麵的根因 |
| | **資料驅動 renderer：每場只注入一塊 `GRAPH` JSON；JS 做 L→R 分層樹自動排版** | **採納** | 按需渲染近乎零成本；自動排版一致；JSON schema 對應 `node-template.md` |
| 節點細節密度 | 圖面顯示否決選項 | 否決 | 否決理由很長，塞上圖面就回到義大利麵 |
| | **圖面只顯示 `#id`＋問題＋✅採納；hover 展開否決選項＋前提（HTML tooltip）** | **採納** | 圖乾淨；完整理由在 hover 或 Markdown SSOT 讀 |
| 邊遮蓋 | 疊層邊橫越畫布 | 否決 | 線被不透明節點蓋住、標籤被裁切 |
| | **主幹走欄間 gap；疊層邊走右側 gutter、標籤加描邊** | **採納** | 沒有線被節點蓋住；交叉邊保持可讀 |
| 語言 | 只用英文（全域預設） | 否決 | 使用者拷問途中以 zh-TW 讀圖；決策圖是討論內容非程式碼 |
| | **雙語：英文為正本＋可選 `*_zh` 平行層渲染於每行下方** | **採納** | 對 zh-TW 讀者好讀，同時保留英文為正本記錄 |

## 備選方案

曾考慮 **Mermaid `mindmap`**（自動排版的樹）作為比 HTML/SVG 更輕的解，但它仍是純樹——會丟掉交叉邊，使 grill-graph 退化回 grill-me。也考慮過**自動刷新但自動排版**的 live 視覺（每回合重生資料驅動 HTML），因成本否決：Markdown SSOT 已滿足 live 閱讀需求，故視覺改為拉取式。

## 後果

**獲得：** 可讀的決策全景（LTR 分層樹＋走 gutter 的彩色交叉邊）；乾淨圖面＋hover 展開細節；雙語節點；近乎零成本的按需渲染（注入一塊 JSON）；自包含、可 PNG/PDF 匯出；不依賴 architecture-diagram skill。已用 headless Chrome 渲染範例圖驗證。

**犧牲：** 不再有永遠最新的視覺圖——使用者得主動要（緩解：Markdown 是 live 閱讀面）；bundled `mindmap-template.html` 多了一段一次性 JS 自動排版要維護；源自最右欄的疊層邊在罕見的列對齊下，回程可能經過 gutter 中某節點附近（可接受，實務上不遮蓋）。

## 待釐清問題

1. 按需渲染該在每次重新假設（stale 傳播）時自動觸發，還是嚴格維持拉取式？
2. 對很寬的圖（單層很多兄弟），LTR 分層樹是否需要垂直分頁或縮放機制？
