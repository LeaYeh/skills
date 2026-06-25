# SDD Template

Project-knowledge reference for the **架構對齊 (SWE / Architect)** Claude.ai Project.
This is the SDD-draft format the reviewer outputs at the end of a Phase 2 grill. The
engineer materializes it via Claude Code `/spec-align`, which fills the canonical
HTML template (`templates/sdd-template.html`) and saves it to
`document/docs/specs/{project-name}.sdd.html` — the web project does not write it.
Downstream converts with `pandoc {file}.sdd.html -o {file}.sdd.docx`.

In chat, output the markdown form below — same sections, same table columns as the
HTML template. Do not add, remove, rename, or reorder sections or columns. Scenario
IDs (`S1`, `S2`, …) must match the BDD artifact exactly.

```markdown
# SDD: {project name}

**Date**: {today}
**Status**: draft
**Driver**: {customer request | grant | internal}
**Deadline**: {date or "none"}

## Context
{from BDD}

## Goal
{primary scenario in one plain-English sentence}

## BDD scenarios

| # | Scenario | Given | When | Then |
|---|----------|-------|------|------|
| S1 | {short name} | {starting context} | {action} | {observable outcome; additional outcome} |

## Scope

| | |
|---|---|
| **In** | {deliverables derived from scenarios} |
| **Out** | {explicit exclusions decided during the grill} |

## Architecture design (IEEE 1016)

### Composition viewpoint

| Design entity | New / Changed | Single responsibility | Depends on |
|---------------|---------------|-----------------------|------------|
| {entity} | {new \| changed} | {one responsibility, no "and"} | {dependencies or "none"} |

### Interface viewpoint

| Design entity | Operation (signature) | Inputs (typed) | Outputs (typed) | Errors / exceptions |
|---------------|-----------------------|----------------|-----------------|---------------------|
| {entity} | {operation(param: Type, ...) -> ReturnType} | {typed inputs} | {typed outputs} | {boundary behavior on bad input} |

### Interaction viewpoint — data flow

| Step | Producer | Payload [Type] | Consumer |
|------|----------|----------------|----------|
| 1 | {producer entity} | {payload [Type]} | {consumer entity} |

Failure path: {where the flow breaks under failure/load and how it is handled}

## Data design

Data dictionary — define every type/structure referenced as `[Type]` in the viewpoints
above (the L1 lock is only real once these types are defined, not just named). If no new
types, a single row of "none".

| Type / structure | Fields / structure | Unit / range | Constraints |
|------------------|--------------------|--------------|-------------|
| {type name} | {field: Type, ... or primitive shape} | {unit and valid range, or "n/a"} | {invariants / validation rules, or "none"} |

## HW/SW interface

| Scenario | Data format | Sample rate | Timing | Protocol |
|----------|-------------|-------------|--------|----------|
| S1 | {format} | {rate} | {timing} | {protocol} |

## Architecture decisions

| ID | Decision | Adopted (why) | Rejected alternatives (reason) | ADR |
|----|----------|---------------|--------------------------------|-----|
| AD1 | {what was decided} | {adopted option — why} | {option B — reason; option C — reason} | {adr/ADR-NNNN \| pending \| inline} |

## Acceptance criteria

| Scenario | Verification | Pass condition |
|----------|--------------|----------------|
| S1 | {manual | automated | customer sign-off} | {pass condition as a testable assertion — becomes a downstream TDD test} |

## Open questions

| Question | Owner | Due |
|----------|-------|-----|

## Change log

One row per material revision, newest first; the initial draft is the first row.

| Date | Change | Status |
|------|--------|--------|
| {today} | initial draft | draft |
```

## Issue list

Alongside the SDD draft, output one row per implementation task. Every issue must trace
to a BDD scenario.

| Title | Label | BDD scenario | Description |
|-------|-------|--------------|-------------|
| SWE: {task} | swe | S{n} | {what to build} |
| HWE: {task} | hwe | S{n} | {what to build} |
