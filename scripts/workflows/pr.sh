#!/bin/bash

# PR Workflow
# Generates PR description promptlet using git-cliff data

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

# Function to generate PR description promptlet
generate_pr_description_promptlet() {
    local branch="$1"
    
    print_color $BLUE "🔍 Generating PR description promptlet for branch: $branch"
    
    # Use git-cliff as the solid data foundation
    local changelog_content
    changelog_content=$(git-cliff --unreleased --strip header 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$changelog_content" ]; then
        print_color $RED "❌ No changelog content generated for branch: $branch"
        return 1
    fi
    
    print_color $GREEN "✅ Retrieved changelog data from git-cliff"
    
    # Pass git-cliff data to promptlet template for processing
    ./scripts/git/promptlet-reader.sh pr_description \
        branch_name="$branch" \
        base_branch="main" \
        changelog_content="$(echo "$changelog_content" | sed 's/"/\\"/g' | tr '\n' '|')"
}

# Main function
main() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        exit 1
    fi
    
    generate_pr_description_promptlet "$branch"
}

# Run main function with all arguments
main "$@"