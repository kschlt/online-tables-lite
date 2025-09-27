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

# Path constants
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"
CACHE_UTIL="$AGENT_BASE/utils/workflow-cache.sh"
PR_WORKFLOW="$AGENT_BASE/workflows/pr-workflow.sh"

# Source cache utilities
. "$CACHE_UTIL"

# Note: Removed source_pr_functions to prevent recursion during sourcing

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
    local workflow_origin="${3:-unknown}"

    # Parse --workflow-origin if passed as argument
    while [[ $# -gt 0 ]]; do
        case $1 in
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            *) shift ;;
        esac
    done
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi
    
    print_trace "DOCS_GEN" "Generating documentation update for branch: $branch"

    # Use centralized cache management
    local changelog_entry=""
    local base=""

    if has_valid_cache; then
        print_color $GREEN "⚡ Using cached git-cliff metadata from centralized cache"
        changelog_entry=$(get_cached_changelog)
        base=$(get_cached_base)
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

    # Quick check: Always run agent analysis for major changes, skip only for trivial updates
    if echo "$changelog_entry" | grep -qE "(refactor|implement|orchestrator|workflow.*pattern|architecture|Added.*API|Added.*component|Fixed.*UI|Added.*feature|scripts/agent)" 2>/dev/null; then
        print_color $BLUE "🎯 Major changes detected - running full agent analysis"
    elif echo "$changelog_entry" | grep -qE "^.*branch.*naming.*only|^.*validation.*only" &&
         ! echo "$changelog_entry" | grep -qE "(refactor|implement|orchestrator)" 2>/dev/null; then
        print_color $BLUE "🎯 Only minor branch naming changes detected - likely no docs updates needed"

        # Skip agent analysis and go directly to apply_docs with NO-OP expectation
        exec ./scripts/agent/workflows/docs-workflow.sh apply_docs --workflow-origin "$workflow_origin"
    else
        print_color $BLUE "🎯 Complex changes detected - running full agent analysis"
    fi

    # Discover current documentation files dynamically
    local docs_discovery_script="$AGENT_BASE/system/docs-discovery.sh"
    local current_docs=""
    if [ -f "$docs_discovery_script" ]; then
        current_docs=$($docs_discovery_script discover paths_only | tr '\n' '|' | sed 's/|$//')
        print_color $BLUE "📋 Discovered $(echo "$current_docs" | tr '|' '\n' | wc -l | tr -d ' ') documentation files"
    else
        print_color $YELLOW "⚠️  Documentation discovery script not found, using fallback"
        current_docs="README.md|CHANGELOG.md|CLAUDE.md|scripts/README.md|apps/web/DESIGN_SYSTEM.md"
    fi

    # Generate documentation update promptlet using new format with dynamic discovery
    $PROMPTLET_READER docs-wf.update \
        branch="$branch" \
        base="$base" \
        changelog="$(echo "$changelog_entry" | tr '\n' ' ' | sed 's/"/\\"/g')" \
        origin="$workflow_origin" \
        discovered_docs="$current_docs"

    print_trace "OUTPUT" "Generated documentation update promptlet"
}


# Step 2: Apply documentation changes (handles both agent updates and NO-OP cases)
apply_docs() {
    local files=""
    local workflow_origin=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --files) files="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: apply_docs [--files FILES] [--workflow-origin ORIGIN]"
                echo "Validates applied documentation changes and continues workflow"
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

        # Auto-chain to commit_docs since this is pure automation
        print_color $GREEN "✅ Auto-chaining to commit documentation changes..."
        ./scripts/agent/workflows/docs-workflow.sh commit_docs --workflow-origin "$workflow_origin"
    else
        print_color $YELLOW "⚠️  No documentation changes detected"
        print_color $GREEN "✅ Documentation workflow complete"

        # Optional chaining: If part of PR workflow, continue to push step
        if [ "$workflow_origin" = "pr-workflow" ]; then
            print_color $BLUE "🔗 Chaining back to PR workflow..."
            BRANCH=$(git rev-parse --abbrev-ref HEAD)

            # Direct chaining back to PR workflow - no agent needed
            print_color $GREEN "✅ Documentation workflow complete (no changes needed)"
            print_color $BLUE "→ Continuing to PR workflow push step"
            exec ./scripts/agent/workflows/pr-workflow.sh push_branch "$BRANCH" "$workflow_origin"
        else
            # Standalone execution - workflow is complete
            print_color $GREEN "✅ Documentation workflow complete (no changes needed)"
            print_color $BLUE "→ No documentation updates required"
        fi
    fi

    print_trace "OUTPUT" "Documentation workflow step completed"
}

# Step 3: Commit documentation changes
commit_docs() {
    local message=""
    local workflow_origin=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --message) message="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: commit_docs [--message MESSAGE] [--workflow-origin ORIGIN]"
                echo "Commits documentation changes"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    print_trace "DOCS_COMMIT" "Committing documentation changes"
    
    # Check if there are changes to commit
    if git diff --quiet HEAD; then
        print_color $YELLOW "⚠️  No changes to commit"
        print_color $GREEN "✅ Documentation workflow complete"

        # Direct completion - no agent needed for no-changes scenario
        print_color $GREEN "✅ Documentation workflow complete (no changes)"
        print_trace "OUTPUT" "Documentation workflow completed - no changes detected"
        return 0
    fi
    
    # Stage documentation files
    git add -A
    
    # Use provided message or default
    local commit_message="${message:-docs: update documentation based on recent changes}"
    
    # Commit changes
    if git commit -m "$commit_message"; then
        print_color $GREEN "✅ Documentation changes committed successfully"
        print_color $GREEN "✅ Documentation workflow complete"

        # Optional chaining: If part of PR workflow, continue to push step
        if [ "$workflow_origin" = "pr-workflow" ]; then
            print_color $BLUE "🔗 Chaining back to PR workflow..."
            BRANCH=$(git rev-parse --abbrev-ref HEAD)

            # Direct chaining back to PR workflow - no agent needed
            print_color $GREEN "✅ Documentation workflow complete - chaining to PR workflow"
            exec ./scripts/agent/workflows/pr-workflow.sh push_branch "$BRANCH" "$workflow_origin"
            return 0
        else
            # Standalone execution - workflow is complete
            print_color $GREEN "✅ Documentation workflow complete"
            print_trace "OUTPUT" "Standalone documentation workflow completed successfully"
        fi
    else
        print_color $RED "❌ Failed to commit documentation changes"
        
        # Direct error handling - no agent needed for commit failures
        print_color $RED "❌ Documentation commit failed"
        print_color $YELLOW "→ Message: '$commit_message'"
        print_color $YELLOW "→ Manual intervention required"
        print_color $BLUE "→ Check git status and resolve any issues"
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
            echo "  apply_docs [--files FILES] - Validate applied documentation changes and continue workflow"
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