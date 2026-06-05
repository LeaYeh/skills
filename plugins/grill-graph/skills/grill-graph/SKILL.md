---
name: grill-graph
description: Heavyweight grilling session that records the decision tree as a live graph — capturing rejected branches, why they were rejected, back-references to past nodes, and re-assumptions — then converges the graph into a spec. Use when a design discussion will branch, you may reopen earlier decisions, and you want the decision evolution preserved rather than a linear transcript. For quick throwaway stress-tests use grill-me; for domain-language alignment use grill-with-docs.
---

<what-to-do>

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time, waiting for feedback on each question before continuing.

If a question can be answered by exploring the codebase, explore the codebase instead.

The difference from plain grilling: as decisions resolve, you maintain a **decision graph** on disk so that branches, rejections, back-references, and re-assumptions are never lost. At the end you converge the graph into a `spec.md`.

</what-to-do>

<supporting-info>

## The artifact chain

```
decision-graph.md   ← grown live during grilling · the topology SSOT · structured Markdown ONLY (no embedded diagram)
   │  on demand ("show the graph") + once at convergence
   ├─▶ decision-graph.html  ← derived view · rendered from resources/mindmap-template.html · overwritten each time
   │ converge: take adopted options of active + resolved nodes
   ▼
spec.md             ← ⚠️ Unresolved Premises + adopted decisions (each with its rejection reason) + link to decision-graph.html
   │ hand off
   ▼
to-prd / to-issues  ← existing skills, not re-implemented here
```

Create `decision-graph.md` lazily — only once the first decision is resolved. Default location: repo root, or `docs/` if it exists. Write to it **inline** as decisions resolve, following the node schema in `resources/node-template.md`; do not batch. The Markdown is the single source of truth and is what the user reads *during* grilling — keep it clean and consistent, because the HTML renderer parses these fields. There is **no live diagram** to maintain (the old embedded Mermaid was unreadable as the graph grew); the visual is generated on demand instead — see Visualization.

## Data model

The on-disk Markdown schema for a node lives in `resources/node-template.md` — follow it exactly so the renderer can parse it. The conceptual model:

A **node** is a *resolved decision point* (not a bare question — a question carries no "why rejected", and that reason is the whole point).

```
Node
  id:       sequential integer (#1, #2, ...) — reading order IS the time axis
  question: the decision being made
  status:   resolved | stale | abandoned
  options:  [ { name, verdict: adopted | rejected, reason } ]
```

An **edge** is a *dependency* and carries the upstream option it assumes:

```
Edge { from: <node id>, assumed_option: <name>, to: <node id> }
```

`assumed_option` is load-bearing: it is what lets re-assumption propagate precisely (see below).

## The grilling loop

After each answer:

1. **Resolve the current node** — record the adopted option AND every rejected option with its reason. Append/update the node in `decision-graph.md`.
2. **Draw the edge** from the parent decision, tagged with the `assumed_option` it depends on.
3. **Decide where the next question attaches.** A follow-up question does NOT always hang off the current node. The user may raise a counter-question that reaches back to an *arbitrary earlier node* to extend it. When that happens, attach the new node to the node it actually depends on, not the frontier.
4. **Detect re-assumption.** If an answer reopens an earlier decision (changes its adopted option), see the next section.
5. **Surface the stale queue** (advisory — see below) before moving to genuinely new ground.
6. **Keep the Markdown clean** — the node block (step 1) is the only live artifact. Do not render a diagram every turn; the visual is on demand (see Visualization). If the user asks to "show the graph" mid-session, render `decision-graph.html` then.

Rejected options rarely sprout their own subtree — when one does and is later dropped, mark that subtree `abandoned`. The common and important case is back-references and re-assumptions, not dead sibling subtrees. Don't over-model dead siblings.

## Re-assumption and stale propagation

When the user reopens an earlier node and its adopted option changes:

1. Record the change: the old node becomes `stale`/superseded; create the new version and link `old -.supersedes.-> new`.
2. **Propagate automatically.** Walk the dependency edges whose `assumed_option` equals the option that just changed. Every downstream node reachable through those edges is marked `stale` and pushed onto a **revisit queue**.
3. **The queue is advisory, never a gate.** Surface the stale nodes — "these premises changed: revisit, or keep as-is?" — but the user may batch-skip all of them. Skipped nodes stay `stale` and stay visible in the graph. The contradiction is never silently swallowed; the user just chooses not to act on it yet.

