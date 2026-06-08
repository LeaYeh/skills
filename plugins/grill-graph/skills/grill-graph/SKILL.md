---
name: grill-graph
description: >
  Relentless one-question-at-a-time design grilling — the same interrogation core as grill-me — that
  also preserves the decision's evolution as a persisted graph: rejected branches and why,
  back-references to earlier decisions, and re-assumptions. The graph is recorded one node per turn in
  the background and rendered only once, at convergence, so it never slows a question. Use this instead
  of grill-me whenever a design discussion is likely to branch or to reopen earlier decisions and you
  want the decision topology preserved, then converged into spec.md. For a quick throwaway linear
  stress-test use grill-me; for domain-language / glossary alignment use grill-with-docs.
---

# grill-graph

## Grill — foreground, the only thing the user feels

Interview the user relentlessly about every aspect of the plan until you reach a shared understanding.
Walk down each branch of the design tree, resolving dependencies one at a time. For every question,
give your own recommended answer — take a position, don't just ask.

Ask **one question at a time** and wait for the answer before continuing. Keep it short, pointed,
specific. If a question can be answered by reading the codebase, read the codebase instead of asking.

This is exactly grill-me. Nothing below is allowed to slow the rhythm or soften a question.

## Record — background, one node per turn and nothing more

After each answer, before you ask the next question, append the resolved decision to
`decision-graph.md` as a single node following `resources/node-template.md`: the adopted option, every
rejected option with a one-line reason, and the decision it builds on. Capture the reasons **now** —
they are only alive in the moment. One append, then move on.

If an answer reopens an earlier decision, don't stop to chase the consequences — drop a one-line
`Reopens #<id>` flag on the new node and keep grilling. It gets resolved at convergence.

Create `decision-graph.md` lazily, on the first resolved decision (repo root, or `docs/` if it exists).
Do **not** wire edges, propagate staleness, or render anything mid-session.

## Converge — the single end point, where the graph is drawn once

When the user calls for convergence, **read `references/graph-mechanics.md` and follow it**. That is
the only moment the heavy work runs — wiring dependencies, propagating the `Reopens` flags into stale
premises, rendering the graph once, and emitting `spec.md`. Don't load that file before then.