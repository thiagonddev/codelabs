# Express

<br />

This directory contains Express-based backend experiments written in TypeScript using the CommonJS module system.

<br />

The examples are separated by the behavior or integration being explored.

<br />

They are small learning implementations, not one application that should be started as a whole.

<br />

## Experiments

<br />

| Path | Focus |
| --- | --- |
| [`commonjs/server/basic/`](commonjs/server/basic/) | Minimal Express application & server entry point. |
| [`commonjs/server/cors/`](commonjs/server/cors/) | CORS middleware configuration. |
| [`commonjs/server/routes/`](commonjs/server/routes/) | Separate HTTP routes and request handling. |
| [`commonjs/database/sqlite/native/`](commonjs/database/sqlite/native/) | Express endpoints using Node.js's native SQLite API. |
| [`commonjs/auth/jwt/bcrypt/sqlite/native/`](commonjs/auth/jwt/bcrypt/sqlite/native/) | Registration, login & authenticated user access using JWT, bcrypt and SQLite. |

<br />

Each runnable example has its own `package.json` and may define a `dev` script.

<br />

Run it from the directory containing that manifest:

```bash
cd languages/js/backend/node/frameworks/express/commonjs/server/basic
npm run dev
```

<br />

Change the path to the experiment you want to run. 

<br />

Install its dependencies first using the repository's [JavaScript setup script](../../../../../../scripts/README.md).

<br />

## Dependency boundaries

<br />

The Express dependency is declared in this directory's `package.json`.

<br />

Middleware and other integrations are declared in their respective package manifests or in the Node.js backend workspace.

<br />

For example, the JWT & bcrypt experiment has package-level dependencies for jsonwebtoken and bcrypt.

The SQLite examples use the built-in `node:sqlite` API and do not require a separate SQLite npm driver.

<br />

Check the nearest `package.json` before adding, removing or upgrading a dependency.

<br />

## Shared Resources

<br />

Some experiments import helpers, schemas or types from [`../../shared/`](../../shared/README.md).

These are shared building blocks, not mandatory abstractions for every example.

<br />

## HTTP Requests & Tests

<br />

Where present, `api.rest` files provide request examples for manual exploration.

The automated HTTP tests live in [`languages/js/tests/`](../../../../tests/README.md) & use Jest with Supertest.


The existing suite covers basic server behavior, routes and native SQLite integration.

<br />

## Configuration & Security

<br />

Some examples read environment variables for server configuration or authentication. 

Review the relevant package script and the referenced `.env.example` file before running an experiment.

<br />

> [!CAUTION]
>
> Do not commit actual credentials.
>
> The JWT development script currently loads a tracked example environment file; its sample secret is for disposable local experimentation only.
>
> Replace that configuration with a local ignored environment file before using a real secret.

<br />

These implementations are educational examples.

<br />

Authentication, CORS & security-header middleware should not be interpreted as a complete security design or production deployment configuration.