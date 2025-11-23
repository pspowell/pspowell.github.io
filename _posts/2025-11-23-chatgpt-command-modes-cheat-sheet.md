---
layout: post
title: "ChatGPT Command Modes Cheat Sheet"
date: 2025-11-23
tags: [chatgpt, shortcuts, modes, howto]
---

This post documents the custom **command modes** I use with ChatGPT to control how it responds.  
All commands are typed **at the start of a message** (except `s` and `go`, which can be sent alone).

---

## Core Control Commands

### Standby / Resume

- **`s`** – *Standby mode*  
  - Puts ChatGPT into **listen-only** mode.  
  - It will **not respond** again until I send `go`.

- **`go`** – *Resume / process*  
  - Tells ChatGPT to **resume normal processing** and reply to my next message.

### Reset

- **`reset`** – *Clear modes*  
  - Clears any temporary modes like `min`, `max`, `nx`, etc.  
  - Returns output to **normal length, normal style**.  
  - Does **not** erase memory, only response-mode tweaks.

---

## Output-Control Modes

These change **how long or structured** the answer is.

- **`nx`** – *No extras*  
  - Short, direct answer. No side comments or fluff.

- **`min`** – *Minimal mode*  
  - One or two sentences. Very concise.

- **`max`** – *Detailed mode*  
  - Very thorough, expanded explanation with extra context.

- **`1s`** – *One-sentence mode*  
  - Exactly **one sentence** in the reply.

- **`bp`** – *Bullet-point mode*  
  - Respond using **bullet lists** instead of paragraphs when possible.

- **`code`** – *Code-only mode*  
  - Output is **only code blocks**, with no explanation text around them.

---

## Writing Style Modes

These change the **tone or style** of the writing.

- **`cas`** – *Casual*  
  - Friendly, informal tone.

- **`fmt`** – *Formal*  
  - More professional, polished phrasing.

- **`leg`** – *Legal tone*  
  - Legal-ish structure and wording (still informational, not legal advice).

- **`tec`** – *Technical*  
  - More technical language, geared toward experienced users.

- **`ast`** – *Assertive*  
  - Direct, confident language.

- **`pol`** – *Polite*  
  - Extra courteous and softened phrasing.

---

## Task / Transformation Modes

These tell ChatGPT **what to do with text** I provide.

- **`sum`** – *Summarize*  
  - Summarize the text or content I provide next.

- **`xp`** – *Expand*  
  - Make the text longer, more detailed, or more fully explained.

- **`sh`** – *Shorten*  
  - Compress the content while keeping the key meaning.

- **`rw`** – *Rewrite*  
  - Rephrase the text with the **same meaning**, different wording.

- **`fx`** – *Fix*  
  - Improve grammar, clarity, and readability without changing the core meaning.

- **`tr`** – *Translate*  
  - Translate the provided text into the language I specify (or into English by default).

---

## Coding / Technical Modes

These commands are useful when working with code or technical content.

- **`dbg`** – *Debug code*  
  - Look for bugs, errors, and logic problems in the code I paste.

- **`opt`** – *Optimize code*  
  - Suggest improvements for performance, readability, or structure.

- **`conv`** – *Convert code*  
  - Convert code from one language to another (e.g., Python → C#).

- **`tpl`** – *Template*  
  - Generate a generic **starter template** for the thing I describe (script, document, etc.).

---

## Creative / Idea Modes

- **`br`** – *Brainstorm*  
  - Generate ideas, options, or variations around a topic.

- **`ls`** – *List*  
  - Produce a structured list of items, steps, or options.

- **`st`** – *Story mode*  
  - Write narrative-style text (stories, scenes, etc.).

- **`cont`** – *Continue*  
  - Continue from the previous text or section without restarting.

---

## Usage Examples

### 1. Enter standby, then resume

```text
s
```

*(ChatGPT goes quiet and waits.)*

```text
go
Explain what happens when police take your phone during an arrest.
```

---

### 2. Ask for a very short answer

```text
min
In one or two sentences, what is Riley v. California about?
```

---

### 3. Get a detailed technical explanation

```text
max tec
Explain how BitLocker works on Windows 11 and how recovery keys are stored.
```

---

### 4. Rewrite and clean up text

```text
rw fx
[paste messy paragraph here]
```

ChatGPT will **rewrite** the text and **fix grammar/clarity** at the same time.

---

### 5. Summarize something in bullet points

```text
sum bp
[paste long email or article]
```

---

## Notes

- Commands like `min`, `max`, `nx`, `bp`, `code`, style modes, and task modes apply to the **current request** (and possibly nearby ones) until I override them or use `reset`.
- `s` (standby) and `go` (resume) are **always available** as my main control switches.
- `reset` is the quick way to go **back to normal behavior** if things get too verbose or constrained.

This cheat sheet is meant for my own workflow with ChatGPT so I can drive it quickly with short commands.
