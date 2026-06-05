# Node template — `decision-graph.md`

The live SSOT is **structured Markdown**, not a diagram. Every resolved decision is one
`### #N` block following the exact schema below. Keep the field order fixed — the on-demand
HTML renderer parses these fields into the `GRAPH` JSON that `mindmap-template.html` consumes,
so Markdown and JSON stay mechanically convertible (same field names).

Append/update a block **inline** the moment a decision resolves. Do not batch.

---

## Per-node block schema

```markdown
### #N — <short title>

- **Question:** <the decision being made>
- **Status:** resolved | stale | abandoned | graduated
- **Depends on:** #<id> (assumed: <upstream adopted option>)   ← omit for the root node
- **Feeds:** #<id> (<what it supplies>)                         ← only if a cross-edge exists
- **Options:**
  - ✅ **<adopted option>** *(adopted)* — <why chosen>
  - ❌ <rejected option> *(rejected)* — <why rejected; this reason is the whole point>
```

### Field rules

- **`#N`** — sequential integer. Reading order **is** the time axis; never renumber.
- **`Depends on`** — the single **backbone parent**. Its `assumed:` value is load-bearing: it
  is what lets re-assumption propagate (if that upstream option changes, this node goes `stale`).
- **`Feeds` / cross-edges** — any non-backbone dependency: a node that *feeds* a sibling
  (`#7 → #6`), a **supersedes** link from a reopened node to its replacement, or a **failure**
  route (`#8 → #4`). These become overlay edges in the diagram; the backbone stays a clean tree.
- **`Status`** — `resolved` (active), `stale` (an upstream premise changed; on the revisit
  queue), `abandoned` (a dropped sibling subtree), `graduated` (became an ADR).
- **Rejected options** — keep every one with its reason. They never appear on the diagram face;
  they surface on **hover**. The Markdown is where they are read in full.

---

## Mapping to the renderer's `GRAPH` JSON

`mindmap-template.html` is a data-driven renderer. Each `### #N` block maps to one node object;
`Depends on` becomes a `backbone` edge, `Feeds`/supersedes/failure become overlay edges:

**Bilingual.** English is canonical; Traditional Chinese is an optional parallel layer the renderer
shows beneath each English line. In the Markdown, write the zh-TW after a `／` on the same line
(e.g. `**Question:** Per-stage withhold target ／ 每階段的保留目標`). In the JSON, every text field has
an optional `*_zh` sibling (`question_zh`, `adopted_zh`, `reason_zh`). Omit them for an English-only graph.

```js
// node #N  →
{ id: N, question: "<short title>", question_zh: "<中文標題>", adopted: "<adopted option>", adopted_zh: "<中文採用>",
  status: "resolved", dependsOn: <id|null>, premise: "<assumed option>",
  rejected: [ { name: "<rejected option>", reason: "<why rejected>", reason_zh: "<中文否決理由>" } ] }

// edges →
{ from: <dependsOn>, to: N, kind: "backbone",   label: "assumed:<premise>" }
{ from: 7,           to: 6, kind: "feeds",       label: "<what it supplies>" }
{ from: <old>,       to: N, kind: "supersedes",  label: "supersedes" }
{ from: 8,           to: 4, kind: "failure",     label: "on failure" }
```

`kind` drives the overlay edge colour/style (see `mindmap-template.html` legend):
`backbone` = solid; `feeds` / `supersedes` / `failure` = coloured dashed curves.
