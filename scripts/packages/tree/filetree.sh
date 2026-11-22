#!/usr/bin/env bash

set -euo pipefail

# ============================================================
# Directory tree generator
# ============================================================
# Usage:
#   ./scripts/filetree.sh [options] [directory]
#
# Behavior:
#   - Uses the tree utility to display a directory structure.
#   - Writes filetree.txt to the target directory by default.
#   - Can print to stdout or write to a custom output file.
#   - Includes hidden entries on request.
#   - Excludes common generated and dependency directories by default.
#   - Preserves an existing output file if tree generation fails.
# ============================================================

# ------------------------------------------------------------
# 1. Defaults and runtime options
# ------------------------------------------------------------

SCRIPT_NAME="${0##*/}"
TARGET_DIR_INPUT="."
TARGET_SET=false
OUTPUT=""
OUTPUT_SET=false
INCLUDE_HIDDEN=false
DIRECTORIES_ONLY=false
DEPTH=""
USE_DEFAULT_IGNORES=true
CUSTOM_IGNORES=()
TEMP_FILE=""

# ------------------------------------------------------------
# 2. Help and error messages
# ------------------------------------------------------------

usage() {
  cat <<EOF_USAGE
Usage: $SCRIPT_NAME [options] [directory]

Generate a readable directory tree with the tree utility.

Arguments:
  directory                 Directory to inspect (default: current directory)

Options:
  -a, --all                 Include hidden files and directories
  -d, --dirs-only           Display directories only
  -L, --level LEVEL         Limit the display depth (positive integer)
  -o, --output FILE         Write to FILE instead of <directory>/filetree.txt
                            Use '-' to print the tree to stdout
  -I, --ignore PATTERN      Add a tree exclusion pattern (may be repeated)
      --no-default-ignore   Do not exclude common generated directories
  -h, --help                Display this help message

Default exclusions:
  .git, node_modules, dist, build, coverage, .next, .turbo, .cache,
  .venv, venv, __pycache__, .pytest_cache, and filetree.txt

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME languages/js
  $SCRIPT_NAME --all --level 3
  $SCRIPT_NAME --dirs-only --output directories.txt .
  $SCRIPT_NAME --ignore '*.log' --ignore '*.tmp' .
  $SCRIPT_NAME --no-default-ignore --output - .

Notes:
  - Relative output paths are resolved from the current working directory.
  - The output file is excluded from the tree when it is inside the target.
  - Directories are listed before files for easier scanning.
  - Custom patterns use tree's pattern syntax; separate alternatives with '|'.
EOF_USAGE
}

error() {
  printf 'Error: %s\n' "$*" >&2
}

usage_error() {
  error "$1"
  printf '\n' >&2
  usage >&2
  exit 2
}

# ------------------------------------------------------------
# 3. Parse command-line arguments
# ------------------------------------------------------------

