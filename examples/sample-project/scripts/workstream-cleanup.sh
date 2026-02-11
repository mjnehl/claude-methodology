#!/usr/bin/env bash
set -euo pipefail

# ─── Resolve project root from script location ───
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
PARENT_DIR="$(cd "$PROJECT_ROOT/.." && pwd)"

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[info]${NC}  $*"; }
ok()    { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${NC}  $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; exit 1; }

# ─── Usage ───
usage() {
  cat <<EOF
Usage: $(basename "$0") <feature-name> [options]

Clean up a workstream (remove worktree + delete branch).

Arguments:
  feature-name       Name of the workstream to remove

Options:
  --force            Skip merge/clean checks
  --delete-remote    Also delete remote branch
  --dry-run          Show what would happen without doing it
  -h, --help         Show this help

Examples:
  $(basename "$0") tags
  $(basename "$0") tags --delete-remote
  $(basename "$0") tags --force --delete-remote
  $(basename "$0") tags --dry-run
EOF
  exit 0
}

# ─── Parse arguments ───
FEATURE_NAME=""
FORCE=false
DELETE_REMOTE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --force) FORCE=true; shift ;;
    --delete-remote) DELETE_REMOTE=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -*)
      fail "Unknown option: $1" ;;
    *)
      [[ -z "$FEATURE_NAME" ]] || fail "Unexpected argument: $1"
      FEATURE_NAME="$1"; shift ;;
  esac
done

[[ -n "$FEATURE_NAME" ]] || fail "Feature name is required. Run with --help for usage."

WORKTREE_DIR="${PARENT_DIR}/${PROJECT_NAME}--${FEATURE_NAME}"

cd "$PROJECT_ROOT"

# ─── Detect branch from worktree ───
BRANCH_NAME=""
if git worktree list --porcelain | grep -Fq "worktree $WORKTREE_DIR"; then
  BRANCH_NAME=$(git worktree list --porcelain | awk -v dir="$WORKTREE_DIR" '
    $1 == "worktree" && $2 == dir { found=1 }
    found && $1 == "branch" { print $2; exit }
  ')
  BRANCH_NAME="${BRANCH_NAME#refs/heads/}"
fi

# If we couldn't detect from worktree, try common prefixes
if [[ -z "$BRANCH_NAME" ]]; then
  for prefix in feature fix refactor; do
    if git show-ref --verify --quiet "refs/heads/${prefix}/${FEATURE_NAME}"; then
      BRANCH_NAME="${prefix}/${FEATURE_NAME}"
      break
    fi
  done
fi

if [[ -z "$BRANCH_NAME" ]]; then
  if [[ "$FORCE" = true ]]; then
    warn "Could not detect branch for '$FEATURE_NAME'"
  else
    fail "Could not detect branch for workstream '$FEATURE_NAME'.\n       Use --force to clean up the directory anyway."
  fi
fi

echo ""
echo -e "${CYAN}═══ Cleanup Workstream ═══${NC}"
echo -e "  Feature:   $FEATURE_NAME"
echo -e "  Branch:    ${BRANCH_NAME:-<unknown>}"
echo -e "  Worktree:  $WORKTREE_DIR"
[[ "$DRY_RUN" = true ]] && echo -e "  ${YELLOW}DRY RUN — no changes will be made${NC}"
echo ""

# ─── Pre-flight checks ───
if [[ -d "$WORKTREE_DIR" && -n "$BRANCH_NAME" && "$FORCE" = false ]]; then
  # Check for uncommitted changes
  if [[ -n "$(git -C "$WORKTREE_DIR" status --porcelain 2>/dev/null)" ]]; then
    fail "Worktree has uncommitted changes.\n       Commit or stash them, or use --force to discard."
  fi

  # Check for unpushed commits
  if [[ -n "$BRANCH_NAME" ]]; then
    LOCAL_SHA=$(git rev-parse --verify "refs/heads/$BRANCH_NAME" 2>/dev/null || echo "")
    REMOTE_SHA=$(git rev-parse --verify "refs/remotes/origin/$BRANCH_NAME" 2>/dev/null || echo "")
    if [[ -n "$LOCAL_SHA" && "$LOCAL_SHA" != "$REMOTE_SHA" && -n "$REMOTE_SHA" ]]; then
      warn "Branch has unpushed commits"
    elif [[ -n "$LOCAL_SHA" && -z "$REMOTE_SHA" ]]; then
      warn "Branch has never been pushed to origin"
    fi
  fi

  # Check if branch is merged into main
  if [[ -n "$BRANCH_NAME" ]]; then
    if ! git branch --merged main 2>/dev/null | grep -qE "(^|\s)${BRANCH_NAME}$"; then
      fail "Branch '$BRANCH_NAME' is not merged into main.\n       Merge first, or use --force to delete anyway."
    fi
  fi
fi

# ─── Dry run: show plan and exit ───
if [[ "$DRY_RUN" = true ]]; then
  echo "Would perform:"
  [[ -d "$WORKTREE_DIR" ]] && echo "  - Remove worktree: $WORKTREE_DIR"
  echo "  - Prune worktree references"
  [[ -n "$BRANCH_NAME" ]] && echo "  - Delete local branch: $BRANCH_NAME"
  [[ "$DELETE_REMOTE" = true && -n "$BRANCH_NAME" ]] && echo "  - Delete remote branch: origin/$BRANCH_NAME"
  echo ""
  info "Dry run complete. No changes made."
  exit 0
fi

# ─── Remove worktree ───
if [[ -d "$WORKTREE_DIR" ]]; then
  info "Removing worktree..."
  if [[ "$FORCE" = true ]]; then
    git worktree remove "$WORKTREE_DIR" --force 2>/dev/null || rm -rf "$WORKTREE_DIR"
  else
    git worktree remove "$WORKTREE_DIR" || fail "Could not remove worktree. Use --force to override."
  fi
  ok "Worktree removed"
else
  warn "Worktree directory not found: $WORKTREE_DIR"
fi

# ─── Prune worktree references ───
info "Pruning worktree references..."
git worktree prune
ok "Worktree references pruned"

# ─── Delete local branch ───
if [[ -n "$BRANCH_NAME" ]]; then
  if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    info "Deleting local branch '$BRANCH_NAME'..."
    if [[ "$FORCE" = true ]]; then
      git branch -D "$BRANCH_NAME"
    else
      git branch -d "$BRANCH_NAME"
    fi
    ok "Local branch deleted"
  else
    warn "Local branch '$BRANCH_NAME' not found"
  fi
fi

# ─── Delete remote branch ───
if [[ "$DELETE_REMOTE" = true && -n "$BRANCH_NAME" ]]; then
  if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
    info "Deleting remote branch 'origin/$BRANCH_NAME'..."
    git push origin --delete "$BRANCH_NAME" 2>/dev/null || warn "Could not delete remote branch"
    ok "Remote branch deleted"
  else
    warn "Remote branch 'origin/$BRANCH_NAME' not found"
  fi
fi

# ─── Summary ───
REMAINING=$(git worktree list | grep -c "${PROJECT_NAME}--" || true)
echo ""
echo -e "${GREEN}═══ Cleanup Complete ═══${NC}"
echo -e "  Removed:    ${PROJECT_NAME}--${FEATURE_NAME}"
[[ -n "$BRANCH_NAME" ]] && echo -e "  Branch:     $BRANCH_NAME (deleted)"
echo -e "  Remaining:  $REMAINING workstream(s)"
echo -e "${GREEN}════════════════════════${NC}"
