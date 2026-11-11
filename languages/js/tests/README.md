# JavaScript Tests

<br />

This directory contains automated tests for the JavaScript & Node.js experiments.

The current suite uses Jest as its test runner and Supertest to exercise HTTP applications.

<br />

## Execution

<br />

Install the repository's JavaScript dependencies from the repository root:

```bash
./scripts/js/setup.sh
```

<br />

Then run the tests from `languages/js`:

```bash
npm test
```

<br />

The available scripts are:

| Command | Purpose |
| --- | --- |
| `npm test` | Run the Jest suite. |
| `npm run test:watch` | Rerun tests as files change. |
| `npm run test:coverage` | Run tests and generate coverage reports. |

<br />

The scripts are declared in [`languages/js/package.json`](../package.json).

<br />

Run them from the `languages/js` directory.

<br />

## Current Coverage

<br />

Tests are organized by the implementation they exercise:

<br />

| Test | Subject |
| --- | --- |
| [Basic server](jest/backend/supertest/frameworks/express/server/basic/server.test.ts) | Basic Express application behavior. |
| [Routes](jest/backend/supertest/frameworks/express/server/routes/routes.test.ts) | HTTP route handling. |
| [Native SQLite](jest/backend/supertest/frameworks/express/database/sqlite/native/sqlite.test.ts) | Express endpoints backed by Node.js native SQLite. |

<br />

The tests use Supertest to send HTTP requests to the applications without requiring each test to manage a separately running HTTP server.

<br />

## Dependency Ownership

<br />

Jest, ts-jest & TypeScript are declared in the JavaScript workspace package at [`../package.json`](../package.json).

<br />

Supertest and `@types/supertest` are declared separately in [`jest/backend/supertest/package.json`](jest/backend/supertest/package.json).

<br />

This keeps the HTTP-testing dependency close to the tests that use it.

<br />

The repository setup script discovers both manifests.

<br />

## Jest Configuration

<br />

The configuration is maintained in [`../jest.config.ts`](../jest.config.ts), with the custom resolver in [`../jest.resolver.ts`](../jest.resolver.ts).

<br />
The current setup:

<br />

- Uses the Node.js test environment.
- Uses ts-jest to transform TypeScript test files.
- Collects coverage output under `tests/jest/coverage`.
- Applies a project-specific resolver for selected CommonJS TypeScript imports.

<br />

### Why the custom resolver exists

<br />

Some CommonJS TypeScript source files use the `.cts` extension, while their relative import specifiers use the corresponding `.cjs` runtime extension.

<br />

When the importing file's directory is inside Jest's `rootDir` and is not inside `node_modules`, a relative request ending in `.cjs` is checked for a corresponding `.cts` file.

<br />

If that file exists, the resolver uses it; otherwise, the request is passed to Jest's default resolver.

<br />

This is intentionally narrow.

<br />
It does not rewrite arbitrary package imports or every file extension.

<br />

The eligibility check is based on the importing file's directory; the resolver does not independently enforce that the resolved `.cts` path remains inside `rootDir`.


<br />

## Adding Tests

<br />

Keep tests grouped by the implementation and behavior they verify.

<br />

Prefer descriptive test names and assertions against observable HTTP behavior.

<br />

When a test area introduces a dependency that should remain local to that area, declare it in the nearest appropriate package manifest and keep its lockfile alongside it.

<br />

Update this guide when the suite's structure, commands or resolver behavior changes.