while (($#)); do
  case "$1" in
    -h|--help)
      if (($# != 1)); then
        usage_error "--help cannot be combined with other arguments."
      fi
      usage
      exit 0
      ;;
    -a|--all)
      INCLUDE_HIDDEN=true
      shift
      ;;
    -d|--dirs-only)
      DIRECTORIES_ONLY=true
      shift
      ;;
    -L|--level)
      if (($# < 2)) || [[ -z "$2" ]]; then
        usage_error "${1} requires a positive integer."
      fi
      DEPTH="$2"
      shift 2
      ;;
    --level=*)
      DEPTH="${1#*=}"
      [[ -n "$DEPTH" ]] || usage_error "--level requires a positive integer."
      shift
      ;;
    -o|--output)
      if (($# < 2)) || [[ -z "$2" ]]; then
        usage_error "${1} requires a file path or '-'."
      fi
      if [[ "$OUTPUT_SET" == true ]]; then
        usage_error "--output may only be specified once."
      fi
      OUTPUT="$2"
      OUTPUT_SET=true
      shift 2
      ;;
    --output=*)
      if [[ "$OUTPUT_SET" == true ]]; then
        usage_error "--output may only be specified once."
      fi
      OUTPUT="${1#*=}"
      [[ -n "$OUTPUT" ]] || usage_error "--output requires a file path or '-'."
      OUTPUT_SET=true
      shift
      ;;
    -I|--ignore)
      if (($# < 2)) || [[ -z "$2" ]]; then
        usage_error "${1} requires a non-empty pattern."
      fi
      CUSTOM_IGNORES+=("$2")
      shift 2
      ;;
    --ignore=*)
      PATTERN="${1#*=}"
      [[ -n "$PATTERN" ]] || usage_error "--ignore requires a non-empty pattern."
      CUSTOM_IGNORES+=("$PATTERN")
      shift
      ;;
    --no-default-ignore)
      USE_DEFAULT_IGNORES=false
      shift
      ;;
    --)
      shift
      if (($# > 1)); then
        usage_error "Only one target directory may be specified."
      fi
      if (($# == 1)); then
        TARGET_DIR_INPUT="$1"
        TARGET_SET=true
      fi
      break
      ;;
    -*)
      usage_error "Unknown option: $1"
      ;;
    *)
      if [[ "$TARGET_SET" == true ]]; then
        usage_error "Only one target directory may be specified."
      fi
      TARGET_DIR_INPUT="$1"
      TARGET_SET=true
      shift
      ;;
  esac
done

if [[ -n "$DEPTH" && ! "$DEPTH" =~ ^[1-9][0-9]*$ ]]; then
  usage_error "--level must be a positive integer; received: $DEPTH"
fi

# ------------------------------------------------------------
# 4. Validate prerequisites and target directory
# ------------------------------------------------------------

if ! command -v tree >/dev/null 2>&1; then
  error "the 'tree' utility is required but was not found in PATH."
  printf 'Install it with your system package manager (for example: apt install tree or brew install tree).\n' >&2
  exit 1
fi

if [[ ! -d "$TARGET_DIR_INPUT" ]]; then
  error "target is not a directory: $TARGET_DIR_INPUT"
  exit 1
fi

if ! TARGET_DIR="$(cd -- "$TARGET_DIR_INPUT" && pwd -P)"; then
  error "could not resolve target directory: $TARGET_DIR_INPUT"
  exit 1
fi

if ! CURRENT_DIR="$(pwd -P)"; then
  error "could not resolve the current working directory."
  exit 1
fi

# ------------------------------------------------------------
# 5. Resolve and validate the output destination
# ------------------------------------------------------------

if [[ "$OUTPUT_SET" != true ]]; then
  OUTPUT_PATH="$TARGET_DIR/filetree.txt"
elif [[ "$OUTPUT" == "-" ]]; then
  OUTPUT_PATH="-"
elif [[ "$OUTPUT" == /* ]]; then
  OUTPUT_PATH="$OUTPUT"
else
  OUTPUT_PATH="$CURRENT_DIR/$OUTPUT"
fi

OUTPUT_DIR=""
OUTPUT_NAME=""

if [[ "$OUTPUT_PATH" != "-" ]]; then
  OUTPUT_NAME="${OUTPUT_PATH##*/}"
  OUTPUT_DIR="${OUTPUT_PATH%/*}"
  [[ -n "$OUTPUT_DIR" ]] || OUTPUT_DIR="/"

  if [[ -z "$OUTPUT_NAME" || "$OUTPUT_NAME" == "." || "$OUTPUT_NAME" == ".." ]]; then
    error "output must be a file path, not a directory: $OUTPUT_PATH"
    exit 1
  fi

  if ! OUTPUT_DIR="$(cd -- "$OUTPUT_DIR" 2>/dev/null && pwd -P)"; then
    error "output directory does not exist or cannot be accessed: ${OUTPUT_PATH%/*}"
    exit 1
  fi

  OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_NAME"

  if [[ -L "$OUTPUT_PATH" ]]; then
    error "refusing to replace a symbolic link: $OUTPUT_PATH"
    exit 1
  fi

  if [[ -e "$OUTPUT_PATH" && ! -f "$OUTPUT_PATH" ]]; then
    error "output exists but is not a regular file: $OUTPUT_PATH"
    exit 1
  fi

  SCRIPT_PATH="${BASH_SOURCE[0]}"
  if [[ "$SCRIPT_PATH" != /* ]]; then
    SCRIPT_PATH="$CURRENT_DIR/$SCRIPT_PATH"
  fi
  if [[ -e "$OUTPUT_PATH" && -e "$SCRIPT_PATH" && "$OUTPUT_PATH" -ef "$SCRIPT_PATH" ]]; then
    error "refusing to overwrite the running script: $OUTPUT_PATH"
    exit 1
  fi
fi

# ------------------------------------------------------------
# 6. Build tree arguments and exclusion patterns
# ------------------------------------------------------------

IGNORE_PATTERNS=()

if [[ "$USE_DEFAULT_IGNORES" == true ]]; then
  IGNORE_PATTERNS+=(
    '.git'
    'node_modules'
    'dist'
    'build'
    'coverage'
    '.next'
    '.turbo'
    '.cache'
    '.venv'
    'venv'
    '__pycache__'
    '.pytest_cache'
    'filetree.txt'
  )
fi

# Exclude the output file when it is located inside the inspected directory.
is_output_inside_target=false
if [[ "$OUTPUT_PATH" != "-" ]]; then
  if [[ "$TARGET_DIR" == "/" ]]; then
    [[ "$OUTPUT_DIR" == /* ]] && is_output_inside_target=true
  elif [[ "$OUTPUT_DIR" == "$TARGET_DIR" || "$OUTPUT_DIR" == "$TARGET_DIR/"* ]]; then
    is_output_inside_target=true
  fi

  if [[ "$is_output_inside_target" == true ]]; then
    if [[ "$OUTPUT_NAME" != "filetree.txt" || "$USE_DEFAULT_IGNORES" != true ]]; then
      IGNORE_PATTERNS+=("$OUTPUT_NAME")
    fi
  fi
fi

IGNORE_PATTERNS+=("${CUSTOM_IGNORES[@]}")

build_tree() {
  local -a tree_args=(--noreport --dirsfirst)
  local pattern

  if [[ "$INCLUDE_HIDDEN" == true ]]; then
    tree_args+=(-a)
  fi

  if [[ "$DIRECTORIES_ONLY" == true ]]; then
    tree_args+=(-d)
  fi

  if [[ -n "$DEPTH" ]]; then
    tree_args+=(-L "$DEPTH")
  fi

  for pattern in "${IGNORE_PATTERNS[@]}"; do
    tree_args+=(-I "$pattern")
  done

  tree "${tree_args[@]}" -- "$TARGET_DIR"
}

# ------------------------------------------------------------
# 7. Generate the tree
# ------------------------------------------------------------

if [[ "$OUTPUT_PATH" == "-" ]]; then
  if ! build_tree; then
    error "tree could not generate the directory listing."
    exit 1
  fi
  exit 0
fi

# Create the temporary file beside the destination so the final rename stays
# on the same filesystem. This also allows the previous output to survive a
# failed tree run.
if ! TEMP_FILE="$(mktemp "$OUTPUT_DIR/.filetree.XXXXXX")"; then
  error "could not create a temporary file in: $OUTPUT_DIR"
  exit 1
fi

cleanup() {
  if [[ -n "${TEMP_FILE:-}" && -e "$TEMP_FILE" ]]; then
    rm -f -- "$TEMP_FILE"
  fi
}
trap cleanup EXIT

# The temporary file is inside the target in some cases (including the
# default). Exclude it so it never appears in its own generated listing.
if [[ "$is_output_inside_target" == true ]]; then
  IGNORE_PATTERNS+=("${TEMP_FILE##*/}")
fi

if ! build_tree > "$TEMP_FILE"; then
  error "tree could not generate the directory listing; the existing output was left unchanged."
  exit 1
fi

# Respect the user's umask instead of leaving mktemp's restrictive 0600 mode.
CURRENT_UMASK="$(umask)"
printf -v OUTPUT_MODE '%04o' "$((0666 & ~(8#$CURRENT_UMASK)))"
if ! chmod "$OUTPUT_MODE" "$TEMP_FILE"; then
  error "could not set permissions on the generated tree file."
  exit 1
fi

if ! mv -f -- "$TEMP_FILE" "$OUTPUT_PATH"; then
  error "could not move the generated tree into place: $OUTPUT_PATH"
  exit 1
fi
TEMP_FILE=""

printf 'Directory tree saved to: %s\n' "$OUTPUT_PATH"