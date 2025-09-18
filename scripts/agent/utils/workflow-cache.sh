#!/bin/bash

# Workflow Cache Management
# Centralized management of git-cliff cache data to eliminate redundant reads

set -e

# Cache file location
if [ -z "$CACHE_FILE" ]; then
    readonly CACHE_FILE=".git/commit-cache/last-commit-meta"
fi

# Global variables to store cached data
CACHE_LOADED=false
CACHED_BASE=""
CACHED_BRANCH=""
CACHED_COMMIT_TIME=""
CACHED_CHANGELOG_ENTRY=""

# Load cache data once and store in variables
load_cache() {
    if [ "$CACHE_LOADED" = true ]; then
        return 0  # Already loaded
    fi

    if [ ! -f "$CACHE_FILE" ]; then
        return 1  # No cache file exists
    fi

    # Source the cache file to load variables
    . "$CACHE_FILE"

    # Store in our global variables
    CACHED_BASE="$BASE"
    CACHED_BRANCH="$BRANCH"
    CACHED_COMMIT_TIME="$COMMIT_TIME"
    CACHED_CHANGELOG_ENTRY="$CHANGELOG_ENTRY"

    CACHE_LOADED=true
    return 0
}

# Get base commit
get_cached_base() {
    if ! load_cache; then
        # Fallback to git command if no cache
        git merge-base main HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1
        return
    fi
    echo "$CACHED_BASE"
}

# Get branch name
get_cached_branch() {
    if ! load_cache; then
        # Fallback to git command if no cache
        git rev-parse --abbrev-ref HEAD 2>/dev/null
        return
    fi
    echo "$CACHED_BRANCH"
}

# Get changelog content (converts | back to newlines)
get_cached_changelog() {
    if ! load_cache; then
        # Fallback to fresh git-cliff if no cache
        git-cliff --unreleased --strip header 2>/dev/null || echo "No unreleased changes detected"
        return
    fi
    echo "$CACHED_CHANGELOG_ENTRY" | tr '|' '\n'
}

# Check if cache exists and is valid
has_valid_cache() {
    load_cache >/dev/null 2>&1
}

# Combined git operations to reduce subprocess overhead
get_branch_status() {
    # Returns: branch_name|has_uncommitted|branch_exists
    local branch=""
    local has_uncommitted="false"
    local branch_exists="false"

    # Use cache if available, otherwise git command
    if has_valid_cache; then
        branch=$(get_cached_branch)
    else
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    fi

    if [ -n "$branch" ]; then
        # Check if branch exists and has uncommitted changes in single operation
        if git rev-parse --verify "$branch" >/dev/null 2>&1; then
            branch_exists="true"
            if ! git diff --quiet HEAD 2>/dev/null; then
                has_uncommitted="true"
            fi
        fi
    fi

    echo "${branch}|${has_uncommitted}|${branch_exists}"
}

# Combined merge conflict check
check_merge_conflicts() {
    local branch="$1"
    local base_branch="${2:-main}"

    # Get base commit and check conflicts in one operation
    local base_commit=$(git merge-base "$base_branch" "$branch" 2>/dev/null || echo "")
    local conflicts_exist="false"
    local is_fast_forward="false"

    if [ -n "$base_commit" ]; then
        local base_head=$(git rev-parse "$base_branch" 2>/dev/null || echo "")
        if [ "$base_commit" = "$base_head" ]; then
            is_fast_forward="true"
        elif git merge-tree "$base_commit" "$base_branch" "$branch" 2>/dev/null | grep -q "<<<<<<< "; then
            conflicts_exist="true"
        fi
    fi

    echo "${conflicts_exist}|${is_fast_forward}|${base_commit}"
}

# Export functions for use by other scripts
export -f load_cache get_cached_base get_cached_branch get_cached_changelog has_valid_cache get_branch_status check_merge_conflicts