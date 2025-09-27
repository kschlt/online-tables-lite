#!/bin/bash

# Branch Workflow - Comprehensive branch management with integrated utilities
#
# ARCHITECTURE:
#   Orchestrator coordinates branch creation, validation, and protection
#   All branch logic consolidated from Makefile and utils into single workflow
#   Integrates: validate-branch-name, protect-main-branch, branch-suggest logic
#
# FUNCTIONS (Separation of Concerns):
#   branch_new_orchestrator - Entry point, coordinates entire flow
#   validate_current_state - Check for uncommitted changes, existing PRs
#   protect_main_branch - Prevent work on protected branches
#   suggest_branch_name - Generate branch name from recent commits
#   validate_branch_name - Check branch name compliance
#   auto_fix_branch_name - Attempt automatic name correction
#   create_branch - Actually create and checkout new branch
#   branch_rename - Rename branch with PR support

set -e

# Path constants
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"

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

# Function 1: Entry point orchestrator
branch_new_orchestrator() {
    local branch_name=""
    local workflow_origin="${1:-branch-new}"

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --name) branch_name="$2"; shift 2 ;;
            --workflow-origin) workflow_origin="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: branch_new_orchestrator [--name BRANCH_NAME] [--workflow-origin ORIGIN]"
                echo "Create new feature branch with validation and protection"
                return 0 ;;
            *)
                # Handle NAME=value from Makefile
                if [[ "$1" =~ NAME=.+ ]]; then
                    branch_name="${1#NAME=}"
                    shift
                else
                    echo "Unknown option: $1" >&2
                    return 1
                fi
                ;;
        esac
    done

    print_trace "BRANCH_ORCHESTRATOR" "Starting branch creation workflow (origin: $workflow_origin)"

    # Step 1: Validate current state
    validate_current_state "$workflow_origin"

    # Step 2: Protect main branch
    protect_main_branch

    # Step 3: Handle branch name (suggest or validate provided)
    if [ -z "$branch_name" ]; then
        suggest_branch_name "$workflow_origin"
        return 0  # Agent will continue workflow
    else
        handle_provided_branch_name "$branch_name" "$workflow_origin"
    fi
}

# Function 2: Validate current repository state
validate_current_state() {
    local workflow_origin="$1"

    print_trace "VALIDATE_STATE" "Checking current repository state"

    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Check if not on main - if so, ensure clean state before switching
    if [ "$current_branch" != "main" ]; then
        if ! git diff --quiet || ! git diff --cached --quiet; then
            if ! git diff --cached --quiet; then
                print_color $RED "❌ STOP: Staged changes detected"
                print_color $BLUE "Terminal: Commit changes first"
                print_color $BLUE "USER ACTION REQUIRED: make commit"
                exit 1
            else
                print_color $RED "❌ STOP: Unstaged changes detected"
                print_color $BLUE "Terminal: Stash changes first"
                print_color $BLUE "USER ACTION REQUIRED: git stash"
                exit 1
            fi
        fi
        print_trace "VALIDATE_STATE" "Switching from $current_branch to main"
        git checkout main
    fi

    # Sync with remote
    print_trace "VALIDATE_STATE" "Syncing with remote main"
    git fetch origin main >/dev/null 2>&1
    if [ "$(git rev-parse main)" != "$(git rev-parse origin/main)" ]; then
        print_trace "VALIDATE_STATE" "Pulling latest changes from origin/main"
        git pull origin main
    fi

    # Check for open PRs (warning, not blocking)
    if command -v gh >/dev/null 2>&1; then
        local open_prs=$(gh pr list --state open --json number,title,headRefName 2>/dev/null || echo "[]")
        local pr_count=$(echo "$open_prs" | jq length 2>/dev/null || echo "0")

        if [ "$pr_count" -gt 0 ]; then
            print_color $YELLOW "⚠️ STOP: Open PRs detected"
            print_color $BLUE "Terminal: $pr_count open PRs found"
            echo "$open_prs" | jq -r '.[] | "  #\(.number): \(.title) (\(.headRefName))"' 2>/dev/null || echo "  Could not parse PR details"
            print_color $BLUE "USER CHOICE: Continue anyway? (Y/N)"
            # Note: This is informational - user can decide to continue
        fi
    fi

    print_trace "VALIDATE_STATE" "Repository state validation completed"
}

# Function 3: Protect main branch from direct work
protect_main_branch() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    if [ "$current_branch" = "main" ] || [ "$current_branch" = "production" ]; then
        print_trace "PROTECT_MAIN" "Protected branch validation passed - on $current_branch for branch creation"
        return 0
    fi

    # Should not reach here after validate_current_state, but safety check
    print_color $RED "❌ Cannot create branch from: $current_branch"
    exit 1
}

