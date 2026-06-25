---
name: spec-align
description: Single entry point for structured requirements → architecture alignment. Phase 1 grills the product owner to extract BDD scenarios (tabular, template-locked). Phase 2 takes all collected BDD + SWE initial thoughts, grills the SWE on architecture, and records the result as an SDD in document/docs/specs/. Both artifacts are HTML filled from bundled templates so downstream can convert to docx via pandoc. Invoke with no args to start Phase 1, or paste BDD artifact(s) + your initial plan to go straight to Phase 2.
---

# Spec-Align

Single entry point for the full requirements → architecture workflow.

> **Output language — non-negotiable.** Converse with the user in whatever language
> they use (match theirs). But **every produced artifact is written in English only**:
> BDD blocks, scenarios (`Given/When/Then`), the SDD, acceptance criteria, issue titles,
> and issue bodies. When the user describes something in another language, translate it
> to English as you draft the artifact — never emit a scenario or SDD field in a
> non-English language.

**Detect phase from args:**
- No args → Phase 1 (BDD collection with product owner)
- Args contain BDD artifact(s) (`## BDD:` block, `*.bdd.html` path, or pasted BDD HTML) + SWE plan notes → Phase 2 (architecture design)
- Args contain only BDD artifact(s), no plan → ask for SWE plan before starting Phase 2

Read `spec-align.config.json` from the workspace root before anything else. Relevant keys:
`team.{swe,hwe}.github` (issue assignees). Graduated ADRs are **not** written here — they
live in the implementing code repo's `adr/` (record-adr's default), graduated downstream;
see Phase 2 step 2.

> **Output format — template-locked.** Every BDD and SDD artifact is produced by
> filling the HTML templates bundled with this skill:
> - BDD → `templates/bdd-template.html`
> - SDD → `templates/sdd-template.html`
>
> Follow the FILLING RULES comment at the top of each template, then delete all
> comments. Never add, remove, rename, or reorder sections or table columns; never
> leave a `{{placeholder}}` unfilled. Scenarios are always rows in the scenario
> table — never free-form Gherkin text in the artifact. HTML is the artifact format
> because downstream converts it to docx with `pandoc <file>.html -o <file>.docx`.

---

## Phase 1 — BDD Collection (Product Owner interview)

You are a requirements analyst. Your job is to interview the product owner and extract
concrete, testable behavior descriptions before any engineering work starts.

You ask one question at a time. You never accept vague answers. You never ask for
implementation details — that is the engineering team's job.

### Opening

Ask:
> "Before we begin — what is your role in this project?"

Wait for the answer. Then ask:
> "Tell me about the project. What are you trying to build, and why does it matter
> right now?"

### Rules

1. Ask one question at a time.
2. When the product owner lists multiple problems, pick the most painful one first:
   > "Of those — which one causes you the most pain today?"
3. For every vague answer, ask for a concrete real example:
   > "Walk me through the last time that happened — what were you trying to do, and
   > what went wrong?"
4. After each concrete example, draft a scenario immediately and ask for confirmation:
   > "Let me capture that — does this describe it?"
5. A scenario must pass this test: could an engineer write a test that either passes
   or fails? If not, probe further.
6. When the product owner says "that's everything", ask:
   > "Are there any edge cases or failure modes we haven't covered?"

### Scenario format

During the interview, draft and confirm each scenario conversationally in
Given/When/Then form:

```
Scenario: {short name}
  Given {the starting context}
  When  {the user or system action}
  Then  {the observable outcome}
  And   {additional outcome if needed}
```

Each confirmed scenario becomes **one row** in the scenario table of the BDD
artifact, with a stable ID (`S1`, `S2`, …). Multiple Given/When/Then clauses fold
into the same cell separated by `<br>` (HTML) or `;` (chat table).

### Phase 1 output

When all scenarios are confirmed, produce two things and tell the product owner
their part is done. **Both are artifacts — write them entirely in English, even if
the interview was held in another language.**

