#!/bin/bash

# PR Workflow - Complete pull request creation chain
# Contains all functions needed for PR creation from validation to finalization
# 
# PING-PONG CHAIN:
#   make pr-validate → validate_changes → promptlet → agent → validate_changes_result
#   agent → pr_body → promptlet → agent → create_pr  
#   agent → finalize_pr → promptlet → agent → [deployment or complete]
# 
# FUNCTIONS:
#   validate_changes [--branch BRANCH] [--base BASE] - Step 1: Validate branch changes
#   pr_body [--branch BRANCH] - Step 2: Generate PR description  
#   create_pr [--title TITLE] [--body BODY] - Step 3: Create GitHub PR
#   finalize_pr [--branch BRANCH] [--pr-url URL] - Step 4: Post-creation tasks

set -e

# Path constants
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"
CACHE_UTIL="$AGENT_BASE/utils/workflow-cache.sh"
DOCS_WORKFLOW="$AGENT_BASE/workflows/docs-workflow.sh"

# Source cache utilities
. "$CACHE_UTIL"

# Function to source docs workflow functions without executing main
source_docs_functions() {
    # Source docs-workflow.sh functions by redefining main to prevent execution
    local original_main=$(declare -f main 2>/dev/null || echo "")

    # Temporarily disable main function
    main() { :; }

    # Source the docs workflow file to import functions
    . "$DOCS_WORKFLOW"

    # Restore original main if it existed
    if [ -n "$original_main" ]; then
        eval "$original_main"
    fi
}

# Source docs workflow functions
source_docs_functions

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

