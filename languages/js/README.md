# JavaScript & TypeScript Workspace

<br />

This directory contains the JavaScript and TypeScript tooling, backend experiments & automated tests used throughout the repository.

<br />

It is not configured as a single npm workspace.

<br />

Dependency manifests & lockfiles are scoped to the workspace or to individual experiments so that examples can keep their own requirements.

<br />

## Requirements

<br />

- Node.js `24.22.1` or later
- npm

<br />

The minimum Node.js version matches the `engines.node` requirement in this directory's `package.json` and the Node.js backend package manifest.

<br />

## Install dependencies

<br />

Run the setup helper from the repository root:

```bash
./scripts/js/setup.sh --dry-run
./scripts/js/setup.sh
```

<br />

The helper searches recursively for `package.json` files under `languages/js`.

<br />

It runs `npm install` in packages that declare dependencies, skips packages without declared dependencies & reports individual failures in its final summary.

<br />

The dry run previews which packages would be installed without invoking npm.

<br />

Node.js is still required because the helper uses it to parse package manifests.

<br />

See [Scripts](../../scripts/README.md) for the helper's behavior and options.

<br />

## Workspace map

<br />

| Path | Responsibility |
| --- | --- |
| [`backend/node/`](backend/node/README.md) | Node.js runtime concepts, Express experiments and shared backend resources. |
| [`tests/`](tests/README.md) | Jest configuration and Supertest-based HTTP tests. |
| [`package.json`](package.json) | Jest, ts-jest, TypeScript, tsx and shared JavaScript tooling. |
| [`tsconfig.json`](tsconfig.json) | Shared TypeScript compiler options. |
| [`jest.config.ts`](jest.config.ts) | Jest runtime, transform, resolver and coverage configuration. |
| [`jest.resolver.ts`](jest.resolver.ts) | Project-scoped resolution of relative `.cjs` specifiers to existing `.cts` source files. |

<br />

Individual experiments may define additional package manifests, lockfiles & configuration.

<br />

Install and run commands in the context of the package that owns them; do not assume that every directory shares one dependency tree.

<br />

## Type checking

<br />

From this directory:

```bash
npx tsc --project tsconfig.json
```

<br />

The configuration enables strict checking, uses `NodeNext` for module and module resolution behavior, targets ES2025 and sets `noEmit` to `true`.

<br />

The command checks types without generating JavaScript output.

<br />

The configuration also enables `esModuleInterop`, `moduleDetection: "force"` & `isolatedModules` and includes Node.js + Jest type definitions.

<br />

## Testing

<br />

Run the Jest scripts from this directory:

```bash
npm test
npm run test:watch
npm run test:coverage
```

<br />

The test files live under [`tests/jest/`](tests/jest/).

Supertest and its type definitions are declared by the nested package at [`tests/jest/backend/supertest/package.json`](tests/jest/backend/supertest/package.json).

<br />

The custom Jest resolver supports the repository's current CommonJS TypeScript experiments: for relative project-source requests ending in `.cjs`, it checks for a corresponding `.cts` file and resolves to that source file when it exists.

<br />

Other requests are delegated to Jest's default resolver.

<br />

See the [testing guide](tests/README.md) for the test layout & resolution details.

<br />

## Dependency boundaries

<br />

The main `languages/js/package.json` declares the test runner & shared development tooling.

<br />

The Node.js backend has its own manifest and framework integrations or individual experiments may declare additional dependencies closer to the code that uses them.

<br />

This organization is deliberate: experiments can be installed & explored independently without requiring every example to adopt the same stack.