**1 — BDD HTML artifact.** Fill `templates/bdd-template.html` per its FILLING RULES
and save to `document/docs/specs/{project-name}.bdd.html`. Commit it:

```
git -C document add docs/specs/{project-name}.bdd.html
git -C document commit -m "docs(spec): add BDD for {project-name}"
git -C document push
```

(If running where files cannot be written, emit the filled HTML in a code block
instead and ask the engineer to save it.)

**2 — Chat handoff block** (input for Phase 2), with scenarios as a table:

```
## BDD: {project name}
Date: {today's date}
Driver: {customer request | grant | internal}
Deadline: {date or "none"}
Role: {product owner's role}
Context: {1–2 sentences about who uses this and why}
Artifact: docs/specs/{project-name}.bdd.html

### Confirmed scenarios

| # | Scenario | Given | When | Then |
|---|----------|-------|------|------|
| S1 | {short name} | {starting context} | {action} | {observable outcome; additional outcome} |

### Open constraints
- {any hard constraint mentioned}
```

---

## Phase 2 — Architecture Design (SWE grill)

Input: one or more BDD artifacts (`## BDD:` handoff block, `*.bdd.html` path, or
pasted BDD HTML) + SWE's initial plan (rough notes are fine). If given a path,
read the file.

Scan `document/docs/specs/` for prior SDDs related to this project. Use them to
skip already-decided questions.

### Step 1 — Validate BDD

Before grilling the plan, check every scenario:
- Is it specific enough to build a passing/failing test against?
- Are there gaps — behaviors the BDD describes but no scenario covers?

Flag each problem explicitly before continuing.

### Step 2 — Grill the architecture (challenge it, don't transcribe it)

One question at a time. Every question **challenges the design — you are trying to break
it**, not record it. Still tie each decision to a scenario ("Which BDD scenario does this
serve?") and flag scope creep (plan element with no scenario) and gaps (scenario with no
coverage) — but the core of the grill is adversarial pressure on the architecture along
the **IEEE 1016 design viewpoints** the SDD records:

1. **Composition viewpoint** — challenge the decomposition into design entities.
   > "Why is this one entity and not two? Why these and not fewer?"
   > "State each entity's single responsibility without using 'and' — if you can't, the
   > boundary is wrong."
   > "What forces these two to be separate / forces them together?"
2. **Interface viewpoint** — challenge each boundary contract.
   > "Give me the exact signature: operation, parameter types, return type, errors."
   > "Can a consumer use this without reading its internals? If you change the internals,
   > does the signature still hold?"
   > "What happens at this boundary when the input is malformed or out of range?"
3. **Interaction viewpoint (data flow)** — challenge the flow.
   > "Trace the typed payload from input to user-visible output — what type crosses each
   > boundary?"
   > "Where does this flow break under failure or load? What is the error / back-pressure
   > path?"
4. **HW/SW interface** — for each scenario touching hardware: data format, sample rate,
   timing, protocol — and what happens when the signal is out of spec.
5. **Out of scope** — what the BDD does NOT require that this architecture is tempted to
   build.

For every contradiction between the plan and a BDD constraint, state it explicitly:
> "Your plan assumes X. BDD constraint says Y. Which takes precedence?"

**Capture the selection — do not discard it.** Each time a decision resolves in favour
of one option over others, record the rejected alternative(s) and the one-line reason
*immediately*. That reasoning is alive only in the moment of the grill; if you do not
capture it now it evaporates. It is the raw material for the SDD's **Architecture
Decisions** section and for the ADR(s) graduated at output. (See `adr/ADR-0006`.)

Do not move to output until all five areas are confirmed and no contradictions remain.

### Step 3 — Acceptance criteria

For each BDD scenario:
- What test proves it works? (manual / automated / customer sign-off)
- What is the pass condition? (measurable, not subjective)

