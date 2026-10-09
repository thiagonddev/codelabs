# codelabs

> _A personal monorepo for experiments, prototypes & learning_.

<br />

## About

**codelabs** is my personal playground for exploring technologies, experimenting with different approaches & learning how things really work.

It isn't a collection of polished portfolio projects.

It's a space to test ideas, compare implementations, explore unfamiliar tools & break things without the pressure of building production-ready software.

Think of it as a collection of **knowledge drafts**: small, focused experiments that help me understand a concept, evaluate a technology or investigate an approach.

Some experiments may eventually grow into something more complete.

Others exist simply because I wanted to understand how something works.

## Topics

The repository covers different areas of software development, including:

* Languages & runtimes

* Backend architectures

* Frameworks & libraries

* Database integrations

* HTTP servers & API design

* Authentication

* Project organization

* Development workflows

* Alternative implementations of the same problem

The goal isn't always to build something production-ready.

Sometimes, it's simply to **understand how something works**.

## Structure

The repository is organized around areas of experimentation rather than a single application or architectural pattern.

```
codelabs/
├── languages/
│   ├── bash/
│   │   └── intro/
│   └── js/
│       └── backend/
│           └── node/
│               ├── concepts/
│               ├── frameworks/
│               ├── shared/
│               ├── package.json
│               └── tsconfig.json
├── .vsls.json
└── README.md
```

### Node.js

Node.js experiments are grouped by the concepts or technologies being explored.

```
node/
├── concepts/
│   └── commonjs/
│       ├── database/
│       │   ├── sqlite/
│       │   └── supabase/
│       ├── os/
│       └── server/
│
├── frameworks/
│   └── express/
│       └── commonjs/
│           ├── auth/
│           ├── database/
│           └── http/
│
├── shared/
│   ├── auth/
│   ├── database/
│   │   ├── sqlite/
│   │   └── supabase/
│   └── server/
│
├── package.json
└── tsconfig.json
```

* `**concepts/**` — Experiments with Node.js APIs, runtime behavior & fundamental concepts.

* `**frameworks/**` — Framework-specific experiments, integrations & implementation patterns.

* `**shared/**` — Shared schemas, types, configuration & infrastructure used across experiments.

Individual experiments can contain their own source code, dependencies, configuration, database schemas, API examples & supporting files.

There is no requirement for every experiment to follow the same internal structure.

Each one can be organized according to what makes sense for the subject being explored.

## Philosophy

The principle behind this repository is simple: **learn by building.**

I use it to:

* Explore unfamiliar concepts through hands-on experimentation.

* Compare implementations and architectural approaches.

* Evaluate technologies before using them in larger projects.

* Investigate runtime behavior, libraries & development tools.

* Build isolated proofs of concept without unnecessary complexity.

* Keep a record of experiments and lessons learned.

The code doesn't always need to be elegant or complete.

It needs to be useful for learning.

## Current Focus

The repository currently focuses primarily on backend development with Node.js & TypeScript.

Areas of exploration include:

* HTTP servers & routing

* Express

* SQLite & Supabase

* Database integrations & schema design

* API structure & design

* CommonJS & Node.js runtime behavior

* Authentication & password hashing

* Project organization & shared infrastructure

Other languages, frameworks & technologies will be added as I explore them.

## Notes

This repository is intentionally a work in progress.

Code, dependencies, conventions & directory structures may change as experiments evolve.

Some experiments may be incomplete, and others may never go beyond a proof of concept.

That's part of the process.

An experiment doesn't need to become a complete project to be valuable.

Sometimes the most useful outcome is understanding why an approach works, why it doesn't or how it compares to an alternative.

---

> **_codelabs is about exploration, not perfection_.**

---
