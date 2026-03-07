---
layout: post
title: "Creating Jekyll Markdown Posts"
date: 2026-03-07
tags:
  - jekyll
  - markdown
  - github-pages
  - publishing
---

# Creating Jekyll Markdown Posts {#creating-jekyll-markdown-posts}

A practical reference guide for writing, naming, and publishing Jekyll Markdown posts that are ready to drop into your `_posts` directory.

## Purpose {#purpose}

Jekyll uses Markdown files with YAML front matter to generate blog posts and pages. A well-formed post file gives you predictable URLs, correct post dates, reliable rendering on GitHub Pages, and a clean publishing workflow.

This guide is meant to serve as a repeatable reference for creating posts that work the first time, especially when you want to generate content quickly and publish without reformatting.

## When to Use It {#when-to-use-it}

Use a Jekyll Markdown post whenever you want to publish dated content such as:

- reference guides
- tutorials
- changelogs
- project notes
- technical writeups
- announcements

A Jekyll post is the right choice when the content belongs in your site's `_posts` folder and should be treated as a dated article rather than a standalone page.

## How It Works {#how-it-works}

A Jekyll post is normally a Markdown file stored in the `_posts` directory using this filename pattern:

```text
YYYY-MM-DD-title.md
```

Example:

```text
2026-03-07-creating-jekyll-markdown-posts.md
```

The file has two main parts:

1. **YAML front matter** at the top, surrounded by `---`
2. **Markdown body content** below it

### YAML Front Matter {#yaml-front-matter}

The front matter tells Jekyll how to treat the file. A common post header looks like this:

```yaml
---
layout: post
title: "Creating Jekyll Markdown Posts"
date: 2026-03-07
tags:
  - jekyll
  - markdown
  - github-pages
---
```

Typical fields include:

- `layout`: usually `post`
- `title`: the human-readable post title
- `date`: the post date
- `tags`: optional classification labels

Depending on your theme or site, you may also use fields such as `categories`, `excerpt`, `author`, or custom metadata.

### Filename Rules {#filename-rules}

For posts, the filename matters just as much as the content.

Use:

```text
YYYY-MM-DD-title.md
```

Important conventions:

- use **dashes** between all filename parts
- do **not** use underscores in the filename
- keep the title slug lowercase unless you intentionally want mixed case
- use short, readable words in the slug

Good examples:

```text
2026-03-07-creating-jekyll-markdown-posts.md
2026-03-07-chat-policy-block-reference-guide.md
2026-03-07-uv-onedrive-workflow.md
```

Bad examples:

```text
2026_03_07_creating_jekyll_markdown_posts.md
03-07-2026-creating-jekyll-markdown-posts.md
creating-jekyll-markdown-posts.md
```

### Markdown Body {#markdown-body}

After the front matter, write the article in standard Markdown. Jekyll will render headings, paragraphs, code fences, lists, links, images, and tables.

A minimal post body might look like this:

```md
# My Post Title

This is the opening paragraph.

## Section Heading

Some content here.
```

For GitHub Pages compatibility, keep the Markdown straightforward and consistent.

## Tips and Pitfalls {#tips-and-pitfalls}

### Use Dashes in Filenames {#use-dashes-in-filenames}

This is one of the most important habits. Jekyll post filenames should use dashes, not underscores. Dashes keep the date and slug readable and avoid workflow problems with post recognition and permalink generation.

### Keep Front Matter Valid {#keep-front-matter-valid}

A broken YAML block can cause the post to fail or render unexpectedly.

Common mistakes include:

- missing opening or closing `---`
- inconsistent indentation
- stray colon characters in unquoted text
- malformed lists under `tags`

When in doubt, quote the `title` value.

### Put Posts in `_posts` {#put-posts-in-posts}

A file can be perfectly written and still not behave like a post if it is placed outside `_posts`. If the content is supposed to be a dated article, store it in `_posts`.

### Use Custom Heading IDs Deliberately {#use-custom-heading-ids-deliberately}

Custom heading IDs make it easier to link directly to sections.

Example:

```md
## Tips and Pitfalls {#tips-and-pitfalls}
```

This is useful for:

- table of contents links
- cross-linking from other posts
- stable deep links even if automatic slug generation changes

### Prefer Clean Asset Paths {#prefer-clean-asset-paths}