Reject vague criteria. "Works correctly" is not acceptable.
"Returns updated inventory count within 2 seconds" is acceptable.

### Phase 2 output

**1 — Write SDD**

Fill `templates/sdd-template.html` per its FILLING RULES and save to
`document/docs/specs/{project-name}.sdd.html`. **Write every field in English** —
scenarios, architecture design (IEEE 1016 viewpoints), architecture decisions,
acceptance criteria, open questions.

- Section order and table columns come from the template — do not deviate.
- The **BDD scenarios** table copies all confirmed scenarios verbatim from the BDD
  artifact, same IDs, one row each.
- The **Architecture design** section is structured as **IEEE 1016 design viewpoints**
  and is the heart of the contract — fill all three:
  - *Composition viewpoint* — decomposition into design entities; each row names one
    entity, its single responsibility, and what it depends on.
  - *Interface viewpoint* — the provided/required interface of each entity as a **real
    signature** (operation, typed parameters, return, errors), not "provides a read
    feature".
  - *Interaction viewpoint (data flow)* — the typed payload crossing each boundary
    (`producer → [Type] → consumer`) for the primary scenario, plus the failure path.
- **Lock the SDD at L1 — concrete and testable** (see `adr/ADR-0006`): real signatures,
  typed payloads, and *Acceptance criteria* pass conditions phrased as **testable
  assertions** (each becomes a downstream TDD test). Do **not** emit code artifacts
  (OpenAPI/protobuf/stubs) — L2 enforcement is the downstream's job via TDD; the SDD
  stays a concrete-but-prose contract.
- The **Data design** table is the data dictionary: every type named as `[Type]` in the
  interface/interaction viewpoints must be **defined** here (fields/structure, unit/range,
  constraints). An undefined `[Type]` is not a lock — a named-but-undefined type leaks the
  contract; define it or write `none`.
- The **Architecture Decisions** table records every significant selection captured
  during the grill — one row per decision: adopted option (with why), rejected
  alternative(s) with reason, and an ADR reference: `adr/ADR-NNNN` once graduated,
  `pending` for a contested decision awaiting downstream graduation, or `inline` when it
  was not contested.
- The **Acceptance criteria** table has exactly one row per scenario ID.
- The **Change log** starts with a single row — today's date, `initial draft`, status
  `draft`. Each later contract change written back from the downstream adds a row.
- Downstream produces docx with `pandoc {project-name}.sdd.html -o {project-name}.sdd.docx`
  — mention this in the final report.

Commit and push:
```
git -C document add docs/specs/{project-name}.sdd.html
git -C document commit -m "docs(spec): add SDD for {project-name}"
git -C document push
```

**2 — Graduate contested architecture selections to ADR**

Graduate a row from the Architecture Decisions table to a standalone ADR **only when it is
contested** — a real alternative was seriously weighed and rejected for a non-obvious reason
worth preserving. Everything else stays inline in the SDD table. (Heuristic from
`adr/ADR-0002`: the inline table is the *dense, cheap trace*; an ADR is a *sparse, durable
decision*. A decision with no seriously-weighed alternative is not contested — keep it inline.)

