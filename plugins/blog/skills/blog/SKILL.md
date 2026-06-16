---
name: blog
description: Turn a valuable working session into a polished, bilingual (zh-TW + en) public technical blog post and stage it as a draft in the lyeh-infra Hugo blog. Manually triggered with /blog when the user feels the current session produced an insight worth publishing. Use when the user says "/blog", "write this up", "blog this", "把這個寫成文章", or wants to capture the value/lessons of a session as an article.
---

# Blog

Distill the **value and insight** of the current session into a public technical article, co-written through interview, then stage it as a bilingual Hugo draft. This is a flexible, conversational skill — never auto-publish.

Discussion in Traditional Chinese (zh-TW); article content in both zh-TW and English.

## Blog location

Default Hugo source: `~/project/git_dev/lyeh-infra/apps/portal/src` (posts in `content/posts/`).
If that path does not exist, ask the user for the blog repo path before writing anything.

## Workflow

### 1. Free description
Ask the user to describe, in their own words, what they found valuable about this session. Let them ramble — do not interrupt with questions yet.

### 2. Mine the session
Review the actual conversation/session context and pre-fill a draft of these dimensions. Show the user what you extracted so they can correct it:

1. **Hook** — the problem or itch that drove this; why a reader should care
2. **Context** — the setup, constraints, what was tried before
3. **Turning point / core insight** — the non-obvious thing learned (the heart of the post)
4. **How it works** — the concrete solution, with code/config snippets where they earn their place
5. **Trade-offs / what I'd do differently** — the honesty that makes it credible
6. **Takeaway** — what the reader should remember and can reuse

### 3. Interview to fill gaps
Interview the user **one question at a time**, grill-me style, only on the dimensions still thin or ambiguous after step 2. For each question, offer your recommended answer. Goal: sharpen the angle and surface the insight — not interrogate the design. Stop when the six dimensions are solid and the article's spine is clear.

### 4. Converge on an outline
Propose a title + section outline. Get a thumbs-up before drafting full prose.

### 5. Write the bilingual draft
Write the **English** post first, then the **zh-TW** translation (idiomatic, not literal — adapt examples and phrasing for a Chinese-reading developer). See [PUBLISHING.md](PUBLISHING.md) for exact front matter, file naming, and the one-time i18n setup.

### 6. De-slop — mandatory
Before writing any post to disk, you **MUST** invoke the `stop-slop` skill and run the English prose through its rules and scoring. Revise until it scores ≥ 35/50. Apply the same anti-AI-tell principles to the zh-TW version (cut filler, active voice, varied rhythm, no em dashes, trust the reader). A draft that has not passed stop-slop is not finished — do not skip this step even under time pressure.

### 7. Hand off — never commit
Report:
- the file paths written (both languages)
- how to preview locally (`hugo server -D` from the Hugo source dir)
- a reminder that `draft = true`; the user flips it and commits/pushes themselves when ready

Do not run `git add`, `git commit`, or `git push`.

## Principles

- **Insight over chronology.** A blog post is not a session transcript. Lead with the lesson; cut the dead-ends unless a dead-end *is* the lesson.
- **Show, don't summarize.** Prefer a real code/config snippet or a small table over hand-waving.
- **Honest trade-offs build trust.** Always include what didn't work or what you'd change.
- **Bilingual parity.** Both versions carry the same insight; the zh-TW one reads natively, not as a translation.
- **No slop, ever.** Every draft passes the `stop-slop` skill before it touches disk. No throat-clearing openers, no em dashes, no "not X but Y" contrasts, no narrator-from-a-distance voice.
