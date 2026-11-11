# Repository Scripts

<br />

This directory contains small utilities for inspecting the repository & setting up dependencies for the JavaScript experiments.

<br />

## Available Scripts

<br />

| Script | Purpose |
| --- | --- |
| [`filetree.sh`](filetree.sh) | Generates a readable directory tree and saves it as `filetree.txt`. |
| [`js/setup.sh`](js/setup.sh) | Discovers JavaScript package manifests & installs dependencies where they are declared. |

<br />

## JavaScript Dependency Setup

<br />

Run from the repository root:

```bash
./scripts/js/setup.sh --help
./scripts/js/setup.sh --dry-run
./scripts/js/setup.sh
```

<br />

The setup script:

<br />

1. Searches recursively under `languages/js` for `package.json` files.

<br />

2. Excludes `node_modules` & `.git` directories from discovery.

<br />

3. Uses Node.js to inspect the dependency fields in each manifest.

<br />

4. Runs `npm install` in packages that declare dependencies.

<br />

5. Skips packages without declared dependencies.

<br />

6. Continues after an individual installation failure & reports a summary.

<br />

The script requires Node.js.

An actual installation also requires npm; the dry-run mode does not invoke npm.

<br />

The script exits with a non-zero status if one or more package installations fail.


Because it runs `npm install` in each applicable package directory, it may create or update lockfiles.

<br />

Review the working tree after running it.

<br />

## Generate a directory tree

<br />

Run from the repository root:

```bash
./scripts/filetree.sh
```

<br />

To generate a tree for a specific directory:

```bash
./scripts/filetree.sh languages/js
```

<br />

The output is written to `filetree.txt` inside the selected target directory.

When no target is supplied, the current directory is used.

The script requires the `tree` command to be installed.

<br />

It excludes common generated or low-value entries, including `node_modules`, `.git`, build output, coverage directories, package manifests, lockfiles & any existing `filetree.txt`.

<br />

## Design notes

<br />

These scripts are convenience tools, not a replacement for inspecting package manifests or reviewing generated changes.

<br />

The setup helper does not run tests, type checks or application-specific setup steps.

<br />

The tree generator does not modify source files, but it does write its output file to the selected target directory.