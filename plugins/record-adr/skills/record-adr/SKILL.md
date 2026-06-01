---
name: record-adr
description: Scan the current session context and the project's adr/ directory to create or update an Architecture Decision Record. Use after any decision point (/grill-me, /plan, or design discussions) when the user invokes /record-adr. Maintains adr/README.md as an auto-updated index.
---

# Record ADR

## Process

1. **Scan existing ADRs**
   - Read `adr/README.md` for the index (if it exists)
   - Read each `adr/ADR-*.md` to identify topic, status, and ADR number
   - Track the highest existing ADR number for auto-increment

2. **Decide: create or update**
   - Identify the key decision(s) from the current session context
   - If the topic significantly overlaps with an existing ADR → update that file (revise sections, update date, keep number)
   - If the topic is new → create `adr/ADR-XXXX-<kebab-slug>.md` where XXXX = max existing number + 1 (zero-padded to 4 digits)

3. **Generate content** — follow the template below:
   - Fixed sections: Context, Decision, Alternatives Considered, Consequences
   - Optional section: Open Questions (include only if genuine open items remain)
   - Diagrams: embed Mermaid for simple flows; for complex architecture invoke the `architecture-diagram` skill, save to `adr/diagrams/`, link from ADR as `[Diagram](diagrams/xxx.html)`
   - Default status: `Proposed`

4. **Write bilingual file**
   - Top half: complete English version
   - Separator: `---` (full width)
   - Bottom half: complete Traditional Chinese (zh-TW) version with identical structure

5. **Update index**
   - Maintain `adr/README.md` as a table: `| ADR | Title (EN) | Status | Date |`
   - Add a new row or update the existing row for the affected ADR

6. **Do NOT commit** — leave files for user review

## Template

```markdown
# ADR-XXXX — <Title>

**Status:** Proposed
**Date:** YYYY-MM-DD
**Related:** ADR-XXXX (<topic>), ...

---

## Context

<What situation or session triggered this decision? What constraints, pain points, or goals set the stage?>

## Decision

<What was decided and why? Use tables to compare options where helpful.>

| Option | Verdict | Reason |
|--------|---------|--------|
| Option A | Rejected | ... |
| **Option B** | **Adopted** | ... |

## Alternatives Considered

<Deeper rationale for rejected options, if not already captured in the Decision table.>

## Consequences

**We gain:** ...
**We sacrifice:** ...

## Open Questions *(optional)*

1. ...

---

---

# ADR-XXXX — <中文標題>

**狀態：** 提議中
**日期：** YYYY-MM-DD
**相關：** ADR-XXXX（<主題>）

---

## 背景

## 決策

## 備選方案

## 後果

**獲得：** ...
**犧牲：** ...

## 待釐清問題 *(可選)*

1. ...
```

## Diagram guidance

- **Simple decision flows, data flows, component relationships** → Mermaid in the ADR body:
  ````
  ```mermaid
  graph TD
    A[Context] --> B{Decision}
    B -->|Adopted| C[Option B]
    B -->|Rejected| D[Option A]
  ```
  ````
- **System architecture, infra topology, multi-service diagrams** → invoke `architecture-diagram` skill → save output to `adr/diagrams/ADR-XXXX-<name>.html` → link: `[Architecture Diagram](diagrams/ADR-XXXX-<name>.html)`

## Index format (`adr/README.md`)

```markdown
# ADR Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [ADR-0001](ADR-0001-<slug>.md) | <Title> | Proposed | YYYY-MM-DD |
```
