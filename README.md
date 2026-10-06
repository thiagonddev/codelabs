# codelabs

 > A personal monorepo for experiments, prototypes & learning.

 ## About

 **codelabs** is my personal playground for trying new ideas, exploring technologies & experimenting with different ways of building software.

 It isn't a collection of polished portfolio projects.

 It's a place to experiment, compare approaches, work with unfamiliar tools & break things without worrying about production quality.

 Think of it as a collection of **knowledge drafts**: small experiments that help me understand a concept, explore a technology or test an approach.
 
 Some may eventually grow into something more complete; others exist simply because I wanted to understand how something works.

 ## Topics

 The experiments in this repository cover different areas of software development, including:

- Backend architectures
- Frameworks & runtimes
- Database integrations
- API design
- Project organization
- Development workflows
- Libraries & tools
- Different solutions to the same problem

 Not everything here is meant to be finished.

 Some projects are quick proofs of concept; others compare technologies or implementations, while some are simply ideas I wanted to explore in code.

 Sometimes the goal isn't to build something production-ready.

 It's simply to **understand how something works**.

 ## Structure

 The repository is organized around areas of experimentation rather than a single application architecture.

```
codelabs/
├── backend/
│   └── js/
│       └── node/
│           ├── concepts/       # Node.js and runtime experiments
│           ├── frameworks/     # Framework-specific experiments
│           └── shared/         # Shared experiments and infrastructure
│
├── languages/
│   └── bash/                   # Language experiments
│
└── README.md
```

 Node.js experiments are further organized by the topic or technology being explored:

```
backend/js/node/
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
└── shared/
    ├── auth/
    ├── database/
    │   ├── sqlite/
    │   └── supabase/
    └── server/
```

 Each experiment can contain whatever it needs: source code, dependencies, configuration, schemas, API examples & other supporting files.

 There is no requirement for every experiment to follow the same structure.

 The organization itself is part of the experimentation and will evolve as the repository grows.

 ## Philosophy

 The main goal is simple: **learn by building.**

 I use this repository to:

- Learn new concepts through hands-on experimentation.
- Compare different implementations & approaches.
- Try technologies before introducing them into larger projects.
- Explore unfamiliar tools & architectural patterns.
- Build small, isolated experiments that may eventually grow into larger applications.
- Keep a record of things I've learned along the way.

 The code doesn't always need to be elegant.

 It needs to be useful for learning.

 ## Current Focus

 Most of the repository is currently focused on backend development with Node.js.

 Current experiments include:

- HTTP server implementations
- Express
- SQLite
- Supabase
- API structure & design
- CommonJS & Node.js runtime behavior
- Authentication
- Project organization

 More languages, frameworks & technologies will be added as I explore them.

 ## Notes

 This repository is intentionally a work in progress.

 Code, dependencies, conventions & folder structures may change often.

 That's part of the point.

 A small experiment doesn't need to become a complete project to be valuable.
 
 Sometimes the most useful result is simply understanding why an approach works, why it doesn't or how it compares to another one.

 ---
 
 > ### **codelabs is about exploration, not perfection.**

---
