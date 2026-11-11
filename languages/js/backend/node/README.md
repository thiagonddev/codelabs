# Node.js

<br />

> A workspace for exploring Node.js & TypeScript backend development through focused experiments.

<br />

This directory contains backend experiments that investigate Node.js fundamentals, framework-based implementations and reusable resources.

<br />

The goal is to understand runtime behavior & backend concepts through implementation, not to build one monolithic application.

<br />

## Explore

<br />

| Area | Focus |
| --- | --- |
| [`concepts/`](concepts/) | Node.js APIs & backend fundamentals, including CommonJS, HTTP servers, operating-system information, SQLite & Supabase. |
| [`frameworks/express/`](frameworks/express/README.md) | Express server patterns, middleware, routing, database access and authentication experiments. |
| [`shared/`](shared/README.md) | Reusable authentication, database and server types, schemas & helpers. |

<br />

Each experiment can evolve independently.

<br />

It may have its own package manifest, lockfile, dependencies & execution script.

<br />

## Requirements

<br />

- Node.js `24.22.1` or later.
- npm.

<br />

The minimum version matches the `engines.node` field in this package manifest and the JavaScript workspace manifest.

<br />

## Dependencies

<br />

The package manifest in this directory declares dependencies used by the Node.js backend workspace:

<br />

| Package | Purpose |
| --- | --- |
| `cors` | CORS middleware. |
| `helmet` | HTTP security-header middleware. |
| `@types/cors` | TypeScript declarations for CORS. |
| `@types/node` | TypeScript declarations for Node.js APIs. |

<br />

Other integrations declare their own dependencies in nearby manifests.

Examples include Express, bcrypt, jsonwebtoken and the Supabase client.

<br />

There is no single dependency manifest for every experiment in this directory.

<br />

Use the repository's [JavaScript setup script](../../../../scripts/README.md) to discover & install dependencies across the JavaScript packages.

<br />

## Concepts

<br />

The current concept experiments include:

<br />

- **HTTP servers:** basic server creation & request handling using Node.js APIs.

- **Routing:** a small implementation for handling HTTP paths.

- **Operating-system APIs:** examples using the built-in `node:os` module.

- **SQLite:** database access using Node.js's built-in `node:sqlite` API.

- **Supabase:** an example integration with the Supabase JavaScript client.

<br />

The examples are grouped under `concepts/commonjs/` & use package-level configuration where needed.

<br />

## Express

<br />

The Express workspace currently explores:

<br />

- Basic application & server setup.
- CORS middleware and HTTP response headers.
- Route handling.
- Native SQLite integration.
- JWT-based authentication with bcrypt password hashing & SQLite persistence.

<br />

The [Express guide](frameworks/express/README.md) maps the individual implementations & explains how to run them.

<br />

## Shared Resources

<br />

The `shared/` directory contains modules that can be reused where doing so helps keep related experiments consistent.

It includes authentication types and middleware, database schemas and types, a Supabase client configuration and server helpers.

Shared code is optional: an experiment can keep its own implementation when that is more useful for the concept being investigated.

See the [shared resources guide](shared/README.md) before reusing these modules.

<br />

## TypeScript configuration

<br />

The shared compiler configuration is located at [`languages/js/tsconfig.json`](../../tsconfig.json).

<br />

Its current options include:

<br />

| Option | Value | Purpose |
| --- | --- | --- |
| `target` | `es2025` | Sets the ECMAScript language target. |
| `module` | `NodeNext` | Uses Node.js-aware module semantics. |
| `moduleResolution` | `NodeNext` | Resolves modules according to Node.js package & extension rules. |
| `strict` | `true` | Enables strict type checking. |
| `noEmit` | `true` | Prevents TypeScript from generating output. |
| `isolatedModules` | `true` | Enforces compatibility with single-file transpilation. |

<br />

The configuration also enables `esModuleInterop`, forces module detection and includes Node.js & Jest type definitions.

Individual experiments may add their own configuration when necessary.

<br />

## Execution

<br />

Many individual examples define a `dev` script in their local `package.json`.

To run one:

1. Open the directory containing the experiment.
2. Check its `package.json` and any local documentation.
3. Confirm that its dependencies have been installed.
4. Configure any required environment variables or external services.
5. Run the script defined by that package, commonly `npm run dev`.

<br />

Do not assume that a command or environment file used by one experiment applies to another.

<br />

## Security & Scope

<br />

Authentication, password hashing, JWT & database examples are learning exercises.

They have not been presented as production-ready services or independently security-audited implementations.

<br />

Never commit real credentials.

<br />

Treat tracked `.env.example` files as templates, replace sample values for local experiments and keep actual secrets in local, ignored environment files.

In particular, the current JWT example's development configuration loads a committed example environment file; do not put a real JWT secret in that file.

<br />

For test commands and the custom Jest resolver, see [`languages/js/tests/README.md`](../../tests/README.md).