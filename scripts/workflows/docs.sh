#!/bin/bash

# Documentation Workflow
# Generates documentation update promptlet using git-cliff data

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" >&2
}

# Function to generate documentation update promptlet
generate_docs_promptlet() {
    local branch="$1"
    local base_ref="${2:-main}"
    
    print_color $BLUE "📚 Generating documentation update promptlet for branch: $branch"
    
    # Try to use cached git-cliff metadata first
    local cache_file=".git/commit-cache/last-commit-meta"
    local changelog_entry
    local base
    
    if [ -f "$cache_file" ]; then
        print_color $GREEN "⚡ Using cached git-cliff metadata from pre-commit hook"
        . "$cache_file"
        changelog_entry=$(echo "$CHANGELOG_ENTRY" | tr '|' '\n')
        base="$BASE"
    else
        print_color $YELLOW "🔍 No commit cache found - generating fresh git-cliff data..."
        base=$(git merge-base "$base_ref" HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)
        changelog_entry=$(git-cliff --unreleased --strip header 2>/dev/null || echo "No unreleased changes detected")
    fi
    
    if [ -z "$changelog_entry" ] || [ "$changelog_entry" = "No unreleased changes detected" ]; then
        print_color $RED "❌ No changelog content available for documentation analysis"
        return 1
    fi
    
    print_color $GREEN "✅ Retrieved changelog data for documentation analysis"
    
    # Generate documentation update promptlet
    ./scripts/git/promptlet-reader.sh documentation_update \
        diff_base="$base" \
        branch="$branch" \
        changelog_content="$(echo "$changelog_entry" | tr '\n' ' ' | sed 's/"/\\"/g')"
}

# Main function
main() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    local base_ref="${2:-main}"
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        exit 1
    fi
    
    generate_docs_promptlet "$branch" "$base_ref"
}

# Run main function with all arguments
main "$@"