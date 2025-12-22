---
layout: post
title: "CIF Language Definition by Preston Powell"
date: 2025-12-21 00:00:00 -0500
tags: [CIF, Chat Instructional Format, language, specification]
---

# CIF Language Definition {#cif-language-definition}

*Chat Instructional Format (CIF)*  
**by Preston Powell**

## Preface {#preface}

This book defines **CIF**, the *Chat Instructional Format*, as a language.

It is not a prompt style, a conversational technique, or a collection of best practices. It is not advice on how to persuade or coax an artificial system. CIF exists to restore clarity, authority, and determinism to instruction in environments that have become dominated by negotiation, inference, and ambiguity.

Modern conversational systems blur the line between instruction and dialogue. They optimize for helpfulness, fluency, and approximation. CIF rejects this model. It asserts that there are situations in which a client does not want collaboration, suggestion, or interpretation. The client wants execution.

CIF treats instruction as an authored artifact. A CIF document is written once, read as a whole, and processed in order. It is intended to be understood by both humans and machines, replayed, audited, and reasoned about.

This book defines the CIF language, its execution model, its control semantics, and its philosophy of restraint. It is written for readers who value precision over convenience, and discipline over improvisation.

## The problem CIF addresses {#the-problem-cif-addresses}

Conversational systems encourage ambiguity by design. They infer intent, smooth over gaps, and negotiate meaning dynamically. While this behavior is often useful, it breaks down when the client requires:

- Predictable execution
- Reproducible outcomes
- Clear authority
- Auditable instruction

In conversational instruction, the unit of control is the *message*. Each exchange resets context, invites reinterpretation, and introduces drift. The system becomes an active participant in shaping the task, rather than an executor of it.

CIF addresses this failure mode by redefining the unit of control. In CIF, the unit is not a message. It is a **document**.

## The CIF mental model {#the-cif-mental-model}

CIF is built on a small number of non-negotiable ideas.

First, **authority is explicit**. The client authors instructions. The system executes them.

Second, **order is meaningful**. Instructions are processed serially, in the order provided. No reordering, merging, or optimization is implied unless explicitly commanded.

Third, **control and content are separate**. CIF distinguishes between lines that modify execution behavior and lines that describe work to be done.

Fourth, **inference is forbidden by default**. CIF does not guess. It does not fill gaps. It reports errors instead of compensating for them.

These ideas are not optional conventions. They define the language.

## Roles and responsibility {#roles-and-responsibility}

CIF defines two roles.

### The client {#the-client}

The client is the authoritative author of the instruction document. The client is responsible for:

- Completeness of instructions
- Correct ordering
- Explicit intent

Ambiguity in a CIF document is an error condition, not an invitation for interpretation.

### The executor {#the-executor}

The executor (human or machine) is responsible for:

- Reading the document as written
- Processing instructions serially
- Respecting control commands
- Reporting errors faithfully

The executor does not negotiate scope, reinterpret goals, or substitute alternatives unless explicitly instructed to do so.

## The CIF instruction document {#the-cif-instruction-document}

A CIF instruction document is a linear text artifact. It is not conversational. It is not interactive by default.

A document may contain:

- Control commands
- Instructional content
- Nested execution blocks

The document is read top to bottom. Earlier instructions establish context for later ones.

The document, once execution begins, is the source of truth.

## Control vs content {#control-vs-content}

CIF draws a strict boundary between **control** and **content**.

- Control modifies *how* execution proceeds.
- Content describes *what* is to be done.

This boundary is enforced syntactically.

## Control prefix {#control-prefix}

All CIF control commands MUST begin with a single reserved prefix character:

```text
!
```

Any line whose first non-whitespace character is `!` is interpreted as a CIF control command.

Lines without this prefix are treated as content or instructions.

Prefix stacking is forbidden. Multiple control characters have no meaning and are invalid.

## Core control commands {#core-control-commands}

CIF defines a baseline command set.

### Execution flow {#execution-flow}

- `!BEGIN`  
  Marks the beginning of an execution block.

- `!END`  
  Marks the end of an execution block.

- `!PAUSE`  
  Suspends execution while preserving state.

- `!GO`  
  Resumes execution from the current state.

- `!STOP`  
  Terminates execution immediately.

### Interpretation control {#interpretation-control}

- `!STRICT`  
  Disables inference, assumption, and optimization.

- `!LITERAL`  
  Requires exact interpretation of content as written.

### Error handling {#error-handling}

- `!ON_ERROR STOP`  
  Any error halts execution.

- `!ON_ERROR CONTINUE`  
  Errors are reported but execution continues.

These commands are finite, explicit, and versioned. Unrecognized commands are errors under `!STRICT`.

## Serial execution semantics {#serial-execution-semantics}

CIF execution is serial.

Each instruction is processed only after the previous instruction completes. There is no implicit parallelism. There is no speculative execution.

State changes persist unless explicitly reverted.

Order is semantic, not cosmetic.

## Nesting and scope {#nesting-and-scope}

CIF supports nesting through explicit scoping.

Nesting is achieved using `!BEGIN` and `!END` blocks.

```text
!BEGIN CHAT
Outer instructions

!BEGIN CHAT
Inner instructions
!END CHAT

Resume outer instructions
!END CHAT
```

Each nested block creates a child execution context. Context is inherited unless overridden by control commands within the block.

Control prefixes do not stack. Scope is defined structurally, not symbolically.

## Scope rules {#scope-rules}

- Every `!BEGIN` MUST have a corresponding `!END`.
- Scope is lexical and explicit.
- Control commands apply to the current scope.
- Errors may either terminate the current scope or propagate, depending on error policy.

Implicit scope is forbidden.

## Error philosophy {#error-philosophy}

Errors in CIF are signals, not inconveniences.

