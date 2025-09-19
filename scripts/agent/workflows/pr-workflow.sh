#!/bin/bash

# PR Workflow - Orchestrator-based pull request creation (2B Pattern)
#
# ARCHITECTURE:
#   Orchestrator coordinates 10 focused functions following 2B diagram flow
#   Each function handles single responsibility with clean separation of concerns
#   Agent returns to next logical step in workflow sequence, not back to makefile
#
# PING-PONG PATTERN:
#   Automation → Promptlet → Agent → Next Automation Function (following diagram)
#
# FUNCTIONS (Separation of Concerns):
#   pr_workflow_orchestrator - Entry point, coordinates entire flow
#   validate_branch - Protected branch check only
#   check_conflicts - Merge conflict detection only
#   check_commits - Commits ahead validation only
#   check_uncommitted - Uncommitted changes detection only
#   run_docs_workflow - Documentation workflow execution only
#   push_branch - Branch pushing with pre-push hook only
#   generate_pr_body - PR description promptlet generation only
#   create_pr - GitHub PR creation only
#   finalize_workflow - Completion handling only

set -e

# Path constants
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"
CACHE_UTIL="$AGENT_BASE/utils/workflow-cache.sh"
DOCS_WORKFLOW="$AGENT_BASE/workflows/docs-workflow.sh"

# Source cache utilities
. "$CACHE_UTIL"

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

# Main Orchestrator - Entry point from makefile
pr_workflow_orchestrator() {
    local branch=""
    local workflow_origin="pr-workflow"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --branch) branch="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: pr_workflow_orchestrator [--branch BRANCH] [--workflow-origin ORIGIN]"
                echo "Main orchestrator for PR workflow following 2B pattern"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done

    # Auto-detect branch if not provided
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    fi

    print_color $BLUE "🚀 Starting PR workflow orchestrator"
    print_color $BLUE "🌿 Current branch: $branch"
    print_trace "ORCHESTRATOR" "Starting validation chain"

    # Start the workflow chain - follows 2B diagram flow
    validate_branch "$branch" "$workflow_origin"
}

# Function 1: Protected branch validation (CheckBranch in 2B)
validate_branch() {
    local branch="$1"
    local workflow_origin="$2"

    print_trace "VALIDATE_BRANCH" "Checking if branch is protected: $branch"

    if [ "$branch" = "main" ] || [ "$branch" = "production" ]; then
        print_color $RED "❌ STOP: Protected branch detected"
        print_color $RED "Terminal: Cannot create PR from main/production"
        print_color $RED "USER ACTION REQUIRED"
        print_color $BLUE "💡 Create a feature branch first: make branch-new NAME=feat/your-feature"

        # This is a terminal condition per 2B diagram - no promptlet, user must act
        return 1
    fi

    print_color $GREEN "✅ Branch validation passed"
    print_trace "VALIDATE_BRANCH" "Proceeding to conflict check"

    # Success: proceed to next step in workflow
    check_conflicts "$branch" "$workflow_origin"
}

# Function 2: Merge conflict detection (CheckConflicts in 2B)
check_conflicts() {
    local branch="$1"
    local workflow_origin="$2"
    local base_branch="main"

    print_trace "CHECK_CONFLICTS" "Checking for merge conflicts with $base_branch"

    # Use cached conflict check
    local conflict_status=$(check_merge_conflicts "$branch" "$base_branch")
    local conflicts_exist=$(echo "$conflict_status" | cut -d'|' -f1)
    local is_fast_forward=$(echo "$conflict_status" | cut -d'|' -f2)

    if [ "$conflicts_exist" = "true" ]; then
        print_color $YELLOW "⚠️ STOP: Merge conflicts detected"
        print_color $YELLOW "Terminal: Rebase required before PR"
        print_color $YELLOW "USER ACTION REQUIRED"
        print_color $BLUE "💡 Resolve with: git rebase main, then retry: make pr-workflow"

        # This is a terminal condition per 2B diagram - no promptlet, user must act
        return 1
    fi

    if [ "$is_fast_forward" = "true" ]; then
        print_color $GREEN "✅ Fast-forward merge - no conflicts possible"
    else
        print_color $GREEN "✅ No merge conflicts detected"
    fi

    print_trace "CHECK_CONFLICTS" "Proceeding to commits check"

    # Success: proceed to next step in workflow
    check_commits "$branch" "$workflow_origin"
}

# Function 3: Commits ahead validation (CheckCommits in 2B)
check_commits() {
    local branch="$1"
    local workflow_origin="$2"
    local base_branch="main"

    print_trace "CHECK_COMMITS" "Checking commits ahead of $base_branch"

    # Count commits ahead of base
    local commits_ahead=$(git rev-list --count "$base_branch..$branch" 2>/dev/null || echo "0")

    if [ "$commits_ahead" -eq 0 ]; then
        print_color $BLUE "ℹ️ STOP: No changes to create PR"
        print_color $BLUE "Terminal: 0 commits ahead of main"
        print_color $BLUE "WORKFLOW COMPLETE"
        return 0
    fi

    print_color $GREEN "✅ Found $commits_ahead commits ahead of $base_branch"
    print_trace "CHECK_COMMITS" "Proceeding to uncommitted changes check"

    # Success: proceed to next step in workflow
    check_uncommitted "$branch" "$workflow_origin"
}

