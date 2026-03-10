---
layout: post
title: "Jekyll Markdown Syntax Reference"
date: 2026-03-10
tags:
  - jekyll
  - markdown
  - kramdown
  - reference
---

# Jekyll Markdown Syntax Reference {#jekyll-markdown-syntax-reference}

This page is a single-file reference for writing Markdown in a typical Jekyll site.

Jekyll supports Markdown, and the default Markdown engine is **kramdown**. In practice, that means you usually have access to:

- standard Markdown
- many **kramdown** extensions
- YAML front matter at the top of the file
- optional Liquid templating inside Markdown files

Use this document as a practical cheat sheet when you forget how to format something.

> **Important:** exact behavior can vary based on your `_config.yml`, theme, plugins, and whether your site uses plain kramdown input or GFM-style input through kramdown. This reference covers the syntax you are most likely to use in normal Jekyll posts and pages.

---

## Quick start {#quick-start}

A minimal Jekyll post looks like this:

```md
---
layout: post
title: "My Post Title"
date: 2026-03-10
tags:
  - jekyll
  - markdown
---

# My Heading

This is a paragraph with **bold**, *italic*, and a [link](https://example.com).
```

---

## 1. YAML front matter {#yaml-front-matter}

Jekyll uses **YAML front matter** at the top of a file to define metadata.

### Example

```yaml
---
layout: post
title: "Example Post"
date: 2026-03-10
permalink: /example-post/
tags:
  - jekyll
  - markdown
categories:
  - docs
published: true
---
```

### Common fields

- `layout` - layout file to use
- `title` - page or post title
- `date` - publication date
- `tags` - tag list
- `categories` - category list
- `permalink` - custom output URL
- `published` - whether the page/post should be published

---

## 2. Paragraphs and line breaks {#paragraphs-and-line-breaks}

### Paragraph

Leave a blank line between paragraphs.

```md
This is the first paragraph.

This is the second paragraph.
```

### Hard line break

End a line with two trailing spaces, or use the HTML break tag.

```md
First line.  
Second line.
```

```md
First line.<br>
Second line.
```

---

## 3. Headings {#headings}

Markdown supports headings from level 1 to level 6.

```md
# H1
## H2
### H3
#### H4
##### H5
###### H6
```

### Heading IDs in kramdown

kramdown lets you assign explicit IDs to headings, which is useful for stable anchor links.

```md
## Installation {#installation}
```

You can then link to it with:

```md
[Jump to Installation](#installation)
```

---

## 4. Emphasis {#emphasis}

### Italic

```md
*italic*
_italic_
```

### Bold

```md
**bold**
__bold__
```

### Bold + italic

```md
***bold italic***
___bold italic___
```

### Strikethrough

This is commonly available when using GFM-style parsing.

```md
~~strikethrough~~
```

---

## 5. Blockquotes {#blockquotes}

```md
> This is a blockquote.
```

Nested blockquotes:

```md
> Outer quote
>> Inner quote
```

Blockquote with multiple paragraphs:

```md
> First paragraph.
>
> Second paragraph.
```

---

## 6. Lists {#lists}

### Unordered list

```md
- Item one
- Item two
- Item three
```

You can also use `*` or `+`:

```md
* Item one
* Item two
```

### Ordered list

```md
1. First
2. Second
3. Third
```

### Nested list

```md
- Parent
  - Child
  - Child
- Parent
```

### Task list

Often available with GFM-style input.

```md
- [x] Done
- [ ] Not done
```

---

## 7. Links {#links}

### Inline link

```md
[OpenAI](https://openai.com)
```

### Link with title

```md
[OpenAI](https://openai.com "OpenAI homepage")
```

### Reference-style link

```md
[OpenAI][openai]

[openai]: https://openai.com
```

### Link to local page or file

```md
[About](/about/)
[My PDF](/assets/files/example.pdf)
```

### Link to heading anchor

```md
[Go to Lists](#lists)
```

---

## 8. Images {#images}

### Inline image

```md
![Alt text](/assets/images/example.png)
```

### Image with title

```md
![Alt text](/assets/images/example.png "Optional title")
```

### Linked image

```md
[![Alt text](/assets/images/example.png)](https://example.com)
```

### Reference-style image

```md
![Alt text][logo]

[logo]: /assets/images/example.png
```

---

## 9. Inline code and code blocks {#inline-code-and-code-blocks}

### Inline code

```md
Use the `bundle exec jekyll serve` command.
```

### Fenced code block

<pre><code>```bash
bundle exec jekyll serve
```</code></pre>

### Fenced code block with language

<pre><code>```powershell
Get-ChildItem -Path .
```</code></pre>

### Indented code block

```md
    This is an indented code block.
```

### Escaping backticks in inline code

Use double backticks when the code itself contains a backtick.

