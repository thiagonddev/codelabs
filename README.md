# codelabs

> A personal monorepo for experiments, prototypes & learning.

 ## About

 **codelabs** is my personal playground for trying new ideas, exploring technologies & experimenting with different ways of building software.

 This isn't a collection of polished portfolio projects. It's a place where I can try things out, compare different approaches, work with unfamiliar tools & break things without worrying about production quality.

 Think of it as a collection of **knowledge drafts**: small experiments that help me understand a concept and, sometimes, grow into something more complete.

 ## What I Explore

 The experiments in this repository cover different parts of software development, including:

 - Backend architectures
- Frameworks and runtimes
- Database integrations
- API design
- Project organization
- Development workflows
- New libraries and tools
- Different solutions to the same problem

 Not everything here is meant to be finished. Some projects are quick proofs of concept, some compare technologies or implementations, while others are simply ideas I wanted to explore in code.

 Sometimes the goal isn't to build something production-ready. It's just to understand how something works.

 ## Repository Structure

 The repository is organized around areas of experimentation rather than a single application architecture.

```
codelabs/
├── backend/
│   └── js/
│       └── node/
│           ├── concepts/       # Runtime and language experiments
│           ├── frameworks/     # Framework-specific experiments
│           └── utils/          # Utilities and integrations
│
└── README.md
```

 Node.js experiments are further organized by the topic or technology being explored:

```
backend/js/node/
├── concepts/
│   └── cjs/
│       ├── db/
│       │   ├── sqlite/
│       │   └── supabase/
│       ├── os/
│       └── server/
│
├── frameworks/
│   └── express/
│       └── cjs/
│           ├── db/
│           └── server/
│
└── utils/
    └── db/
        ├── sqlite/
        └── supabase/
```

 Each experiment can contain whatever it needs: source code, dependencies, configuration, schemas, API examples & other supporting files.

 The structure isn't set in stone and will change as the repository grows.

 ## Why This Exists

 The main goal is simple: **learn by building**.

 I use this repository to:

 - Learn new concepts through hands-on experimentation.
- Compare different implementations and approaches.
- Try technologies before introducing them into larger projects.
- Explore unfamiliar tools and architectural patterns.
- Build small, isolated experiments that may eventually grow into larger applications.
- Keep a record of things I've learned along the way.

 ## Current Focus

 Right now, most of the repository is focused on backend development with Node.js.

 Some of the current experiments involve:

 - HTTP server implementations
- Express
- SQLite
- Supabase
- API structure and design
- CommonJS & Node.js runtime behavior
- Different approaches to organizing projects

 More languages, frameworks & technologies will be added as I explore them.

 ## Notes

 This repository is intentionally a work in progress.

 Code, dependencies, conventions & folder structures may change often. Experiments may be refactored, replaced, abandoned or completely reorganized as I learn more.

 That's part of the point.

> **codelabs is about exploration, not perfection.**