# Function 4: Uncommitted changes detection (CheckUncommitted in 2B)
check_uncommitted() {
    local branch="$1"
    local workflow_origin="$2"

    print_trace "CHECK_UNCOMMITTED" "Checking for uncommitted changes"

    # Use cached branch status check
    local branch_status=$(get_branch_status)
    local has_uncommitted=$(echo "$branch_status" | cut -d'|' -f2)

    if [ "$has_uncommitted" = "true" ]; then
        print_color $YELLOW "⚠️ Uncommitted changes detected"
        print_color $YELLOW "Terminal: Commit changes first"

        # Generate promptlet for agent to commit changes (UncommittedPromptlet in 2B)
        $PROMPTLET_READER uncommitted_changes \
            branch="$branch" \
            workflow_origin="$workflow_origin" \
            next_step="./scripts/agent/workflows/pr-workflow.sh run_docs_workflow $branch $workflow_origin"
        return 0
    fi

    print_color $GREEN "✅ No uncommitted changes detected"
    print_trace "CHECK_UNCOMMITTED" "Proceeding to documentation workflow"

    # Success: proceed to next step in workflow
    run_docs_workflow "$branch" "$workflow_origin"
}

# Function 5: Documentation workflow execution (DocsWorkflow in 2B)
run_docs_workflow() {
    local branch="$1"
    local workflow_origin="$2"

    print_trace "RUN_DOCS_WORKFLOW" "Starting documentation workflow"
    print_color $BLUE "📚 Running documentation workflow..."

    # Call docs workflow with proper return path
    $DOCS_WORKFLOW generate_docs "$branch" "main" --workflow-origin "$workflow_origin"

    # Note: docs-workflow.sh will handle its own completion and call push_branch
    # This function completes here as docs workflow manages its own flow
}

# Function 6: Branch pushing with pre-push hook (PushBranch in 2B)
push_branch() {
    local branch="$1"
    local workflow_origin="$2"

    print_trace "PUSH_BRANCH" "Pushing branch to origin"

    # Auto-detect branch if not provided
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    fi

    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi

    print_color $BLUE "📤 Pushing $branch to origin..."

    if git push -u origin "$branch"; then
        print_color $GREEN "✅ Branch pushed successfully"
        print_trace "PUSH_BRANCH" "Pre-push hook executed, proceeding to PR body generation"

        # Success: proceed to next step in workflow
        generate_pr_body "$branch" "$workflow_origin"
    else
        print_color $RED "❌ Failed to push branch"
        return 1
    fi
}

# Function 7: PR description promptlet generation (GeneratePRBody in 2B)
generate_pr_body() {
    local branch="$1"
    local workflow_origin="$2"

    print_trace "GENERATE_PR_BODY" "Generating PR description for branch: $branch"

    # Use centralized cache management for changelog data
    local changelog_entry=""
    local base=""

    if has_valid_cache; then
        print_color $GREEN "⚡ Using cached git-cliff metadata"
        changelog_entry=$(get_cached_changelog)
        base=$(get_cached_base)
    else
        print_color $YELLOW "🔍 Generating fresh git-cliff data..."
        base=$(git merge-base main HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)
        changelog_entry=$(git-cliff --unreleased --strip header 2>/dev/null || echo "No unreleased changes detected")
    fi

    if [ -z "$changelog_entry" ] || [ "$changelog_entry" = "No unreleased changes detected" ]; then
        print_color $RED "❌ No changelog content available for PR description"
        return 1
    fi

    print_color $GREEN "✅ Retrieved changelog data for PR description"

    # Generate PR description promptlet (PRBodyPromptlet in 2B)
    $PROMPTLET_READER pr_description \
        branch_name="$branch" \
        base_branch="main" \
        diff_base="$base" \
        changelog_content="$(echo "$changelog_entry" | tr '\n' ' ' | sed 's/"/\\"/g')" \
        workflow_origin="$workflow_origin" \
        next_step="./scripts/agent/workflows/pr-workflow.sh create_pr $branch $workflow_origin"

    print_trace "GENERATE_PR_BODY" "Generated PR description promptlet for agent processing"
}