```md
``code with a ` backtick``
```

---

## 10. Horizontal rules {#horizontal-rules}

Any of these usually works:

```md
---
```

```md
***
```

```md
___
```

---

## 11. Tables {#tables}

Tables are widely used in Jekyll sites when supported by the active parser/input mode.

```md
| Name | Role | Status |
|------|------|--------|
| Sam  | Admin | Active |
| Lee  | User  | Pending |
```

Alignment:

```md
| Left | Center | Right |
|:-----|:------:|------:|
| A    | B      | C     |
```

---

## 12. Escaping special characters {#escaping-special-characters}

Use a backslash to escape Markdown punctuation.

```md
\*not italic\*
\# not a heading
\[not a link\]
```

Common characters you may escape include:

```text
\\ ` * _ { } [ ] ( ) # + - . ! >
```

---

## 13. HTML inside Markdown {#html-inside-markdown}

Jekyll/kramdown allows raw HTML in Markdown files.

```md
<div class="note">
  This is raw HTML inside Markdown.
</div>
```

Useful examples:

```md
<kbd>Ctrl</kbd>+<kbd>C</kbd>
<sup>2</sup>
<sub>2</sub>
<mark>highlighted</mark>
```

Use raw HTML when Markdown syntax does not cover the formatting you need.

---

## 14. Automatic IDs and manual IDs {#automatic-ids-and-manual-ids}

kramdown can generate header IDs automatically, and it also supports manually assigned IDs.

### Manual block ID

```md
A paragraph with an explicit ID.
{: #my-paragraph}
```

### Manual class

```md
A paragraph with a CSS class.
{: .note}
```

### Multiple attributes

```md
A paragraph with both.
{: #important-note .note .warning}
```

This syntax is one of the most useful kramdown extensions in Jekyll.

---

## 15. Attribute lists (IAL) {#attribute-lists-ial}

IAL stands for **Inline Attribute List** in kramdown.

You can attach attributes to many block elements.

### Paragraph

```md
This paragraph has a class.
{: .callout}
```

### Heading

```md
## Warning {#warning .title}
```

### List

```md
- One
- Two
{: .compact-list}
```

### Image with attributes

```md
![Diagram](/assets/images/diagram.png){: width="600" .shadowed }
```

---

## 16. Definition lists {#definition-lists}

kramdown supports definition lists.

```md
Term 1
: Definition for term 1

Term 2
: Definition for term 2
: Another definition for term 2
```

Useful for glossaries and references.

---

## 17. Footnotes {#footnotes}

kramdown supports footnotes.

```md
Here is a statement with a footnote.[^1]

[^1]: This is the footnote text.
```

Footnotes can span multiple lines:

```md
Here is another footnote example.[^long]

[^long]: This footnote continues
    on the next indented line.
```

---

## 18. Abbreviations {#abbreviations}

kramdown supports abbreviations.

```md
The HTML specification is widely used.

*[HTML]: HyperText Markup Language
```

When rendered, `HTML` may show the full expansion depending on styling/output.

---

## 19. Typographic symbols and smart quotes {#typographic-symbols-and-smart-quotes}

Depending on configuration, typographic replacements may occur.

Examples you may write normally:

```md
"quotes"
-- dashes --
... ellipsis ...
```

Actual output depends on configuration and parser options.

---

## 20. Math support {#math-support}

Math is **not guaranteed by Markdown alone**. It depends on your Jekyll setup, theme, and math rendering approach.

A common style is:

```md
Inline math: $E = mc^2$

Block math:
$$
a^2 + b^2 = c^2
$$
```

This usually requires MathJax, KaTeX, or theme/plugin support.

---

## 21. Liquid in Markdown files {#liquid-in-markdown-files}

Jekyll lets you use Liquid templating in Markdown documents.

### Output a variable

```liquid
{{ page.title }}
```

### Use a filter

```liquid
{{ "/assets/files/example.pdf" | relative_url }}
```

### Conditional example

```liquid
{% if page.title %}
# {{ page.title }}
{% endif %}
```

### Loop example

```liquid
{% for post in site.posts limit:5 %}
- [{{ post.title }}]({{ post.url }})
{% endfor %}
```

### Warning about Liquid and code examples

If you want to show Liquid syntax literally, wrap it so Jekyll does not execute it:

```liquid
{% raw %}
{{ page.title }}
{% endraw %}
```

---

## 22. Comments {#comments}

### HTML comment

```md
<!-- This is an HTML comment -->
```

### Liquid comment

```liquid
{% comment %}
This will not be rendered.
{% endcomment %}
```

---

## 23. Auto-linking and bare URLs {#auto-linking-and-bare-urls}

Do not assume a plain bare URL will always render as a clickable link in every Jekyll setup.

Safer form:

```md
<https://example.com>
```

