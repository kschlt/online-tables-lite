#!/bin/bash

# Main branch protection script for Online Tables Lite
# Prevents commits on main and provides rescue promptlets

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

# Function to generate main branch rescue promptlet
generate_rescue_promptlet() {
    local suggested_branch="$1"
    local has_changes="$2"
    
    # Build rescue instructions based on situation
    local rescue_instructions
    if [ "$has_changes" = "true" ]; then
        rescue_instructions="1. Run: git reset --soft HEAD~1  # Undo the blocked commit|2. Run: make branch-new NAME=$suggested_branch|3. Your changes are now safely staged on the new branch|4. Run: git commit  # Re-commit on the feature branch"
    else
        rescue_instructions="1. Run: make branch-new NAME=$suggested_branch|2. Start working on your feature in the new branch"
    fi
    
    # Use promptlet library for single source of truth
    ./scripts/agent/promptlets/promptlet-reader.sh main_branch_rescue \
        suggested_branch="$suggested_branch" \
        has_changes="$has_changes" \
        rescue_instructions="$rescue_instructions"
}

# Function to suggest branch name based on recent changes
suggest_branch_from_changes() {
    # Look at staged files to suggest branch type and name
    local staged_files=$(git diff --cached --name-only 2>/dev/null || true)
    local suggested_type="feat"
    local suggested_name="new-feature"
    
    if [ -n "$staged_files" ]; then
        # Analyze files to suggest type
        if echo "$staged_files" | grep -qE "(fix|bug|patch)" || \
           git diff --cached | grep -qiE "(fix|bug|patch|error)"; then
            suggested_type="fix"
            suggested_name="bug-fix"
        elif echo "$staged_files" | grep -qE "(test|spec)" || \
             git diff --cached | grep -qiE "(test|spec)"; then
            suggested_name="test-updates"
        elif echo "$staged_files" | grep -qE "(doc|readme|md)" || \
             git diff --cached | grep -qiE "(doc|documentation)"; then
            suggested_name="docs-update"
        elif echo "$staged_files" | grep -qE "(style|css|scss)" || \
             git diff --cached | grep -qiE "(style|css|ui)"; then
            suggested_name="ui-improvements"
        else
            # Default based on file patterns
            if echo "$staged_files" | grep -q "api"; then
                suggested_name="api-changes"
            elif echo "$staged_files" | grep -q "web"; then
                suggested_name="web-updates"
            else
                suggested_name="feature-updates"
            fi
        fi
    fi
    
    echo "${suggested_type}/${suggested_name}"
}

# Main protection function
protect_main() {
    local branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    
    # Check if we're on main
    if [[ "$branch_name" != "main" ]]; then
        return 0  # Not on main, protection not needed
    fi
    
    # Check if there are staged changes (indicating attempted commit)
    local has_staged_changes=false
    if ! git diff --cached --quiet 2>/dev/null; then
        has_staged_changes=true
    fi
    
    # Check if this is just a merge or other allowed operation
    if [ -f ".git/MERGE_HEAD" ]; then
        return 0  # Allow merge commits
    fi
    
    # Block the commit and provide guidance
    print_color $RED "❌ Direct commits to main branch are blocked!"
    print_color $YELLOW "🛡️  Policy: All development must happen in feature branches"
    echo
    
    local suggested_branch=$(suggest_branch_from_changes)
    
    if [ "$has_staged_changes" = true ]; then
        print_color $BLUE "💡 Rescue your work with this guided process:"
    else
        print_color $BLUE "💡 Create a feature branch to start working:"
    fi
    
    echo
    generate_rescue_promptlet "$suggested_branch" "$has_staged_changes"
    
    exit 1
}

# Run protection
protect_main "$@"