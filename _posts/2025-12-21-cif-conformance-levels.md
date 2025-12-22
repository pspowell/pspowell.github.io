---
layout: post
title: "CIF Conformance Levels"
date: 2025-12-21 00:00:00 -0500
tags: [CIF, conformance, specification]
---

# CIF Conformance Levels {#cif-conformance-levels}

CIF defines explicit conformance levels to allow partial or strict implementations.

## CIF-Core {#cif-core}

Minimum required behavior:

- Serial execution
- Control prefix recognition
- BEGIN / END block handling
- ON_ERROR handling
- No implicit reordering

CIF-Core MAY allow limited inference if not prohibited by intent.

## CIF-Strict {#cif-strict}

Superset of CIF-Core with additional guarantees:

- STRICT interpretation enforced
- No inference or assumption
- Unrecognized commands are fatal errors
- Intent contracts are mandatory if present
- Executor demeanor restrictions apply

CIF-Strict is REQUIRED for any system claiming full CIF compliance.