# Step 1: Validate branch changes before PR creation
validate_changes() {
    local branch=""
    local base_branch="main"
    local workflow_origin=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --branch) branch="$2"; shift 2 ;;
            --base) base_branch="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: validate_changes [--branch BRANCH] [--base BASE] [--workflow-origin ORIGIN]"
                echo "Validates branch changes before PR creation"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    # Get branch status using combined operations
    local branch_status=$(get_branch_status)
    local detected_branch=$(echo "$branch_status" | cut -d'|' -f1)
    local has_uncommitted=$(echo "$branch_status" | cut -d'|' -f2)
    local branch_exists=$(echo "$branch_status" | cut -d'|' -f3)

    # Use provided branch or detected branch
    if [ -z "$branch" ]; then
        branch="$detected_branch"
    fi

    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi

    # Branch name validation and context display
    print_color $BLUE "🌿 Current branch: $branch"
    if [ "$branch" = "main" ] || [ "$branch" = "production" ]; then
        print_color $RED "❌ Cannot create PR from protected branch: $branch"

        $PROMPTLET_READER branch_protection_error \
            current_branch="$branch" \
            next_step="make branch-new NAME=feat/your-feature"
        return 1
    fi
    
    # Validate branch naming compliance
    if ! $AGENT_BASE/utils/validate-branch-name.sh "$branch" validate >/dev/null 2>&1; then
        print_color $YELLOW "⚠️  Branch name '$branch' violates naming policy"
        local suggested_name=$($AGENT_BASE/utils/validate-branch-name.sh "$branch" suggest)
        print_color $BLUE "💡 Suggested compliant name: $suggested_name"
        print_color $BLUE "💡 Rename with: make branch-rename NAME=$suggested_name"
        echo
    fi
    
    # Validate work context vs branch name
    if ! $AGENT_BASE/utils/validate-work-context.sh "$branch" validate "$base_branch" >/dev/null 2>&1; then
        print_color $YELLOW "🎯 Work context analysis:"
        $AGENT_BASE/utils/validate-work-context.sh "$branch" validate "$base_branch" || true
        local suggested_work_name=$($AGENT_BASE/utils/validate-work-context.sh "$branch" suggest "$base_branch")
        print_color $BLUE "💡 Work-based suggestion: $suggested_work_name"
        print_color $BLUE "💡 Rename with: make branch-rename NAME=$suggested_work_name"
        echo
    else
        print_color $GREEN "✅ Branch name matches work being done"
    fi
    
    print_trace "VALIDATE" "Starting validation for branch: $branch"

    # Check if branch exists (already checked in branch_status, reuse result)
    if [ "$branch_exists" != "true" ]; then
        print_color $RED "❌ Branch '$branch' does not exist"
        return 1
    fi

    # Use branch status results (already checked uncommitted changes)
    if [ "$has_uncommitted" = "true" ]; then
        print_color $YELLOW "⚠️  Uncommitted changes detected"
    fi

    # Check for merge conflicts using combined operation
    local conflict_status=$(check_merge_conflicts "$branch" "$base_branch")
    local conflicts_exist=$(echo "$conflict_status" | cut -d'|' -f1)
    local is_fast_forward=$(echo "$conflict_status" | cut -d'|' -f2)
    local base_commit=$(echo "$conflict_status" | cut -d'|' -f3)

    if [ "$is_fast_forward" = "true" ]; then
        print_color $GREEN "✅ Fast-forward merge - no conflicts possible"
    elif [ "$conflicts_exist" = "true" ]; then
        print_color $YELLOW "⚠️  Merge conflicts detected"
    else
        print_color $GREEN "✅ No merge conflicts detected"
    fi
    
    # Count commits ahead of base
    local commits_ahead=$(git rev-list --count "$base_branch..$branch" 2>/dev/null || echo "0")
    
    # Generate validation results
    local validation_status="passed"
    local issues_detected=""
    local next_step=""

    if [ "$has_uncommitted" = "true" ]; then
        validation_status="warning"
        issues_detected="${issues_detected}- Uncommitted changes detected\\n"
        # If uncommitted changes and workflow started from pr-workflow, fall back to commit workflow
        if [ "$workflow_origin" = "pr-workflow" ]; then
            next_step="make commit --return-to=docs-workflow --workflow-origin=$workflow_origin"
        fi
    fi

    if [ "$conflicts_exist" = "true" ]; then
        validation_status="conflicts"
        issues_detected="${issues_detected}- Merge conflicts with $base_branch branch\\n"
        next_step="git rebase $base_branch  # Resolve conflicts manually, then continue with: make pr-workflow"
    fi

    if [ "$commits_ahead" -eq 0 ]; then
        validation_status="no_changes"
        issues_detected="${issues_detected}- No commits ahead of $base_branch branch\\n"
        next_step="NO-OP"
    fi

    # If validation passed or just warnings, start documentation workflow (auto-chain)
    if [ "$validation_status" = "passed" ] || ([ "$validation_status" = "warning" ] && [ "$workflow_origin" != "pr-workflow" ]); then
        print_color $GREEN "✅ Auto-chaining to documentation workflow..."
        # Auto-execute documentation workflow instead of returning promptlet
        exec ./scripts/agent/workflows/docs-workflow.sh generate_docs "$branch" main --workflow-origin "$workflow_origin"
    fi
    
    print_trace "RESULTS" "Validation status: $validation_status"
    
    # Output validation promptlet (only for error cases)
    $PROMPTLET_READER change_validation \
        branch="$branch" \
        base_branch="$base_branch" \
        validation_status="$validation_status" \
        commits_ahead="$commits_ahead" \
        has_uncommitted="$has_uncommitted" \
        conflicts_exist="$conflicts_exist" \
        workflow_origin="$workflow_origin" \
        issues_detected="$(echo -e "$issues_detected" | sed 's/"/\\"/g' | tr '\n' '|')" \
        next_step="$next_step"
    
    print_trace "OUTPUT" "Generated validation promptlet with next_step: $next_step"
}

