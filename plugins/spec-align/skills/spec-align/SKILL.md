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

Read `spec-align.config.json` from the workspace root before anything else.

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

### Step 2 — Grill the SWE plan

One question at a time. For every design decision, ask:
> "Which BDD scenario does this serve?"

Flag scope creep (plan element with no corresponding scenario) and gaps (BDD scenario
with no plan coverage) explicitly.

Cover these areas in order:

1. **Component breakdown** — which existing modules change, what new ones are needed
2. **HW/SW interface** — for each scenario touching hardware: data format, sample rate,
   timing, protocol
3. **Data flow** — from input to user-visible output for the primary scenario
4. **Error handling** — what happens when each scenario fails
5. **Out of scope** — what the BDD does NOT require that might be tempting to build

For every contradiction between the plan and a BDD constraint, state it explicitly:
> "Your plan assumes X. BDD constraint says Y. Which takes precedence?"

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
scenarios, component design, data flow, acceptance criteria, open questions.

- Section order and table columns come from the template — do not deviate.
- The **BDD scenarios** table copies all confirmed scenarios verbatim from the BDD
  artifact, same IDs, one row each.
- The **Acceptance criteria** table has exactly one row per scenario ID.
- Downstream produces docx with `pandoc {project-name}.sdd.html -o {project-name}.sdd.docx`
  — mention this in the final report.

Commit and push:
```
git -C document add docs/specs/{project-name}.sdd.html
git -C document commit -m "docs(spec): add SDD for {project-name}"
git -C document push
```

**2 — Create GitHub issues**

One issue per implementation task. Every issue must trace to a BDD scenario.

```
gh issue create \
  --repo C-Sense/document \
  --title "SWE: {task}" \
  --body "BDD scenario: {name}\nSDD: docs/specs/{project-name}.sdd.html\n\n{description}" \
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

**3 — Report**

List the SDD file path and all created issue URLs.

---

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
- If `gh` is not authenticated, stop and ask the user to run `gh auth login`.
