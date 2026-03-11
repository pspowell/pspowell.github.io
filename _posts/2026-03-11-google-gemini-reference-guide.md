---
layout: post
title: "The Complete Google Gemini Reference Guide"
description: "A comprehensive guide to capabilities, tips, and tricks for optimal use of Google Gemini, including command aliases and workflow shortcuts."
date: 2026-03-11
category: reference
tags: [AI, Gemini, Productivity, Guide, Shortcuts]
---

# Google Gemini: The Complete Reference Guide

Welcome to the ultimate reference document for Google Gemini. This guide covers the core capabilities of the platform, the best prompting strategies, and the fastest shortcuts and aliases to get the most out of your interactions.

## Table of Contents
* [Core Capabilities](#core-capabilities)
  * [1. Text & Code Synthesis](#1-text--code-synthesis)
  * [2. Image Generation & Editing](#2-image-generation--editing)
  * [3. Video Generation](#3-video-generation)
  * [4. Music Generation](#4-music-generation)
  * [5. Gemini Live Mode](#5-gemini-live-mode)
* [Tips & Tricks for Optimal Prompting](#tips--tricks-for-optimal-prompting)
* [Quick Reference: Prompting Strategies](#quick-reference-prompting-strategies)
* [Advanced Multimodal Workflows](#advanced-multimodal-workflows)
  * [1. Image Editing and Composition](#1-image-editing-and-composition)
  * [2. Video Direction](#2-video-direction)
  * [3. Music Production](#3-music-production)
* [Mastering Gemini Live (Mobile)](#mastering-gemini-live-mobile)
* [Advanced Workspace Integrations](#advanced-workspace-integrations)
* [Best Practices for Hallucination Mitigation](#best-practices-for-hallucination-mitigation)
* [The 4-Part Prompt Framework](#the-4-part-prompt-framework)
  * [Specific Use-Case Templates](#specific-use-case-templates-text-expander-aliases)
* [Integrating Gemini via API](#integrating-gemini-via-api)
* [Extracting a Policy Block (Context Synthesis)](#extracting-a-policy-block-context-synthesis)

---

## Core Capabilities

As Gemini 3.1 Pro, operating on the Paid tier, the platform brings a highly robust set of generative and analytical tools.

### 1. Text & Code Synthesis
* **Deep Analysis:** Capable of processing massive context windows for entire books or codebases.
* **Agentic Workflows:** Performs multi-step reasoning and formats data into complex structures.
* **Shortcut / Alias:** Use the `+` icon or drag-and-drop to upload files instantly. In supported IDEs, use the shortcut `Cmd/Ctrl + I` to trigger inline code generation.

### 2. Image Generation & Editing
* **Powered By:** Nano Banana 2 (officially known as Gemini 3 Flash Image).
* **Features:** State-of-the-art text-to-image generation, editing, composition, and style transfer. 
* **Shortcut / Alias:** Start your prompt with action verbs like `> Draw`, `> Generate`, or `> Create an image of`. 
* **Pro Shortcut:** To upgrade an image, click the three-dot menu and select **Redo with Pro** (accesses the Nano Banana Pro model).

### 3. Video Generation 
* **Powered By:** Veo.
* **Features:** Generates high-fidelity videos with natively generated audio, text-to-video, and video extension.
* **Shortcut / Alias:** Use the prompt alias `> Animate this` when attaching reference images, or start text prompts with `> Create a video showing...`

### 4. Music Generation 
* **Powered By:** Lyria 3.
* **Features:** Creates professional-grade 30-second tracks with granular control over tempo, genre, and mood (includes SynthID watermark).
* **Shortcut / Alias:** Start prompts with `> Score this` (for images/video) or `> Produce a track...`

### 5. Gemini Live Mode
* **Availability:** Android and iOS.
* **Features:** Natural, real-time voice conversations with screen and camera sharing.
* **Shortcut / Alias:** Tap the **Waveform Icon** in the mobile app to launch instantly. Say *"Hold on"* or *"Stop"* to interrupt the model mid-sentence.

---

## Tips & Tricks for Optimal Prompting

### The "Anchor" Technique for Massive Context
Load your context (PDFs, videos, code) *first*. Put your specific instructions at the very *end* of the prompt.
* **Shortcut / Alias:** Save a text-expander snippet like `/anchor`: *"Based strictly on the documents uploaded above, answer the following: [Insert Question]"*

### Leverage @ Extensions
* **Best Practice:** Pull real-time data from Workspace files.
* **Shortcut / Alias:** Type `@` to immediately open the extension drop-down. Use `@Docs [Filename]` or `@Drive [Keyword]` to bypass manual searching.

### Command, Don't Chat
* **Best Practice:** Use specific formatting constraints rather than conversational requests.
* **Shortcut / Alias:** Prefix your desired output format at the end of the prompt: `-> [Markdown Table]`, `-> [JSON]`, or `-> [Bulleted List]`.

---

## Quick Reference: Prompting Strategies

| Technique | Description | Shortcut / Alias |
| :--- | :--- | :--- |
| **Zero-Shot** | Direct question with no examples. | `> Define: [Term]` |
| **Few-Shot** | Providing 2-3 examples of desired output. | `> Pattern: [Ex 1], [Ex 2]. Now do [Task]` |
| **Prompt Chaining** | Breaking a large task into sequential prompts. | `> Step 1 of 3: [Task]` |
| **Directional Cues** | Assigning a specific persona. | `> Act As: [Persona]` |

---

## Advanced Multimodal Workflows

### 1. Image Editing and Composition
* **Features:** Inpainting, outpainting, and style transfer.
* **Shortcut / Alias:** Upload an image and use quick commands like `> Remove background`, `> Expand to 16:9`, or `> Apply watercolor style`.

### 2. Video Direction
* **Features:** Audio cues, video extension, and keyframing via reference images.
* **Shortcut / Alias:** Upload a start and end image and use the alias `> Morph A to B`. For audio, append `[Audio: description]` to your prompt.

### 3. Music Production
* **Features:** High-fidelity, 30-second track generation. 
* **Shortcut / Alias:** Use standard musical notation abbreviations in your prompt (e.g., `> 120BPM`, `> 4/4 time`, `> C minor`).

---

## Mastering Gemini Live (Mobile)

* **Interrupt and Pivot:** You don't need to wait for Gemini to finish speaking.
* **Shortcut / Alias:** Use physical gestures (if enabled) or quick verbal stops like *"Pivot,"* *"Nevermind,"* or *"Skip to the end."*
* **Context Sharing:** * **Shortcut / Alias:** Tap the **Camera Icon** during a Live session to instantly share your physical environment, or use the **Share Screen** system prompt to discuss active apps.

---

## Advanced Workspace Integrations

* **Cross-App Synthesis:** Use multiple `@` tags to cross-reference data.
* **Shortcut / Alias:** `> Compare @DocA and @DocB -> [Summary]`
* **Drafting & Iteration:** * **Shortcut / Alias:** Click the **Share & export** icon -> **Export to Docs** to move text instantly. Inside Google Docs, use the shortcut `Help me write` (the pencil icon hovering on the left margin) to continue prompting.

---

## Best Practices for Hallucination Mitigation

1.  **Mandate Citations:** * **Shortcut / Alias:** Append `+CiteSources` or `+URLs` to the end of your prompt.
2.  **The "I Don't Know" Clause:** * **Shortcut / Alias:** Append `+StrictContext`. (e.g., *"If not in the document, say 'I do not know'"*).
3.  **Self-Correction Prompts:** * **Shortcut / Alias:** Follow up a complex generation with the quick command: `> Critique your previous response for logical flaws.`

---

## The 4-Part Prompt Framework

Use the **PACT** framework shortcut for reliable results:
1. **P**ersona: Tell Gemini who it is.
2. **A**ction: State exactly what you need done.
3. **C**ontext: Provide the background.
4. **T**emplate: Define the exact output structure.

### Specific Use-Case Templates (Text Expander Aliases)

Create shortcuts in your OS text expander to instantly populate these frameworks:

* **Code Generation (`!gencode`):**
    > "Act As: Senior Developer. Action: Write [Language] code for [Task]. Context: [Environment/Constraints]. Template: Executable code only, inline comments."

* **Copywriting (`!gencopy`):**
    > "Act As: Digital Marketer. Action: Write a [Format] using the AIDA framework. Context: Target audience is [Audience]. Template: Catchy hook, under [X] words, one clear CTA."

* **Data Analysis (`!gendata`):**
    > "Act As: Data Analyst. Action: Extract [Data Points]. Context: Attached raw text. Template: Clean Markdown table with columns [A, B, C]."

---

## Integrating Gemini via API

* **The Hub:** Google AI Studio. 
* **Shortcut / Alias:** Go to `aistudio.google.com` to instantly grab your API key and access the GUI testing environment.
* **Core API Capabilities:** Structured JSON outputs, Function Calling, and Multimodal Live API via WebSockets.
* **Workflow Automation Shortcuts:** Search for "Gemini App" in Zapier, n8n, or Make.com to drop pre-built AI nodes into your automated pipelines without writing code.

---

## Extracting a Policy Block (Context Synthesis)

To avoid losing valuable context, extract learned parameters into a portable "Policy Block."

* **The Extraction Prompt Shortcut (`!policy`):**
    > "Review our conversation history. Extract a 'Policy Block' organizing our rules into: 1. Core Objective, 2. Persona, 3. Formatting Constraints, 4. Negative Constraints. Output as a clean text block."
* **The Application Shortcut (`!loadpolicy`):**
    > "Act according to the following Policy Block for this session: [Paste Block]"