# Function 8: GitHub PR creation (CreatePR in 2B)
create_pr() {
    local branch="$1"
    local workflow_origin="$2"
    local title="$3"
    local body="$4"

    print_trace "CREATE_PR" "Creating GitHub PR for branch: $branch"

    # Auto-detect branch if not provided
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    fi

    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi

    # Push branch if not already pushed
    if ! git ls-remote --heads origin "$branch" | grep -q "$branch"; then
        print_color $BLUE "📤 Pushing branch to remote..."
        git push -u origin "$branch"
    fi

    # Check if PR already exists for this branch
    local existing_pr=$(gh pr list --head "$branch" --json number,url --jq '.[0] | select(.number) | .url' 2>/dev/null || echo "")
    local pr_url=""

    if [ -n "$existing_pr" ]; then
        print_color $BLUE "🔄 Updating existing PR: $existing_pr"
        local pr_number=$(echo "$existing_pr" | grep -o '[0-9]\+$')

        # Update existing PR with new title and body if provided
        if [ -n "$title" ] && [ -n "$body" ]; then
            gh pr edit "$pr_number" --title "$title" --body "$body"
            print_color $GREEN "✅ PR updated successfully: $existing_pr"
        else
            print_color $GREEN "✅ PR exists: $existing_pr"
        fi
        pr_url="$existing_pr"
    else
        # Create new PR using gh CLI
        if [ -n "$title" ] && [ -n "$body" ]; then
            pr_url=$(gh pr create --title "$title" --body "$body" 2>&1 | grep -o 'https://github.com/[^[:space:]]*' || echo "")
        else
            pr_url=$(gh pr create --fill 2>&1 | grep -o 'https://github.com/[^[:space:]]*' || echo "")
        fi

        if [ -n "$pr_url" ]; then
            print_color $GREEN "✅ PR created successfully: $pr_url"
        fi
    fi

    if [ -n "$pr_url" ]; then
        print_trace "CREATE_PR" "PR created/updated, proceeding to finalization"

        # Success: proceed to final step in workflow
        finalize_workflow "$branch" "$pr_url" "$workflow_origin"
    else
        print_color $RED "❌ Failed to create PR"
        return 1
    fi
}

# Function 9: Completion handling (FinalizePR/CheckCI in 2B)
finalize_workflow() {
    local branch="$1"
    local pr_url="$2"
    local workflow_origin="$3"

    print_trace "FINALIZE_WORKFLOW" "Starting workflow finalization"

    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: --branch parameter is required"
        return 1
    fi

    # Check CI/CD status if PR URL provided
    local ci_status="unknown"
    local ci_checks_passing=false

    if [ -n "$pr_url" ]; then
        print_trace "FINALIZE_WORKFLOW" "Checking CI/CD status for PR: $pr_url"
        local pr_number=$(echo "$pr_url" | grep -o '[0-9]\+$' || echo "")

        if [ -n "$pr_number" ] && command -v gh >/dev/null 2>&1; then
            local pr_status=$(gh pr view "$pr_number" --json state --jq '.state' 2>/dev/null || echo "unknown")
            ci_status="$pr_status"

            if [ "$pr_status" = "OPEN" ]; then
                ci_checks_passing=true
            fi
        fi
    fi

    print_color $GREEN "✅ Workflow Complete"
    print_color $GREEN "🔗 PR URL: $pr_url"
    print_color $GREEN "🔍 CI Status: $ci_status"

    print_trace "FINALIZE_WORKFLOW" "PR workflow completed successfully"

    return 0
}

# Main function dispatcher
main() {
    local function_name="$1"
    shift

    case "$function_name" in
        pr_workflow_orchestrator) pr_workflow_orchestrator "$@" ;;
        validate_branch) validate_branch "$@" ;;
        check_conflicts) check_conflicts "$@" ;;
        check_commits) check_commits "$@" ;;
        check_uncommitted) check_uncommitted "$@" ;;
        run_docs_workflow) run_docs_workflow "$@" ;;
        push_branch) push_branch "$@" ;;
        generate_pr_body) generate_pr_body "$@" ;;
        create_pr) create_pr "$@" ;;
        finalize_workflow) finalize_workflow "$@" ;;
        -h|--help|help)
            echo "PR Workflow Functions (2B Pattern):"
            echo "  pr_workflow_orchestrator [--branch BRANCH] [--workflow-origin ORIGIN] - Main entry point"
            echo "  validate_branch BRANCH WORKFLOW_ORIGIN - Protected branch check"
            echo "  check_conflicts BRANCH WORKFLOW_ORIGIN - Merge conflict detection"
            echo "  check_commits BRANCH WORKFLOW_ORIGIN - Commits ahead validation"
            echo "  check_uncommitted BRANCH WORKFLOW_ORIGIN - Uncommitted changes detection"
            echo "  run_docs_workflow BRANCH WORKFLOW_ORIGIN - Documentation workflow execution"
            echo "  push_branch BRANCH WORKFLOW_ORIGIN - Branch pushing with pre-push hook"
            echo "  generate_pr_body BRANCH WORKFLOW_ORIGIN - PR description promptlet generation"
            echo "  create_pr BRANCH WORKFLOW_ORIGIN [TITLE] [BODY] - GitHub PR creation"
            echo "  finalize_workflow BRANCH PR_URL WORKFLOW_ORIGIN - Completion handling"
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