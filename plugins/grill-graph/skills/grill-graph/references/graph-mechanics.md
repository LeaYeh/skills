# graph-mechanics — convergence-only

Read this **only when the user calls for convergence**. During grilling it must stay out of context:
the whole point of the foreground/background split is that none of this dilutes the interrogation.
By now `decision-graph.md` holds a flat list of nodes (each with adopted/rejected options + reasons,
a "builds on" line, and possibly `Reopens #N` flags). This file turns that into wired topology,
a single rendered diagram, and `spec.md`.

## Data model

A **node** is a *resolved decision point* (not a bare question — a question carries no "why
rejected", and that reason is the whole point). On disk it follows `resources/node-template.md`
exactly; field order is load-bearing because the renderer parses it.

- `id` — sequential integer (`#1`, `#2`, …); reading order **is** the time axis.
- `question` — the decision being made.
- `status` — `resolved | stale | abandoned`.
- `options` — `[ { name, verdict: adopted | rejected, reason } ]`.

An **edge** is a dependency carrying the upstream option it assumes:
`Edge { from, assumed_option, to }`. `assumed_option` is load-bearing — it is what lets a
re-assumption propagate *precisely* down the branches that actually relied on the changed option,
instead of flooding the whole graph.

## Convergence procedure

Run these once, in order.

### 1. Wire dependencies

Per-turn recording appended each node's "builds on" line against the frontier by default. Now fix it:
a follow-up doesn't always hang off the previous node — the user may have reached back to extend an
*arbitrary earlier* node. Re-point each edge to the node it actually depends on, and tag it with the
`assumed_option` it relied on.

### 2. Propagate re-assumption (the `Reopens` flags)

For every node flagged `Reopens #N`:
1. Mark the old `#N` `stale` (superseded); create its new version; link `old -.supersedes.-> new`.
2. Walk the dependency edges whose `assumed_option` equals the option that changed, and mark every
   downstream node reachable through them `stale`, collecting them into a **revisit list**.

Rejected options rarely sprout their own subtree; when one did and was later dropped, mark that
subtree `abandoned`. Don't over-model dead siblings — the cases that matter are back-references and
re-assumptions.

### 3. Render the graph — once

Copy `resources/mindmap-template.html` to `decision-graph.html` (alongside the Markdown) and replace
**only** the `GRAPH` data block. Mapping: each `### #N` node → one node object; the "builds on" /
`Depends on` line → a backbone edge; `Feeds` / supersedes / failure → dashed overlay edges. The
renderer auto-lays-out an L→R layered tree over the single-parent backbone and draws cross-edges as
coloured dashed overlays, so you never hand-place anything. Overwrite the HTML — it is a derived view,
not the SSOT.

Encoding (built into the template): node face = `#id` badge + short question + ✅ adopted option, with
rejected options and the assumed premise shown on hover; number = time axis; colour = status (active
blue, stale grey-dashed + dimmed, graduated gold, abandoned faded); export via the `⋯` toolbar. The
template is a fork of the architecture-diagram design system and does **not** invoke that skill.

### 4. Emit `spec.md`

1. **⚠️ Unresolved Premises** (top of file) — every `stale` or unanswered node, i.e. the revisit
   list from step 2. Convergence is **not** gated on these; surface them, don't block. Present them as
   "these premises changed; revisit or keep as-is?" — the user may batch-skip all of them, and skipped
   nodes stay `stale` and stay visible.
2. **Adopted decisions** in dependency order — each adopted option with a one-line
   "chosen because … / rejected … because …" rationale carried straight from the node.
3. **Final panorama** — link `decision-graph.html` (rendered in step 3).

### 5. Graduate ADRs (only the few that earn it)

Most nodes never become ADRs — small, reversible, no real trade-off. Graduate a node only when all
three hold (same bar as record-adr): hard to reverse, surprising without context, the result of a
real trade-off. For each that qualifies, invoke **record-adr**. Its `Related:` field is a *projection*
of the graph: walk up to the nearest ancestor that is *also* graduated and link that ADR; intermediate
non-graduated nodes compress away, so graduated ADRs form a sparse high-level view while
`decision-graph.md` stays the single source of truth for topology.

### 6. Hand off

Offer **to-prd** or **to-issues** to take `spec.md` downstream. Don't re-implement PRD/issue
generation here.
