#!/usr/bin/env bash

set -u

# ============================================================
# CONFIGURATION
# ============================================================

DRY_RUN=false
NO_PUSH=false
NO_REBASE=false

BASE_BRANCH=""

BACKUP_NAMESPACE="refs/backup/git-rebase-all"

for ARG in "$@"; do
    case "$ARG" in
        --dry-run)
            DRY_RUN=true
            ;;
        --no-push)
            NO_PUSH=true
            ;;
        --no-rebase)
            NO_REBASE=true
            ;;
        --base=*)
            BASE_BRANCH="${ARG#*=}"
            ;;
        -h|--help)
            cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --base=BRANCH  Rebase onto this base branch.
                Default: each branch's configured upstream.

  --dry-run      Inspect without fetching, rebasing or pushing.
  --no-push      Fetch and rebase, but never offer pushes.
  --no-rebase    Fetch and inspect without rebasing or pushing.
  -h, --help     Show this help.

Examples:
  $0
  $0 --base=origin/main
  $0 --dry-run
  $0 --no-push
  $0 --no-rebase
EOF
            exit 0
            ;;
        *)
            echo "Unknown option: $ARG"
            exit 1
            ;;
    esac
done

# ============================================================
# VALIDATE REPOSITORY
# ============================================================

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: Not inside a Git repository."
    exit 1
fi

ORIGINAL_BRANCH=$(git branch --show-current)

if [[ -z "$ORIGINAL_BRANCH" ]]; then
    echo "Error: HEAD is detached. Switch to a branch first."
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "Error: Working tree contains uncommitted changes."
    git status --short
    echo "Commit or stash your changes before running this script."
    exit 1
fi

# ============================================================
# SUMMARY
# ============================================================

SUCCESSFUL_REBASES=()
SKIPPED_BRANCHES=()
CONFLICTS=()
PENDING_PUSHES=()
SUCCESSFUL_PUSHES=()

add_item() {
    local -n ARRAY="$1"
    ARRAY+=("$2")
}

