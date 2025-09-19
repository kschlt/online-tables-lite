#!/bin/bash

# Branch Rename Utility (PR-safe)
# Renames current branch with validation and PR support

set -e

# Path constants
AGENT_BASE="./scripts/agent"
AGENT_UTILS="$AGENT_BASE/utils"

# Configuration
PR_BASE="${PR_BASE:-main}"

# Usage function
usage() {
    echo "Usage: $0 NEW_BRANCH_NAME"
    echo "Rename current branch with validation and PR support"
    echo
    echo "Examples:"
    echo "  $0 feat/new-feature"
    echo "  $0 fix/bug-description"
    echo
    echo "💡 Get naming suggestion: $AGENT_UTILS/branch-suggest.sh"
    exit 1
}

# Check if new name provided
NEW="${1:-}"
if [ -z "$NEW" ]; then
    usage
fi

# Get current branch
CUR=$(git rev-parse --abbrev-ref HEAD)

# Validate current branch is not protected
if [ "$CUR" = "main" ] || [ "$CUR" = "production" ]; then
    echo "❌ Cannot rename protected branch: $CUR"
    exit 1
fi

# Validate new branch name
echo "🔍 Validating new branch name: $NEW"
if ! "$AGENT_UTILS/validate-branch-name.sh" "$NEW" validate >/dev/null 2>&1; then
    echo "❌ New branch name '$NEW' violates naming policy"
    "$AGENT_UTILS/validate-branch-name.sh" "$NEW" promptlet
    exit 1
fi

echo "✅ New branch name is compliant"

# Check for existing PR
echo "🔍 Checking for existing PR..."
if command -v gh >/dev/null 2>&1; then
    PR_INFO=$(gh pr list --head "$CUR" --json number,title 2>/dev/null || echo "[]")
    PR_NUMBER=$(echo "$PR_INFO" | jq -r '.[0].number // empty' 2>/dev/null || echo "")

    if [ -n "$PR_NUMBER" ]; then
        echo "🔄 Found existing PR #$PR_NUMBER - will update automatically"
        echo "📝 Renaming local branch..."
        git branch -m "$NEW"
        echo "📤 Pushing new branch name to remote..."
        git push origin -u "$NEW"
        echo "🗑️  Deleting old remote branch..."
        git push origin --delete "$CUR" 2>/dev/null || echo "⚠️  Could not delete old remote branch (may not exist)"
        echo "✅ PR #$PR_NUMBER automatically updated to track new branch name"
        echo "🔗 PR will now show changes from: $NEW"
    else
        echo "ℹ️  No existing PR found - performing simple rename"
        git branch -m "$NEW"
        if git rev-parse --verify "origin/$CUR" >/dev/null 2>&1; then
            echo "📤 Updating remote branch..."
            git push origin -u "$NEW"
            git push origin --delete "$CUR"
        fi
    fi
else
    echo "ℹ️  GitHub CLI not available - performing local rename only"
    git branch -m "$NEW"
    echo "⚠️  Manual steps required if branch was pushed:"
    echo "   1. git push origin -u $NEW"
    echo "   2. git push origin --delete $CUR"
    echo "   3. Update any existing PR to track new branch"
fi

echo "🔁 Branch renamed: $CUR → $NEW"