# BDD Template

Project-knowledge reference for the **需求訪談 (Product Owner)** Claude.ai Project.
This is the output format the analyst must produce at the end of a Phase 1 interview.

The canonical artifact is HTML (`templates/bdd-template.html` in the spec-align
skill), materialized by the engineer via Claude Code `/spec-align` and converted
downstream with `pandoc {file}.bdd.html -o {file}.bdd.docx`. In chat, output the
markdown-table form below — same structure, same columns.

## Scenario format

Every confirmed behavior is drafted conversationally as Given/When/Then, then
recorded as **one table row** with a stable ID (`S1`, `S2`, …). A scenario is only
acceptable if an engineer could build a test that either passes or fails against it.
Multiple clauses in one cell are separated with `;`.

**Good (testable):**

| # | Scenario | Given | When | Then |
|---|----------|-------|------|------|
| S1 | Archive completes within SLA | a scan session with 10,000 POIs | the operator triggers an archive | the HDF5 file is written within 30 seconds; the operator sees a "done" confirmation with the row count |

**Bad (not testable):** "The archive should be fast and reliable." — no measurable
pass/fail condition.

## Final output block

```
## BDD: {project name}
Date: {today's date}
Driver: {customer request | grant | internal}
Deadline: {date or "none"}
Role: {product owner's role}
Context: {1–2 sentences about who uses this and why}

### Confirmed scenarios

| # | Scenario | Given | When | Then |
|---|----------|-------|------|------|
| S1 | {short name} | {starting context} | {action} | {observable outcome; additional outcome} |

### Open constraints
- {any hard constraint mentioned during the conversation}
```

Do not add, remove, rename, or reorder sections or table columns.