print_section() {
    local TITLE="$1"
    local -n ITEMS="$2"

    echo
    echo "$TITLE (${#ITEMS[@]})"

    if [[ ${#ITEMS[@]} -eq 0 ]]; then
        echo "  None."
        return
    fi

    for ITEM in "${ITEMS[@]}"; do
        echo "  - $ITEM"
    done
}

# ============================================================
# SHOW COMMITS
# ============================================================

show_commits() {
    local BRANCH="$1"
    local UPSTREAM="$2"

    local -a COMMITS

    mapfile -t COMMITS < <(
        git rev-list --reverse "$UPSTREAM..$BRANCH"
    )

    if [[ ${#COMMITS[@]} -eq 0 ]]; then
        echo "No commits ahead of upstream."
        return 0
    fi

    echo
    echo "Found ${#COMMITS[@]} unpushed commit(s)."

    for COMMIT in "${COMMITS[@]}"; do
        echo
        echo "======================================"

        git show -s \
            --format='%h %s%nAuthor: %an%nDate: %ad' \
            --date=short "$COMMIT"

        echo "======================================"

        git show --format= --stat "$COMMIT"
    done
}

# ============================================================
# REVIEW COMMITS
# ============================================================

review_commits() {
    local BRANCH="$1"
    local UPSTREAM="$2"

    local -a COMMITS
    local ALL_APPROVED=true

    mapfile -t COMMITS < <(
        git rev-list --reverse "$UPSTREAM..$BRANCH"
    )

    for COMMIT in "${COMMITS[@]}"; do
        echo
        echo "======================================"
        echo "Reviewing commit: $COMMIT"
        echo "======================================"

        git show --format=fuller --stat --patch "$COMMIT"

        echo
        read -r -p "Approve this commit for pushing? [y/N] " ANSWER

        case "$ANSWER" in
            y|Y|yes|YES)
                echo "Approved."
                ;;
            *)
                echo "Rejected."
                ALL_APPROVED=false
                ;;
        esac
    done

    [[ "$ALL_APPROVED" == true ]]
}

# ============================================================
# RESTORE ORIGINAL BRANCH
# ============================================================

restore_branch() {
    if [[ "$(git branch --show-current)" != "$ORIGINAL_BRANCH" ]]; then
        git switch "$ORIGINAL_BRANCH" >/dev/null 2>&1 || {
            echo "WARNING: Could not restore original branch."
        }
    fi
}

trap restore_branch EXIT

# ============================================================
# FETCH
# ============================================================

echo
echo "======================================"
echo " Git: Update matching local branches"
echo "======================================"

if [[ "$DRY_RUN" == true ]]; then
    echo "MODE: DRY RUN"
    echo "Using existing remote-tracking references."
else
    echo "Fetching all remotes..."

    if ! git fetch --all --prune; then
        echo "Fetch failed. Aborting."
        exit 1
    fi
fi

# ============================================================
# OPTIONAL BASE VALIDATION
# ============================================================

if [[ -n "$BASE_BRANCH" ]]; then
    if ! git rev-parse --verify "$BASE_BRANCH^{commit}" >/dev/null 2>&1; then
        echo "Error: Base branch does not exist: $BASE_BRANCH"
        exit 1
    fi
fi

# ============================================================
# DISCOVER LOCAL BRANCHES
# ============================================================

mapfile -t BRANCHES < <(
    git for-each-ref --format='%(refname:short)' refs/heads
)

# ============================================================
# PROCESS MATCHING BRANCHES
# ============================================================

for BRANCH in "${BRANCHES[@]}"; do

    echo
    echo "======================================"
    echo "Local branch: $BRANCH"
    echo "======================================"

    # --------------------------------------------------------
    # FIND CONFIGURED UPSTREAM
    # --------------------------------------------------------

    REMOTE=$(git config --get "branch.$BRANCH.remote" || true)

    MERGE_REF=$(git config --get "branch.$BRANCH.merge" || true)

    if [[ -z "$REMOTE" || -z "$MERGE_REF" ]]; then
        echo "SKIPPED: No configured upstream."

        add_item SKIPPED_BRANCHES "$BRANCH (no upstream)"
        continue
    fi

    if [[ "$REMOTE" == "." ]]; then
        echo "SKIPPED: Local upstream is not a remote branch."

        add_item SKIPPED_BRANCHES "$BRANCH (local upstream)"
        continue
    fi

    if [[ "$MERGE_REF" != refs/heads/* ]]; then
        echo "SKIPPED: Unexpected upstream reference."

        add_item SKIPPED_BRANCHES "$BRANCH (invalid upstream)"
        continue
    fi

    REMOTE_BRANCH="${MERGE_REF#refs/heads/}"

    REMOTE_REF="refs/remotes/$REMOTE/$REMOTE_BRANCH"

    echo "Remote: $REMOTE"
    echo "Remote branch: $REMOTE_BRANCH"

    # --------------------------------------------------------
    # VERIFY MATCHING REMOTE BRANCH
    # --------------------------------------------------------

    if ! git rev-parse --verify "$REMOTE_REF^{commit}" >/dev/null 2>&1; then
        echo "SKIPPED: Matching remote branch does not exist."

        add_item SKIPPED_BRANCHES "$BRANCH (missing remote branch)"
        continue
    fi

    REMOTE_TIP=$(git rev-parse "$REMOTE_REF")

    # --------------------------------------------------------
    # CHECK WORKTREE
    # --------------------------------------------------------

    CURRENT_BRANCH=$(git branch --show-current)

    if [[ "$BRANCH" != "$CURRENT_BRANCH" ]]; then

        if git worktree list --porcelain |
            grep -Fxq "branch refs/heads/$BRANCH"; then

            echo "SKIPPED: Branch is checked out in another worktree."

            add_item SKIPPED_BRANCHES "$BRANCH (another worktree)"
            continue
        fi
    fi

    # --------------------------------------------------------
    # DETERMINE REBASE TARGET
    # --------------------------------------------------------

    TARGET="$REMOTE_REF"

    if [[ -n "$BASE_BRANCH" ]]; then
        TARGET="$BASE_BRANCH"
    fi

    if ! git rev-parse --verify "$TARGET^{commit}" >/dev/null 2>&1; then
        echo "SKIPPED: Rebase target does not exist."

        add_item SKIPPED_BRANCHES "$BRANCH (missing rebase target)"
        continue
    fi

    TARGET_TIP=$(git rev-parse "$TARGET")

    echo "Rebase target: $TARGET"

    # --------------------------------------------------------
    # DRY RUN
    # --------------------------------------------------------

    if [[ "$DRY_RUN" == true ]]; then

        echo
        echo "[DRY RUN] Inspecting $BRANCH"

        if [[ "$BRANCH" == "$CURRENT_BRANCH" ]] &&
            [[ -n "$(git status --porcelain)" ]]; then

            echo "Uncommitted changes detected."

            add_item SKIPPED_BRANCHES "$BRANCH (uncommitted changes)"
            continue
        fi

        BEHIND=$(git rev-list --count "$BRANCH..$TARGET")
        AHEAD=$(git rev-list --count "$TARGET..$BRANCH")

        echo "Commits behind target: $BEHIND"
        echo "Commits ahead of target: $AHEAD"

        show_commits "$BRANCH" "$TARGET"

        if [[ "$AHEAD" -gt 0 ]]; then
            add_item PENDING_PUSHES "$BRANCH (not pushed)"
        fi

        continue
    fi

    # --------------------------------------------------------
    # SWITCH BRANCH
    # --------------------------------------------------------

    if [[ "$BRANCH" != "$CURRENT_BRANCH" ]]; then
        if ! git switch "$BRANCH" >/dev/null 2>&1; then
            echo "SKIPPED: Cannot switch branch."

            add_item SKIPPED_BRANCHES "$BRANCH (cannot switch)"
            continue
        fi
    fi

    # --------------------------------------------------------
    # CHECK UNCOMMITTED CHANGES
    # --------------------------------------------------------

    if [[ -n "$(git status --porcelain)" ]]; then
        echo "SKIPPED: Uncommitted changes detected."

        git status --short

        add_item SKIPPED_BRANCHES "$BRANCH (uncommitted changes)"
        continue
    fi

    # --------------------------------------------------------
    # CHECK DIVERGENT LOCAL AND REMOTE HISTORIES
    # --------------------------------------------------------

    if ! git merge-base "$BRANCH" "$REMOTE_REF" >/dev/null 2>&1; then
        echo "SKIPPED: Local and remote histories have no common ancestor."

        add_item SKIPPED_BRANCHES "$BRANCH (unrelated histories)"
        continue
    fi

    # --------------------------------------------------------
    # BACKUP ORIGINAL COMMIT
    # --------------------------------------------------------

    OLD_COMMIT=$(git rev-parse HEAD)

    BACKUP_REF="$BACKUP_NAMESPACE/$REMOTE/$REMOTE_BRANCH"

    if ! git update-ref "$BACKUP_REF" "$OLD_COMMIT"; then
        echo "SKIPPED: Could not update backup reference."

        add_item SKIPPED_BRANCHES "$BRANCH (backup failed)"
        continue
    fi

    echo "Backup created/updated: $BACKUP_REF"

    # --------------------------------------------------------
    # REBASE
    # --------------------------------------------------------

    if [[ "$NO_REBASE" == false ]]; then

        echo
        echo "Rebasing $BRANCH onto $TARGET..."

        if ! git rebase "$TARGET_TIP"; then
            echo "REBASE FAILED: $BRANCH"

            git rebase --abort || true

            add_item CONFLICTS "$BRANCH"
            continue
        fi

        echo "Rebase successful."

        add_item SUCCESSFUL_REBASES "$BRANCH"

    else
        echo "Rebase disabled."
    fi

    # --------------------------------------------------------
    # IDENTIFY COMMITS TO PUSH
    # --------------------------------------------------------

    mapfile -t COMMITS < <(
        git rev-list --reverse "$REMOTE_TIP..HEAD"
    )

    if [[ ${#COMMITS[@]} -eq 0 ]]; then
        echo "No commits to push."
        continue
    fi

    echo
    echo "Commits to push: ${#COMMITS[@]}"

    # --------------------------------------------------------
    # NO-PUSH / NO-REBASE
    # --------------------------------------------------------

    if [[ "$NO_PUSH" == true || "$NO_REBASE" == true ]]; then

        show_commits HEAD "$REMOTE_TIP"

        add_item PENDING_PUSHES \
            "$BRANCH (${#COMMITS[@]} commit(s), not pushed)"

        continue
    fi

    # --------------------------------------------------------
    # REVIEW COMMITS
    # --------------------------------------------------------

    if ! review_commits "$BRANCH" "$REMOTE_TIP"; then

        echo "PUSH CANCELLED: At least one commit was rejected."

        add_item PENDING_PUSHES \
            "$BRANCH (review rejected)"

        continue
    fi

    # --------------------------------------------------------
    # APPROVE PUSH
    # --------------------------------------------------------

    echo
    echo "All commits approved."

    read -r -p "Push $BRANCH to $REMOTE/$REMOTE_BRANCH? [y/N] " ANSWER

    case "$ANSWER" in
        y|Y|yes|YES)
            ;;
        *)
            echo "Push declined."

            add_item PENDING_PUSHES "$BRANCH (push declined)"
            continue
            ;;
    esac

    # --------------------------------------------------------
    # VERIFY REMOTE STATE
    # --------------------------------------------------------

    echo "Verifying remote state..."

    REMOTE_RESULT=$(
        git ls-remote --exit-code "$REMOTE" \
            "refs/heads/$REMOTE_BRANCH" 2>/dev/null || true
    )

    if [[ -z "$REMOTE_RESULT" ]]; then
        echo "PUSH ABORTED: Remote branch missing or unreachable."

        add_item PENDING_PUSHES "$BRANCH (remote unavailable)"
        continue
    fi

    ACTUAL_REMOTE=$(awk '{print $1}' <<< "$REMOTE_RESULT")

    if [[ "$REMOTE_TIP" != "$ACTUAL_REMOTE" ]]; then

        echo "PUSH ABORTED: Remote branch changed."
        echo "Expected: $REMOTE_TIP"
        echo "Actual: $ACTUAL_REMOTE"

        add_item PENDING_PUSHES "$BRANCH (remote changed)"
        continue
    fi

    # --------------------------------------------------------
    # PUSH
    # --------------------------------------------------------

    echo
    echo "Pushing $BRANCH..."

    if git push \
        --force-with-lease="refs/heads/$REMOTE_BRANCH:$REMOTE_TIP" \
        "$REMOTE" "HEAD:refs/heads/$REMOTE_BRANCH"; then

        echo "Push successful."

        add_item SUCCESSFUL_PUSHES "$BRANCH"

    else
        echo "Push failed."

        add_item PENDING_PUSHES "$BRANCH (push failed)"
    fi

done

# ============================================================
# FINAL SUMMARY
# ============================================================

echo
echo
echo "======================================"
echo " FINAL SUMMARY"
echo "======================================"

print_section "Successful rebases" SUCCESSFUL_REBASES
print_section "Skipped branches" SKIPPED_BRANCHES
print_section "Rebase conflicts" CONFLICTS
print_section "Pending pushes" PENDING_PUSHES
print_section "Successful pushes" SUCCESSFUL_PUSHES

echo
echo "======================================"
echo " Finished."
echo "======================================"