When linking files or images in your post, use site-friendly paths that match your layout.

Example image reference:

```md
![Example diagram](/assets/images/jekyll-post-flow.png)
```

If your workflow stores post assets in `/assets`, keep those paths consistent.

### Watch Table Formatting {#watch-table-formatting}

Markdown tables can break if spacing is inconsistent or if the surrounding blank lines are missing. If you use tables in Jekyll posts, keep them simple and test the rendered result.

## Examples {#examples}

### Example 1: Minimal Jekyll Post {#example-1-minimal-jekyll-post}

```md
---
layout: post
title: "My First Jekyll Post"
date: 2026-03-07
tags:
  - jekyll
  - markdown
---

# My First Jekyll Post {#my-first-jekyll-post}

This is a simple Jekyll blog post.

## Why I Made It {#why-i-made-it}

I wanted a clean post that would publish correctly in GitHub Pages.
```

### Example 2: Post with Code Block {#example-2-post-with-code-block}

```md
---
layout: post
title: "Running a Local Jekyll Site"
date: 2026-03-07
tags:
  - jekyll
  - ruby
  - github-pages
---

# Running a Local Jekyll Site {#running-a-local-jekyll-site}

Start the local server with:

```bash
bundle exec jekyll serve
```

Then open the local address shown in the terminal.
```

### Example 3: Post with Image Reference {#example-3-post-with-image-reference}

```md
---
layout: post
title: "Understanding My Site Layout"
date: 2026-03-07
tags:
  - jekyll
  - assets
---

# Understanding My Site Layout {#understanding-my-site-layout}

![Site layout diagram](/assets/images/site-layout.png)
```

## Related Tools or Workflows {#related-tools-or-workflows}

A good Jekyll workflow often connects to the following tools and habits:

### GitHub Pages {#github-pages}

GitHub Pages is a common hosting target for Jekyll sites. Keeping your Markdown and front matter compatible with GitHub Pages helps avoid surprises during deployment.

### Local Preview Workflow {#local-preview-workflow}

If you run Jekyll locally, you can preview formatting before publishing. This is especially useful for checking:

- heading structure
- code fences
- table rendering
- image paths
- permalink behavior

### Reusable Prompt Templates {#reusable-prompt-templates}

If you generate posts with ChatGPT, a reusable prompt template can enforce:

- correct filename format
- valid front matter
- heading IDs
- consistent style
- publication-ready output

A strong prompt can save cleanup time and reduce formatting errors.

### Asset Management {#asset-management}

A consistent asset workflow makes posts easier to maintain. For example:

- store images under `/assets/...`
- use predictable names
- prefer PNG when quality and compatibility matter
- keep image references stable after publishing

## Recommended Post Creation Workflow {#recommended-post-creation-workflow}

Use this sequence when creating a new post:

1. Choose the topic.
2. Create a filename in `YYYY-MM-DD-title.md` format.
3. Add valid YAML front matter.
4. Write the content using Markdown headings with custom IDs.
5. Add any code blocks, links, tables, or image references.
6. Check that file paths and formatting are GitHub Pages compatible.
7. Save the file into `_posts`.
8. Preview locally or commit and publish.

## Quick Reference {#quick-reference}

### Required Structure {#required-structure}

```text
_posts/
  2026-03-07-creating-jekyll-markdown-posts.md
```

### Minimal Front Matter {#minimal-front-matter}

```yaml
---
layout: post
title: "Post Title"
date: 2026-03-07
---
```

### Recommended Prompt for Generated Posts {#recommended-prompt-for-generated-posts}

```text
Create a downloadable Jekyll post artifact about <TOPIC>.
Use standard Jekyll filename format YYYY-MM-DD-title.md with dashes only.
Include valid YAML front matter, custom heading IDs, and GitHub Pages compatible Markdown.
```

## Final Notes {#final-notes}

The most reliable Jekyll posts are simple, consistent, and predictable. If the filename, front matter, and Markdown body are all clean, publishing becomes much easier.

The biggest wins come from following a few non-negotiable rules:

- use `YYYY-MM-DD-title.md`
- use dashes, never underscores
- keep front matter valid
- add clear heading structure
- keep the file ready to drop into `_posts`

Once that pattern becomes habit, creating Jekyll posts is fast and repeatable.
