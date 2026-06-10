# skills

Personal Agent Skills Collection for Claude Code.

## Installation

```
/plugin marketplace add LeaYeh/skills
```

Then install individual skills:

```
/plugin install <skill-name>
```

## Available Skills

| Name | Description |
|------|-------------|
| [commit-splitter](plugins/commit-splitter) | Scan pending changes and produce an ordered conventional-commit plan; confirms before any git write |
| [grill-graph](plugins/grill-graph) | Heavyweight grilling that records the decision tree as a live graph — rejected branches, re-assumptions, back-references — then converges it into a spec |
| [learn-mentor](plugins/learn-mentor) | Learning mentor that drives true mastery of a topic instead of completing the task for you — decomposes a learning goal into stages and runs each through gap-surfacing, guided paper reading, hands-on implementation, and teach-back, withholding exactly the skill the goal targets |
| [spec-align](plugins/spec-align) | Single entry point for requirements → architecture alignment — Phase 1 grills the product owner into BDD scenarios, Phase 2 grills the SWE on architecture and records an SDD |

## Adding a New Skill

1. Create the skill directory structure:

```
plugins/<skill-name>/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    └── <skill-name>/
        └── SKILL.md
```

2. **`plugin.json`** — metadata:

```json
{
  "name": "<skill-name>",
  "description": "<one-line trigger description>",
  "author": { "name": "Lea Yeh" },
  "category": "development",
  "homepage": "https://github.com/LeaYeh/skills"
}
```

3. **`SKILL.md`** — frontmatter + prompt body:

```markdown
---
name: <skill-name>
description: "<trigger phrases and when to invoke this skill>"
---

# <Skill Title>

<Prompt body here>
```

4. Add an entry to `.claude-plugin/marketplace.json` `plugins` array:

```json
{
  "name": "<skill-name>",
  "description": "<one-line trigger description>",
  "author": { "name": "Lea Yeh" },
  "source": "./plugins/<skill-name>",
  "category": "development",
  "homepage": "https://github.com/LeaYeh/skills"
}
```

5. Commit, push — the skill is immediately available via `/plugin install <skill-name>`.
