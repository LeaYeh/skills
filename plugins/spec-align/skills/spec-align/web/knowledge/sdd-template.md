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

## Component design
{which modules change, what is new}

## HW/SW interface

| Scenario | Data format | Sample rate | Timing | Protocol |
|----------|-------------|-------------|--------|----------|
| S1 | {format} | {rate} | {timing} | {protocol} |

## Data flow
{input → processing → output for primary scenario}

## Acceptance criteria

| Scenario | Verification | Pass condition |
|----------|--------------|----------------|
| S1 | {manual | automated | customer sign-off} | {measurable pass condition} |

## Open questions

| Question | Owner | Due |
|----------|-------|-----|
```

## Issue list

Alongside the SDD draft, output one row per implementation task. Every issue must trace
to a BDD scenario.

| Title | Label | BDD scenario | Description |
|-------|-------|--------------|-------------|
| SWE: {task} | swe | S{n} | {what to build} |
| HWE: {task} | hwe | S{n} | {what to build} |
