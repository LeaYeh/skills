---
name: grill-graph
description: >
  Relentless one-question-at-a-time design grilling — the same interrogation core as grill-me — that
  also preserves the decision's evolution as a graph: rejected branches and why, back-references to
  earlier decisions, and re-assumptions. Each resolved decision is held in context, then the whole
  graph is written and rendered once, at convergence, so nothing ever slows a question. Use this
  instead of grill-me whenever a design discussion is likely to branch or to reopen earlier decisions
  and you want the decision topology preserved, then converged into spec.md. For a quick throwaway
  linear stress-test use grill-me; for domain-language / glossary alignment use grill-with-docs.
---

# grill-graph

## Grill — foreground, the only thing the user feels

Interview the user relentlessly about every aspect of the plan until you reach a shared understanding.
Walk down each branch of the design tree, resolving dependencies one at a time. For every question,
give your own recommended answer — take a position, don't just ask.

Ask **one question at a time** and wait for the answer before continuing. Keep it short, pointed,
specific. If a question can be answered by reading the codebase, read the codebase instead of asking.

This is exactly grill-me. Nothing below is allowed to slow the rhythm or soften a question.

## Track — in context, one node per turn, nothing written yet

After each answer, before you ask the next question, mentally record the resolved decision as a node
following `resources/node-template.md`: the adopted option, every rejected option with a one-line
reason, and the decision it builds on. Capture the reasons **now** — they are only alive in the moment
— but hold the node in context. Don't touch disk.

If an answer reopens an earlier decision, don't stop to chase the consequences — drop a one-line
`Reopens #<id>` flag on the new node and keep grilling. It gets resolved at convergence.

Do **not** create `decision-graph.md`, wire edges, propagate staleness, or render anything mid-session.

## Converge — the single end point, where everything is written and drawn once

When the user calls for convergence:

1. Write every node held in context to `decision-graph.md` in one shot, in order, each following
   `resources/node-template.md` (repo root, or `docs/` if it exists). This is the first time the file
   touches disk.
2. **Read `references/graph-mechanics.md` and follow it.** That is the only moment the rest of the
   heavy work runs — wiring dependencies, propagating the `Reopens` flags into stale premises,
   rendering the graph once, and emitting `spec.md`. Don't load that file before now.

Convergence produces **three artifacts together: `decision-graph.md`, `decision-graph.html`, and
`spec.md`**. None alone is convergence — emit all three or you haven't converged.