# Function 4: Suggest branch name from recent commits/context
suggest_branch_name() {
    local workflow_origin="$1"

    print_trace "SUGGEST_BRANCH" "Generating branch name suggestion from commit context"

    # Get base commit for comparison
    local base_ref="origin/main"
    local base=$(git merge-base "$base_ref" HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)
    local title=$(git log --format='%s' "$base..HEAD" | head -1 | tr '[:upper:]' '[:lower:]')

    # Fallback if no title found
    [[ -n "$title" ]] || title="update miscellaneous"

    # Create safe branch name suggestion
    local safe=$(printf "%s" "$title" | sed 's/[^a-z0-9]+/-/g; s/ /-/g; s/--\+/-/g; s/^-//; s/-$//')
    local suggested=$(printf "feat/%s" "$safe" | cut -c1-70)

    print_color $BLUE "Current: $(git rev-parse --abbrev-ref HEAD)"
    print_color $BLUE "Suggested: $suggested"

    # Check if any open PRs for additional context
    local pr_count="0"
    if command -v gh >/dev/null 2>&1; then
        pr_count=$(gh pr list --state open --json number 2>/dev/null | jq length 2>/dev/null || echo "0")
    fi

    # Generate promptlet for agent decision
    $PROMPTLET_READER branch-wf.generation \
        open_prs="$pr_count" \
        suggested_name="$suggested" \
        origin="$workflow_origin"

    print_trace "SUGGEST_BRANCH" "Generated branch name suggestion promptlet"
}

