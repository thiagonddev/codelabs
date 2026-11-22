#!/usr/bin/env bash
# Safely rebase local branches onto a selected base branch.
#
# Default mode:
#   Rebase published and local-only commits locally. Never push.
#
# --push mode:
#   Rebase the branch's published history, replay local-only commits on top,
#   and push ONLY the rebased published tip using an explicit force-with-lease.
#
# --skip-unpushed mode:
#   Skip branches with local-only commits (or an unverifiable upstream).
#
# Requires Bash 4.3+ and a reasonably recent Git (rebase --rebase-merges).

set -uo pipefail
IFS=$'\n\t'

SCRIPT_NAME="${0##*/}"
DEFAULT_REMOTE="origin"
DEFAULT_BASE="master"
REMOTE="$DEFAULT_REMOTE"
BASE_BRANCH="$DEFAULT_BASE"
LOCAL_BASE=0
SKIP_UNPUSHED=0
PUSH=0
DRY_RUN=0
ASSUME_YES=0
BRANCH_PATTERNS=()

if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_BLUE=$'\033[34m'
  C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'; C_RED=$'\033[31m'; C_CYAN=$'\033[36m'
else
  C_RESET=''; C_BOLD=''; C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_CYAN=''
fi

info()    { printf '%s[INFO]%s %s\n' "$C_BLUE" "$C_RESET" "$*"; }
success() { printf '%s[ OK ]%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn()    { printf '%s[WARN]%s %s\n' "$C_YELLOW" "$C_RESET" "$*"; }
error()   { printf '%s[FAIL]%s %s\n' "$C_RED" "$C_RESET" "$*" >&2; }
header()  { printf '\n%s%s%s\n' "$C_BOLD$C_CYAN" "$*" "$C_RESET"; }

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Rebase selected local branches onto REMOTE/BASE (or the local base with
--local-base). By default, no push is ever performed.

Options:
  -r, --remote NAME       Remote providing the base branch (default: $DEFAULT_REMOTE)
  -b, --base NAME         Base branch name (default: $DEFAULT_BASE)
      --local-base        Use the local base branch instead of REMOTE/BASE
  -p, --pattern GLOB      Include branches matching this Bash glob (repeatable)
                          Default: all local branches except the base branch
      --skip-unpushed     Skip branches with local-only commits. Also skips
                          branches whose upstream status cannot be verified.
      --push              Push the rebased published history to each branch's
                          configured upstream. Local-only commits are replayed
                          locally and are NOT included in the push.
  -n, --dry-run           Fetch and show the plan; do not rebase or push
  -y, --yes               Skip the final confirmation prompt
  -h, --help              Show this help

Commit handling:
  * With no upstream, the local branch is rebased as a whole (unless
    --skip-unpushed or --push is used, in which case its status is unknown).
  * With a verifiable upstream, the upstream's published history is rebased
    onto the base, then local-only commits are replayed on top.
  * --push pushes only the rebased published tip, using an explicit
    --force-with-lease. Local-only commits remain local.
  * --skip-unpushed is independent of --push. Combining them means branches
    with local-only commits are skipped entirely.

Safety:
  * The script never pushes unless --push is explicitly supplied.
  * Uncommitted changes and in-progress Git operations are never stashed,
    discarded, committed, rebased, or pushed by this script.
  * Branches with divergent local/upstream histories are skipped for manual
    reconciliation.
  * Pushes use a lease pinned to the upstream OID observed during preflight.
  * The target base must already be reachable from the push remote's fetched
    references; otherwise the push is blocked to avoid publishing local-only
    base commits to that remote.
  * Recovery refs are created before rewriting history and removed only after
    the local branch has been updated successfully.

Examples:
  $SCRIPT_NAME --dry-run
  $SCRIPT_NAME --pattern 'feature/*' --pattern 'bugfix/*'
  $SCRIPT_NAME --skip-unpushed --dry-run
  $SCRIPT_NAME --push --dry-run
  $SCRIPT_NAME --push --yes
  $SCRIPT_NAME --remote upstream --base main --pattern 'feature/*'
EOF
}

while (($#)); do
  case "$1" in
    -r|--remote)
      [[ $# -ge 2 && -n "$2" ]] || { error "Missing value for $1"; usage; exit 2; }
      REMOTE="$2"; shift 2 ;;
    -b|--base)
      [[ $# -ge 2 && -n "$2" ]] || { error "Missing value for $1"; usage; exit 2; }
      BASE_BRANCH="$2"; shift 2 ;;
    --local-base)
      LOCAL_BASE=1; shift ;;
    --skip-unpushed)
      SKIP_UNPUSHED=1; shift ;;
    --push)
      PUSH=1; shift ;;
    -p|--pattern)
      [[ $# -ge 2 && -n "$2" ]] || { error "Missing value for $1"; usage; exit 2; }
      BRANCH_PATTERNS+=("$2"); shift 2 ;;
    -n|--dry-run)
      DRY_RUN=1; shift ;;
    -y|--yes)
      ASSUME_YES=1; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      error "Unknown option: $1"; usage; exit 2 ;;
  esac
done

if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3) )); then
  error "Bash 4.3 or newer is required."
  exit 2
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  error "Run this script from inside a Git working tree."
  exit 2
fi

REPO_ROOT="$(git rev-parse --show-toplevel)" || exit 2
cd "$REPO_ROOT" || exit 2

if ! git check-ref-format --branch "$BASE_BRANCH" >/dev/null 2>&1; then
  error "Invalid base branch name: $BASE_BRANCH"
  exit 2
fi

if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  error "Remote '$REMOTE' does not exist."
  exit 2
fi

if ! git --version >/dev/null 2>&1; then
  error "Git is required."
  exit 2
fi

RUN_ID="$(date +%Y%m%d%H%M%S)-$$"
ACTIVE_REBASE_PATH=""
ACTIVE_WORKTREE_PATH=""
ACTIVE_BRANCH=""
ACTIVE_RESTORE_BRANCH=""
ACTIVE_TEMP_ROOT=""
ACTIVE_TEMP_PATH=""
KEEP_ACTIVE_TEMP=0

