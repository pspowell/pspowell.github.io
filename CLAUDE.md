# Site rules for Claude

This repo is Preston Powell's Jekyll site, **Highland Services** (https://pspowell.github.io), built by GitHub Pages with the **Minimal Mistakes** theme (`remote_theme`, pinned in `_config.yml`). Posts go straight to `main` when Preston asks for a post to be created and pushed.

## New posts

- **Filename:** `_posts/YYYY-MM-DD-title-with-dashes.md`. Use lowercase with dashes, no spaces or underscores.
- **Front matter** (no `layout:` line; the post layout comes from `_config.yml` defaults, and `layout: post` or `layout: page` would break the page because the theme has neither):

```yaml
---
title: "Post Title"
date: YYYY-MM-DD HH:MM:SS -0500
categories: ["One of the nine below"]
tags: [lowercase, dash-separated, topic-tags]
excerpt: "One or two sentences shown in post lists and search results."
---
```

- **Exactly one category**, spelled exactly as below, quoted, in a list. Pick the best fit. If nothing fits, use the closest one and tell Preston, rather than inventing a new category.

| Category | Covers |
|---|---|
| `Windows & PC Help` | Fixing, backing up, imaging, upgrading and migrating Windows PCs; Windows utilities |
| `Coding & Automation` | PowerShell, Python/uv, Docker/WSL, C#/C++, Excel/DAX/Power Query, Google Apps Script, GnuCash/Fidelity import tooling, Jekyll |
| `AI & Chat Tools` | ChatGPT, Claude, Gemini, Copilot, agentic AI, prompting, AI explainers |
| `Money & Retirement` | Social Security, Medicare, taxes, investing, bookkeeping concepts, negotiating, buying |
| `Kitchen & Recipes` | Recipes, baking, cocktails, cookware care |
| `Home, Shop & DIY` | Woodworking, welding, tractors and small engines, electrical/lighting, home projects, appliance repair, garden |
| `Health & Safety` | Health, wellness, online privacy and safety, legal rights, difficult conversations |
| `Local Interest` | Champaign County / Urbana / central Ohio news, issues, food, folklore |
| `Life & Leisure` | Careers, management, etiquette, games, sports, hobbies |

- **Don't start the body with a `#` heading that repeats the title**; the theme already shows it. Start with an intro paragraph, then use `##` sections. Long posts get an automatic "On this page" menu built from those headings.
- Use Kramdown-compatible tables. Put images in `/assets/` (PNG) and downloads in `/assets/` or `/assets/scripts/`.
- Link to other posts with `{% post_url YYYY-MM-DD-slug %}` and to site pages with `{{ '/path/' | relative_url }}`.

## Don't

- Don't change `permalink`, `timezone` or the category names in `_config.yml`, `_data/navigation.yml` or `_pages/category-*.md`. Post URLs and the topic pages depend on them.
- Don't rename or re-date existing posts without adding `redirect_from:` with the old URL.
- Don't add plugins that GitHub Pages doesn't support (https://pages.github.com/versions/).

## Where things are

- `_config.yml`: site settings, theme, post defaults
- `_data/navigation.yml`: top menu
- `_pages/`: About, the all-topics page, the nine category pages, tags, year archive, search, 404
- `index.html`: home page with topic tiles
- Snapshot of the pre-theme site: branch `archive/minima`, tag `minima-final-2026-11-14`
