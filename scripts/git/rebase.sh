#!/usr/bin/env bash

# Rebase all local branches with a configured remote upstream.
# Push rebased published commits and restore local-only commits.

set -uo pipefail

BASE_BRANCH="${BASE_BRANCH:-master}"
BASE_REF="${BASE_REF:-}"

RUN_ID="$(date +%Y%m%d%H%M%S)-$$"
PROCESSED=0
SKIPPED=0
FAILED=0
SEQ=0

log() {
  printf '%s\n' "$*"
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "Error: run this script inside a Git repository."
  exit 1
fi

ROOT="$(git rev-parse --show-toplevel)" || exit 1
cd "$ROOT" || exit 1

log "Fetching all remotes..."

if ! git fetch --all --prune; then
  log "Error: fetch failed. No branches were changed."
  exit 1
fi

find_worktree_for_branch() {
  local wanted="refs/heads/$1"
  local path=""
  local line

  while IFS= read -r line; do
    case "$line" in
      "worktree "*)
        path="${line#worktree }"
        ;;
      "branch $wanted")
        printf '%s\n' "$path"
        return 0
        ;;
    esac
  done < <(git worktree list --porcelain)

  return 1
}

remove_temp_worktree() {
  local wt="$1"
  local force="${2:-0}"

  if (( force )); then
    git worktree remove --force "$wt" >/dev/null 2>&1
  else
    git worktree remove "$wt" >/dev/null 2>&1
  fi
}

has_operation_in_progress() {
  local wt="$1"
  local state path

  for state in rebase-apply rebase-merge MERGE_HEAD \
    CHERRY_PICK_HEAD REVERT_HEAD; do

    path="$(git -C "$wt" rev-parse --git-path "$state")" || continue

    if [[ -e "$path" ]]; then
      return 0
    fi
  done

  return 1
}

recover_original_branch() {
  local wt="$1"
  local branch="$2"
  local restore_branch="$3"

  git -C "$wt" rebase --abort >/dev/null 2>&1 || true

  if ! git -C "$wt" switch --quiet "$branch"; then
    log "ERROR: Could not restore branch '$branch'."
    return 1
  fi

  if [[ -n "$restore_branch" ]]; then
    git -C "$wt" branch -D "$restore_branch" >/dev/null 2>&1 || true
  fi

  return 0
}

