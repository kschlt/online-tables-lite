#!/bin/bash

# PR Metadata Aggregation Script for Online Tables Lite
# Aggregates per-commit metadata into rich PR descriptions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Removed: aggregate_branch_metadata() - replaced by git-cliff direct usage

# Function to generate AI-enhanced PR description using git-cliff as foundation
generate_pr_description_promptlet() {
    local branch="$1"
    
    # Use git-cliff as the solid data foundation - only current branch changes
    local changelog_content
    changelog_content=$(git-cliff main..HEAD --strip header 2>/dev/null)
    
    if [ $? -ne 0 ] || [ -z "$changelog_content" ]; then
        echo "No changelog content generated for branch: $branch" >&2
        return 1
    fi
    
    # Pass git-cliff data to AI promptlet for enriched reasoning and formatting
    ./scripts/agent/promptlets/promptlet-reader.sh pr_description \
        branch_name="$branch" \
        base_branch="main" \
        changelog_content="$(echo "$changelog_content" | sed 's/"/\\"/g' | tr '\n' '|')"
}
# Removed: generate_basic_pr_description() - replaced by AI-enhanced promptlet workflow

# Main function
main() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    local mode="${2:-description}"  # description|metadata|json|promptlet
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        exit 1
    fi
    
    case "$mode" in
        "promptlet")
            generate_pr_description_promptlet "$branch"
            ;;
        *)
            print_color $RED "❌ Invalid mode: $mode (only 'promptlet' mode supported)"
            echo "Usage: $0 [branch_name] promptlet"
            echo "Note: Old metadata/description/json modes removed - use git-cliff based promptlet mode"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"