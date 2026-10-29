#!/usr/bin/env bash

set -uo pipefail

# ============================================================
# Repository setup script
# ============================================================
# Usage:
#   ./scripts/js/setup.sh
#   ./scripts/js/setup.sh --dry-run
#   ./scripts/js/setup.sh --help
#
# Behavior:
#   - Discovers every package.json under languages/js.
#   - Installs dependencies when declared.
#   - Skips packages without declared dependencies.
#   - Continues processing if an installation fails.
#   - Excludes node_modules and .git from discovery.
# ============================================================

# ------------------------------------------------------------
# 1. Resolve repository root and search directory
# ------------------------------------------------------------

SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
  pwd
)" || exit 1

ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)" || exit 1
SEARCH_ROOT="$ROOT_DIR/languages/js"

# ------------------------------------------------------------
# 2. Runtime options
# ------------------------------------------------------------

DRY_RUN=false

usage() {
  printf 'Usage: ./scripts/js/setup.sh [--dry-run|--help]\n'
  printf '  --dry-run  Preview actions without installing dependencies\n'
  printf '  --help     Display this help message\n'
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)
      if [[ "$DRY_RUN" == true ]]; then
        printf 'Error: duplicate argument: %s\n' "$arg" >&2
        usage >&2
        exit 2
      fi
      DRY_RUN=true
      ;;
    --help|-h)
      if (( $# != 1 )); then
        printf 'Error: --help cannot be combined with other arguments.\n' >&2
        usage >&2
        exit 2
      fi
      usage
      exit 0
      ;;
    *)
      printf 'Error: unknown argument: %s\n' "$arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# ------------------------------------------------------------
# 3. Prerequisite checks
# ------------------------------------------------------------

if ! command -v node >/dev/null 2>&1; then
  printf 'Error: Node.js is not installed or not in PATH.\n' >&2
  exit 2
fi

if [[ "$DRY_RUN" != true ]] &&
   ! command -v npm >/dev/null 2>&1; then
  printf 'Error: npm is not installed or not in PATH.\n' >&2
  exit 2
fi

if [[ ! -d "$SEARCH_ROOT" ]]; then
  printf 'Error: search directory does not exist: %s\n' \
    "$SEARCH_ROOT" >&2
  exit 2
fi

# ------------------------------------------------------------
# 4. Counters
# ------------------------------------------------------------

TOTAL=0
PROCESSED=0
INSTALLED=0
WOULD_INSTALL=0
SKIPPED=0
FAILED=0

printf 'Repository: %s\n' "$ROOT_DIR"
printf 'Search root: %s\n' "$SEARCH_ROOT"

if [[ "$DRY_RUN" == true ]]; then
  printf 'Mode: DRY RUN (no installations)\n'
else
  printf 'Mode: INSTALL\n'
fi

# ------------------------------------------------------------
# 5. Process one package
# ------------------------------------------------------------

process_project() {
  local package_json="$1"
  local project_dir="${package_json%/package.json}"
  local relative_path="${project_dir#"$ROOT_DIR"/}"
  local dependency_status

  PROCESSED=$((PROCESSED + 1))

  printf '\n----------------------------------------\n'
  printf 'Project: %s\n' "$relative_path"

  # Parse package.json and detect declared dependencies.
  if ! dependency_status="$(
    node -e '
      const fs = require("node:fs");
      const file = process.argv[1];

      let pkg;

      try {
        pkg = JSON.parse(fs.readFileSync(file, "utf8"));
      } catch (error) {
        console.error(error.message);
        process.exit(1);
      }

      if (
        pkg === null ||
        typeof pkg !== "object" ||
        Array.isArray(pkg)
      ) {
        console.error("package.json must contain a JSON object");
        process.exit(1);
      }

      const fields = [
        "dependencies",
        "devDependencies",
        "optionalDependencies",
        "peerDependencies"
      ];

      const hasDependencies = fields.some(field => {
        const value = pkg[field];

        return value !== null &&
          typeof value === "object" &&
          !Array.isArray(value) &&
          Object.keys(value).length > 0;
      });

      process.stdout.write(hasDependencies ? "yes" : "no");
    ' "$package_json" 2>&1
  )"; then
    printf 'Status: FAILED (invalid package.json)\n' >&2
    if [[ -n "$dependency_status" ]]; then
      printf '%s\n' "$dependency_status" >&2
    fi
    FAILED=$((FAILED + 1))
    return 1
  fi

  if [[ "$dependency_status" != "yes" ]]; then
    printf 'Status: SKIPPED (no declared dependencies)\n'
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  printf 'Command: npm install\n'

  if [[ "$DRY_RUN" == true ]]; then
    printf 'Status: WOULD INSTALL\n'
    WOULD_INSTALL=$((WOULD_INSTALL + 1))
    return 0
  fi

  if (cd -- "$project_dir" && npm install); then
    printf 'Status: SUCCESS\n'
    INSTALLED=$((INSTALLED + 1))
    return 0
  else
    printf 'Status: FAILED (npm install returned an error)\n' >&2
    FAILED=$((FAILED + 1))
    return 1
  fi
}

# ------------------------------------------------------------
# 6. Discover every package.json
# ------------------------------------------------------------

printf '\nDiscovering packages...\n'

DISCOVERY_FILE="$(mktemp)" || {
  printf 'Error: could not create temporary file for package discovery.\n' >&2
  exit 1
}

trap 'rm -f -- "$DISCOVERY_FILE"' EXIT

if ! find "$SEARCH_ROOT" \
  \( -type d \( -name node_modules -o -name .git \) -prune \) \
  -o \
  \( -type f -name package.json -print0 \) \
  > "$DISCOVERY_FILE"; then
  printf 'Error: package discovery failed under: %s\n' \
    "$SEARCH_ROOT" >&2
  exit 1
fi

while IFS= read -r -d '' package_json; do
  TOTAL=$((TOTAL + 1))
  process_project "$package_json" || true
done < "$DISCOVERY_FILE"

# ------------------------------------------------------------
# 7. Final report
# ------------------------------------------------------------

printf '\n========================================\n'
printf 'SETUP SUMMARY\n'
printf '========================================\n'
printf 'Discovered: %d\n' "$TOTAL"
printf 'Processed: %d\n' "$PROCESSED"

if [[ "$DRY_RUN" == true ]]; then
  printf 'Would install: %d\n' "$WOULD_INSTALL"
else
  printf 'Installed: %d\n' "$INSTALLED"
fi

printf 'Skipped: %d\n' "$SKIPPED"
printf 'Failed: %d\n' "$FAILED"
printf '========================================\n'

if (( FAILED > 0 )); then
  printf 'Result: completed with errors.\n' >&2
  exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
  printf 'Result: dry run completed successfully.\n'
else
  printf 'Result: setup completed successfully.\n'
fi

exit 0