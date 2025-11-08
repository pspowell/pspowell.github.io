---
layout: post
title: "Understanding C Associativity and BNF Syntax Rules"
date: 2025-11-08
tags: [C, programming, BNF, associativity, grammar, syntax]
---

## Overview

In C (and many other programming languages), *associativity* determines how operators of the same precedence are grouped when a statement is parsed.  
In *Kernighan & Ritchie’s* grammar, associativity isn’t merely a rule of precedence — it’s **built into the structure of the Backus–Naur Form (BNF)** itself.

---

## What Is Backus–Naur Form (BNF)?

**Backus–Naur Form (BNF)** is a formal way to describe programming language syntax.  
Each rule defines how a construct can be composed using other constructs or symbols.

```bnf
<nonterminal> ::= <expression>
```

For example, a simplified expression grammar might look like this:

```bnf
<expression> ::= <term> | <expression> "+" <term> | <expression> "-" <term>
<term>       ::= <factor> | <term> "*" <factor> | <term> "/" <factor>
<factor>     ::= <identifier> | <number> | "(" <expression> ")"
```

Here, `<expression>`, `<term>`, and `<factor>` are **nonterminals**; the symbols like `+` or `*` are **terminals**.

---

## Associativity in the Grammar

Associativity describes **how repeated operators of the same precedence group**.  
In BNF, this is determined by **where recursion occurs** in the rule definition.

| Grammar Form | Example Rule | Associativity |
|---------------|--------------|---------------|
| **Left-Recursive** | `<expr> ::= <expr> op <term>` | **Left-to-Right** |
| **Right-Recursive** | `<expr> ::= <term> op <expr>` | **Right-to-Left** |

---

## Left-to-Right Associativity

### Example

Expression:
```c
a + b + c
```

BNF rule:
```bnf
<additive-expression> ::=
      <additive-expression> "+" <multiplicative-expression>
    | <multiplicative-expression>
```

### Parse Tree

```
         (+)
        /         (+)     c
     /       a     b
```

### Interpretation

- Grammar is **left-recursive**.
- The parse groups as `(a + b) + c`.
- Operations of equal precedence are performed **from left to right**.

---

## Right-to-Left Associativity

### Example

Expression:
```c
a = b = c;
```

BNF rule:
```bnf
<assignment-expression> ::=
      <unary-expression> "=" <assignment-expression>
    | <conditional-expression>
```

### Parse Tree

```
       (=)
      /        a    (=)
         /           b     c
```

### Interpretation

- Grammar is **right-recursive**.
- The parse groups as `a = (b = c)`.
- Operations of equal precedence are performed **from right to left**.

---

## Summary Table

| Operator Category | Example | Associativity |
|--------------------|----------|---------------|
| Arithmetic (`+`, `-`, `*`, `/`, `%`) | `a - b - c` | Left-to-Right |
| Comparison (`<`, `>`, `<=`, `>=`, `==`, `!=`) | `a < b < c` | Left-to-Right |
| Logical (`&&`, `||`) | `a && b && c` | Left-to-Right |
| Assignment (`=`, `+=`, `-=` etc.) | `a = b = c` | Right-to-Left |
| Conditional (`?:`) | `a ? b : c ? d : e` | Right-to-Left |
| Comma (`,`) | `a, b, c` | Left-to-Right |

---

## Key Takeaways

- Associativity in C is **not just an evaluation rule** — it’s **a grammatical property**.
- **Left recursion** in BNF → *left associativity*.
- **Right recursion** in BNF → *right associativity*.
- The C grammar in K&R encodes these relationships directly into the syntax rules.

---

*References:*  
- *The C Programming Language*, 2nd Edition — Brian W. Kernighan & Dennis M. Ritchie  
- ISO/IEC 9899:2018 (C18) Grammar Annex  
- John Backus & Peter Naur, *Revised Report on the Algorithmic Language ALGOL 60*