cleanup() {
  if [[ -n "$ACTIVE_REBASE_PATH" ]]; then
    if git -C "$ACTIVE_REBASE_PATH" rev-parse -q --verify REBASE_HEAD >/dev/null 2>&1; then
      git -C "$ACTIVE_REBASE_PATH" rebase --abort >/dev/null 2>&1 || true
    fi
  fi

  # On interruption, return an existing worktree to its original branch. The
  # branch ref is only moved after both rebase phases (and any push) succeed.
  if [[ -n "$ACTIVE_WORKTREE_PATH" && -d "$ACTIVE_WORKTREE_PATH" && -n "$ACTIVE_BRANCH" ]]; then
    git -C "$ACTIVE_WORKTREE_PATH" switch --quiet "$ACTIVE_BRANCH" >/dev/null 2>&1 || true
    if [[ -n "$ACTIVE_RESTORE_BRANCH" ]]; then
      git -C "$ACTIVE_WORKTREE_PATH" branch -D "$ACTIVE_RESTORE_BRANCH" >/dev/null 2>&1 || true
    fi
  fi

  if [[ -n "$ACTIVE_TEMP_PATH" && $KEEP_ACTIVE_TEMP -eq 0 ]]; then
    git worktree remove --force "$ACTIVE_TEMP_PATH" >/dev/null 2>&1 || true
  fi
  if [[ -n "$ACTIVE_TEMP_ROOT" && $KEEP_ACTIVE_TEMP -eq 0 ]]; then
    rm -rf -- "$ACTIVE_TEMP_ROOT"
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Fetch each distinct remote at most once. This refreshes both the selected
# base and each branch's own upstream before ahead/behind checks.
declare -A FETCHED_REMOTE=()
declare -A FAILED_REMOTE=()
fetch_remote() {
  local remote_name="$1"
  [[ -n "$remote_name" && "$remote_name" != "." ]] || return 1
  [[ -n "${FETCHED_REMOTE[$remote_name]-}" ]] && return 0
  [[ -n "${FAILED_REMOTE[$remote_name]-}" ]] && return 1
  if ! git remote get-url "$remote_name" >/dev/null 2>&1; then
    FAILED_REMOTE["$remote_name"]=1
    return 1
  fi
  info "Fetching '$remote_name' (fetch only; no push)..."
  if git fetch --prune "$remote_name"; then
    FETCHED_REMOTE["$remote_name"]=1
    return 0
  fi
  FAILED_REMOTE["$remote_name"]=1
  return 1
}

header "Refreshing remote-tracking references"
if ! fetch_remote "$REMOTE"; then
  error "Could not fetch base remote '$REMOTE'. No branches were changed."
  exit 1
fi

if (( LOCAL_BASE )); then
  BASE_REF="refs/heads/$BASE_BRANCH"
  BASE_LABEL="$BASE_BRANCH (local)"
else
  BASE_REF="refs/remotes/$REMOTE/$BASE_BRANCH"
  BASE_LABEL="$REMOTE/$BASE_BRANCH"
fi

if ! git rev-parse --verify --quiet "$BASE_REF^{commit}" >/dev/null; then
  error "Base reference '$BASE_REF' does not exist."
  exit 1
fi
BASE_OID="$(git rev-parse "$BASE_REF^{commit}")"
BASE_SHORT="$(git rev-parse --short "$BASE_OID")"
success "Target base: $BASE_LABEL ($BASE_SHORT)"

mapfile -t ALL_BRANCHES < <(git for-each-ref --format='%(refname:short)' refs/heads/)
BRANCHES=()
for branch in "${ALL_BRANCHES[@]}"; do
  [[ "$branch" == "$BASE_BRANCH" ]] && continue
  include=1
  if ((${#BRANCH_PATTERNS[@]} > 0)); then
    include=0
    for pattern in "${BRANCH_PATTERNS[@]}"; do
      if [[ "$branch" == $pattern ]]; then
        include=1
        break
      fi
    done
  fi
  (( include )) && BRANCHES+=("$branch")
done

if ((${#BRANCHES[@]} == 0)); then
  success "No local branches matched the selection."
  exit 0
fi

# Fetch each configured branch-upstream remote so that unpushed counts are
# based on refreshed references, not stale local tracking data.
for branch in "${BRANCHES[@]}"; do
  branch_remote="$(git config --get "branch.$branch.remote" 2>/dev/null || true)"
  if [[ -n "$branch_remote" && "$branch_remote" != "." ]]; then
    fetch_remote "$branch_remote" || warn "Could not refresh '$branch_remote'; branches using it will be treated as unknown."
  fi
done

# Resolve worktrees and inspect their status. Branches checked out in linked
# worktrees are processed there; other branches get a temporary worktree.
declare -A WORKTREE_FOR_BRANCH=()
declare -A WORKTREE_BRANCH_FOR_PATH=()
declare -A DIRTY_BRANCH=()
declare -A BLOCKED_BRANCH=()
declare -A UNAVAILABLE_BRANCH=()
declare -a WORKTREE_PATHS=()
current_worktree=""
while IFS= read -r line; do
  case "$line" in
    "worktree "*)
      current_worktree="${line#worktree }"
      WORKTREE_PATHS+=("$current_worktree")
      ;;
    "branch refs/heads/"*)
      wt_branch="${line#branch refs/heads/}"
      WORKTREE_FOR_BRANCH["$wt_branch"]="$current_worktree"
      WORKTREE_BRANCH_FOR_PATH["$current_worktree"]="$wt_branch"
      ;;
  esac
done < <(git worktree list --porcelain)

has_operation_in_progress() {
  local path="$1" marker state_path
  for marker in rebase-apply rebase-merge MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD; do
    if [[ "$marker" == rebase-* ]]; then
      state_path="$(git -C "$path" rev-parse --git-path "$marker" 2>/dev/null || true)"
      [[ -n "$state_path" && -e "$state_path" ]] && return 0
    elif git -C "$path" rev-parse -q --verify "$marker" >/dev/null 2>&1; then
      return 0
    fi
  done
  return 1
}

dispose_temp_worktree() {
  local path="$1" root="$2"
  git worktree remove --force "$path" >/dev/null 2>&1 || true
  rm -rf -- "$root"
  if [[ "$ACTIVE_TEMP_PATH" == "$path" ]]; then
    ACTIVE_TEMP_PATH=""
    ACTIVE_TEMP_ROOT=""
    KEEP_ACTIVE_TEMP=0
  fi
  if [[ "$ACTIVE_WORKTREE_PATH" == "$path" ]]; then
    ACTIVE_WORKTREE_PATH=""
    ACTIVE_BRANCH=""
    ACTIVE_RESTORE_BRANCH=""
  fi
}

header "Inspecting working trees"
for wt_path in "${WORKTREE_PATHS[@]}"; do
  wt_branch="${WORKTREE_BRANCH_FOR_PATH[$wt_path]-}"
  if [[ ! -d "$wt_path" ]]; then
    if [[ -n "$wt_branch" ]]; then
      UNAVAILABLE_BRANCH["$wt_branch"]=1
      warn "Branch '$wt_branch' has an inaccessible worktree: $wt_path"
    else
      warn "An inaccessible detached worktree was found: $wt_path"
    fi
    continue
  fi

  wt_status="$(git -C "$wt_path" status --porcelain=v1 --untracked-files=all --ignore-submodules=none 2>/dev/null)" || {
    [[ -n "$wt_branch" ]] && UNAVAILABLE_BRANCH["$wt_branch"]=1
    warn "Could not inspect worktree '$wt_path'."
    continue
  }
  if [[ -n "$wt_status" ]]; then
    if [[ -n "$wt_branch" ]]; then
      DIRTY_BRANCH["$wt_branch"]=1
      warn "Uncommitted changes belong to branch '$wt_branch' ($wt_path):"
    else
      warn "Uncommitted changes found in detached worktree '$wt_path' (no branch is checked out):"
    fi
    while IFS= read -r status_line; do
      [[ -n "$status_line" ]] && printf '      %s\n' "$status_line"
    done <<< "$wt_status"
  fi
  if has_operation_in_progress "$wt_path"; then
    [[ -n "$wt_branch" ]] && BLOCKED_BRANCH["$wt_branch"]=1
    warn "Git operation in progress in '$wt_path'${wt_branch:+ (branch '$wt_branch')}; it will not be touched."
  fi
done

# Per-branch preflight results.
declare -A UPSTREAM_REF_FOR_BRANCH=()
declare -A UPSTREAM_REMOTE_FOR_BRANCH=()
declare -A UPSTREAM_MERGE_FOR_BRANCH=()
declare -A UPSTREAM_OID_FOR_BRANCH=()
declare -A LOCAL_OID_FOR_BRANCH=()
declare -A LOCAL_ONLY_FOR_BRANCH=()
declare -A UPSTREAM_UNKNOWN=()
declare -A DIVERGED_BRANCH=()
declare -A PUSH_BLOCKED=()
declare -A CANDIDATE=()
declare -A BRANCH_STATUS=()
declare -A BRANCH_REASON=()

READY=0
UNPUSHED=0
UNKNOWN=0
DIVERGED=0
DIRTY=0
PUSH_BLOCKED_COUNT=0

header "Branch overview"
for branch in "${BRANCHES[@]}"; do
  local_ref="refs/heads/$branch"
  local_oid="$(git rev-parse --verify "$local_ref^{commit}" 2>/dev/null || true)"
  LOCAL_OID_FOR_BRANCH["$branch"]="$local_oid"
  upstream_ref="$(git for-each-ref --format='%(upstream)' "$local_ref")"
  branch_remote="$(git config --get "branch.$branch.remote" 2>/dev/null || true)"
  branch_merge="$(git config --get "branch.$branch.merge" 2>/dev/null || true)"

  printf '\n%s%s%s\n' "$C_BOLD" "$branch" "$C_RESET"
  branch_unpushed=0
  branch_unknown=0

  if [[ -n "$upstream_ref" && -n "$branch_remote" && "$branch_remote" != "." && \
        "$branch_merge" == refs/heads/* && -z "${FAILED_REMOTE[$branch_remote]-}" && \
        -n "${FETCHED_REMOTE[$branch_remote]-}" ]] && \
     git rev-parse --verify --quiet "$upstream_ref^{commit}" >/dev/null; then
    upstream_oid="$(git rev-parse "$upstream_ref^{commit}")"
    UPSTREAM_REF_FOR_BRANCH["$branch"]="$upstream_ref"
    UPSTREAM_REMOTE_FOR_BRANCH["$branch"]="$branch_remote"
    UPSTREAM_MERGE_FOR_BRANCH["$branch"]="$branch_merge"
    UPSTREAM_OID_FOR_BRANCH["$branch"]="$upstream_oid"

    divergence_counts="$(git rev-list --left-right --count "$upstream_oid...$local_oid")"
    IFS=$' \t' read -r behind local_only <<< "$divergence_counts"
    if git merge-base --is-ancestor "$upstream_oid" "$local_oid"; then
      : # All local-only commits are safely based on the upstream tip.
    elif git merge-base --is-ancestor "$local_oid" "$upstream_oid"; then
      local_only="0" # The local branch is simply behind its upstream.
    else
      DIVERGED_BRANCH["$branch"]=1
      DIVERGED=$((DIVERGED + 1))
    fi

    LOCAL_ONLY_FOR_BRANCH["$branch"]="$local_only"
    if (( local_only > 0 )); then
      branch_unpushed=1
      UNPUSHED=$((UNPUSHED + 1))
      printf '  Local-only commits: %s (relative to %s)\n' "$local_only" "$upstream_ref"
      git log --format='      %h %s' "$upstream_ref..$local_ref"
    else
      printf '  Local-only commits: none\n'
    fi
    printf '  Upstream: %s\n' "$upstream_ref"
    printf '  Upstream-only commits: %s\n' "$behind"

    if [[ -n "${DIVERGED_BRANCH[$branch]-}" ]]; then
      printf '  History: %sDIVERGED — local and upstream have independent commits%s\n' "$C_YELLOW" "$C_RESET"
    fi

    if (( PUSH )); then
      # Do not publish commits from a base that the destination remote does not
      # already know through any of its fetched branches/tags.
      unpublished_base="$(git rev-list --count "$BASE_OID" --not --remotes="$branch_remote")"
      if (( unpublished_base > 0 )); then
        PUSH_BLOCKED["$branch"]=1
        PUSH_BLOCKED_COUNT=$((PUSH_BLOCKED_COUNT + 1))
        printf '  Push safety: %sBLOCKED — base has %s commit(s) not advertised by %s%s\n' \
          "$C_YELLOW" "$unpublished_base" "$branch_remote" "$C_RESET"
      fi
    fi
  else
    branch_unknown=1
    UPSTREAM_UNKNOWN["$branch"]=1
    UNKNOWN=$((UNKNOWN + 1))
    if [[ -z "$upstream_ref" ]]; then
      printf '  Upstream: %snot configured%s\n' "$C_YELLOW" "$C_RESET"
    elif [[ -n "${FAILED_REMOTE[$branch_remote]-}" ]]; then
      printf '  Upstream: %sunavailable; fetch failed for %s%s\n' "$C_YELLOW" "$branch_remote" "$C_RESET"
    else
      printf '  Upstream: %sunverifiable (%s)%s\n' "$C_YELLOW" "${upstream_ref:-missing}" "$C_RESET"
    fi

    # Heuristic only: identify commits not reachable from any fetched remote
    # tracking branch. This cannot prove whether an untracked commit was pushed
    # to an unconfigured remote, so safe modes treat this status as unknown.
    heuristic_local="$(git rev-list --count "$local_ref" --not --remotes 2>/dev/null || printf '0')"
    if (( heuristic_local > 0 )); then
      printf '  Commits not reachable from fetched remote-tracking branches: %s (possibly unpublished)\n' "$heuristic_local"
      git log --format='      %h %s' "$local_ref" --not --remotes 2>/dev/null || true
      LOCAL_ONLY_FOR_BRANCH["$branch"]="$heuristic_local"
    else
      LOCAL_ONLY_FOR_BRANCH["$branch"]="0"
    fi
  fi

  if [[ -n "${DIRTY_BRANCH[$branch]-}" ]]; then
    BRANCH_STATUS["$branch"]="dirty"
    BRANCH_REASON["$branch"]="uncommitted changes in its worktree"
    DIRTY=$((DIRTY + 1))
    printf '  Status: %sSKIPPED — uncommitted changes%s\n' "$C_YELLOW" "$C_RESET"
  elif [[ -n "${BLOCKED_BRANCH[$branch]-}" ]]; then
    BRANCH_STATUS["$branch"]="blocked"
    BRANCH_REASON["$branch"]="a Git operation is already in progress"
    printf '  Status: %sSKIPPED — Git operation in progress%s\n' "$C_YELLOW" "$C_RESET"
  elif [[ -n "${UNAVAILABLE_BRANCH[$branch]-}" ]]; then
    BRANCH_STATUS["$branch"]="unavailable"
    BRANCH_REASON["$branch"]="its worktree is unavailable or could not be inspected"
    printf '  Status: %sSKIPPED — worktree unavailable%s\n' "$C_YELLOW" "$C_RESET"
  elif [[ -n "${DIVERGED_BRANCH[$branch]-}" ]]; then
    BRANCH_STATUS["$branch"]="diverged"
    BRANCH_REASON["$branch"]="local and upstream histories have diverged"
    printf '  Status: %sSKIPPED — reconcile local/upstream history manually%s\n' "$C_YELLOW" "$C_RESET"
  elif (( (SKIP_UNPUSHED || PUSH) && branch_unpushed && SKIP_UNPUSHED )); then
    BRANCH_STATUS["$branch"]="unpushed"
    BRANCH_REASON["$branch"]="contains ${LOCAL_ONLY_FOR_BRANCH[$branch]} local-only commit(s)"
    printf '  Status: %sSKIPPED — local-only commits (--skip-unpushed)%s\n' "$C_YELLOW" "$C_RESET"
  elif (( (SKIP_UNPUSHED || PUSH) && branch_unknown && (SKIP_UNPUSHED || PUSH) )); then
    BRANCH_STATUS["$branch"]="unknown"
    BRANCH_REASON["$branch"]="upstream status cannot be verified"
    printf '  Status: %sSKIPPED — upstream status cannot be verified%s\n' "$C_YELLOW" "$C_RESET"
  elif (( PUSH )) && [[ -n "${PUSH_BLOCKED[$branch]-}" ]]; then
    BRANCH_STATUS["$branch"]="push-blocked"
    BRANCH_REASON["$branch"]="pushing would publish base commits not advertised by the destination remote"
    printf '  Status: %sSKIPPED — push would publish commits unknown to destination remote%s\n' "$C_YELLOW" "$C_RESET"
  else
    BRANCH_STATUS["$branch"]="ready"
    CANDIDATE["$branch"]=1
    READY=$((READY + 1))
    if (( PUSH )); then
      printf '  Status: %sready — push will exclude local-only commits%s\n' "$C_GREEN" "$C_RESET"
    elif (( branch_unknown )); then
      printf '  Status: %sready for local-only rebase; publication status is unknown%s\n' "$C_GREEN" "$C_RESET"
    else
      printf '  Status: %sready to rebase locally%s\n' "$C_GREEN" "$C_RESET"
    fi
  fi
done

printf '\n'
info "Branches selected: ${#BRANCHES[@]}"
info "Branches ready: $READY"
info "Branches with local-only commits: $UNPUSHED"
info "Branches with unknown upstream status: $UNKNOWN"
info "Branches with divergent histories: $DIVERGED"
if (( PUSH )); then
  info "Push mode: enabled; only rebased published history will be pushed."
else
  info "Push mode: disabled; no push command will run."
fi
if (( SKIP_UNPUSHED )); then
  info "Unpublished policy: skip branches with local-only or unverifiable upstream status."
else
  info "Unpublished policy: preserve local-only commits and rebase them locally."
fi
if ((${#BRANCH_PATTERNS[@]} > 0)); then
  info "Branch filters: ${BRANCH_PATTERNS[*]}"
else
  info "Branch filters: all local branches except '$BASE_BRANCH'"
fi

if (( DRY_RUN )); then
  success "Dry run complete. No branch was rebased and no push was performed."
  exit 0
fi
if (( READY == 0 )); then
  warn "No eligible branches to process; the detailed final report will still be shown."
elif (( ! ASSUME_YES )); then
  if (( PUSH )); then
    printf '\nProcess %s branch(es) onto %s and push only published history? [y/N] ' "$READY" "$BASE_LABEL"
  else
    printf '\nRebase %s branch(es) onto %s without pushing? [y/N] ' "$READY" "$BASE_LABEL"
  fi
  read -r answer
  case "$answer" in
    y|Y|yes|YES|Yes) ;;
    *) info "Cancelled. No branches were rebased."; exit 0 ;;
  esac
fi

# Processing uses one worktree per branch. The original branch ref is left
# untouched until both the published and local-only portions have rebased.
# Recovery refs keep both the original and computed result reachable.
ACTIVE_RESTORE_BRANCH=""
ACTIVE_BRANCH=""

RECOVERY_NOTE=""
recover_without_commit() {
  local wt="$1" branch="$2" restore_branch="$3"
  local original_oid="$4" backup_original="$5"
  RECOVERY_NOTE=""
  if [[ -n "$ACTIVE_REBASE_PATH" ]] && \
     git -C "$ACTIVE_REBASE_PATH" rev-parse -q --verify REBASE_HEAD >/dev/null 2>&1; then
    git -C "$ACTIVE_REBASE_PATH" rebase --abort >/dev/null 2>&1 || true
  fi
  ACTIVE_REBASE_PATH=""
  if [[ -n "$restore_branch" ]]; then
    git -C "$wt" switch --quiet --detach "$original_oid" >/dev/null 2>&1 || true
    git -C "$wt" branch -D "$restore_branch" >/dev/null 2>&1 || true
  fi
  if git -C "$wt" switch --quiet "$branch" >/dev/null 2>&1; then
    if ! git update-ref -d "$backup_original" "$original_oid" >/dev/null 2>&1; then
      RECOVERY_NOTE="could not remove original recovery ref: $backup_original"
      warn "Could not remove recovery ref '$backup_original'."
    fi
  else
    RECOVERY_NOTE="could not restore branch '$branch'; recovery ref retained: $backup_original"
    warn "Could not restore '$branch' in '$wt'; recovery ref retained: $backup_original"
  fi
}

process_branch() {
  local branch="$1" index="$2"
  PROCESS_REASON=""
  PROCESS_RECOVERY=""
  PROCESS_PUSHED=0
  PROCESS_PARTIAL=0
  local wt="" temp_root="" created_temp=0
  local old_local_oid="${LOCAL_OID_FOR_BRANCH[$branch]}"
  local upstream_ref="${UPSTREAM_REF_FOR_BRANCH[$branch]-}"
  local upstream_oid="${UPSTREAM_OID_FOR_BRANCH[$branch]-}"
  local local_only="${LOCAL_ONLY_FOR_BRANCH[$branch]-0}"
  local remote="${UPSTREAM_REMOTE_FOR_BRANCH[$branch]-}"
  local merge_ref="${UPSTREAM_MERGE_FOR_BRANCH[$branch]-}"
  local source_oid="" published_tip="" final_tip=""
  local backup_original="" backup_result="" restore_branch=""
  local current_local_oid=""
  local status=""

  if [[ -n "${WORKTREE_FOR_BRANCH[$branch]-}" ]]; then
    wt="${WORKTREE_FOR_BRANCH[$branch]}"
  else
    temp_root="$(mktemp -d "${TMPDIR:-/tmp}/git-rebase-branches.XXXXXX")" || {
      PROCESS_REASON="could not create a temporary worktree directory"
      error "Could not create a temporary worktree directory for '$branch'."
      return 1
    }
    wt="$temp_root/worktree"
    if ! git worktree add --quiet "$wt" "$branch"; then
      rm -rf -- "$temp_root"
      PROCESS_REASON="could not create a temporary worktree"
      error "Could not create a temporary worktree for '$branch'."
      return 1
    fi
    created_temp=1
    ACTIVE_TEMP_ROOT="$temp_root"
    ACTIVE_TEMP_PATH="$wt"
    KEEP_ACTIVE_TEMP=0
  fi
  # Re-check conditions immediately before touching the branch. Do not mark
  # this worktree active until its state and checked-out branch are verified;
  # cleanup must never switch a worktree that changed concurrently.
  status="$(git -C "$wt" status --porcelain=v1 --untracked-files=all --ignore-submodules=none 2>/dev/null)" || status="UNKNOWN"
  if [[ -n "$status" || "$(git -C "$wt" symbolic-ref --quiet --short HEAD 2>/dev/null || true)" != "$branch" ]] || has_operation_in_progress "$wt"; then
    PROCESS_REASON="worktree changed or became unavailable after preflight"
    warn "Skipping '$branch': its worktree changed or became unavailable after preflight."
    if (( created_temp )); then
      dispose_temp_worktree "$wt" "$temp_root"
    fi
    return 2
  fi

  current_local_oid="$(git rev-parse "refs/heads/$branch" 2>/dev/null || true)"
  if [[ "$current_local_oid" != "$old_local_oid" ]]; then
    PROCESS_REASON="local branch tip changed after preflight"
    warn "Skipping '$branch': its local branch tip changed after preflight."
    if (( created_temp )); then
      dispose_temp_worktree "$wt" "$temp_root"
    fi
    return 2
  fi

  ACTIVE_WORKTREE_PATH="$wt"
  ACTIVE_BRANCH="$branch"
  ACTIVE_RESTORE_BRANCH=""

  # For branches with an upstream, start from the fetched upstream tip. This
  # incorporates commits that may have reached the remote after the local
  # branch last tracked it. Without an upstream, rebase the local tip as a unit.
  if [[ -n "$upstream_oid" ]]; then
    source_oid="$upstream_oid"
    if ! git merge-base "$source_oid" "$BASE_OID" >/dev/null 2>&1; then
      PROCESS_REASON="upstream and target base have no common ancestor"
      warn "Skipping '$branch': upstream and target base have no common ancestor."
      if (( created_temp )); then
        dispose_temp_worktree "$wt" "$temp_root"
      fi
      return 2
    fi
  else
    source_oid="$old_local_oid"
    if (( PUSH || SKIP_UNPUSHED )); then
      PROCESS_REASON="upstream status cannot be verified with --push or --skip-unpushed"
      warn "Skipping '$branch': upstream status cannot be verified in this mode."
      if (( created_temp )); then
        dispose_temp_worktree "$wt" "$temp_root"
      fi
      return 2
    fi
    if ! git merge-base "$source_oid" "$BASE_OID" >/dev/null 2>&1; then
      PROCESS_REASON="local branch and target base have no common ancestor"
      warn "Skipping '$branch': local branch and target base have no common ancestor."
      if (( created_temp )); then
        dispose_temp_worktree "$wt" "$temp_root"
      fi
      return 2
    fi
    local_only=0
  fi

  backup_original="refs/backup/rebase-all/$RUN_ID/$index/original"
  backup_result="refs/backup/rebase-all/$RUN_ID/$index/result"
  if ! git update-ref "$backup_original" "$old_local_oid"; then
    PROCESS_REASON="could not create the original recovery reference"
    error "Could not create recovery reference for '$branch'."
    if (( created_temp )); then
      dispose_temp_worktree "$wt" "$temp_root"
    fi
    return 1
  fi

  ACTIVE_BRANCH="$branch"
  ACTIVE_RESTORE_BRANCH=""

  if ! git -C "$wt" switch --quiet --detach "$source_oid"; then
    PROCESS_REASON="could not detach at the published/base source"
    PROCESS_RECOVERY="original recovery ref: $backup_original"
    error "Could not detach at the published/base source for '$branch'. Recovery ref: $backup_original"
    recover_without_commit "$wt" "$branch" "" "$old_local_oid" "$backup_original"
    PROCESS_RECOVERY="$RECOVERY_NOTE"
    if (( created_temp )); then
      dispose_temp_worktree "$wt" "$temp_root"
    fi
    return 1
  fi

  if [[ -n "$upstream_oid" ]]; then
    info "Rebasing published history of '$branch' onto '$BASE_LABEL'..."
  else
    info "Rebasing local history of '$branch' onto '$BASE_LABEL' (no upstream configured)..."
  fi
  ACTIVE_REBASE_PATH="$wt"
  if ! git -C "$wt" -c rebase.updateRefs=false rebase --rebase-merges --no-autostash "$BASE_OID"; then
    PROCESS_REASON="published-history rebase failed; rebase was aborted"
    PROCESS_RECOVERY="original recovery ref: $backup_original"
    error "Published-history rebase failed for '$branch'; aborting."
    git -C "$wt" rebase --abort >/dev/null 2>&1 || true
    ACTIVE_REBASE_PATH=""
    recover_without_commit "$wt" "$branch" "" "$old_local_oid" "$backup_original"
    PROCESS_RECOVERY="$RECOVERY_NOTE"
    if (( created_temp )); then
      dispose_temp_worktree "$wt" "$temp_root"
    fi
    return 1
  fi
  ACTIVE_REBASE_PATH=""
  published_tip="$(git -C "$wt" rev-parse HEAD)"
  final_tip="$published_tip"

  # Replay local-only commits after the published history has been rebased.
  if [[ -n "$upstream_oid" ]] && (( local_only > 0 )); then
    restore_branch="__rebase_restore_${RUN_ID//[^a-zA-Z0-9_]/_}_${index}"
    ACTIVE_RESTORE_BRANCH="$restore_branch"
    if git show-ref --verify --quiet "refs/heads/$restore_branch"; then
      PROCESS_REASON="temporary recovery branch already exists"
      PROCESS_RECOVERY="original recovery ref: $backup_original"
      error "Temporary recovery branch '$restore_branch' already exists; stopping."
      recover_without_commit "$wt" "$branch" "" "$old_local_oid" "$backup_original"
      PROCESS_RECOVERY="$RECOVERY_NOTE"
      if (( created_temp )); then
        dispose_temp_worktree "$wt" "$temp_root"
      fi
      return 1
    fi
    if ! git -C "$wt" switch --quiet --create "$restore_branch" "$old_local_oid"; then
      PROCESS_REASON="could not prepare local-only commit replay"
      PROCESS_RECOVERY="original recovery ref: $backup_original"
      error "Could not prepare local-only commit replay for '$branch'."
      recover_without_commit "$wt" "$branch" "" "$old_local_oid" "$backup_original"
      PROCESS_RECOVERY="$RECOVERY_NOTE"
      if (( created_temp )); then
        dispose_temp_worktree "$wt" "$temp_root"
      fi
      return 1
    fi

    info "Replaying $local_only local-only commit(s) for '$branch'..."
    ACTIVE_REBASE_PATH="$wt"
    if ! git -C "$wt" -c rebase.updateRefs=false rebase --rebase-merges --no-autostash --onto "$published_tip" "$upstream_oid"; then
      PROCESS_REASON="local-only commit replay failed; rebase was aborted"
      PROCESS_RECOVERY="original recovery ref: $backup_original"
      error "Local-only commit replay failed for '$branch'; aborting."
      git -C "$wt" rebase --abort >/dev/null 2>&1 || true
      ACTIVE_REBASE_PATH=""
      recover_without_commit "$wt" "$branch" "$restore_branch" "$old_local_oid" "$backup_original"
      PROCESS_RECOVERY="$RECOVERY_NOTE"
      if (( created_temp )); then
        dispose_temp_worktree "$wt" "$temp_root"
      fi
      return 1
    fi
    ACTIVE_REBASE_PATH=""
    final_tip="$(git -C "$wt" rev-parse HEAD)"
  fi

  # Keep the result reachable before any push/ref updates. If a later step
  # fails, the user can inspect or recover both the original and new histories.
  if ! git update-ref "$backup_result" "$final_tip"; then
    PROCESS_REASON="could not create the completed-result recovery reference"
    PROCESS_RECOVERY="original recovery ref: $backup_original"
    (( created_temp )) && PROCESS_RECOVERY+="; recovery worktree retained: $wt"
    error "Could not create result recovery reference for '$branch'. Original retained at $backup_original"
    if (( created_temp )); then
      KEEP_ACTIVE_TEMP=1
      warn "Recovery worktree retained at: $wt"
    fi
    return 1
  fi

  # Push ONLY the rebased published tip. The local-only commits are reachable
  # from final_tip but not from published_tip, so they cannot enter this push.
  if (( PUSH )); then
    expected_upstream="$upstream_oid"
    info "Pushing published history of '$branch' to '$remote' ($merge_ref)..."
    if ! git push --no-follow-tags "--force-with-lease=$merge_ref:$expected_upstream" \
      "$remote" "$published_tip:$merge_ref"; then
      PROCESS_REASON="push failed; local branch restoration was attempted"
      PROCESS_RECOVERY="original recovery ref: $backup_original; result recovery ref: $backup_result"
      error "Push failed for '$branch'. The local branch will be restored to its original tip."
      recover_without_commit "$wt" "$branch" "$restore_branch" "$old_local_oid" "$backup_original"
      PROCESS_RECOVERY="$RECOVERY_NOTE"
      git update-ref -d "$backup_result" "$final_tip" >/dev/null 2>&1 || true
      if (( created_temp )); then
        dispose_temp_worktree "$wt" "$temp_root"
      fi
      return 1
    fi
    PROCESS_PUSHED=1

    # Git normally updates the matching remote-tracking ref after a successful
    # push. Handle both that behavior and clients/configurations that do not.
    current_tracking_oid="$(git rev-parse --verify "$upstream_ref^{commit}" 2>/dev/null || true)"
    if [[ "$current_tracking_oid" != "$published_tip" ]]; then
      if [[ "$current_tracking_oid" == "$expected_upstream" ]]; then
        if ! git update-ref "$upstream_ref" "$published_tip" "$expected_upstream" 2>/dev/null; then
          warn "Push succeeded, but tracking ref '$upstream_ref' could not be refreshed; fetch '$remote' again."
        fi
      else
        warn "Push succeeded, but tracking ref '$upstream_ref' moved independently; fetch '$remote' again."
      fi
    fi
  fi

  # Check that the active worktree has no changes before changing its branch ref.
  status="$(git -C "$wt" status --porcelain=v1 --untracked-files=all --ignore-submodules=none 2>/dev/null)" || status="UNKNOWN"
  if [[ -n "$status" ]]; then
    PROCESS_REASON="worktree became dirty after rebase/push; local branch ref was not updated"
    PROCESS_RECOVERY="original recovery ref: $backup_original; result recovery ref: $backup_result"
    (( created_temp )) && PROCESS_RECOVERY+="; recovery worktree retained: $wt"
    (( PUSH )) && PROCESS_PARTIAL=1
    error "Worktree for '$branch' became dirty before the local ref update. Recovery refs: $backup_original and $backup_result"
    if (( created_temp )); then
      KEEP_ACTIVE_TEMP=1
      warn "Recovery worktree retained at: $wt"
    fi
    return 1
  fi

  # Atomic compare-and-swap prevents overwriting a branch moved by another process.
  if ! git update-ref "refs/heads/$branch" "$final_tip" "$old_local_oid"; then
    PROCESS_REASON="local branch changed concurrently; computed result was not installed"
    PROCESS_RECOVERY="original recovery ref: $backup_original; result recovery ref: $backup_result"
    (( created_temp )) && PROCESS_RECOVERY+="; recovery worktree retained: $wt"
    (( PUSH )) && PROCESS_PARTIAL=1
    error "Local branch '$branch' changed concurrently. Recovery refs: $backup_original and $backup_result"
    if (( created_temp )); then
      KEEP_ACTIVE_TEMP=1
      warn "Recovery worktree retained at: $wt"
    fi
    return 1
  fi

  # The branch ref now points to the completed result. Switch back to it in
  # this worktree (whether it is the main or a linked worktree).
  if ! git -C "$wt" switch --quiet "$branch"; then
    PROCESS_REASON="branch ref updated, but its worktree could not be switched back"
    PROCESS_RECOVERY="original recovery ref: $backup_original; result recovery ref: $backup_result"
    (( created_temp )) && PROCESS_RECOVERY+="; recovery worktree retained: $wt"
    PROCESS_PARTIAL=1
    error "Updated '$branch', but could not switch its worktree back to that branch. Recovery refs: $backup_original and $backup_result"
    if (( created_temp )); then
      KEEP_ACTIVE_TEMP=1
      warn "Recovery worktree retained at: $wt"
    fi
    return 1
  fi

  if [[ -n "$restore_branch" ]]; then
    git -C "$wt" branch -D "$restore_branch" >/dev/null 2>&1 || warn "Could not remove temporary branch '$restore_branch'."
  fi

  git update-ref -d "$backup_original" "$old_local_oid" >/dev/null 2>&1 || warn "Could not remove recovery ref '$backup_original'."
  git update-ref -d "$backup_result" "$final_tip" >/dev/null 2>&1 || warn "Could not remove recovery ref '$backup_result'."
  PROCESS_RECOVERY=""
  if git show-ref --verify --quiet "$backup_original"; then
    PROCESS_RECOVERY="original recovery ref retained: $backup_original"
  fi
  if git show-ref --verify --quiet "$backup_result"; then
    [[ -n "$PROCESS_RECOVERY" ]] && PROCESS_RECOVERY+="; "
    PROCESS_RECOVERY+="result recovery ref retained: $backup_result"
  fi
  if [[ -n "$restore_branch" ]] && git show-ref --verify --quiet "refs/heads/$restore_branch"; then
    [[ -n "$PROCESS_RECOVERY" ]] && PROCESS_RECOVERY+="; "
    PROCESS_RECOVERY+="temporary branch retained: $restore_branch"
  fi

  if (( PUSH )); then
    if (( local_only > 0 )); then
      success "Rebased and pushed published history for '$branch'; kept $local_only local-only commit(s) local."
    else
      success "Rebased and pushed '$branch'."
    fi
  else
    if (( local_only > 0 )); then
      success "Rebased '$branch' and preserved $local_only local-only commit(s)."
    else
      success "Rebased '$branch'."
    fi
  fi

  if (( created_temp )); then
    dispose_temp_worktree "$wt" "$temp_root"
  fi

  ACTIVE_WORKTREE_PATH=""
  ACTIVE_BRANCH=""
  ACTIVE_RESTORE_BRANCH=""
  return 0
}

REBASED_COUNT=0
SKIPPED_COUNT=0
FAILED_COUNT=0
PARTIAL_COUNT=0
PUSHED_COUNT=0
LOCAL_ONLY_PRESERVED_COUNT=0

declare -A REBASED_REASON=()
declare -A SKIPPED_REASON=()
declare -A FAILED_REASON=()
declare -A PARTIAL_REASON=()
declare -A PUSHED_REASON=()
declare -A RECOVERY_REASON=()

header "Processing selected branches"
index=0
for branch in "${BRANCHES[@]}"; do
  index=$((index + 1))
  if [[ -z "${CANDIDATE[$branch]-}" ]]; then
    SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
    SKIPPED_REASON["$branch"]="${BRANCH_REASON[$branch]:-not eligible during preflight}"
    continue
  fi

  local_before="${LOCAL_ONLY_FOR_BRANCH[$branch]-0}"
  if process_branch "$branch" "$index"; then
    REBASED_COUNT=$((REBASED_COUNT + 1))
    if [[ -n "$PROCESS_RECOVERY" ]]; then
      RECOVERY_REASON["$branch"]="$PROCESS_RECOVERY"
    fi
    if (( local_before > 0 )); then
      LOCAL_ONLY_PRESERVED_COUNT=$((LOCAL_ONLY_PRESERVED_COUNT + 1))
      REBASED_REASON["$branch"]="rebased; preserved $local_before local-only commit(s) locally"
    else
      REBASED_REASON["$branch"]="rebased onto $BASE_LABEL"
    fi
    if (( PROCESS_PUSHED )); then
      PUSHED_COUNT=$((PUSHED_COUNT + 1))
      PUSHED_REASON["$branch"]="published rebased history pushed to ${UPSTREAM_REMOTE_FOR_BRANCH[$branch]}/${UPSTREAM_MERGE_FOR_BRANCH[$branch]#refs/heads/}"
    fi
  else
    process_result=$?
    PROCESS_REASON="${PROCESS_REASON:-operation did not complete}"
    if [[ -n "$PROCESS_RECOVERY" ]]; then
      RECOVERY_REASON["$branch"]="$PROCESS_RECOVERY"
    fi
    if (( PROCESS_PARTIAL )); then
      PARTIAL_COUNT=$((PARTIAL_COUNT + 1))
      PARTIAL_REASON["$branch"]="$PROCESS_REASON"
    elif (( process_result == 2 )); then
      SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
      SKIPPED_REASON["$branch"]="$PROCESS_REASON"
    else
      FAILED_COUNT=$((FAILED_COUNT + 1))
      FAILED_REASON["$branch"]="$PROCESS_REASON"
    fi
  fi
done

print_branch_section() {
  local title="$1" map_name="$2" count="$3"
  local -n reasons="$map_name"
  header "$title ($count)"
  if (( count == 0 )); then
    info "None."
    return
  fi
  for branch in "${BRANCHES[@]}"; do
    if [[ -n "${reasons[$branch]-}" ]]; then
      printf '  - %s: %s\n' "$branch" "${reasons[$branch]}"
    fi
  done
}

header "Final summary"
print_branch_section "Successfully rebased" REBASED_REASON "$REBASED_COUNT"
print_branch_section "Pushed" PUSHED_REASON "$PUSHED_COUNT"
print_branch_section "Skipped" SKIPPED_REASON "$SKIPPED_COUNT"
print_branch_section "Failed / aborted" FAILED_REASON "$FAILED_COUNT"
print_branch_section "Partially completed — attention required" PARTIAL_REASON "$PARTIAL_COUNT"

header "Additional details"
info "Branches with local-only commits preserved: $LOCAL_ONLY_PRESERVED_COUNT"
if (( PUSH )); then
  info "Pushes performed: $PUSHED_COUNT"
else
  info "Pushes performed: 0 (use --push to opt in)"
fi

header "Recovery information"
if ((${#RECOVERY_REASON[@]} == 0)); then
  success "No recovery references were reported as retained."
else
  for branch in "${BRANCHES[@]}"; do
    if [[ -n "${RECOVERY_REASON[$branch]-}" ]]; then
      warn "$branch — ${RECOVERY_REASON[$branch]}"
    fi
  done
fi

info "Summary: $REBASED_COUNT rebased; $SKIPPED_COUNT skipped; $FAILED_COUNT failed/aborted; $PARTIAL_COUNT partially completed; $PUSHED_COUNT pushed."

if (( FAILED_COUNT > 0 || PARTIAL_COUNT > 0 )); then
  exit 1
fi