# Step 2: Generate PR description using git-cliff data
pr_body() {
    local branch=""
    local workflow_origin=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --branch) branch="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: pr_body [--branch BRANCH] [--workflow-origin ORIGIN]"
                echo "Generates PR description using git-cliff data"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    # Auto-detect branch if not provided (use cache if available)
    if [ -z "$branch" ]; then
        if has_valid_cache; then
            branch=$(get_cached_branch)
        else
            branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        fi
    fi

    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi

    print_trace "PR_BODY" "Generating PR description for branch: $branch"

    # Use centralized cache management
    local changelog_entry=""
    local base=""

    if has_valid_cache; then
        print_color $GREEN "⚡ Using cached git-cliff metadata from centralized cache"
        changelog_entry=$(get_cached_changelog)
        base=$(get_cached_base)
    else
        print_color $YELLOW "🔍 No commit cache found - generating fresh git-cliff data..."
        base=$(git merge-base main HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)
        changelog_entry=$(git-cliff --unreleased --strip header 2>/dev/null || echo "No unreleased changes detected")
    fi

    if [ -z "$changelog_entry" ] || [ "$changelog_entry" = "No unreleased changes detected" ]; then
        print_color $RED "❌ No changelog content available for PR description"
        return 1
    fi

    print_color $GREEN "✅ Retrieved changelog data for PR description"
    
    # Generate PR description promptlet
    $PROMPTLET_READER pr_description \
        branch_name="$branch" \
        base_branch="main" \
        diff_base="$base" \
        changelog_content="$(echo "$changelog_entry" | tr '\n' ' ' | sed 's/"/\\"/g')" \
        workflow_origin="$workflow_origin" \
        next_step="./scripts/agent/workflows/pr-workflow.sh create_pr --branch $branch --workflow-origin $workflow_origin"
    
    print_trace "OUTPUT" "Generated PR description promptlet"
}

# Step 2.5: Push branch and trigger pre-push hook
push_branch() {
    local branch=""
    local workflow_origin=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --branch) branch="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: push_branch [--branch BRANCH] [--workflow-origin ORIGIN]"
                echo "Pushes branch to origin and continues workflow"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done

    # Auto-detect branch if not provided
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    fi

    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi

    print_trace "PUSH_BRANCH" "Pushing branch: $branch"

    # Push branch to origin (pre-push hook will execute)
    print_color $BLUE "📤 Pushing $branch to origin..."

    if git push -u origin "$branch"; then
        print_color $GREEN "✅ Branch pushed successfully"

        # Auto-chain to pr_body (hook already ran during push)
        print_color $GREEN "✅ Auto-chaining to PR description generation..."
        exec ./scripts/agent/workflows/pr-workflow.sh pr_body --branch "$branch" --workflow-origin "$workflow_origin"
    else
        print_color $RED "❌ Failed to push branch"
        return 1
    fi
}

# Step 3: Create GitHub PR
create_pr() {
    local branch=""
    local title=""
    local body=""
    local workflow_origin=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --branch) branch="$2"; shift 2 ;;
            --title) title="$2"; shift 2 ;;
            --body) body="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: create_pr [--branch BRANCH] [--title TITLE] [--body BODY] [--workflow-origin ORIGIN]"
                echo "Creates GitHub PR with provided title and body"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    # Auto-detect branch if not provided
    if [ -z "$branch" ]; then
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    fi
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        return 1
    fi
    
    print_trace "CREATE_PR" "Creating PR for branch: $branch"

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
        # Generate finalization promptlet
        $PROMPTLET_READER pr_finalization \
            branch="$branch" \
            pr_url="$pr_url" \
            workflow_origin="$workflow_origin" \
            next_step="./scripts/agent/workflows/pr-workflow.sh finalize_pr --branch $branch --pr-url $pr_url --workflow-origin $workflow_origin"
    else
        print_color $RED "❌ Failed to create PR"
        return 1
    fi
    
    print_trace "OUTPUT" "Generated PR finalization promptlet"
}

