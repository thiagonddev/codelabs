#!/usr/bin/env bash

set -euo pipefail

if (( $# > 1 )); then
    printf 'Usage: %s [target-directory]\n' "$0" >&2
    exit 1
fi

if (( $# == 0 )); then
    TARGET="."
else
    TARGET="$1"
fi

while [[ "$TARGET" != "/" && "$TARGET" == */ ]]; do
    TARGET="${TARGET%/}"
done

OUTPUT="$TARGET/filetree.txt"

IGNORE=(
    "node_modules"
    "dist"
    "build"
    "coverage"
    ".git"
    ".next"
    ".turbo"
    "package.json"
    "package-lock.json"
    "filetree.txt"
)

PATTERN=$(IFS='|'; printf '%s' "${IGNORE[*]}")

if [[ ! -d "$TARGET" ]]; then
    printf 'Error: "%s" is not a directory.\n' "$TARGET" >&2
    exit 1
fi

if ! command -v tree >/dev/null 2>&1; then
    printf 'Error: "tree" is not installed.\n' >&2
    exit 1
fi

tree --noreport -I "$PATTERN" -- "$TARGET" > "$OUTPUT"

printf 'File tree saved to: %s\n' "$OUTPUT"