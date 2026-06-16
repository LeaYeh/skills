# Publishing mechanics (Hugo + Blowfish)

Hugo source: `<blog>/apps/portal/src` (default `~/project/git_dev/lyeh-infra/apps/portal/src`).
Posts live in `content/posts/` as flat files. Existing posts use **YAML** front matter (`---`), not TOML.

## File naming (bilingual)

One slug, two language files in `content/posts/`:

```
content/posts/<slug>.en.md
content/posts/<slug>.zh.md
```

`<slug>` is kebab-case, English, descriptive (e.g. `gitops-self-hosting-on-k3s`).

## Front matter

Identical keys in both files; `title`/`summary` translated, `translationKey` shared so Hugo links the two as translations.

```yaml
---
title: "<title in this file's language>"
date: <YYYY-MM-DD>          # get the real date at runtime: `date +%Y-%m-%d` — never hardcode
draft: true                 # ALWAYS true; the user publishes manually
tags: ["Tag1", "Tag2"]      # same tags both languages, English tag names
summary: "<1–2 sentence summary in this file's language>"
translationKey: "<slug>"    # SAME value in both .en.md and .zh.md
---
```

## One-time i18n setup (do once, then skip)

The blog ships English-only. Before writing the first zh post, check for `config/_default/languages.zh.toml`. If missing, create it and the matching menu, modelled on the existing `.en.toml` files:

`config/_default/languages.zh.toml`
```toml
locale = "zh-tw"
label = "中文"
weight = 2
title = "Lea Yeh"

[params]
  displayName = "中文"
  isoCode = "zh-tw"
  rtl = false
  dateFormat = "2006年1月2日"
  description = "資深軟體工程師 · 資料工程 · MLOps · 系統架構"
```

Copy `config/_default/menus.en.toml` to `config/_default/menus.zh.toml`, translating only the visible labels. Leave `hugo.toml`'s `defaultContentLanguage = "en"` as-is — Hugo auto-merges `languages.<lang>.toml`, so adding the file is enough to enable the language switcher. Confirm with the user before editing config; mention it in the hand-off.

## Preview

From the Hugo source dir: `hugo server -D` (the `-D` flag renders drafts). Drafts are excluded from production builds until `draft: true` is removed.
