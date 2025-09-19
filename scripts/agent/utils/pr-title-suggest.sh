#!/bin/bash

# PR Title Suggestion Utility
# Suggests PR title based on recent commit messages

set -e

# Default base reference
BASE_REF="${BASE_REF:-origin/main}"

# Get base commit for comparison
BASE=$(git merge-base "$BASE_REF" HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)

# Extract title from most recent commit
TITLE=$(git log --format='%s' "$BASE..HEAD" | head -1 | sed 's/[[:space:]]\+/ /g')

# Fallback if no title found
[[ -n "$TITLE" ]] || TITLE="Update: miscellaneous changes"

# Output suggested title
echo "$TITLE"