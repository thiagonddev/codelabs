# Node.js

<br />

> _A workspace for exploring Node.js and TypeScript backend development through focused experiments_.

<br />

## Overview

<br />

This directory contains experiments focused on backend development with Node.js & TypeScript.

<br />

Rather than building a single application, the workspace provides an environment for exploring runtime behavior, comparing implementation approaches, testing integrations & understanding backend development concepts through practical examples.

<br />

The experiments are organized into three main areas: `concepts/`, `frameworks/` & `shared/`.

<br />

Each experiment can evolve independently, with its own dependencies, configuration & implementation choices.

<br />

## Structure

<br />

```
node/
├── concepts/
│   └── commonjs/
├── frameworks/
│   └── express/
│       └── commonjs/
├── shared/
│   ├── auth/
│   ├── database/
│   └── server/
├── package.json
├── package-lock.json
└── tsconfig.json
```

<br />

### `concepts/`

Experiments focused on Node.js fundamentals, built-in APIs, runtime behavior & backend development concepts.

<br />

Current explorations include:

<br />

- HTTP servers & request handling
- Routing and API design
- Operating system APIs
- CommonJS module behavior
- SQLite & Supabase integrations

<br />

These experiments explore how backend functionality works, including implementations that use Node.js APIs directly rather than relying on a framework.

<br />

### `frameworks/`

Experiments focused on frameworks, libraries, integrations & implementation patterns.

<br />

Current explorations primarily use Express and include:

<br />

- Server configuration & middleware
- Routing and request handling
- Database integrations
- Authentication & authorization
- JWTs and password hashing

<br />

Framework-based experiments provide an opportunity to explore higher-level abstractions & compare them with more direct Node.js implementations.

<br />

### `shared/`

Supporting code & resources that can be reused across experiments when appropriate.

<br />

Current areas include:

<br />

- `auth/` — authentication types, schemas & supporting resources
- `database/` — database integrations, configurations, schemas and types
- `server/` — server configuration & shared API resources

<br />

Shared code helps reduce duplication without requiring every experiment to follow the same architecture.

<br />

Reuse is intentional rather than mandatory.

<br />

An experiment can maintain its own implementation when that better serves the concept being explored.

<br />

## Requirements

<br />

- Node.js `24.18.0` or later
- `npm`
- TypeScript tooling appropriate to the experiment

<br />

Individual experiments may have additional requirements, such as native modules, database services, environment variables or external API credentials.

<br />

## Dependencies

<br />

The root `package.json` defines dependencies & development tooling shared across the workspace.

<br />

### Runtime Dependencies

<br />

| Package | Purpose |
| --- | --- |
| `cors` | Middleware for configuring Cross-Origin Resource Sharing (CORS). |
| `helmet` | Middleware for setting HTTP security-related response headers. |

<br />

### Development Dependencies

<br />

| Package | Purpose |
| --- | --- |
| `@types/cors` | TypeScript declarations for `cors`. |
| `@types/node` | TypeScript declarations for Node.js APIs. |

<br />

Individual experiments may declare additional dependencies in their own package manifests.

<br />

## TypeScript

<br />

The root `tsconfig.json` defines the following compiler options:

<br />

| Option | Value | Description |
| --- | --- | --- |
| `target` | `es2025` | Targets the ECMAScript 2025 language level. |
| `strict` | `true` | Enables strict type-checking options. |
| `noEmit` | `true` | Prevents TypeScript from generating compiled output. |
| `types` | `["node"]` | Explicitly includes Node.js type definitions in the global type scope. |

<br />

This configuration supports strict type checking without generating JavaScript files.

<br />

The `target` option specifies the language level used for TypeScript compilation & checking.

<br />

It does not, by itself, configure Node.js module resolution or determine whether an experiment uses CommonJS or ECMAScript modules.

<br />

Experiments may provide additional TypeScript configuration when their requirements differ from the workspace defaults.

<br />

## Explore

<br />

Each experiment has its own setup & execution requirements.

<br />

A typical workflow is:

<br />

1. Navigate to the experiment you want to explore.
2. Inspect its source files, `package.json` and configuration.
3. Install dependencies using the appropriate package manifest & lockfile.
4. Configure any required environment variables or external services.
5. Run the available scripts or use the execution method documented by the experiment.
6. Record useful observations, limitations & implementation trade-offs.

<br />

### Type Checking

<br />

For projects using the root TypeScript configuration, run:

<br />

```
npx tsc --project tsconfig.json
```

<br />

Run the command from the directory containing the intended configuration or specify its path explicitly.

<br />

Because `noEmit` is enabled, this command checks the code without generating JavaScript output.

<br />

Type checking does not execute the experiment.

<br />

The execution method depends on its dependencies, module system & runtime configuration.

<br />

### Dependencies & Configuration

<br />

The workspace root & individual experiments may contain their own package manifests, lockfiles and configuration files.

<br />

Use the package manifest & lockfile associated with the project you intend to install or run.

<br />

Do not assume that every nested experiment shares the same dependency tree or configuration.

<br />

## Organization

<br />

Experiments are grouped by concept, framework or implementation approach rather than forced into a single application structure.

<br />

Depending on their requirements, individual experiments may contain:

<br />

- Source files & package manifests
- Dedicated dependencies and configuration
- Database schemas & data access implementations
- API request examples
- Environment variable examples
- Experiment-specific documentation

<br />

A dedicated README is useful when an experiment has non-obvious setup instructions, external dependencies, architectural decisions or findings worth preserving.

<br />

Smaller experiments can remain self-explanatory when additional documentation would add little value.

<br />

## Shared Code & Architecture

<br />

Shared modules are introduced when multiple experiments benefit from common types, schemas, utilities or configuration.

<br />

When an experiment depends on shared code, its import paths & TypeScript configuration should make that relationship explicit.

<br />

Not every implementation needs to use the same abstractions.

<br />

Similar problems may be explored through different approaches to make their trade-offs easier to understand.

<br />

Dependencies & shared modules should simplify experimentation rather than impose unnecessary architectural constraints.

<br />

## Security & Configuration

<br />

Some experiments involve authentication, password hashing, JWTs, databases or external services.

<br />

When configuration requires credentials or secrets:

<br />

- Keep sensitive values out of source control.
- Use environment variables or appropriate local configuration.
- Provide example configuration files without real credentials when useful.
- Document required services & configuration in the relevant experiment.
- Treat experimental authentication and security implementations as learning exercises unless they have been independently reviewed for production use.

<br />

## Philosophy

<br />

These experiments are learning exercises, not necessarily production-ready applications.

<br />

The objective is to understand how Node.js & its ecosystem work, compare alternative implementations and explore architectural decisions without introducing complexity that does not serve the experiment.