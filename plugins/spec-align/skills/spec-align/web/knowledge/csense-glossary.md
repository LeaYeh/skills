# C-Sense Glossary

Project-knowledge reference for both Claude.ai Projects, so the analyst and the
architecture reviewer use C-Sense's own vocabulary instead of inventing terms.

Sourced from `document/docs/` and `document/docs/adr/`. Cited column points to the
authoritative doc. Terms marked **(confirm)** are inferred from filenames/context and
need a human to verify the exact meaning.

## Domain model

| Term | Definition | Source |
|------|------------|--------|
| POI (Point of Interest) | Session-scoped **spatial anchor** — a named coordinate within one measurement session. Has no `status`/`action_type` (those live on Measurement). | ADR-0002 |
| Sample | A physical specimen loaded onto the stage. `samples` table. | ADR-0002 |
| Session | One continuous measurement run on a loaded sample. Coordinates are **session-relative** — not comparable across sessions without a registration record. | ADR-0002 |
| Measurement | An action performed at a POI (`indent` / `approach` / `scan_afm` / `optical` / …). One POI → many Measurements. | ADR-0002 |
| session_registration | Future affine transform (dx, dy, rotation) between two sessions' coordinate frames. Zero-cost extension point, deferred until optical-hardware upgrade. | ADR-0002 |
| params_snapshot | Full hardware parameter state captured at measurement time. Feeds the LLM guided mode. | ADR-0002, ADR-0006 |
| outcome_notes | Operator free-text quality notes on a measurement. Primary LLM few-shot context. | ADR-0002, ADR-0006 |
| Scene vs stage coordinates | Scene `(x, y)` = display coordinates; stage `(x_stage, y_stage)` = hardware coordinates. Both session-relative. | ADR-0002 |

## User roles

| Term | Definition | Source |
|------|------------|--------|
| Navigator | Role + GUI: plans and reviews measurement tasks, offline or online. Shares ~90% of `core/` with Operator. | 0_overview, CLAUDE.md |
| Operator | Role + GUI: performs measurements with connected hardware, including calibration. | 0_overview |
| PnP (Plug-and-Play) | The plug-and-play measurement workflow — hardware-agnostic swapping of stages/scanners/indenters. Active project (`Drive: Projects/PnP`). | 0_overview, docs/5 |
| PnP operator | Operator persona running the PnP measurement workflow (`assets/pnp_measurement_menu/`, `docs/5_user_manual_pnp_operator.md`). | docs/5 |

## Architecture

| Term | Definition | Source |
|------|------------|--------|
| MVCS | Model-View-Controller-Service — the Application Layer pattern. | docs/2.x, CLAUDE.md |
| Event Bus | Single pub/sub channel with SQLite WAL persistence used by all layers. Backend is pluggable via `IEventBus` (swap ZeroMQ/Redis/Cloud with no app change). | ADR-0003, CLAUDE.md |
| Command vs Event | Commands (intent) flow **down**; Events (results/state) flow **up**. | CLAUDE.md |
| System Layer | Bridges Application commands to Concurrency tasks; consolidates results, publishes app events. | CLAUDE.md |
| Concurrency Layer | Resource coordination, mutual exclusion, drives external hardware (Python). Same repo as System Layer. | CLAUDE.md, concurrency repo |
| Guided Mode | Phase 3 LLM-assisted measurement assistance, fed by `params_snapshot` + `outcome_notes`. | ADR-0006 |
| Streaming architecture | High-rate data path that **bypasses app-platform**. | ADR-0005 |
| Sealed Adapter (LabVIEW/EPFL boundary) | Pattern isolating LabVIEW/EPFL code behind a sealed adapter. | ADR-0007 |

## Storage & formats

| Term | Definition | Source |
|------|------------|--------|
| SQLite | Application DB; source of truth for POI/Session/Measurement. | ADR-0001 |
| HDF5 | Experiment data archive format (original DB; now archive). | ADR-0001, docs/2.2 |
| .gwy / Gwyddion | SPM data-analysis file format / tool; measurement `result_path` targets. | ADR-0002, Gwyddion repo |
| PostgreSQL | Future DB target (HDF5 → SQLite → PostgreSQL roadmap). | ADR-0001 |

## Hardware & optics

| Term | Definition | Source |
|------|------------|--------|
| AFM | Atomic Force Microscope; scanner (OpenSPM-compatible). | 0_overview, docs/1.1 |
| OpenSPM | AFM scanner compatibility target. | 0_overview |
| Indenter / Indentation | Indentation hardware and its lab workflow. | 0_overview, docs/1.2 |
| Linear stage | Positioning hardware; plug-and-play across manufacturers. Defines stage coordinate frame. | 0_overview, ADR-0002 |
| FOV (Field of View) | Optical microscope field of view; ~5 μm/pixel current resolution. | ADR-0002 |
| Fiducial marker | Reference marker for cross-session coordinate registration (on sample = destructive; on holder = preferred). | ADR-0002 |
| FIB (Focused Ion Beam) | Destructive method of marking sample fiducials. | ADR-0002 |
| Kinematic mount | Hardware for reproducible sample-holder repositioning; enables holder-based fiducials. | ADR-0002 |

## Process

| Term | Definition | Source |
|------|------------|--------|
| BDD | Behavior-Driven Development scenarios (Given/When/Then). Phase 1 output. | spec-align |
| SDD | Software Design Document. Phase 2 output → `document/docs/specs/`. | spec-align |
| ADR | Architecture Decision Record. `document/docs/adr/`. | docs/adr |
| TDD | Test-Driven Development process adopted for the refactoring. | ADR-0009 |

---

## Internal jargon — add yours here

> Drop any internal shorthand the docs don't cover, format `term — definition — repo/doc`,
> and I'll fold it into the tables above. Also confirm the **(confirm)** entries.