Or the standard link form:

```md
[Example](https://example.com)
```

---

## 24. Mixed Markdown + HTML examples {#mixed-markdown-html-examples}

### Collapsible section

```md
<details>
  <summary>Click to expand</summary>

  Hidden content written in **Markdown**.
</details>
```

### Keyboard shortcut

```md
Press <kbd>Ctrl</kbd>+<kbd>S</kbd> to save.
```

### Superscript / subscript

```md
H<sub>2</sub>O
x<sup>2</sup>
```

---

## 25. Common block attribute patterns {#common-block-attribute-patterns}

These are especially handy in Jekyll sites using kramdown.

### Add an ID to a paragraph

```md
Remember this paragraph.
{: #remember-this }
```

### Add classes for styling

```md
Important note.
{: .notice .notice-warning }
```

### Add attributes to a blockquote

```md
> Warning: back up your site first.
{: .warning }
```

---

## 26. Syntax you may expect but should verify {#syntax-you-may-expect-but-should-verify}

Some syntax depends on parser mode, plugins, or theme behavior.

### Task lists

```md
- [x] Completed
- [ ] Pending
```

### Strikethrough

```md
~~old text~~
```

### Tables

```md
| A | B |
|---|---|
| 1 | 2 |
```

### Emoji

```md
:smile:
```

### Math

```md
$$x + y = z$$
```

These often work, but not in every Jekyll configuration.

---

## 27. Things that are not really "Markdown tokens" but matter in Jekyll {#things-that-are-not-really-markdown-tokens-but-matter-in-jekyll}

### Front matter separators

```yaml
---
```

These are not normal Markdown content; they mark the YAML front matter block.

### Liquid delimiters

```liquid
{{ variable }}
{% tag %}
```

These belong to Liquid, not Markdown, but they are commonly used inside Jekyll Markdown files.

### HTML tags

```html
<div></div>
```

These are HTML, but Jekyll Markdown files often include them.

---

## 28. Copy-ready examples by task {#copy-ready-examples-by-task}

### Create a note box

```md
> **Note:** Review `_config.yml` after changing plugins.
{: .notice }
```

### Create a section with a stable anchor

```md
## Restore workflow {#restore-workflow}
```

### Link to a local asset

```md
[Download the ZIP](/assets/files/toolkit.zip)
```

### Show a shell command

<pre><code>```bash
bundle exec jekyll build
```</code></pre>

### Show PowerShell

<pre><code>```powershell
Get-ChildItem -Force
```</code></pre>

### Create a glossary entry

```md
Front matter
: YAML metadata at the top of a Jekyll file.
```

### Add a footnote

```md
This behavior depends on configuration.[^config]

[^config]: Check `_config.yml` and theme docs.
```

---

## 29. Recommended habits for Jekyll writing {#recommended-habits-for-jekyll-writing}

1. Use explicit heading IDs when you want stable anchors.
2. Prefer normal Markdown first; use HTML only when needed.
3. Use fenced code blocks with a language whenever possible.
4. Use absolute asset paths like `/assets/...` for site files.
5. Be careful when showing Liquid examples; use `{% raw %}` when needed.
6. Verify parser-dependent features such as task lists, math, emoji, and strikethrough.

---

## 30. One-page syntax index {#one-page-syntax-index}

| Purpose | Syntax |
|---|---|
| Front matter | `---` YAML `---` |
| H1-H6 | `#` through `######` |
| Italic | `*text*` or `_text_` |
| Bold | `**text**` or `__text__` |
| Bold italic | `***text***` |
| Strikethrough | `~~text~~` |
| Blockquote | `> quote` |
| Unordered list | `- item` |
| Ordered list | `1. item` |
| Task list | `- [ ] item` |
| Link | `[text](url)` |
| Image | `![alt](url)` |
| Inline code | `` `code` `` |
| Fenced code | <code>```lang</code> |
| Horizontal rule | `---` |
| Table | `| a | b |` |
| Footnote ref | `[^1]` |
| Footnote def | `[^1]: note` |
| Definition list | `Term` then `: Definition` |
| Abbreviation | `*[HTML]: HyperText Markup Language` |
| Header ID | `## Title {#id}` |
| Block attributes | `{: .class #id }` |
| HTML | `<div>...</div>` |
| Liquid output | `{{ page.title }}` |
| Liquid tag | `{% if %}...{% endif %}` |
| Raw Liquid escape | `{% raw %}...{% endraw %}` |

---

## 31. Final note {#final-note}

If something in this file does not render the way you expect, the first places to check are:

- `_config.yml`
- your active Jekyll theme
- whether you are using standard kramdown input or GFM-style input through kramdown
- whether a feature requires additional JavaScript, CSS, or a plugin

For everyday authoring, the syntax in this document covers the vast majority of what you will actually need.