## Graduation to ADR

Most nodes never become ADRs — they are small, reversible, no real trade-off. Only graduate a node when all three hold (same bar as record-adr): hard to reverse, surprising without context, the result of a real trade-off.

When a node graduates, invoke the **record-adr** skill. The ADR's `Related:` field is a *projection* of the graph: walk up from the node to the nearest ancestor that is *also* graduated, and link that ADR. Intermediate non-graduated nodes are compressed away, so graduated ADRs form a sparse high-level view — but `decision-graph.md` remains the single source of truth for topology. ADR parent links are never hand-maintained independently of the graph.

## Visualization

The visual is **on demand, never live**. During grilling the user reads the structured Markdown
(`decision-graph.md`) — that is the SSOT and it is genuinely readable. A diagram is rendered only
when the user asks ("show the graph") or once at convergence. The old approach — a Mermaid `graph TD`
refreshed every turn — became unreadable spaghetti once the graph grew past a handful of cross-edges,
so it has been removed.

**How to render.** Copy `resources/mindmap-template.html` to `decision-graph.html` (alongside
`decision-graph.md`) and replace the single `GRAPH` data block — nothing else. Each `### #N` node
block maps to one node object; `Depends on` becomes a `backbone` edge, and `Feeds`/supersedes/failure
become overlay edges. The exact mapping is documented in `resources/node-template.md`. The renderer
is data-driven: it auto-lays-out an **L→R layered tree** (the single-parent `dependsOn` backbone) and
draws cross-edges as coloured dashed overlays — so you never hand-place coordinates, and the output is
consistent every time. Overwrite `decision-graph.html` on each render; it is a derived view, not SSOT.

**Encoding (built into the template):**

- **Layout** — backbone (`dependsOn`) = a clean left-to-right tree; cross-edges (`feeds` / `supersedes`
  / `failure`) = coloured dashed curves layered on top. This is the "mindmap backbone + DAG overlay"
  hybrid: DAG semantics preserved, readability restored.
- **Node face** = `#<id>` badge + short question + `✅ adopted option`. Long detail is **not** on the
  face; **hover** a node to expand its rejected options (with reasons) and the premise it depends on.
- **Number = time axis** — sequential ids carry the evolution; no replay needed.
- **Colour = status** — active = blue, stale = grey dashed + dimmed, graduated = gold, abandoned = faded.
- **Export** — the built-in toolbar (`⋯`) copies/saves PNG or PDF (a clean static snapshot; hover detail
  lives in the Markdown SSOT anyway).

This template is a **fork** of the architecture-diagram design system (dark theme, JetBrains Mono,
self-contained HTML, export toolbar) — grill-graph owns its own decision-semantics encoding and does
**not** invoke the architecture-diagram skill.

## Convergence

When the user calls for convergence, walk the DAG and emit `spec.md`:

1. **⚠️ Unresolved Premises** (top of file) — list every `stale` or unanswered node. Convergence is NOT gated on these; surface them, don't block. This mirrors the "stale is batch-skippable" philosophy.
2. **Adopted decisions** in dependency order — each adopted option with a one-line "chosen because … / rejected …" rationale carried from the node.
3. **Final panorama** — render `decision-graph.html` from `resources/mindmap-template.html` (see Visualization) and link it from `spec.md`.

Then hand off: offer **to-prd** or **to-issues** to take `spec.md` downstream. Do not re-implement PRD/issue generation here.

## Resources

Two bundled templates under `resources/` crystallise the format so neither the Markdown nor the diagram is improvised per session:

- **`node-template.md`** — the fixed Markdown node schema for `decision-graph.md` (the live SSOT). Field order is load-bearing: it maps mechanically to the renderer's `GRAPH` JSON.
- **`mindmap-template.html`** — the on-demand visual: a self-contained, data-driven renderer (L→R layered-tree auto-layout, SVG edge layer + HTML node layer with hover-to-expand detail, export toolbar). Per session you replace only its `GRAPH` data block. A fork of the architecture-diagram design system; it does not invoke that skill.

## Relationship to sibling skills

- **grill-me** — quick, throwaway stress-test, linear, no persisted graph.
- **grill-with-docs** — aligns domain language (CONTEXT.md glossary) and writes sparse ADRs.
- **grill-graph** (this) — preserves decision *topology and evolution*; built on grill-me's grilling core, not on grill-with-docs' glossary machinery. The three coexist.

</supporting-info>
