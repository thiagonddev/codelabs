# codelabs

> A personal monorepo for experiments, prototypes & learning.

## About

**codelabs** is my personal playground for exploring new ideas, testing technologies & experimenting with different architectural approaches.

Unlike portfolio projects, this repository is intentionally built as a safe space to learn. Here I can prototype features, compare implementations, try unfamiliar tools & even break things without worrying about production quality.

Think of it as a collection of knowledge drafts that eventually help shape more complete & polished applications.

## Philosophy

This repository exists because experimentation is an important part of software development.

Inside this monorepo I explore topics such as:

* Backend architectures
* Different frameworks
* Database integrations
* Project organization
* API design
* Development workflows
* New libraries and tools

Not every project here is expected to become "finished." Some are proof of concepts, some are technology comparisons & others are simply notes written as code.

## Repository Structure

```
codelabs/
├── README.md
└── backend/
    ├── .env.example
    ├── .gitignore
    ├── .vsls.json
    └── js/
        └── node/
            ├── concepts/
            │   └── cjs/
            │       ├── db/
            │       │   ├── sqlite/
            │       │   │   └── native/
            │       │   │       ├── api.rest
            │       │   │       ├── index.ts
            │       │   │       ├── package.json
            │       │   │       └── schema.ts
            │       │   └── supabase/
            │       │       ├── api.http
            │       │       ├── index.ts
            │       │       ├── package-lock.json
            │       │       └── package.json
            │       ├── os/
            │       │   ├── index.ts
            │       │   ├── package-lock.json
            │       │   └── package.json
            │       └── server/
            │           ├── mvp/
            │           │   ├── index.ts
            │           │   └── package.json
            │           └── routes/
            │               ├── index.ts
            │               └── package.json
            ├── frameworks/
            │   └── express/
            │       ├── cjs/
            │       │   ├── db/
            │       │   │   └── sqlite/
            │       │   │       └── native/
            │       │   │           ├── api.rest
            │       │   │           ├── index.ts
            │       │   │           └── package.json
            │       │   └── server/
            │       │       └── mvp/
            │       │           ├── index.ts
            │       │           └── package.json
            │       ├── package-lock.json
            │       └── package.json
            ├── package-lock.json
            ├── package.json
            ├── tsconfig.json
            └── utils/
                └── db/
                    ├── sqlite/
                    │   ├── schema.ts
                    │   └── types.ts
                    └── supabase/
                        ├── config/
                        │   ├── .env.example
                        │   ├── db.ts
                        │   └── types.ts
                        ├── package-lock.json
                        └── package.json

```

## Purpose

The goal of this repository is to:

* Learn by building.
* Compare different implementations.
* Explore new technologies before using them in production or portfolio projects.
* Create small, isolated experiments that can later evolve into larger applications.

## Current Focus

At the moment, the repository mainly contains backend experiments with Node.js, including:

* Server implementations
* Express-based projects
* SQLite integrations
* Supabase integrations
* API structure experiments

More technologies, languages & frameworks will be added over time.

## Notes

This repository is under continuous development.

Code quality, conventions & folder structures may change frequently as new ideas are tested and older experiments are refactored or discarded.

That is expected — the purpose of **codelabs** is exploration.
