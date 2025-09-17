#!/bin/bash

# Documentation Workflow - Complete documentation update chain
# Contains all functions needed for documentation updates and maintenance
# 
# PING-PONG CHAIN:
#   make docs-update → generate_docs → promptlet → agent → apply_docs
#   agent → commit_docs → promptlet → agent → [complete]
# 
# FUNCTIONS:
#   generate_docs [BRANCH] [BASE_REF] - Step 1: Generate documentation update promptlet
#   apply_docs [--files FILES] - Step 2: Apply documentation changes
#   commit_docs [--message MESSAGE] - Step 3: Commit documentation changes

set -e

# Colors for output and traceability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}" >&2
}

print_trace() {
    local step=$1
    local message=$2
    echo -e "${PURPLE}🔍 TRACE [$step]: ${message}${NC}" >&2
}

# Step 1: Generate documentation update promptlet using git-cliff data
generate_docs() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    local base_ref="${2:-main}"
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi
    
    print_trace "DOCS_GEN" "Generating documentation update for branch: $branch"
    
    # Try to use cached git-cliff metadata first
    local cache_file=".git/commit-cache/last-commit-meta"
    local changelog_entry=""
    local base=""
    
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
    ./scripts/agent/promptlets/promptlet-reader.sh documentation_update \
        diff_base="$base" \
        branch="$branch" \
        changelog_content="$(echo "$changelog_entry" | tr '\n' ' ' | sed 's/"/\\"/g')" \
        next_step="./scripts/agent/workflows/docs-workflow.sh apply_docs"
    
    print_trace "OUTPUT" "Generated documentation update promptlet"
}

# Step 2: Apply documentation changes (placeholder for agent-driven updates)
apply_docs() {
    local files=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --files) files="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: apply_docs [--files FILES]"
                echo "Validates applied documentation changes"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    print_trace "DOCS_APPLY" "Validating applied documentation changes"
    
    # Check if there are any documentation files that were modified
    local modified_docs=$(git diff --name-only HEAD | grep -E '\.(md|rst|txt)$' || echo "")
    
    if [ -n "$modified_docs" ]; then
        print_color $GREEN "✅ Documentation changes detected:"
        echo "$modified_docs" | while read -r file; do
            print_color $BLUE "  📝 $file"
        done
        
        # Generate commit promptlet
        ./scripts/agent/promptlets/promptlet-reader.sh documentation_commit \
            modified_files="$(echo "$modified_docs" | tr '\n' '|')" \
            next_step="./scripts/agent/workflows/docs-workflow.sh commit_docs"
    else
        print_color $YELLOW "⚠️  No documentation changes detected"
        
        # Generate no-op promptlet
        ./scripts/agent/promptlets/promptlet-reader.sh documentation_no_changes \
            next_step="WORKFLOW_COMPLETE"
    fi
    
    print_trace "OUTPUT" "Generated documentation validation promptlet"
}

# Step 3: Commit documentation changes
commit_docs() {
    local message=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --message) message="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: commit_docs [--message MESSAGE]"
                echo "Commits documentation changes"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    print_trace "DOCS_COMMIT" "Committing documentation changes"
    
    # Check if there are changes to commit
    if git diff --quiet HEAD; then
        print_color $YELLOW "⚠️  No changes to commit"
        
        ./scripts/agent/promptlets/promptlet-reader.sh workflow_complete \
            status="no_changes" \
            next_step="WORKFLOW_COMPLETE"
        
        print_trace "OUTPUT" "Generated no-changes completion promptlet"
        return 0
    fi
    
    # Stage documentation files
    git add -A
    
    # Use provided message or default
    local commit_message="${message:-docs: update documentation based on recent changes}"
    
    # Commit changes
    if git commit -m "$commit_message"; then
        print_color $GREEN "✅ Documentation changes committed successfully"
        
        ./scripts/agent/promptlets/promptlet-reader.sh workflow_complete \
            status="success" \
            commit_message="$commit_message" \
            next_step="WORKFLOW_COMPLETE"
    else
        print_color $RED "❌ Failed to commit documentation changes"
        
        ./scripts/agent/promptlets/promptlet-reader.sh workflow_error \
            error="commit_failed" \
            next_step="MANUAL_INTERVENTION_REQUIRED"
    fi
    
    print_trace "OUTPUT" "Generated commit completion promptlet"
}

# Main function dispatcher
main() {
    local function_name="$1"
    shift
    
    case "$function_name" in
        generate_docs) generate_docs "$@" ;;
        apply_docs) apply_docs "$@" ;;
        commit_docs) commit_docs "$@" ;;
        -h|--help|help)
            echo "Documentation Workflow Functions:"
            echo "  generate_docs [BRANCH] [BASE_REF] - Generate documentation update promptlet"
            echo "  apply_docs [--files FILES] - Validate applied documentation changes"
            echo "  commit_docs [--message MESSAGE] - Commit documentation changes"
            ;;
        *)
            echo "Unknown function: $function_name" >&2
            echo "Use --help to see available functions" >&2
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"