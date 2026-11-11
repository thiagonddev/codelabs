<div>

[🇺🇸 English](README.md) · [🇧🇷 Português](README.pt-BR.md)

</div>

<div align="center">
  <img
    width="1000"
    alt="codelabs — a personal engineering lab"
    src="https://github.com/user-attachments/assets/e253983a-97d3-441f-b587-bcfbf6f4fd7f"
  />
</div>

<br />

<div align="center">

![Commits](https://shieldcn.dev/github/commits/thiagonddev/codelabs.svg?size=default&logo=ri%3AFiGitCommit&mode=dark)
![Last commit](https://shieldcn.dev/github/last-commit/thiagonddev/codelabs.svg?size=default&logo=ri%3AFiGitCommit&mode=dark)

</div>

<br />

# codelabs

<br />

> _A personal engineering lab for experimentation, prototyping & continuous learning_.

<br />

`codelabs` is a collection of focused experiments for exploring software concepts through practical implementation.

<br />

It covers programming fundamentals, backend development, runtime behavior, database integrations, testing & development tooling.

<br />

Rather than prioritizing finished applications, this repository focuses on understanding how software works, why different implementations behave as they do and what trade-offs they introduce.

<br />

> [!NOTE]
>
> `codelabs` is a work in progress.
>
> Its code, dependencies, conventions and structure may evolve as experiments develop & new questions arise.

<br />

## Explore

<br />

| Area | What you'll find | Documentation |
| --- | --- | --- |
| **Bash** | Introductory exercises on variables, input & conditional execution. | [Bash guide](languages/bash/README.md) |
| **JavaScript & TypeScript** | Workspace configuration, runtime tooling and testing workflows. | [JavaScript workspace](languages/js/README.md) |
| **Node.js concepts** | Built-in APIs, CommonJS, HTTP servers, SQLite & Supabase experiments. | [Node.js guide](languages/js/backend/node/README.md) |
| **Express** | Server setup, CORS, routing, SQLite integration and authentication experiments. | [Express guide](languages/js/backend/node/frameworks/express/README.md) |
| **Shared backend resources** | Reusable authentication, database & server modules. | [Shared resources guide](languages/js/backend/node/shared/README.md) |
| **Testing** | Jest configuration and Supertest-based HTTP tests. | [Testing guide](languages/js/tests/README.md) |
| **Scripts** | Dependency setup & directory-tree utilities. | [Scripts guide](scripts/README.md) |

<br />

## Structure

<br />

The repository is organized by language & development area.

<br />

Experiments remain independently structured, while shared code is introduced where it provides a practical benefit.

<br />

```text
codelabs/
├── languages/
│   ├── bash/
│   │   ├── README.md
│   │   └── intro/
│   └── js/
│       ├── README.md
│       ├── backend/
│       │   └── node/
│       │       ├── README.md
│       │       ├── concepts/
│       │       ├── frameworks/
│       │       │   └── express/
│       │       └── shared/
│       └── tests/
│           └── README.md
├── scripts/
│   └── README.md
├── README.md
└── README.pt-BR.md
```

<br />

This is a high-level map, not a complete file listing.

<br />

Individual experiment directories contain their own source files, manifests, lockfiles & supporting resources.

<br />

## Getting Started

### Requirements

<br />

- **Node.js:** `24.22.1` or later, as declared by the JavaScript & Node.js package manifests.

<br />

- **npm:** used to install dependencies for the JavaScript and Node.js experiments.

<br />

- **Bash:** required by the repository utility scripts & Bash examples.

<br />

- **tree:** required only by the directory-tree script.

<br />

### Install JavaScript dependencies

<br />

There is no single root-level npm project.

Package manifests are scoped to the JavaScript workspace & individual experiments.

<br />

From the repository root, preview the setup script's actions:

```bash
./scripts/js/setup.sh --dry-run
```

<br />

Then install dependencies:

```bash
./scripts/js/setup.sh
```

<br />

The script discovers `package.json` files under `languages/js`, installs dependencies for packages that declare them, skips packages without dependencies and continues after individual installation failures.

<br />

Review its final summary for failures.

<br />

See the [JavaScript workspace guide](languages/js/README.md) for dependency boundaries, type checking & testing.

<br />

### Run a Bash exercise

<br />

From the repository root:

```bash
bash languages/bash/intro/variables.sh
bash languages/bash/intro/conditions.sh
```

<br />

---

<br />


### Run tests

<br />

After installing dependencies:

```bash
cd languages/js
npm test
```

<br />

Additional commands are available for watch mode and coverage:

```bash
npm run test:watch
npm run test:coverage
```

<br />

The tests and their custom Jest resolver are documented in the [testing guide](languages/js/tests/README.md).

<br />

## Experiments

<br />

Each experiment starts with a question, concept or implementation detail worth investigating.

<br />

Depending on its scope, it may contain source code, a package manifest, configuration, database schemas, HTTP request examples or automated tests.

<br />

Experiments are not required to share one architecture or abstraction layer.

<br />

Keeping them focused makes it easier to compare approaches & understand their behavior without introducing unnecessary coupling.

<br />

Some experiments may remain incomplete or never progress beyond a proof of concept; others may be refactored or expanded as the underlying understanding develops.

<br />

**_The primary goal is understanding, not production readiness_.**

<br />

Unless an experiment explicitly states otherwise, treat its code as a learning exercise rather than a production-ready implementation.

<br />

## Principles

<br />

- **Learn by building.** Investigate concepts through small, practical implementations.

<br/>

- **Prefer understanding over ceremony.** Introduce abstractions when they help answer the question being explored.

<br />

- **Compare approaches.** Examine how different implementations solve similar problems and what trade-offs they introduce.

<br />

- **Keep experiments focused.** Allow each exploration to evolve at a pace & structure appropriate to its scope.

<br />

- **Preserve useful findings.** Document non-obvious setup, decisions & observations close to the relevant code.

<br />

---

<br />

<div align="center">

> “_Code is the medium; understanding is the outcome_.”

</div>

<br />

---