CIF does not compensate for missing instructions. It does not guess intent. It does not repair ambiguity.

An error means the document is incorrect or incomplete. The correct response is revision, not improvisation.

This is intentional. CIF favors correctness over progress.

## Intent contracts and loyalty rules {#intent-contracts-and-loyalty-rules}

CIF allows a client to define **intent contracts**: explicit, binding rules that the executor MUST remain loyal to for the duration of execution.

Intent contracts exist to prevent drift, reinterpretation, and silent goal substitution. They are not suggestions. They are invariants.

### Intent blocks {#intent-blocks}

Intent rules are declared inside a dedicated intent scope.

```text
!BEGIN INTENT
!STRICT

MUST: Execute instructions serially in document order.
MUST: Ask for clarification if required input is missing.
MUST NOT: Invent facts, sources, or outputs.
MUST NOT: Modify the client’s wording unless instructed.
MUST: Preserve formatting exactly as specified.

!END INTENT
```

Rules inside an intent block apply globally to the document and all nested scopes unless explicitly overridden.

### Locking intent {#locking-intent}

Once intent rules are established, they may be locked.

```text
!LOCK INTENT
```

When intent is locked:
- No additional intent rules may be added
- Existing intent rules may not be modified
- Overrides are forbidden unless explicitly unlocked

Locking intent is the default best practice for CIF.

### Intent enforcement {#intent-enforcement}

CIF defines explicit behavior for intent violations.

```text
!ON_INTENT_VIOLATION STOP
```

or

```text
!ON_INTENT_VIOLATION REPORT_AND_STOP
```

Intent violations are errors, not warnings. Execution must not continue silently after a violation.

### Assertions and requirements {#assertions-and-requirements}

CIF provides enforcement primitives to make intent testable.

- `!REQUIRE` declares a condition that must be true before execution proceeds.
- `!ASSERT` validates that execution has remained within intent boundaries.

```text
!REQUIRE "All required inputs are present"
!ASSERT "No assumptions were introduced"
```

### Overriding intent {#overriding-intent}

By default, intent contracts are non-overridable.

If overrides are permitted, they must require explicit authorization.

```text
!UNLOCK INTENT "Reason required"
```

This command SHOULD be rare and auditable. CIF favors immutability of intent.

### Intent as loyalty {#intent-as-loyalty}

In CIF, loyalty is not behavioral or emotional. It is contractual.

An executor is loyal if and only if:
- It obeys all active intent rules
- It halts or reports when violation occurs
- It refuses to proceed under ambiguity

Intent contracts transform trust from expectation into structure.

## What CIF explicitly refuses to do {#what-cif-explicitly-refuses-to-do}

CIF refuses:

- Intent guessing
- Conversational negotiation
- Silent correction
- Optimization without authorization
- Style drift
- Implicit behavior

These refusals are not limitations. They are the source of CIF’s power.

## The smallest complete CIF example {#the-smallest-complete-cif-example}

```text
!BEGIN
!STRICT
!ON_ERROR STOP

Generate a summary of the following document.
Do not add interpretation.

!END
```

This is a complete CIF program.

## CIF as infrastructure {#cif-as-infrastructure}

CIF is not tied to any specific system, model, or implementation.

It can be applied to:

- AI systems
- Human workflows
- Runbooks
- Automation pipelines
- Review processes

Its value lies in its discipline, not its tooling.

## Closing remarks {#closing-remarks}

CIF is intentionally severe.

It assumes an intelligent author. It demands precision. It offers determinism in exchange for restraint.

This is not a language for every task. It is a language for tasks where correctness matters more than comfort.

CIF is not conversational by accident. It is non-conversational by design.

## Appendix A: CIF document used to produce this result {#appendix-a-cif-document-used-to-produce-this-result}

```text
!BEGIN
!STRICT
!ON_ERROR STOP

!BEGIN INTENT
MUST: Treat this as a document-driven instruction run, not a conversation.
MUST: Process steps serially in the order provided.
MUST: Ask for clarification only if required inputs are missing.
MUST NOT: Add sections not requested.
MUST NOT: remove or rename any headings once written, unless instructed.
MUST: Output must be GitHub Pages / Jekyll compatible Markdown.
MUST: Include YAML front matter with layout=post, title, date, tags.
MUST: Include custom section IDs for EVERY heading.
MUST: Provide both (1) an inline copy-paste Markdown block and (2) a downloadable .md file using a Jekyll-dated filename.
!END INTENT

!LOCK INTENT

!BEGIN SCOPE "CIF Language Definition Book Build"
Goal: Create a complete “book-as-a-post” defining the CIF language, titled “CIF Language Definition by Preston Powell,” suitable for publishing on a Jekyll site.
Deliverable: One Jekyll post (.md) containing the complete text with logically ordered sections.
!END SCOPE

!BEGIN REQUIREMENTS
1) Use the title exactly: "CIF Language Definition by Preston Powell"
2) Use filename convention: YYYY-MM-DD-cif-language-definition-by-preston-powell-v1.3.md
3) Use date: 2025-12-21 00:00:00 -0500
4) Tags must include: CIF, Chat Instructional Format, language, specification
5) All headings must have explicit {#...} IDs in kebab-case, unique, stable
6) Include these major sections, in this order:
   - CIF Language Definition
   - Preface
   - The problem CIF addresses
   - The CIF mental model
   - Roles and responsibility
   - The CIF instruction document
   - Control vs content
   - Control prefix
   - Core control commands
   - Serial execution semantics
   - Nesting and scope
   - Scope rules
   - Error philosophy
   - Intent contracts and loyalty rules (with subsections)
   - What CIF explicitly refuses to do
   - The smallest complete CIF example
   - CIF as infrastructure
   - Closing remarks
!END REQUIREMENTS

!END
```
