
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
# Policies:
#   install      Install dependencies if the package declares any.
#   scripts-only Skip dependency installation for this path.
#   skip         Ignore this path entirely.
#
# All paths are relative to the repository root.
# ============================================================

# ------------------------------------------------------------
# 1. Resolve repository root
# ------------------------------------------------------------

SCRIPT_DIR="$(
  cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &&
  pwd
)" || exit 1

ROOT_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)" || exit 1

# ------------------------------------------------------------
# 2. Configuration
# ------------------------------------------------------------
# Edit this list to control which projects are processed.
#
# Format:
#   "relative/path|policy"
#
# A package.json with no dependencies is automatically skipped
# when its policy is "install".
# ------------------------------------------------------------

PROJECTS=(
  # JavaScript root project
  "languages/js|install"

  # Node.js concepts
  "languages/js/backend/node|install"
  "languages/js/backend/node/concepts/commonjs/database/sqlite/native|install"
  "languages/js/backend/node/concepts/commonjs/database/supabase|install"
  "languages/js/backend/node/concepts/commonjs/os|install"
  "languages/js/backend/node/concepts/commonjs/server/basic|install"
  "languages/js/backend/node/concepts/commonjs/server/routes|install"

  # Express framework
  "languages/js/backend/node/frameworks/express|install"
  "languages/js/backend/node/frameworks/express/commonjs/auth/jwt|install"
  "languages/js/backend/node/frameworks/express/commonjs/auth/jwt/bcrypt|install"
  "languages/js/backend/node/frameworks/express/commonjs/auth/jwt/bcrypt/sqlite/native|install"
  "languages/js/backend/node/frameworks/express/commonjs/database/sqlite/native|install"
  "languages/js/backend/node/frameworks/express/commonjs/server/basic|install"
  "languages/js/backend/node/frameworks/express/commonjs/server/cors|install"
  "languages/js/backend/node/frameworks/express/commonjs/server/routes|install"

  # Shared modules
  "languages/js/backend/node/shared/database/supabase|install"

  # Tests
  "languages/js/tests/jest/backend/supertest|install"
)

# ------------------------------------------------------------
# 3. Runtime options
# ------------------------------------------------------------

DRY_RUN=false

# Reject extra arguments before processing options, including --help.
if (( $# > 1 )); then
  printf 'Error: unexpected extra argument: %s\n' "$2" >&2
  printf 'Usage: ./scripts/js/setup.sh [--dry-run|--help]\n' >&2
  exit 2
fi

case "${1:-}" in
  "")
    ;;
  --dry-run)
    DRY_RUN=true
    ;;
  --help|-h)
    printf 'Usage: ./scripts/js/setup.sh [--dry-run|--help]\n'
    printf '  --dry-run  Preview actions without installing dependencies\n'
    printf '  --help     Display this help message\n'
    exit 0
    ;;
  *)
    printf 'Error: unknown argument: %s\n' "$1" >&2
    printf 'Use --help for usage.\n' >&2
    exit 2
    ;;
esac

# ------------------------------------------------------------
# 4. Prerequisite checks
# ------------------------------------------------------------

# Node.js is required in both modes to parse package.json.
if ! command -v node >/dev/null 2>&1; then
  printf 'Error: Node.js is not installed or not in PATH.\n' >&2
  exit 2
fi

# npm is required only when installing dependencies.
if [[ "$DRY_RUN" != true ]] &&
   ! command -v npm >/dev/null 2>&1; then
  printf 'Error: npm is not installed or not in PATH.\n' >&2
  exit 2
fi

# ------------------------------------------------------------
# 5. Counters and reporting
# ------------------------------------------------------------

TOTAL=${#PROJECTS[@]}
PROCESSED=0
INSTALLED=0
WOULD_INSTALL=0
SKIPPED=0
FAILED=0

printf 'Repository: %s\n' "$ROOT_DIR"
printf 'Configured projects: %d\n' "$TOTAL"

if [[ "$DRY_RUN" == true ]]; then
  printf 'Mode: DRY RUN (no installations)\n'
else
  printf 'Mode: INSTALL\n'
fi

# ------------------------------------------------------------
# 6. Process a configured project
# ------------------------------------------------------------

process_project() {
  local relative_path="$1"
  local policy="$2"
  local project_dir="$ROOT_DIR/$relative_path"
  local package_json="$project_dir/package.json"
  local dependency_status

  printf '\n----------------------------------------\n'
  printf 'Project: %s\n' "$relative_path"
  printf 'Policy:  %s\n' "$policy"

  case "$policy" in
    skip)
      printf 'Status: SKIPPED (disabled in configuration)\n'
      SKIPPED=$((SKIPPED + 1))
      return 0
      ;;

    install|scripts-only)
      ;;

    *)
      printf 'Error: invalid policy: %s\n' "$policy" >&2
      FAILED=$((FAILED + 1))
      return 1
      ;;
  esac

  if [[ ! -d "$project_dir" ]]; then
    printf 'Error: configured directory does not exist.\n' >&2
    FAILED=$((FAILED + 1))
    return 1
  fi

  if [[ ! -f "$package_json" ]]; then
    printf 'Error: package.json not found.\n' >&2
    FAILED=$((FAILED + 1))
    return 1
  fi

  if [[ "$policy" == "scripts-only" ]]; then
    printf 'Status: SKIPPED (scripts-only policy)\n'
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi

  # Parse package.json and determine whether dependencies exist.
  # Invalid JSON is an error, not a reason to silently skip.
  if ! dependency_status="$(
    node -e '
      const fs = require("node:fs");
      const file = process.argv[1];
      const pkg = JSON.parse(fs.readFileSync(file, "utf8"));

      const fields = [
        "dependencies",
        "devDependencies",
        "optionalDependencies",
        "peerDependencies"
      ];

      const hasDependencies = fields.some(field => {
        const value = pkg[field];
        return value &&
          typeof value === "object" &&
          !Array.isArray(value) &&
          Object.keys(value).length > 0;
      });

      process.stdout.write(hasDependencies ? "yes" : "no");
    ' "$package_json"
  )"; then
    printf 'Error: could not parse package.json.\n' >&2
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
# 7. Run all configured projects
# ------------------------------------------------------------

for entry in "${PROJECTS[@]}"; do
  relative_path="${entry%|*}"
  policy="${entry##*|}"

  PROCESSED=$((PROCESSED + 1))

  # Continue even if one project fails.
  process_project "$relative_path" "$policy" || true
done

# ------------------------------------------------------------
# 8. Final report
# ------------------------------------------------------------

printf '\n========================================\n'
printf 'SETUP SUMMARY\n'
printf '========================================\n'
printf 'Configured: %d\n' "$TOTAL"
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