# Function 5: Branch name validation (integrated from validate-branch-name.sh)
validate_branch_name() {
    local branch_name="$1"

    print_trace "VALIDATE_NAME" "Validating branch name: $branch_name"

    # Check basic format requirements
    if [[ ! "$branch_name" =~ ^[a-z0-9/_-]+$ ]]; then
        print_color $RED "❌ Invalid characters in branch name"
        return 1
    fi

    # Check for required prefix (simplified to feat/ and fix/ only)
    if [[ ! "$branch_name" =~ ^(feat|fix)/ ]]; then
        print_color $RED "❌ Branch name must start with: feat/ (for features) or fix/ (for bug fixes)"
        return 1
    fi

    # Check length
    if [ ${#branch_name} -gt 70 ]; then
        print_color $RED "❌ Branch name too long (max 70 characters)"
        return 1
    fi

    # Check for consecutive separators
    if [[ "$branch_name" =~ --|\.\.|// ]]; then
        print_color $RED "❌ No consecutive separators allowed"
        return 1
    fi

    print_trace "VALIDATE_NAME" "Branch name validation passed"
    return 0
}

# Function 6: Auto-fix branch name (integrated from validate-branch-name.sh)
auto_fix_branch_name() {
    local branch_name="$1"

    print_trace "AUTO_FIX" "Attempting to auto-fix branch name: $branch_name"

    # Clean the name
    local clean_name=$(echo "$branch_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9/_-]/-/g' | sed 's/--\+/-/g' | sed 's/^-\+\|-\+$//g')

    # Add feat/ prefix if missing
    if [[ ! "$clean_name" =~ ^(feat|fix)/ ]]; then
        clean_name="feat/$clean_name"
    fi

    # Truncate if too long
    if [ ${#clean_name} -gt 70 ]; then
        clean_name="${clean_name:0:70}"
        # Remove trailing dash if cut mid-word
        clean_name=$(echo "$clean_name" | sed 's/-*$//')
    fi

    # Validate the fixed name
    if validate_branch_name "$clean_name" >/dev/null 2>&1; then
        print_trace "AUTO_FIX" "Auto-fix successful: $clean_name"
        echo "$clean_name"
        return 0
    else
        print_trace "AUTO_FIX" "Auto-fix failed for: $branch_name"
        return 1
    fi
}

# Function 7: Handle provided branch name with validation
handle_provided_branch_name() {
    local branch_name="$1"
    local workflow_origin="$2"

    print_trace "HANDLE_PROVIDED" "Processing provided branch name: $branch_name"

    if validate_branch_name "$branch_name"; then
        print_color $GREEN "✅ Branch name is compliant"
        create_branch "$branch_name" "$workflow_origin"
        return $?
    else
        print_color $YELLOW "⚠️ Branch name validation failed, attempting auto-fix..."
        local auto_fixed=$(auto_fix_branch_name "$branch_name")

        if [ $? -eq 0 ] && [ -n "$auto_fixed" ]; then
            print_color $GREEN "✅ Auto-fixed name: $auto_fixed"
            create_branch "$auto_fixed" "$workflow_origin"
            return $?
        else
            print_color $RED "❌ Cannot auto-fix branch name"

            # Generate promptlet for agent to provide better name
            $PROMPTLET_READER branch-wf.compliance \
                original_name="$branch_name" \
                validation_errors="Invalid format, see naming policy" \
                origin="$workflow_origin"

            print_trace "HANDLE_PROVIDED" "Generated naming compliance promptlet"
            return 1
        fi
    fi
}

# Function 8: Create and checkout new branch
create_branch() {
    local branch_name="$1"
    local workflow_origin="$2"

    print_trace "CREATE_BRANCH" "Creating branch: $branch_name"

    # Final safety check - ensure we're on main
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [ "$current_branch" != "main" ]; then
        print_color $RED "❌ Not on main branch, cannot create new branch safely"
        return 1
    fi

    # Create and checkout new branch
    if git checkout -b "$branch_name"; then
        print_color $GREEN "✅ Branch created: $branch_name"
        print_trace "CREATE_BRANCH" "Successfully created and checked out: $branch_name"
        return 0
    else
        print_color $RED "❌ Failed to create branch: $branch_name"
        return 1
    fi
}

# Function 9: Rename existing branch with PR support (integrated from branch-rename.sh)
branch_rename() {
    local new_name="$1"
    local workflow_origin="${2:-branch-rename}"

    if [ -z "$new_name" ]; then
        print_color $RED "❌ Error: New branch name required"
        echo "Usage: branch_rename NEW_BRANCH_NAME [WORKFLOW_ORIGIN]"
        return 1
    fi

    print_trace "BRANCH_RENAME" "Starting branch rename to: $new_name"

    local current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Validate current branch is not protected
    if [ "$current_branch" = "main" ] || [ "$current_branch" = "production" ]; then
        print_color $RED "❌ Cannot rename protected branch: $current_branch"
        return 1
    fi

    # Validate new branch name
    if ! validate_branch_name "$new_name"; then
        print_color $RED "❌ New branch name '$new_name' violates naming policy"
        # Could generate promptlet here for agent to provide better name
        return 1
    fi

    print_color $GREEN "✅ New branch name is compliant"

    # Check for existing PR and handle rename
    if command -v gh >/dev/null 2>&1; then
        local pr_info=$(gh pr list --head "$current_branch" --json number,title 2>/dev/null || echo "[]")
        local pr_number=$(echo "$pr_info" | jq -r '.[0].number // empty' 2>/dev/null || echo "")

        if [ -n "$pr_number" ]; then
            print_color $BLUE "🔄 Found existing PR #$pr_number - will update automatically"
            print_color $BLUE "📝 Renaming local branch..."
            git branch -m "$new_name"
            print_color $BLUE "📤 Pushing new branch name to remote..."
            git push origin -u "$new_name"
            print_color $BLUE "🗑️  Deleting old remote branch..."
            git push origin --delete "$current_branch" 2>/dev/null || print_color $YELLOW "⚠️  Could not delete old remote branch (may not exist)"
            print_color $GREEN "✅ PR #$pr_number automatically updated to track new branch name"
        else
            print_color $BLUE "ℹ️  No existing PR found - performing simple rename"
            git branch -m "$new_name"
            if git rev-parse --verify "origin/$current_branch" >/dev/null 2>&1; then
                print_color $BLUE "📤 Updating remote branch..."
                git push origin -u "$new_name"
                git push origin --delete "$current_branch"
            fi
        fi
    else
        print_color $BLUE "ℹ️  GitHub CLI not available - performing local rename only"
        git branch -m "$new_name"
        print_color $YELLOW "⚠️  Manual steps required if branch was pushed:"
        print_color $YELLOW "   1. git push origin -u $new_name"
        print_color $YELLOW "   2. git push origin --delete $current_branch"
    fi

    print_color $GREEN "🔁 Branch renamed: $current_branch → $new_name"
    print_trace "BRANCH_RENAME" "Branch rename completed successfully"
}

# Main function dispatcher
main() {
    local function_name="$1"
    shift

    case "$function_name" in
        branch_new_orchestrator) branch_new_orchestrator "$@" ;;
        validate_current_state) validate_current_state "$@" ;;
        protect_main_branch) protect_main_branch "$@" ;;
        suggest_branch_name) suggest_branch_name "$@" ;;
        validate_branch_name) validate_branch_name "$@" ;;
        auto_fix_branch_name) auto_fix_branch_name "$@" ;;
        handle_provided_branch_name) handle_provided_branch_name "$@" ;;
        create_branch) create_branch "$@" ;;
        branch_rename) branch_rename "$@" ;;
        -h|--help|help)
            echo "Branch Workflow Functions:"
            echo "  branch_new_orchestrator [--name NAME] [--workflow-origin ORIGIN] - Create new branch"
            echo "  branch_rename NEW_NAME [WORKFLOW_ORIGIN]                        - Rename current branch"
            echo "  validate_branch_name BRANCH_NAME                               - Validate name only"
            echo "  auto_fix_branch_name BRANCH_NAME                               - Auto-fix name only"
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