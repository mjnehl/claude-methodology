#!/usr/bin/env bash
set -euo pipefail

# ─── Resolve project root from script location ───
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"

# ─── Colors ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Gather worktree info ───
cd "$PROJECT_ROOT"

MAIN_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
MAIN_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Collect workstream worktrees (matching PROJECT_NAME-- pattern)
WORKTREES=()
while IFS= read -r line; do
  [[ "$line" == *"${PROJECT_NAME}--"* ]] && WORKTREES+=("$line")
done < <(git worktree list)

echo ""
echo -e "${BOLD}Active Workstreams (${PROJECT_NAME})${NC}"
echo "=================================="

if [[ ${#WORKTREES[@]} -eq 0 ]]; then
  echo "  No active workstreams."
  echo ""
  echo -e "Main: ${PROJECT_ROOT} (${MAIN_BRANCH} @ ${MAIN_SHA})"
  echo -e "Total: 0 workstreams"
  exit 0
fi

# ─── Table header ───
printf "  ${BOLD}%-18s %-26s %-9s %-8s %-6s %s${NC}\n" "Name" "Branch" "Status" "Merged" "Clean" "Directory"

READY_COUNT=0

for wt in "${WORKTREES[@]}"; do
  WT_DIR=$(echo "$wt" | awk '{print $1}')
  WT_SHA=$(echo "$wt" | awk '{print $2}')
  WT_BRANCH_RAW=$(echo "$wt" | sed 's/.*\[//' | sed 's/\]//')

  # Extract feature name from directory
  NAME="${WT_DIR##*${PROJECT_NAME}--}"

  # Branch name
  BRANCH="$WT_BRANCH_RAW"

  # Status: check if directory exists and is accessible
  if [[ -d "$WT_DIR" ]]; then
    STATUS="active"
  else
    STATUS="missing"
  fi

  # Merged: check if branch is merged into main
  MERGED="no"
  if git branch --merged main 2>/dev/null | grep -qE "(^|\s)${WT_BRANCH_RAW}$"; then
    MERGED="yes"
  fi

  # Clean: check for uncommitted changes
  CLEAN="yes"
  if [[ -d "$WT_DIR" ]]; then
    if [[ -n "$(git -C "$WT_DIR" status --porcelain 2>/dev/null)" ]]; then
      CLEAN="no"
    fi
  fi

  # Color coding
  MERGED_COLOR="$RED"
  [[ "$MERGED" = "yes" ]] && MERGED_COLOR="$GREEN"

  CLEAN_COLOR="$RED"
  [[ "$CLEAN" = "yes" ]] && CLEAN_COLOR="$GREEN"

  STATUS_COLOR="$GREEN"
  [[ "$STATUS" = "missing" ]] && STATUS_COLOR="$RED"

  printf "  %-18s %-26s ${STATUS_COLOR}%-9s${NC} ${MERGED_COLOR}%-8s${NC} ${CLEAN_COLOR}%-6s${NC} %s\n" \
    "$NAME" "$BRANCH" "$STATUS" "$MERGED" "$CLEAN" "$WT_DIR"

  # Count workstreams ready to clean up (merged + clean)
  if [[ "$MERGED" = "yes" && "$CLEAN" = "yes" ]]; then
    ((READY_COUNT++))
  fi
done

echo ""
echo -e "Main: ${PROJECT_ROOT} (${MAIN_BRANCH} @ ${MAIN_SHA})"

TOTAL=${#WORKTREES[@]}
if [[ $READY_COUNT -gt 0 ]]; then
  echo -e "Total: ${TOTAL} workstream(s) (${GREEN}${READY_COUNT} ready to clean up${NC})"
else
  echo -e "Total: ${TOTAL} workstream(s)"
fi