process_branch() {
  local branch="$1"
  local index="$2"

  local wt=""
  local worktree_tmp=""
  local created_worktree=0

  local remote
  local merge_ref
  local upstream_ref

  local upstream_oid
  local local_tip
  local base_ref
  local base_oid

  local local_only_count
  local backup_ref
  local restore_branch=""

  local published_tip
  local final_local_tip
  local status

  # Only process branches with a configured remote upstream.
  remote="$(git config --get "branch.${branch}.remote" 2>/dev/null || true)"
  merge_ref="$(git config --get "branch.${branch}.merge" 2>/dev/null || true)"

  if [[ -z "$remote" || "$remote" == "." || "$merge_ref" != refs/heads/* ]]; then
    log "Skipping '$branch': no remote upstream configured."
    return 1
  fi

  if ! git remote get-url "$remote" >/dev/null 2>&1; then
    log "Skipping '$branch': remote '$remote' unavailable."
    return 1
  fi

  # Find its existing worktree or create an isolated one.
  if wt="$(find_worktree_for_branch "$branch")"; then
    :
  else
    worktree_tmp="$(mktemp -d "${TMPDIR:-/tmp}/rebase-all.XXXXXX")" || {
      log "Skipping '$branch': cannot create temporary worktree."
      return 1
    }

    if ! git worktree add --quiet "$worktree_tmp" "$branch"; then
      rmdir "$worktree_tmp" 2>/dev/null || true
      log "Skipping '$branch': cannot create worktree."
      return 1
    fi

    wt="$worktree_tmp"
    created_worktree=1
  fi

  # Skip branches with staged, unstaged, or untracked changes.
  status="$(git -C "$wt" status --porcelain --untracked-files=all 2>&1)" || {
    log "Skipping '$branch': cannot inspect worktree."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  }

  if [[ -n "$status" ]]; then
    log "Skipping '$branch': uncommitted changes."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  fi

  if has_operation_in_progress "$wt"; then
    log "Skipping '$branch': Git operation in progress."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  fi

  # Resolve upstream and local branch tips.
  upstream_ref="$(git -C "$wt" rev-parse \
    --symbolic-full-name "${branch}@{upstream}" 2>/dev/null || true)"

  if [[ -z "$upstream_ref" ]]; then
    log "Skipping '$branch': upstream cannot be resolved."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  fi

  upstream_oid="$(git -C "$wt" rev-parse \
    --verify "${upstream_ref}^{commit}" 2>/dev/null || true)"

  local_tip="$(git -C "$wt" rev-parse \
    --verify "refs/heads/${branch}^{commit}" 2>/dev/null || true)"

  if [[ -z "$upstream_oid" || -z "$local_tip" ]]; then
    log "Skipping '$branch': cannot resolve commit references."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  fi

  # Determine the base branch.
  if [[ -n "$BASE_REF" ]]; then
    base_ref="$BASE_REF"
  else
    base_ref="refs/remotes/${remote}/${BASE_BRANCH}"
  fi

  base_oid="$(git -C "$wt" rev-parse \
    --verify "${base_ref}^{commit}" 2>/dev/null || true)"

  if [[ -z "$base_oid" ]]; then
    log "Skipping '$branch': base '$base_ref' does not exist."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  fi

  # Determine whether the local branch is ahead, equal, or behind.
  if git -C "$wt" merge-base --is-ancestor "$upstream_oid" "$local_tip"; then
    local_only_count="$(git -C "$wt" rev-list \
      --count "${upstream_oid}..${local_tip}")"

  elif git -C "$wt" merge-base --is-ancestor "$local_tip" "$upstream_oid"; then
    local_only_count=0

  else
    log "Skipping '$branch': local and remote histories diverged."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  fi

  # Create a recovery reference before modifying history.
  backup_ref="refs/backup/rebase-all/${RUN_ID}/${branch}"

  if ! git -C "$wt" update-ref "$backup_ref" "$local_tip"; then
    log "Skipping '$branch': could not create backup reference."

    if (( created_worktree )); then
      remove_temp_worktree "$wt" 1 || true
    fi

    return 1
  fi

  log "Rebasing '$branch' onto '$base_ref'."
  log "Local-only commits: $local_only_count"

  # First, rebase the published history.
  if ! git -C "$wt" switch --quiet --detach "$upstream_oid"; then
    log "ERROR: Could not detach at upstream. Backup: $backup_ref"

    recover_original_branch "$wt" "$branch" "" || return 2

    if (( created_worktree )); then
      remove_temp_worktree "$wt" || true
    fi

    return 2
  fi

  if ! git -C "$wt" rebase --rebase-merges "$base_ref"; then
    log "ERROR: Rebase failed. Backup: $backup_ref"

    recover_original_branch "$wt" "$branch" "" || return 2

    if (( created_worktree )); then
      remove_temp_worktree "$wt" || true
    fi

    return 2
  fi

  published_tip="$(git -C "$wt" rev-parse HEAD)"

  # Replay local-only commits onto the rebased published history.
  if (( local_only_count > 0 )); then
    restore_branch="__rebase_all_${RUN_ID//[^a-zA-Z0-9_]/_}_${index}"

    if ! git -C "$wt" switch --quiet --create "$restore_branch" "$local_tip"; then
      log "ERROR: Could not create replay branch. Backup: $backup_ref"

      recover_original_branch "$wt" "$branch" "" || return 2

      if (( created_worktree )); then
        remove_temp_worktree "$wt" || true
      fi

      return 2
    fi

    if ! git -C "$wt" rebase --rebase-merges \
      --onto "$published_tip" "$upstream_oid"; then

      log "ERROR: Replaying local commits failed. Backup: $backup_ref"

      recover_original_branch "$wt" "$branch" "$restore_branch" || return 2

      if (( created_worktree )); then
        remove_temp_worktree "$wt" || true
      fi

      return 2
    fi

    final_local_tip="$(git -C "$wt" rev-parse HEAD)"
  else
    final_local_tip="$published_tip"
  fi

  # Push ONLY the rebased published history.
  if ! git -C "$wt" push \
    --force-with-lease="${merge_ref}:${upstream_oid}" \
    "$remote" "${published_tip}:${merge_ref}"; then

    log "ERROR: Push failed. Backup: $backup_ref"

    recover_original_branch "$wt" "$branch" "$restore_branch" || return 2

    if (( created_worktree )); then
      remove_temp_worktree "$wt" || true
    fi

    return 2
  fi

  # Update the remote-tracking reference conditionally.
  local current_upstream

  current_upstream="$(git -C "$wt" rev-parse \
    --verify "$upstream_ref^{commit}" 2>/dev/null || true)"

  if [[ "$current_upstream" != "$published_tip" ]]; then
    if ! git -C "$wt" update-ref \
      "$upstream_ref" "$published_tip" "$upstream_oid"; then

      log "Warning: remote-tracking reference changed; fetch again later."
    fi
  fi

  # Restore the original local branch.
  if ! git -C "$wt" switch --quiet "$branch"; then
    log "ERROR: Push succeeded, but branch restoration failed."
    log "Backup: $backup_ref"
    log "Worktree retained: $wt"
    return 2
  fi

  # Ensure the worktree is still clean before updating its branch.
  status="$(git -C "$wt" status --porcelain --untracked-files=all 2>&1)" || {
    log "ERROR: Could not re-check worktree."
    log "Backup: $backup_ref"
    return 2
  }

  if [[ -n "$status" ]]; then
    log "ERROR: Worktree changed concurrently; no reset performed."
    log "Backup: $backup_ref"
    return 2
  fi

  local current_local_tip

  current_local_tip="$(git -C "$wt" rev-parse \
    --verify "refs/heads/${branch}^{commit}")"

  if [[ "$current_local_tip" != "$local_tip" ]] || \
    ! git -C "$wt" update-ref \
      "refs/heads/$branch" "$final_local_tip" "$local_tip"; then

    log "ERROR: Local branch changed concurrently."
    log "Backup: $backup_ref"
    return 2
  fi

  if ! git -C "$wt" reset --hard "$final_local_tip" >/dev/null; then
    log "ERROR: Could not update worktree."
    log "Backup: $backup_ref"
    return 2
  fi

  # Clean up temporary references.
  if [[ -n "$restore_branch" ]]; then
    git -C "$wt" branch -D "$restore_branch" >/dev/null 2>&1 || true
  fi

  git -C "$wt" update-ref -d "$backup_ref" "$local_tip" || {
    log "Warning: could not remove backup '$backup_ref'."
  }

  log "Done: pushed rebased history and restored $local_only_count local commit(s)."

  if (( created_worktree )); then
    remove_temp_worktree "$wt" || {
      log "Warning: temporary worktree retained at '$wt'."
    }
  fi

  return 0
}

log "Base branch: $BASE_BRANCH"

if [[ -n "$BASE_REF" ]]; then
  log "Base override: $BASE_REF"
else
  log "Using each branch's tracking remote: $BASE_BRANCH"
fi

# Capture branch names before processing.
BRANCH_LIST_FILE="$(mktemp "${TMPDIR:-/tmp}/rebase-all-branches.XXXXXX")" || exit 1

if ! git for-each-ref \
  --format='%(refname:short)' refs/heads > "$BRANCH_LIST_FILE"; then

  rm -f "$BRANCH_LIST_FILE"
  exit 1
fi

while IFS= read -r branch; do
  [[ -z "$branch" || "$branch" == "$BASE_BRANCH" ]] && continue

  SEQ=$((SEQ + 1))

  if process_branch "$branch" "$SEQ"; then
    PROCESSED=$((PROCESSED + 1))
  else
    result=$?

    if (( result == 1 )); then
      SKIPPED=$((SKIPPED + 1))
    else
      FAILED=$((FAILED + 1))
    fi
  fi

done < "$BRANCH_LIST_FILE"

rm -f "$BRANCH_LIST_FILE"

log ""
log "Summary:"
log "Processed: $PROCESSED"
log "Skipped:   $SKIPPED"
log "Failed:    $FAILED"

if (( FAILED > 0 )); then
  exit 1
fi