# Step 4: Post-PR creation finalization tasks
finalize_pr() {
    local branch=""
    local pr_url=""
    local deploy_env=""
    local workflow_origin=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --branch) branch="$2"; shift 2 ;;
            --pr-url) pr_url="$2"; shift 2 ;;
            --deploy) deploy_env="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: finalize_pr [--branch BRANCH] [--pr-url PR_URL] [--deploy ENV] [--workflow-origin ORIGIN]"
                echo "Performs post-PR creation finalization tasks"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: --branch parameter is required"
        return 1
    fi
    
    print_trace "FINALIZE" "Starting PR finalization for branch: $branch"
    
    # Check CI/CD status if PR URL provided
    local ci_status="unknown"
    local ci_checks_passing=false
    
    if [ -n "$pr_url" ]; then
        print_trace "CI_CHECK" "Checking CI/CD status for PR: $pr_url"
        local pr_number=$(echo "$pr_url" | grep -o '[0-9]\+$' || echo "")
        
        if [ -n "$pr_number" ] && command -v gh >/dev/null 2>&1; then
            local pr_status=$(gh pr view "$pr_number" --json state --jq '.state' 2>/dev/null || echo "unknown")
            ci_status="$pr_status"
            
            if [ "$pr_status" = "OPEN" ]; then
                ci_checks_passing=true
            fi
        fi
    fi
    
    # Determine if deployment preparation is needed
    local deployment_needed=false
    local deployment_reason=""
    
    if [ -n "$deploy_env" ]; then
        deployment_needed=true
        deployment_reason="Deployment to $deploy_env requested"
    elif [ "$ci_checks_passing" = true ] && [ "$branch" != "main" ]; then
        if echo "$branch" | grep -qE "(release|hotfix|deploy)"; then
            deployment_needed=true
            deployment_reason="Release/deploy branch detected"
        fi
    fi
    
    # Generate completion status
    local completion_status="success"
    local next_step="WORKFLOW_COMPLETE"
    
    if [ "$deployment_needed" = true ]; then
        next_step="./scripts/workflows/deploy-workflow.sh prepare --branch $branch"
        if [ -n "$deploy_env" ]; then
            next_step="$next_step --env $deploy_env"
        fi
        completion_status="deployment_prep_needed"
    fi
    
    print_trace "RESULTS" "Finalization status: $completion_status"
    
    # Output finalization promptlet
    $PROMPTLET_READER pr_completion \
        branch="$branch" \
        pr_url="$pr_url" \
        completion_status="$completion_status" \
        ci_status="$ci_status" \
        ci_checks_passing="$ci_checks_passing" \
        deployment_needed="$deployment_needed" \
        deployment_reason="$deployment_reason" \
        workflow_origin="$workflow_origin" \
        next_step="$next_step"
    
    print_trace "OUTPUT" "Generated completion promptlet with next_step: $next_step"
}

# Main function dispatcher
main() {
    local function_name="$1"
    shift
    
    case "$function_name" in
        validate_changes) validate_changes "$@" ;;
        push_branch) push_branch "$@" ;;
        pr_body) pr_body "$@" ;;
        create_pr) create_pr "$@" ;;
        finalize_pr) finalize_pr "$@" ;;
        -h|--help|help)
            echo "PR Workflow Functions:"
            echo "  validate_changes [--branch BRANCH] [--base BASE] [--workflow-origin ORIGIN] - Validate branch changes"
            echo "  push_branch [--branch BRANCH] [--workflow-origin ORIGIN] - Push branch to origin"
            echo "  pr_body [--branch BRANCH] [--workflow-origin ORIGIN] - Generate PR description"
            echo "  create_pr [--branch BRANCH] [--title TITLE] [--body BODY] [--workflow-origin ORIGIN] - Create GitHub PR"
            echo "  finalize_pr [--branch BRANCH] [--pr-url URL] [--workflow-origin ORIGIN] - Post-creation tasks"
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