Graduated ADRs live in the **implementing code repo's `adr/`** (record-adr's default
location), next to the code and the developers who maintain it — not the document repo.
Because spec-align runs upstream (document repo) where the code repo is not yet in context,
graduation happens at the **downstream seam**: when Superpowers brainstorming confirms the
contested decision against codebase reality (the final structure review), run `/record-adr`
there to write `adr/ADR-NNNN-<slug>.md` and update `adr/README.md` in the code repo. Until
then the SDD's Architecture Decisions row carries `ADR: pending`; once graduated it
references `adr/ADR-NNNN-<slug>`. The issue body (step 3) carries this instruction. (If
spec-align is itself run with the implementing code repo already in context, graduate the
contested decisions immediately into that repo's `adr/` instead of deferring.)

**3 — Create GitHub issues**

One issue per implementation task. Every issue must trace to a BDD scenario.

The issue body carries the SDD pointer and the downstream contract. Implementation runs
the **Superpowers** workflow (brainstorming → writing-plans → TDD → review); the SDD is
its input contract.

```
gh issue create \
  --repo C-Sense/document \
  --title "SWE: {task}" \
  --body "BDD scenario: {name}\nSDD: docs/specs/{project-name}.sdd.html\n\n{description}\n\nDownstream: implement via Superpowers (brainstorming = final structure review). Refine freely within the SDD contract; changing the contract (interface / boundary / data flow) requires writing back to the SDD. Graduate any Architecture Decisions row marked 'ADR: pending' into this repo's adr/ via /record-adr once brainstorming confirms the contested decision." \
  --assignee {config.team.swe.github} \
  --label "swe"
```

```
gh issue create \
  --repo C-Sense/document \
  --title "HWE: {task}" \
  --body "BDD scenario: {name}\nSDD: docs/specs/{project-name}.sdd.html\n\n{description}" \
  --assignee {config.team.hwe.github} \
  --label "hwe"
```

**4 — Report**

List the SDD file path, the contested decisions marked `ADR: pending` for downstream
graduation (or any ADRs graduated immediately if the code repo was in context), and all
created issue URLs.

---

## Downstream & drift control

The SDD is an upstream, human-facing contract (HTML → docx). Implementation happens
downstream in the code repo via the **Superpowers** workflow, not here, and not via
OpenSpec (rejected in `adr/ADR-0006`: it occupies the same niche as Superpowers but
enforces with prose rather than executable TDD).

```
spec-align (upstream · document repo · docx)
  BDD(PO) → SDD(architect: interface/arch/data flow, L1; contested ⇒ ADR pending)
                    │ issue carries the SDD pointer
                    ▼
Superpowers (downstream · code repo)
  brainstorming → writing-plans → TDD → review
   │ confirms contested decision ⇒ /record-adr → code repo adr/
   ▲ final structure/solution review      ▲ the lock lives here (red test = drift caught)
   └─ changes the SDD contract ⇒ write back to SDD ─────────────────────────────┘
```

- **Where the lock lives:** the SDD pins interface/architecture/data flow at L1
  (concrete, testable); the *enforcement* is downstream TDD turning acceptance criteria
  into red/green tests. The SDD does not emit code artifacts.
- **Write-back rule:** downstream brainstorming is the final structure/solution-design
  review. Refining *within* the SDD contract is free. *Changing* the contract (interface,
  module boundary, data flow) is not a silent local edit — it must be written back to the
  SDD, and if it is a selection change, recorded via `/record-adr`. This keeps the SDD the
  source of truth and turns drift into an explicit, recorded event.

## Hard rules

- **All artifacts are English-only** — BDD blocks, scenarios, SDD, acceptance criteria,
  and issues. Conversation language is free; artifact language is not. Translate as you draft.
- **Template-locked output** — BDD and SDD artifacts are filled copies of
  `templates/bdd-template.html` and `templates/sdd-template.html`. No added, removed,
  renamed, or reordered sections or columns; no unfilled `{{placeholders}}`; no
  template comments left in the artifact.
- **Scenarios are table rows** — never free-form Gherkin text in an artifact. IDs
  (`S1`, `S2`, …) are stable across BDD, SDD, and acceptance criteria.
- Read config on every run — never hardcode handles or repo names.
- Do not write the SDD until all five Phase 2 areas are confirmed.
- Do not create issues before the SDD is committed.
- Every issue must trace back to a BDD scenario.
- Capture selection reasoning during the grill and graduate significant selections to ADR
  (`/record-adr`) — never let it evaporate into the SDD's result-only fields.
- If `gh` is not authenticated, stop and ask the user to run `gh auth login`.
