---
layout: post
title: "Releasing a New CIF Definition"
date: 2025-12-21 00:00:00 -0500
tags: [CIF, Chat Instructional Format, release, specification]
---

# Releasing a New CIF Definition {#releasing-a-new-cif-definition}

## Overview {#overview}

This post announces the release of an updated **CIF (Chat Instructional Format) language definition**.  
This release formalizes CIF as a deterministic, document-driven instruction language and introduces explicit **intent contracts** to ensure executor loyalty.

The purpose of this release is not to add features for convenience, but to lock down behavior for correctness, auditability, and trust.

## Why a New Definition Was Necessary {#why-a-new-definition-was-necessary}

As CIF evolved from an execution concept into a full language, several gaps became apparent:

- Intent was implied rather than enforced
- Executor loyalty relied on convention instead of structure
- Drift was possible during long or nested instruction runs

This release addresses those gaps directly.

## What Has Changed {#what-has-changed}

The new CIF definition introduces the following normative changes:

- CIF is explicitly defined as a **language**, not a prompt style
- Instructions are treated as **documents**, not conversational turns
- Control and content are strictly separated
- Inference is forbidden by default
- **Intent contracts** are introduced as first-class language constructs

These changes do not relax CIF. They make it stricter.

## Intent Contracts (New) {#intent-contracts-new}

The most significant addition is the concept of an **intent contract**.

An intent contract allows the client to declare binding rules that the executor must obey for the entire execution lifecycle.

```text
!BEGIN INTENT
!STRICT

MUST: Process instructions serially.
MUST NOT: Introduce assumptions.
MUST NOT: Alter client wording.
MUST: Halt on ambiguity.

!END INTENT

!LOCK INTENT
```

Intent contracts transform trust from expectation into structure.

## Versioning {#versioning}

This release should be considered **CIF v1.1**.

Future revisions will follow a strict versioning discipline:
- Minor versions clarify or formalize behavior
- Major versions change language semantics
- Deprecated behavior will be documented explicitly

CIF favors stability over velocity.

## Backward Compatibility {#backward-compatibility}

Earlier CIF-style instruction documents remain valid provided they do not rely on implicit inference or executor discretion.

Documents that relied on conversational negotiation should be considered **non-CIF** and revised.

## What This Means for Users {#what-this-means-for-users}

For authors:
- CIF now provides stronger guarantees
- Instructions are more predictable
- Errors surface earlier and more clearly

For executors:
- Authority boundaries are explicit
- Behavior is auditable
- Loyalty is contractual, not interpretive

## What CIF Still Refuses to Do {#what-cif-still-refuses-to-do}

This release does **not** change CIF’s core refusals:

- No intent guessing
- No silent correction
- No optimization without authorization
- No conversational negotiation

These refusals remain central to the language.

## Closing Notes {#closing-notes}

This release marks CIF’s transition from a design philosophy into a formally defined language.

CIF is intentionally severe.  
It is designed for situations where correctness matters more than comfort.

Future work will focus on grammar formalization, tooling, and reference implementations — without compromising the core discipline.
