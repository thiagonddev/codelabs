#!/usr/bin/env bash

# Generate a readable directory tree without depending on the external `tree`
# utility. Compatible with Bash 3.2+ (including the Bash version shipped with
# macOS) and does not follow directory symlinks.

set -Eeuo pipefail
IFS=$'\n\t'

SCRIPT_NAME="${0##*/}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPT_PATH="$SCRIPT_DIR/${BASH_SOURCE[0]##*/}"

SHOW_HIDDEN=false
DIRECTORIES_ONLY=false
DIRECTORIES_FIRST=false
ASCII_TREE=false
SHOW_REPORT=true
NO_DEFAULT_EXCLUDES=false
MAX_DEPTH=""
OUTPUT_ARGUMENT=""
OUTPUT_WAS_SET=false
TARGET_ARGUMENT="."
TARGET_WAS_SET=false

DEFAULT_IGNORES=(
  ".git"
  ".svn"
  ".hg"
  "node_modules"
  "dist"
  "build"
  "coverage"
  ".next"
  ".nuxt"
  ".output"
  ".turbo"
  ".cache"
  ".parcel-cache"
  ".vite"
  ".svelte-kit"
  "__pycache__"
  ".pytest_cache"
  ".mypy_cache"
  ".ruff_cache"
  ".venv"
  "venv"
  "target"
  "filetree.txt"
)
EXTRA_IGNORES=()
IGNORE_PATTERNS=()

DIRECTORY_COUNT=0
FILE_COUNT=0
READ_ERRORS=0
TEMP_FILE=""
OUTPUT_PATH=""
TARGET_REAL=""

usage() {
  cat <<USAGE
Usage:
  $SCRIPT_NAME [OPTIONS] [DIRECTORY]

Generate a directory tree. By default, the current directory is inspected and
its tree is saved to ./filetree.txt.

Arguments:
  DIRECTORY                 Directory to inspect (default: .)

Options:
  -o, --output FILE         Write to FILE instead of <directory>/filetree.txt.
                            Use '-' to print the tree to standard output.
  -L, --depth LEVEL         Limit displayed depth (0 shows only the root).
  -a, --all                 Include hidden entries (dotfiles and dotfolders).
  -d, --dirs-only           Display directories only.
      --dirs-first          List directories before files at each level.
  -A, --ascii               Use ASCII connectors instead of Unicode characters.
  -I, --ignore PATTERN      Exclude entries matching a shell-style pattern.
                            Can be specified more than once; matches names,
                            not paths (for example: --ignore '*.log').
      --no-default-excludes Do not apply the built-in exclusion list.
      --no-report           Do not append directory/file totals.
  -h, --help                Show this help message.

Default exclusions:
  Common dependency, build, cache, test-coverage and version-control folders,
  plus filetree.txt. Use --no-default-excludes to include them, then add back
  selected exclusions with -I/--ignore as needed.

Examples:
  $SCRIPT_NAME
  $SCRIPT_NAME languages/js
  $SCRIPT_NAME --all --depth 3
  $SCRIPT_NAME --dirs-only --dirs-first languages
  $SCRIPT_NAME --ignore '*.log' --ignore '*.tmp' -o /tmp/project-tree.txt .
  $SCRIPT_NAME --ascii --output - . | less

Notes:
  - Bash 3.2+ is required; no external 'tree' package is needed.
  - Relative output paths are resolved from the current working directory.
  - Existing output files are replaced atomically after a successful run.
  - Directory symlinks are shown but never followed, preventing symlink loops.
USAGE
}

error() {
  printf 'Error: %s\n' "$1" >&2
}

require_option_value() {
  local option="$1"
  local value="${2-}"

  if [[ -z "$value" || "$value" == -- ]]; then
    error "${option} requires a value."
    printf 'Try --help for usage.\n' >&2
    exit 2
  fi
}

parse_arguments() {
  while (( $# > 0 )); do
    case "$1" in
      -h|--help)
        usage
        exit 0
        ;;
      -o|--output)
        (( $# >= 2 )) || {
          error "$1 requires a file path."
          exit 2
        }
        require_option_value "$1" "$2"
        OUTPUT_ARGUMENT="$2"
        OUTPUT_WAS_SET=true
        shift 2
        ;;
      -L|--depth)
        (( $# >= 2 )) || {
          error "$1 requires a non-negative integer."
          exit 2
        }
        require_option_value "$1" "$2"
        if [[ ! "$2" =~ ^[0-9]+$ ]]; then
          error "invalid depth '$2'; expected a non-negative integer."
          exit 2
        fi
        MAX_DEPTH="$2"
        shift 2
        ;;
      -a|--all)
        SHOW_HIDDEN=true
        shift
        ;;
      -d|--dirs-only)
        DIRECTORIES_ONLY=true
        shift
        ;;
      --dirs-first)
        DIRECTORIES_FIRST=true
        shift
        ;;
      -A|--ascii)
        ASCII_TREE=true
        shift
        ;;
      -I|--ignore|--exclude)
        (( $# >= 2 )) || {
          error "$1 requires a pattern."
          exit 2
        }
        require_option_value "$1" "$2"
        EXTRA_IGNORES+=("$2")
        shift 2
        ;;
      --no-default-excludes)
        NO_DEFAULT_EXCLUDES=true
        shift
        ;;
      --no-report)
        SHOW_REPORT=false
        shift
        ;;
      --)
        shift
        if (( $# > 1 )); then
          error "expected at most one directory path."
          exit 2
        fi
        if (( $# == 1 )); then
          if [[ "$TARGET_WAS_SET" == true ]]; then
            error "directory specified more than once."
            exit 2
          fi
          TARGET_ARGUMENT="$1"
          TARGET_WAS_SET=true
        fi
        break
        ;;
      -* )
        error "unknown option: $1"
        printf 'Try --help for usage.\n' >&2
        exit 2
        ;;
      *)
        if [[ "$TARGET_WAS_SET" == true ]]; then
          error "expected at most one directory path; got '$1' as an extra argument."
          exit 2
        fi
        TARGET_ARGUMENT="$1"
        TARGET_WAS_SET=true
        shift
        ;;
    esac
  done
}

resolve_target() {
  if [[ ! -d "$TARGET_ARGUMENT" ]]; then
    error "'$TARGET_ARGUMENT' is not an existing directory."
    exit 2
  fi

  if ! TARGET_REAL="$(cd -- "$TARGET_ARGUMENT" 2>/dev/null && pwd -P)"; then
    error "cannot access directory: $TARGET_ARGUMENT"
    exit 2
  fi

  if [[ ! -r "$TARGET_REAL" || ! -x "$TARGET_REAL" ]]; then
    error "directory is not readable: $TARGET_ARGUMENT"
    exit 2
  fi
}

resolve_output() {
  local output_dir_argument
  local output_name

  if [[ "$OUTPUT_WAS_SET" != true ]]; then
    OUTPUT_PATH="$TARGET_REAL/filetree.txt"
    if [[ -d "$OUTPUT_PATH" ]]; then
      error "output path is a directory: $OUTPUT_PATH"
      exit 2
    fi
    return
  fi

  if [[ "$OUTPUT_ARGUMENT" == "-" ]]; then
    OUTPUT_PATH="-"
    return
  fi

  output_name="${OUTPUT_ARGUMENT##*/}"
  output_dir_argument="${OUTPUT_ARGUMENT%/*}"

  if [[ "$output_name" == "$OUTPUT_ARGUMENT" ]]; then
    output_dir_argument="."
  elif [[ -z "$output_dir_argument" ]]; then
    output_dir_argument="/"
  fi

  if [[ -z "$output_name" || "$output_name" == "." || "$output_name" == ".." ]]; then
    error "invalid output file path: $OUTPUT_ARGUMENT"
    exit 2
  fi

  if ! output_dir_argument="$(cd -- "$output_dir_argument" 2>/dev/null && pwd -P)"; then
    error "output directory does not exist or cannot be accessed: ${OUTPUT_ARGUMENT%/*}"
    exit 2
  fi

  OUTPUT_PATH="$output_dir_argument/$output_name"

  if [[ -d "$OUTPUT_PATH" ]]; then
    error "output path is a directory: $OUTPUT_PATH"
    exit 2
  fi

  if [[ -e "$OUTPUT_PATH" && -e "$SCRIPT_PATH" && "$OUTPUT_PATH" -ef "$SCRIPT_PATH" ]]; then
    error "refusing to overwrite the script itself: $OUTPUT_PATH"
    exit 2
  fi
}

build_ignore_list() {
  local pattern

  IGNORE_PATTERNS=()

  if [[ "$NO_DEFAULT_EXCLUDES" != true ]]; then
    for pattern in "${DEFAULT_IGNORES[@]}"; do
      IGNORE_PATTERNS+=("$pattern")
    done
  fi

  if (( ${#EXTRA_IGNORES[@]} > 0 )); then
    for pattern in "${EXTRA_IGNORES[@]}"; do
      IGNORE_PATTERNS+=("$pattern")
    done
  fi
}

is_ignored() {
  local name="$1"
  local pattern

  if (( ${#IGNORE_PATTERNS[@]} > 0 )); then
    for pattern in "${IGNORE_PATTERNS[@]}"; do
      if [[ "$name" == $pattern ]]; then
        return 0
      fi
    done
  fi

  return 1
}

format_entry_name() {
  local name="$1"

  # Escape control characters so unusual filenames cannot break the layout or
  # inject terminal control sequences into output written to the terminal.
  if [[ "$name" == *[[:cntrl:]]* ]]; then
    printf -v FORMATTED_NAME '%q' "$name"
  else
    FORMATTED_NAME="$name"
  fi
}

render_entries() {
  local current_directory="$1"
  local prefix="$2"
  local depth="$3"
  local entry
  local glob_directory="$current_directory"
  local name
  local connector
  local next_prefix
  local formatted_name
  local is_last
  local index
  local total
  local -a entries=()
  local -a directories=()
  local -a other_entries=()

  if [[ "$glob_directory" == "/" ]]; then
    glob_directory=""
  fi

  for entry in "$glob_directory"/*; do
    [[ -e "$entry" || -L "$entry" ]] || continue

    # Do not list the output or its temporary file if either is inside the
    # directory currently being inspected.
    [[ -n "$OUTPUT_PATH" && "$OUTPUT_PATH" != "-" && "$entry" == "$OUTPUT_PATH" ]] && continue
    [[ -n "$TEMP_FILE" && "$entry" == "$TEMP_FILE" ]] && continue

    name="${entry##*/}"

    if [[ "$SHOW_HIDDEN" != true && "$name" == .* ]]; then
      continue
    fi

    if is_ignored "$name"; then
      continue
    fi

    if [[ "$DIRECTORIES_ONLY" == true ]] && [[ ! -d "$entry" || -L "$entry" ]]; then
      continue
    fi

    if [[ "$DIRECTORIES_FIRST" == true ]] && [[ -d "$entry" && ! -L "$entry" ]]; then
      directories+=("$entry")
    else
      other_entries+=("$entry")
    fi
  done

  if [[ "$DIRECTORIES_FIRST" == true ]]; then
    if (( ${#directories[@]} > 0 )); then
      for entry in "${directories[@]}"; do
        entries+=("$entry")
      done
    fi
    if (( ${#other_entries[@]} > 0 )); then
      for entry in "${other_entries[@]}"; do
        entries+=("$entry")
      done
    fi
  elif (( ${#other_entries[@]} > 0 )); then
    entries=("${other_entries[@]}")
  fi

  total="${#entries[@]}"

  for ((index = 0; index < total; index++)); do
    entry="${entries[$index]}"
    name="${entry##*/}"

    if (( index == total - 1 )); then
      is_last=true
      if [[ "$ASCII_TREE" == true ]]; then
        connector='`-- '
        next_prefix="${prefix}    "
      else
        connector='└── '
        next_prefix="${prefix}    "
      fi
    else
      is_last=false
      if [[ "$ASCII_TREE" == true ]]; then
        connector='|-- '
        next_prefix="${prefix}|   "
      else
        connector='├── '
        next_prefix="${prefix}│   "
      fi
    fi

    format_entry_name "$name"
    formatted_name="$FORMATTED_NAME"

    if [[ -L "$entry" ]]; then
      formatted_name="${formatted_name}@"
      FILE_COUNT=$((FILE_COUNT + 1))
    elif [[ -d "$entry" ]]; then
      DIRECTORY_COUNT=$((DIRECTORY_COUNT + 1))
    else
      FILE_COUNT=$((FILE_COUNT + 1))
    fi

    printf '%s%s%s\n' "$prefix" "$connector" "$formatted_name"

    if [[ -d "$entry" && ! -L "$entry" ]]; then
      if [[ -n "$MAX_DEPTH" ]] && (( depth >= MAX_DEPTH )); then
        continue
      fi

      if [[ ! -r "$entry" || ! -x "$entry" ]]; then
        if [[ "$ASCII_TREE" == true ]]; then
          printf '%s`-- [permission denied]\n' "$next_prefix"
        else
          printf '%s└── [permission denied]\n' "$next_prefix"
        fi
        READ_ERRORS=$((READ_ERRORS + 1))
        continue
      fi

      render_entries "$entry" "$next_prefix" "$((depth + 1))"
    fi
  done
}

render_tree() {
  local root_display="$TARGET_ARGUMENT"
  if [[ "$root_display" == *[[:cntrl:]]* ]]; then
    printf -v root_display '%q' "$root_display"
  fi

  printf '%s\n' "$root_display"
  if [[ "$MAX_DEPTH" != "0" ]]; then
    render_entries "$TARGET_REAL" "" 1
  fi

  if [[ "$SHOW_REPORT" == true ]]; then
    local directory_label
    local file_label

    if [[ "$DIRECTORY_COUNT" == 1 ]]; then
      directory_label="directory"
    else
      directory_label="directories"
    fi

    if [[ "$FILE_COUNT" == 1 ]]; then
      file_label="file"
    else
      file_label="files"
    fi

    printf '\n%d %s, %d %s\n' \
      "$DIRECTORY_COUNT" "$directory_label" "$FILE_COUNT" "$file_label"
  fi
}

cleanup() {
  if [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]]; then
    rm -f -- "$TEMP_FILE"
  fi
}

main() {
  parse_arguments "$@"
  resolve_target
  resolve_output
  build_ignore_list

  # Use deterministic, locale-independent filename ordering.
  unset GLOBIGNORE || true
  LC_COLLATE=C
  export LC_COLLATE
  shopt -s dotglob nullglob

  if [[ "$OUTPUT_PATH" == "-" ]]; then
    render_tree
  else
    local output_directory="${OUTPUT_PATH%/*}"
    local output_name="${OUTPUT_PATH##*/}"

    TEMP_FILE="$(mktemp "$output_directory/.${output_name}.tmp.XXXXXX")" || {
      error "could not create a temporary file in: $output_directory"
      exit 1
    }

    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM

    if ! render_tree > "$TEMP_FILE"; then
      error "failed to generate the directory tree."
      exit 1
    fi

    if ! mv -f -- "$TEMP_FILE" "$OUTPUT_PATH"; then
      error "could not write output file: $OUTPUT_PATH"
      exit 1
    fi
    TEMP_FILE=""

    printf 'File tree saved to: %s\n' "$OUTPUT_PATH"
  fi

  if (( READ_ERRORS > 0 )); then
    if [[ "$READ_ERRORS" == 1 ]]; then
      error "finished with 1 unreadable directory."
    else
      error "finished with $READ_ERRORS unreadable directories."
    fi
    exit 1
  fi
}

main "$@"