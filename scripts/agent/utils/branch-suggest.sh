#!/bin/bash

# Branch Name Suggestion Utility
# Suggests better branch name based on recent commits

set -e

# Path constants
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"

# Default base reference
BASE_REF="${BASE_REF:-origin/main}"

# Get current branch and commit info
BRANCH=$(git rev-parse --abbrev-ref HEAD)
BASE=$(git merge-base "$BASE_REF" HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)
TITLE=$(git log --format='%s' "$BASE..HEAD" | head -1 | tr '[:upper:]' '[:lower:]')

# Fallback if no title found
[[ -n "$TITLE" ]] || TITLE="update miscellaneous"

# Create safe branch name suggestion
SAFE=$(printf "%s" "$TITLE" | sed 's/[^a-z0-9]+/-/g; s/ /-/g; s/--\+/-/g; s/^-//; s/-$//')
SUGGESTED=$(printf "feature/%s" "$SAFE" | cut -c1-70)

# Output current and suggested names
echo "Current: $BRANCH"
echo "Suggested: $SUGGESTED"
echo "To rename: ./scripts/agent/utils/branch-rename.sh $SUGGESTED"
echo

# Generate evaluation promptlet
$PROMPTLET_READER branch_evaluation \
    current_branch="$BRANCH" \
    suggested_name="$SUGGESTED" \
    changes_context="Recent commits and file changes"