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

Create a new workstream (branch + worktree + npm install).

Arguments:
  feature-name       Name for the workstream (alphanumeric + hyphens)

Options:
  --base <branch>    Base branch (default: main)
  --prefix <type>    Branch prefix: feature|fix|refactor (default: feature)
  --no-install       Skip npm ci
  -h, --help         Show this help

Examples:
  $(basename "$0") tags
  $(basename "$0") auth-fix --prefix fix
  $(basename "$0") refactor-db --prefix refactor --base develop
EOF
  exit 0
}

# ─── Parse arguments ───
FEATURE_NAME=""
BASE_BRANCH="main"
BRANCH_PREFIX="feature"
RUN_INSTALL=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    --base)
      [[ -n "${2:-}" ]] || fail "--base requires a branch name"
      BASE_BRANCH="$2"; shift 2 ;;
    --prefix)
      [[ -n "${2:-}" ]] || fail "--prefix requires a type"
      case "$2" in
        feature|fix|refactor) BRANCH_PREFIX="$2" ;;
        *) fail "Invalid prefix '$2'. Use: feature, fix, refactor" ;;
      esac
      shift 2 ;;
    --no-install)
      RUN_INSTALL=false; shift ;;
    -*)
      fail "Unknown option: $1" ;;
    *)
      [[ -z "$FEATURE_NAME" ]] || fail "Unexpected argument: $1"
      FEATURE_NAME="$1"; shift ;;
  esac
done

[[ -n "$FEATURE_NAME" ]] || fail "Feature name is required. Run with --help for usage."

# ─── Validate feature name ───
if [[ ! "$FEATURE_NAME" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
  fail "Invalid feature name '$FEATURE_NAME'. Use alphanumeric characters and hyphens only."
fi

BRANCH_NAME="${BRANCH_PREFIX}/${FEATURE_NAME}"
WORKTREE_DIR="${PARENT_DIR}/${PROJECT_NAME}--${FEATURE_NAME}"

echo ""
echo -e "${CYAN}═══ Create Workstream ═══${NC}"
echo -e "  Feature:   $FEATURE_NAME"
echo -e "  Branch:    $BRANCH_NAME"
echo -e "  Worktree:  $WORKTREE_DIR"
echo -e "  Base:      $BASE_BRANCH"
echo ""

# ─── Pre-flight checks ───
cd "$PROJECT_ROOT"

# Check if worktree directory already exists
if [[ -d "$WORKTREE_DIR" ]]; then
  fail "Directory already exists: $WORKTREE_DIR\n       Use 'workstream-cleanup.sh $FEATURE_NAME --force' to remove it first."
fi

# Check if local branch already exists
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  fail "Local branch '$BRANCH_NAME' already exists.\n       Delete it with 'git branch -D $BRANCH_NAME' or choose a different name."
fi

# ─── Fetch latest ───
info "Fetching latest from origin..."
git fetch origin --quiet 2>/dev/null || warn "Could not fetch from origin (offline?)"

# Verify base branch exists
if ! git show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH" && \
   ! git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
  fail "Base branch '$BASE_BRANCH' not found locally or on origin."
fi

# Check if remote branch exists (offer to reuse)
if git show-ref --verify --quiet "refs/remotes/origin/$BRANCH_NAME"; then
  warn "Remote branch 'origin/$BRANCH_NAME' already exists."
  info "Creating worktree from existing remote branch..."
  git worktree add "$WORKTREE_DIR" -b "$BRANCH_NAME" "origin/$BRANCH_NAME"
else
  # ─── Create branch + worktree ───
  info "Creating branch '$BRANCH_NAME' from 'origin/$BASE_BRANCH'..."
  BASE_REF="origin/$BASE_BRANCH"
  if ! git show-ref --verify --quiet "refs/remotes/origin/$BASE_BRANCH"; then
    BASE_REF="$BASE_BRANCH"
    warn "Using local '$BASE_BRANCH' (no remote tracking branch found)"
  fi
  git worktree add -b "$BRANCH_NAME" "$WORKTREE_DIR" "$BASE_REF"
fi
ok "Worktree created at $WORKTREE_DIR"

# ─── Copy local settings ───
SETTINGS_LOCAL="$PROJECT_ROOT/.claude/settings.local.json"
if [[ -f "$SETTINGS_LOCAL" ]]; then
  mkdir -p "$WORKTREE_DIR/.claude"
  cp "$SETTINGS_LOCAL" "$WORKTREE_DIR/.claude/settings.local.json"
  ok "Copied .claude/settings.local.json"
fi

# ─── Install dependencies ───
if [[ "$RUN_INSTALL" = true ]]; then
  info "Installing dependencies..."
  cd "$WORKTREE_DIR"
  if npm ci --silent 2>/dev/null; then
    ok "Dependencies installed (npm ci)"
  elif npm install --silent 2>/dev/null; then
    ok "Dependencies installed (npm install fallback)"
  else
    warn "npm install failed — you may need to install dependencies manually"
  fi
fi

# ─── Summary ───
echo ""
echo -e "${GREEN}═══ Workstream Ready ═══${NC}"
echo -e "  Directory:  $WORKTREE_DIR"
echo -e "  Branch:     $BRANCH_NAME"
echo ""
echo -e "  Next steps:"
echo -e "    cd $WORKTREE_DIR"
echo -e "    claude"
echo -e "${GREEN}════════════════════════${NC}"
