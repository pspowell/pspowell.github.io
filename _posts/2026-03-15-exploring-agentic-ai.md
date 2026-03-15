---
layout: post
title: "Exploring Agentic AI and Building a Personal Agent Stack"
date: 2026-03-15
tags: [ai, agents, agentic-ai, automation, software, python]
---

# Exploring Agentic AI and Building a Personal Agent Stack

This document is a running exploration of **modern agentic AI systems** and the practical path toward building a **small personal agent stack**.

Traditional AI systems are primarily designed to answer prompts. Agentic AI systems go further: they pursue goals, break work into steps, use tools, remember context, and in some cases take actions in the real world.

Agentic systems can:

- plan tasks
- use external tools
- maintain memory
- collaborate with other agents
- evaluate their own work
- iterate toward complex goals

This document is intentionally **topic-oriented** so readers can jump directly to the sections most relevant to them.

## Topics

- [Topic 1 — Real Agentic AI Systems You Can Run Today](#topic-1)
- [Topic 2 — Most Powerful Open-Source Agent Frameworks](#topic-2)
- [Topic 3 — Building Your Own AI Agent in ~100 Lines of Python](#topic-3)
- [Topic 4 — The Most Advanced Agent Tools Available Today](#topic-4)
- [Topic 5 — Modern Agent Architecture](#topic-5)
- [Topic 6 — Comparison of Major Agent Frameworks](#topic-6)
- [Topic 7 — Real-World Agent Workflow Example](#topic-7)
- [Topic 8 — Where Agentic AI Is Going](#topic-8)
- [Topic 9 — Where an Agent Stack Actually Lives](#topic-9)
- [Topic 10 — Sample Walkthrough: Building a Small Personal Agent Stack](#topic-10)

---

# Topic 1 — Real Agentic AI Systems You Can Run Today
{: #topic-1 }

These are **working agent platforms** you can study or run today. They differ in architecture and maturity, but they all help illustrate the move from prompt-response systems to **goal-driven AI execution**.

## Full Autonomous AI Agents

These attempt something close to **end-to-end goal completion**.

### OpenDevin

OpenDevin is one of the closest open-source efforts to reproduce the capabilities demonstrated by autonomous coding agents such as Devin.

Capabilities include:

- writing software
- running code
- debugging
- browsing the web
- interacting with files
- executing terminal commands

Example goal:

> Build a website listing Ohio metal roofing suppliers.

A system like this might:

1. research suppliers
2. generate code
3. run tests
4. fix bugs
5. deploy the application

Repository  
https://github.com/OpenDevin/OpenDevin

### AutoGPT (modern versions)

AutoGPT was one of the earliest agent systems to popularize the idea of autonomous task loops. Early versions were often unstable, but later versions became more structured.

Capabilities include:

- multi-step planning
- task persistence
- tool use
- web research
- long task execution

Example task:

> Research skylight panel replacements compatible with Regal Rib roofing.

Repository  
https://github.com/Significant-Gravitas/AutoGPT

### MetaGPT

MetaGPT models a task as if it were being handled by an entire **AI software company**.

Typical roles include:

| Agent Role | Responsibility |
|---|---|
| CEO | defines project goal |
| Product Manager | writes requirements |
| Engineer | implements code |
| QA | tests output |

Example task:

> Create a marketplace for building materials.

Repository  
https://github.com/geekan/MetaGPT

## Multi-Agent Collaboration Systems

These systems use **teams of specialized agents** instead of one general-purpose agent.

### CrewAI

CrewAI has become one of the most intuitive frameworks for modeling AI systems as teams.

Example crew:

```text
Researcher
Engineer
Writer
Manager
```

Example goal:

> Find compatible skylight panels for Regal Rib roofing.

Possible workflow:

1. research agent gathers panel specifications
2. engineering agent compares profile compatibility
3. writer agent drafts supplier outreach emails

Repository  
https://github.com/joaomdmoura/crewAI

### Microsoft AutoGen

AutoGen is designed around **agents talking to one another** in structured loops.

Typical interaction pattern:

```text
User
↓
Planner
↓
Executor
↓
Critic
```

The system can use one agent to propose an approach, another to execute it, and another to evaluate or improve the result.

Repository  
https://github.com/microsoft/autogen

## Tool-Using Agent Systems

These systems are especially focused on letting the model **act through tools**.

### LangGraph

LangGraph is one of the most important frameworks in modern agent engineering because it combines LLM reasoning with **structured workflow control**.

Capabilities include:

- deterministic execution
- branching workflows
- retries
- memory integration
- tool execution

Repository  
https://github.com/langchain-ai/langgraph

### Open Interpreter

Open Interpreter allows an AI system to interact with a computer environment more directly.

Capabilities include:

- running Python
- executing shell commands
- modifying files
- launching applications

Example task:

> Analyze a spreadsheet and generate a dashboard.

Repository  
https://github.com/OpenInterpreter/open-interpreter

## Knowledge and Research Agents

These systems emphasize **retrieval and reasoning over information sources**.

### LlamaIndex Agents

LlamaIndex focuses on connecting AI systems to documents, archives, and knowledge stores.

Example use cases:

- document analysis
- research automation
- internal knowledge assistants
- engineering documentation lookup

Repository  
https://github.com/run-llama/llama_index

### SuperAGI

SuperAGI is more of an orchestration platform for managing multiple agent workflows.

Features include:

- dashboards
- task monitoring
- memory systems
- tool integration

Repository  
https://github.com/TransformerOptimus/SuperAGI

## Experimental Systems

### BabyAGI (modern versions)

BabyAGI explored recursive task generation:

```text
Task
↓
Agent executes
↓
Agent generates new tasks
↓
Loop
```

This style of self-expanding task tree was an influential idea in early agent experimentation.

Repository  
https://github.com/yoheinakajima/babyagi

## Most Practical Systems Right Now

For real-world projects, the most practical and influential systems in this landscape include:

- CrewAI
- LangGraph
- AutoGen
- OpenDevin
- Open Interpreter

These represent the shift from **chat-oriented AI** toward **goal-oriented automation systems**.

---

# Topic 2 — Most Powerful Open-Source Agent Frameworks
{: #topic-2 }

Agent frameworks provide the infrastructure required to build reliable AI agents. They are the layer that helps coordinate:

- reasoning
- tool execution
- memory
- workflows
- collaboration
- monitoring

The most important open-source frameworks today tend to fall into a few categories.

## LangGraph

LangGraph is arguably the most important modern framework for production-grade agent systems.

It was built to solve a core problem:

> LLM agents are powerful, but they are often unpredictable.

LangGraph addresses that by combining:

- deterministic workflows
- graph-based execution
- state tracking
- LLM reasoning

Instead of relying on a vague loop, it structures execution as a graph of states.

Example:

```text
User Request
↓
Planning Node
↓
Tool Execution Node
↓
Evaluation Node
↓
Final Output
```

Each node can:

- call a model
- execute a tool
- write memory
- branch to another state

That makes LangGraph well suited for:

- research assistants
- automation pipelines
- coding agents
- production orchestration

Repository  
https://github.com/langchain-ai/langgraph

## CrewAI

CrewAI specializes in **collaborating teams of agents**.

It maps naturally to the idea of a human team, where each participant has:

- a role
- a goal
- tools
- responsibilities

Example crew:

| Agent | Role |
|---|---|
| Researcher | finds information |
| Analyst | processes results |
| Writer | creates output |
| Manager | coordinates tasks |

This makes CrewAI especially approachable for users who think in terms of delegated responsibilities.

Repository  
https://github.com/joaomdmoura/crewAI

## Microsoft AutoGen

AutoGen is one of the most flexible frameworks for **agent-to-agent conversations**.

A common pattern is:

```text
User
↓
Planner Agent
↓
Executor Agent
↓
Critic Agent
```

That structure is useful when a task benefits from iterative refinement, debate, or review.

AutoGen is especially strong for:

- coding agents
- complex reasoning loops
- collaborative problem solving

Repository  
https://github.com/microsoft/autogen

## Semantic Kernel

Semantic Kernel is Microsoft’s enterprise-oriented orchestration framework.

It emphasizes:

- reliability
- structured integrations
- business workflows
- internal tools and APIs

Supported languages include:

- Python
- C#
- Java

It is especially relevant when an organization wants AI systems integrated with:

- cloud platforms
- internal services
- databases
- business systems

Repository  
https://github.com/microsoft/semantic-kernel

## LlamaIndex

LlamaIndex focuses on **knowledge retrieval and reasoning**.

Its core value is helping agents connect to external knowledge sources and use them effectively. That makes it central to many **RAG-oriented** systems.

Typical use cases include:

- document assistants
- research agents
- engineering documentation search
- enterprise knowledge bases

Repository  
https://github.com/run-llama/llama_index

## Haystack

Haystack is a strong framework for **search-heavy AI systems**.

It is particularly useful for:

- document pipelines
- search-driven assistants
- RAG systems
- enterprise question answering

Repository  
https://github.com/deepset-ai/haystack

## Core Comparison

| Framework | Primary Strength |
|---|---|
| LangGraph | workflow orchestration |
| CrewAI | multi-agent collaboration |
| AutoGen | structured agent conversation |
| Semantic Kernel | enterprise orchestration |
| LlamaIndex | knowledge retrieval |
| Haystack | search pipelines |

## Key Insight

These frameworks are not always best thought of as direct competitors. In many real systems, they become **complementary layers** in a larger stack.

---

# Topic 3 — Building Your Own AI Agent in ~100 Lines of Python
{: #topic-3 }

One of the most useful things to understand is that an agent is not magic. At its core, an agent is often just a **loop**.

A minimal agent usually follows a pattern like this:

```text
Goal
↓
Plan
↓
Use tools
↓
Observe result
↓
Repeat until done
```

This is closely related to the **ReAct pattern**:

> Reason → Act → Observe

## Core Components of a Minimal Agent

A small agent generally needs five things:

| Component | Purpose |
|---|---|
| LLM | reasoning and planning |
| Tools | actions the agent can take |
| Memory | track previous results |
| Planner | determine next step |
| Loop | repeat until the task is complete |

## Minimal Conceptual Example

A tiny agent can:

- accept a goal
- ask a model for the next step
- execute an action
- store the result
- repeat

Example behavior:

```text
Step 1: Search population of Columbus Ohio
Step 2: Write result to a file
Step 3: Return DONE
```

That may not look glamorous, but conceptually it captures the essence of an agent.

## Why This Matters

Many people imagine agents as requiring huge frameworks from the start. In practice, most real systems begin with something much simpler:

```text
LLM
+ loop
+ tools
+ memory
```

Everything else is an engineering refinement of that core pattern.

## Modern Improvements

Production systems extend this pattern using:

- structured tool calling
- persistent memory
- multi-step planning
- self-reflection
- retries
- evaluation loops

That gives us the modern agent stack, but the minimal loop remains the foundation.

---

# Topic 4 — The Most Advanced Agent Tools Available Today
{: #topic-4 }

While many frameworks and projects exist, a smaller set of tools stand out as especially important because they represent the leading edge of what agents can do in practice.

## OpenDevin

OpenDevin is one of the most visible open-source attempts to approximate an autonomous AI software engineer.

Capabilities include:

- browsing the web
- writing code
- running commands
- editing files
- debugging programs

It is especially interesting because it treats software engineering as a multi-step autonomous workflow rather than a single prompt.

Repository  
https://github.com/OpenDevin/OpenDevin

## LangGraph

LangGraph is included here again because it is not just a framework in the abstract; it has become one of the most important **practical tools** for orchestrating reliable AI behavior.

It supports:

- long-running tasks
- branching workflows
- persistent state
- controlled execution

Repository  
https://github.com/langchain-ai/langgraph

## CrewAI

CrewAI matters because it provides a very usable abstraction for **delegated agent teams**.

This makes it attractive for users who want systems like:

- researcher agents
- analyst agents
- writer agents
- manager agents

Repository  
https://github.com/joaomdmoura/crewAI

## Open Interpreter

Open Interpreter is especially important because it blurs the line between a model and a computer operator.

It enables things like:

- terminal execution
- file editing
- Python execution
- local automation

Repository  
https://github.com/OpenInterpreter/open-interpreter

## AutoGen

AutoGen is powerful because it treats agent systems as **conversations among specialized participants**.

That makes it strong for tasks where:

- one agent proposes a plan
- another executes it
- another critiques it
- the loop repeats until the result improves

Repository  
https://github.com/microsoft/autogen

## Emerging Combined Stack

A modern stack often combines several of these:

```text
LLM
+ LangGraph
+ CrewAI
+ LlamaIndex
+ tools
```

The important shift is that these tools are moving AI away from **answering questions** and toward **executing goals**.

---

# Topic 5 — Modern Agent Architecture
{: #topic-5 }

Most modern agent systems follow a layered architecture. That architecture is important because it helps explain why agents behave differently from ordinary chat systems.

A common mental model looks like this:

```text
User / Goal
↓
Planner
↓
Agent Loop
↓
Tools
↓
Environment
↓
Memory
```

## Goal Layer

Everything starts with a goal.

Example:

> Identify compatible skylight panels for Regal Rib roofing and contact suppliers.

The agent needs to convert that goal into smaller tasks.

## Planning Layer

The planning layer breaks a high-level objective into steps.

Example:

```text
1. Identify Regal Rib panel profile
2. Search skylight panel manufacturers
3. Compare compatibility
4. Collect supplier contacts
5. Draft outreach email
```

Some systems plan once at the beginning. Others **re-plan dynamically** after each step.

## Agent Execution Loop

The execution loop is the core engine.

Typical pattern:

```text
Think
↓
Choose tool
↓
Execute
↓
Observe result
↓
Update memory
↓
Repeat
```

That loop is what makes the system feel agentic rather than conversational.

## Tools Layer

Tools are what allow the agent to do things in the world.

Examples include:

| Tool | Purpose |
|---|---|
| web search | gather information |
| Python | calculations and analysis |
| browser | interact with websites |
| filesystem | read and write files |
| email | communicate externally |

Without tools, an agent is really just a chatbot with ambition. Tools turn it into an actor.

## Memory Layer

Memory is what allows multi-step continuity.

Two common forms:

### Short-Term Memory

Used for:

- current context
- recent steps
- temporary task reasoning

### Long-Term Memory

Used for:

- persistent knowledge
- saved facts
- execution histories
- vector retrieval

## Why This Architecture Matters

A chat system usually looks like this:

```text
Prompt → Response
```

An agent system looks more like this:

```text
Goal → Plan → Act → Evaluate → Repeat
```

That difference is the heart of agentic AI.

---

# Topic 6 — Comparison of Major Agent Frameworks
{: #topic-6 }

Different frameworks solve different parts of the agent problem. Understanding that makes it easier to choose the right one.

## Framework Categories

Most frameworks fall into a few broad categories.

| Category | Purpose |
|---|---|
| workflow orchestration | control execution flow |
| multi-agent coordination | organize teams of agents |
| knowledge systems | retrieval and reasoning |
| enterprise orchestration | reliability and integration |

## LangGraph

**Category:** workflow orchestration

LangGraph is optimized for controlled, structured execution. It is best when the task requires:

- state tracking
- branching
- retries
- reliability
- persistence

Best use cases:

- automation pipelines
- research agents
- coding workflows

## CrewAI

**Category:** multi-agent coordination

CrewAI is best when you want a clear mental model of specialized roles.

Best use cases:

- research and writing teams
- analysis pipelines
- delegated task systems

## AutoGen

**Category:** agent conversation framework

AutoGen shines when you want agents to critique, debate, and refine results.

Best use cases:

- collaborative reasoning
- coding assistants
- iterative problem solving

## Semantic Kernel

**Category:** enterprise orchestration

Semantic Kernel is strongest when integration with business systems matters.

Best use cases:

- enterprise copilots
- internal workflow automation
- business process tooling

## LlamaIndex

**Category:** knowledge retrieval framework

LlamaIndex is designed to connect models with documents and knowledge stores.

Best use cases:

- document analysis
- research assistants
- internal knowledge systems

## Haystack

**Category:** search and retrieval pipelines

Haystack is especially valuable when search is central to the system.

Best use cases:

- enterprise search
- knowledge discovery
- support automation

## Capability Comparison Table

| Framework | Strength | Primary Role |
|---|---|---|
| LangGraph | workflow control | execution engine |
| CrewAI | agent teams | task collaboration |
| AutoGen | agent conversation | reasoning loops |
| Semantic Kernel | enterprise orchestration | production systems |
| LlamaIndex | knowledge retrieval | RAG systems |
| Haystack | search pipelines | document discovery |

## Practical Rule of Thumb

| If you want… | Use |
|---|---|
| reliable workflows | LangGraph |
| teams of agents | CrewAI |
| agent debates | AutoGen |
| enterprise systems | Semantic Kernel |
| document reasoning | LlamaIndex |
| search-heavy pipelines | Haystack |

---

# Topic 7 — Real-World Agent Workflow Example
{: #topic-7 }

A practical workflow helps tie all the abstractions together.

Suppose the system receives this goal:

> Identify skylight panels compatible with Regal Rib roofing and contact suppliers.

This is a good example because it is not a single-answer question. It requires:

- research
- analysis
- memory
- drafting communication
- possibly taking action

## Step 1 — Goal Intake

The request enters the system as a task:

```text
Goal:
Find compatible skylight panels for Regal Rib roofing
and contact suppliers.
```

## Step 2 — Planning

The planner decomposes the task:

```text
1. Identify Regal Rib panel profile
2. Search skylight panel manufacturers
3. Compare rib spacing compatibility
4. Collect supplier contact information
5. Draft supplier outreach email
```

## Step 3 — Research Phase

The agent uses tools such as:

- web search
- document retrieval
- image analysis
- specification lookup

Example:

```text
Search:
"skylight panels compatible with 12 inch rib metal roofing"
```

## Step 4 — Analysis Phase

The agent compares what it found.

Example reasoning:

```text
Regal Rib spacing = 12 inches

Candidate compatible profiles:
- AG Panel
- PBR Panel
- R Panel
```

## Step 5 — Supplier Identification

The system compiles a structured list:

| Supplier | Product Type |
|---|---|
| ABC Metal Roofing | skylight panel |
| Metal Sales | polycarbonate panel |
| Fabral | translucent panel |

## Step 6 — Action Phase

Now the system can act.

Example:

```text
Draft outreach email to suppliers
```

If the system is connected to an email capability, it could generate and send supplier messages, possibly with approval gates.

## Step 7 — Evaluation

The agent checks progress:

```text
Goal progress: 80%

Remaining tasks:
- confirm compatibility
- finalize supplier contact list
```

## Workflow Summary

```text
User Goal
↓
Planning
↓
Research Tools
↓
Analysis
↓
Action
↓
Evaluation
↓
Repeat
```

This is what distinguishes agentic AI from a normal chatbot.

---

# Topic 8 — Where Agentic AI Is Going
{: #topic-8 }

The systems we have now are probably the **first generation** of practical AI agents. Several trends point toward where the next generation is going.

## Persistent Agents

Most current agents are task-bounded:

```text
User request → agent runs → task ends
```

Future agents are likely to run more continuously:

```text
Agent runs continuously
↓
monitors environment
↓
detects events
↓
acts autonomously
```

Examples include:

- monitoring markets
- tracking infrastructure
- watching data feeds
- managing systems continuously

## Hierarchical Agent Systems

Future systems are likely to involve agents coordinating other agents.

Example:

```text
Manager Agent
↓
Research Agents
↓
Analysis Agents
↓
Execution Agents
```

This begins to resemble a digital organization.

## Agent Operating Systems

An emerging idea is that AI becomes the orchestrator for software, rather than merely one feature inside software.

Example:

```text
User intent
↓
AI OS
↓
Apps and APIs
↓
Real-world actions
```

## Autonomous Research Agents

These systems can increasingly:

- read papers
- extract findings
- compare sources
- generate analyses
- propose conclusions

This is relevant to:

- science
- finance
- intelligence analysis
- technical research

## Agent Economies

Some researchers are exploring ecosystems where agents exchange services or information.

Example:

```text
Agent A needs data
↓
Agent B provides data
↓
Agent C performs analysis
```

This is still experimental, but conceptually important.

## Self-Improving Agents

A future direction is agents that refine strategies over time:

```text
Execute task
↓
Evaluate outcome
↓
Update strategy
↓
Try again
```

## Key Long-Term Shift

The big transition is from:

```text
Information tools
```

to

```text
Autonomous systems
```

That is the deeper significance of agentic AI.

---

# Topic 9 — Where an Agent Stack Actually Lives
{: #topic-9 }

One of the most confusing things for new builders is understanding where an “agent stack” actually exists.

It is usually **not one thing in one place**. Instead, it is spread across multiple layers.

## Local Machine Layer

This is what lives on your PC.

Examples include:

- Python environment
- project files
- source code
- local databases
- config files
- installed frameworks
- Docker containers
- scripts and tools

This is the part you control directly.

## Session / Runtime Layer

This exists only while the agent is running.

Examples include:

- current reasoning context
- temporary plans
- tool outputs from the current run
- in-memory state
- intermediate files

This often disappears unless you save it.

## Persistent Storage Layer

This is what survives across runs.

Examples include:

- `.env` files
- SQLite or Postgres
- vector databases
- saved memory
- logs
- Git repositories

This is what gives the system continuity.

## Cloud Services Layer

Many agent stacks also depend on external services.

Examples include:

- LLM APIs
- email APIs
- search APIs
- hosted databases
- cloud storage

These are the outside services your stack can call.

## Mental Model

A useful metaphor is:

```text
Your PC = workshop
Runtime = what is currently on the workbench
Persistent storage = the shelves and filing cabinets
Cloud APIs = outside vendors and tools
```

## Building the Stack Layer by Layer

The easiest way to think about building an agent stack is in layers.

### Layer 1 — Model Layer

This is the reasoning engine.

Examples:

- OpenAI
- Anthropic
- local model via Ollama

Question:

> What will do the reasoning?

### Layer 2 — Orchestration Layer

This manages the workflow.

Examples:

- plain Python
- LangGraph
- CrewAI
- AutoGen

Question:

> How will tasks be coordinated?

### Layer 3 — Tool Layer

This gives the agent actions.

Examples:

- web search
- filesystem access
- Python execution
- email
- APIs
- browser automation

Question:

> What can the agent actually do?

### Layer 4 — Memory Layer

This determines what persists.

Examples:

- JSON
- SQLite
- Postgres
- vector DB

Question:

> What should survive between runs?

### Layer 5 — Interface Layer

This is how you interact with the system.

Examples:

- terminal
- chat UI
- web dashboard
- scheduled jobs

Question:

> How will the user talk to the agent?

## Can Agents Automatically Configure the Stack?

Partially, yes.

Modern coding agents can often help with:

- project scaffolding
- writing config files
- installing packages
- generating integration code
- debugging errors

But they still struggle with:

- OS-specific issues
- Windows path problems
- permissions
- authentication flows
- credential setup
- local environment quirks

So today the realistic model is usually:

> AI-assisted setup, not fully hands-off autonomous setup.

## Practical Build Order

A sensible progression is:

```text
1. Pick one model
2. Build one simple loop
3. Add one or two tools
4. Add persistence
5. Add a nicer interface
6. Add multiple agents later
```

That is much safer than beginning with a giant multi-agent stack.

---

# Topic 10 — Sample Walkthrough: Building a Small Personal Agent Stack
{: #topic-10 }

This section turns the ideas in the document into a **practical walkthrough**.

The purpose is not to build a massive production system immediately. The purpose is to show how a useful personal stack can evolve step by step.

We will use the phased progression discussed earlier:

```text
Phase A — Minimal agent
Phase B — Add persistent memory
Phase C — Add a real external tool
Phase D — Expand into multi-agent orchestration
```

## Suggested Project Layout

```text
agent-stack/
├─ phase-a-agent.py
├─ phase-b-memory-agent.py
├─ phase-c-tool-agent.py
├─ agent_memory.db
└─ .env
```

---

## Phase A — Minimal Agent
{: #phase-a }

This phase creates the smallest useful agent.

### Stack

```text
Python
+
LLM API
+
simple reasoning loop
+
terminal interface
```

### What It Does

This version can:

- receive a goal
- reason about the goal
- suggest a next step

It does **not** persist memory yet.

### Architecture

```text
User Goal
↓
Agent Loop
↓
LLM Reasoning
↓
Output
```

### Runnable Example

```python
# /// script
# dependencies = ["openai"]
# ///

from openai import OpenAI

client = OpenAI()

goal = input("Enter a goal for the agent: ").strip()

prompt = f"""
You are a simple AI agent.

Goal:
{goal}

Suggest the single best next step toward completing this goal.
Be concise and practical.
"""

response = client.responses.create(
    model="gpt-4.1",
    input=prompt,
)

print("\nAgent suggestion:\n")
print(response.output_text)
```

### Run It

```bash
uv run phase-a-agent.py
```

### Why This Matters

Even though it is tiny, this already demonstrates the core agent idea:

> The system is reasoning about how to pursue a goal, not merely answering a question.

---

## Phase B — Add Persistent Memory
{: #phase-b }

The next step is to give the agent continuity.

### Updated Stack

```text
Python
+
LLM API
+
agent loop
+
SQLite memory
```

### What Changes

Now the system can store:

- previous goals
- previous outputs
- notes from past runs

### Architecture

```text
User Goal
↓
Agent Loop
↓
LLM Reasoning
↓
Memory Store (SQLite)
↓
Output
```

### Runnable Example

```python
# /// script
# dependencies = ["openai"]
# ///

import sqlite3
from openai import OpenAI

client = OpenAI()

conn = sqlite3.connect("agent_memory.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS memory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal TEXT NOT NULL,
    note TEXT NOT NULL
)
""")
conn.commit()

goal = input("Enter a goal for the agent: ").strip()

cursor.execute(
    "SELECT goal, note FROM memory ORDER BY id DESC LIMIT 5"
)
recent_items = cursor.fetchall()

recent_context = "\n".join(
    f"- Goal: {g}\n  Note: {n}" for g, n in recent_items
) or "No prior memory."

prompt = f"""
You are a simple AI agent.

Current goal:
{goal}

Recent memory:
{recent_context}

Suggest the single best next step toward completing the current goal.
Be concise and practical.
"""

response = client.responses.create(
    model="gpt-4.1",
    input=prompt,
)

suggestion = response.output_text.strip()

cursor.execute(
    "INSERT INTO memory (goal, note) VALUES (?, ?)",
    (goal, suggestion)
)
conn.commit()

print("\nAgent suggestion:\n")
print(suggestion)

conn.close()
```

### Run It

```bash
uv run phase-b-memory-agent.py
```

### Why This Matters

This is the point where the system starts to feel less like a stateless prompt and more like a persistent assistant.

---

## Phase C — Add a Real External Tool
{: #phase-c }

Now we add a capability that allows the system to do something beyond thinking and remembering.

For a safe introductory example, the tool will **draft and simulate sending** an email rather than actually sending one. That keeps the example simple while still showing the mechanics.

### Updated Stack

```text
Python
+
LLM API
+
agent loop
+
SQLite memory
+
tool execution
```

### Architecture

```text
User Goal
↓
Agent Reasoning
↓
Draft Message
↓
Tool Call
↓
Stored Result
```

### Runnable Example

```python
# /// script
# dependencies = ["openai"]
# ///

import sqlite3
from openai import OpenAI

client = OpenAI()

conn = sqlite3.connect("agent_memory.db")
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS memory (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    goal TEXT NOT NULL,
    note TEXT NOT NULL
)
""")
conn.commit()


def send_email(to: str, subject: str, body: str) -> str:
    print("\n--- EMAIL TOOL (SIMULATED) ---")
    print("To:", to)
    print("Subject:", subject)
    print(body)
    print("--- END EMAIL TOOL ---\n")
    return f"Simulated email sent to {to} with subject '{subject}'"


goal = input("Enter a goal for the agent: ").strip()

cursor.execute(
    "SELECT goal, note FROM memory ORDER BY id DESC LIMIT 5"
)
recent_items = cursor.fetchall()

recent_context = "\n".join(
    f"- Goal: {g}\n  Note: {n}" for g, n in recent_items
) or "No prior memory."

prompt = f"""
You are a practical AI agent.

Current goal:
{goal}

Recent memory:
{recent_context}

A tool is available:

send_email(to, subject, body)

If drafting an email would help move the goal forward, produce:
TO: ...
SUBJECT: ...
BODY:
...

Otherwise, produce:
NEXT_STEP: ...

Be practical and concise.
"""

response = client.responses.create(
    model="gpt-4.1",
    input=prompt,
)

decision = response.output_text.strip()
print("\nAgent output:\n")
print(decision)

if decision.startswith("TO:"):
    lines = decision.splitlines()
    to = lines[0].replace("TO:", "").strip()
    subject = lines[1].replace("SUBJECT:", "").strip()

    body_lines = []
    body_started = False
    for line in lines[2:]:
        if line.startswith("BODY:"):
            body_started = True
            body_lines.append(line.replace("BODY:", "").lstrip())
        elif body_started:
            body_lines.append(line)

    body = "\n".join(body_lines).strip()
    tool_result = send_email(to, subject, body)
    note = f"{decision}\n\nTool result: {tool_result}"
else:
    note = decision

cursor.execute(
    "INSERT INTO memory (goal, note) VALUES (?, ?)",
    (goal, note)
)
conn.commit()
conn.close()
```

### Run It

```bash
uv run phase-c-tool-agent.py
```

### Why This Matters

At this point the system becomes an **action-capable agent**.

The conceptual shift is:

```text
LLM reasoning
→ tool execution
```

That is the moment where the system stops being just a smart text generator and becomes something more operational.

---

## Phase D — Expand the System
{: #phase-d }

Only after the single-agent version works reliably does it make sense to expand into a larger stack.

Possible additions include:

```text
LangGraph → workflow orchestration
CrewAI → specialized agent teams
vector databases → richer memory
web search tools → automated research
approval gates → human review before actions
```

The architecture might evolve into:

```text
User Interface
↓
Agent Framework
↓
Planner Agent
↓
Worker Agents
↓
Tools and APIs
↓
Persistent Memory
```

### Why This Build Order Is Important

Many people try to begin here:

```text
LangGraph
CrewAI
AutoGen
vector DB
search API
browser tools
email APIs
```

But a more realistic and durable path is:

```text
Python
+
LLM
+
one tool
```

Then grow the system gradually.

## Core Takeaway

Most strong agent stacks do not begin as giant systems. They begin small, prove one capability at a time, and expand only after each layer works.

---

# Final Thoughts

Agentic AI represents a shift from software that merely responds to software that can **pursue goals, coordinate actions, and complete tasks**.

The most useful way to understand this space is not just through hype or tool lists, but through a layered view:

- what agent systems exist
- how the frameworks differ
- how agent architecture works
- where the stack actually lives
- how to build a small version yourself

This document is intended to grow over time and can later be reorganized for the best final narrative flow.
