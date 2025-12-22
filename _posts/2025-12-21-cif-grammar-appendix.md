---
layout: post
title: "CIF Grammar Appendix (EBNF)"
date: 2025-12-21 00:00:00 -0500
tags: [CIF, grammar, ebnf, specification]
---

# CIF Grammar Appendix {#cif-grammar-appendix}

This appendix defines the **formal grammar** for CIF v1.x using Extended Backus–Naur Form (EBNF).
The grammar is normative.

## Lexical Conventions {#lexical-conventions}

```
letter        = "A"…"Z" | "a"…"z" ;
digit         = "0"…"9" ;
whitespace    = " " | "\t" ;
newline       = "\n" | "\r\n" ;
textchar      = ? any character except newline ? ;
```

## Tokens {#tokens}

```
PREFIX        = "!" ;
IDENT         = letter , { letter | digit | "_" | "-" } ;
STRING        = '"' , { textchar } , '"' ;
```

## Document Structure {#document-structure}

```
document      = { line } ;
line          = control_line | content_line ;
```

## Control Lines {#control-lines}

```
control_line  = PREFIX , command , [ arguments ] , newline ;
command       = IDENT ;
arguments     = { whitespace , ( IDENT | STRING ) } ;
```

## Content Lines {#content-lines}

```
content_line  = { textchar } , newline ;
```

## Block Structure {#block-structure}

```
block         = begin_block , { line } , end_block ;
begin_block   = PREFIX , "BEGIN" , [ whitespace , IDENT ] , newline ;
end_block     = PREFIX , "END" , [ whitespace , IDENT ] , newline ;
```

## Validity Rules {#validity-rules}

- Prefix stacking is invalid.
- Every BEGIN must have a matching END.
- Commands are case-sensitive.
- Unrecognized commands are errors under STRICT conformance.
