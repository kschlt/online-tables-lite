#!/bin/bash

# Commit Workflow - Execute commit with message validation
# Validates conventional commit message and executes git commit

set -e

# Path constants
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"
STAGING_LOGIC="$AGENT_BASE/utils/staging-logic.sh"

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

# Integrated staging workflow - handles staging before commit
integrate_staging() {
    local auto_stage="${1:-false}"
    local workflow_starter="${2:-commit_command}"

    print_trace "STAGING_INTEGRATION" "Starting integrated staging workflow (auto_stage=$auto_stage)"

    # Source staging logic functions
    if [ ! -f "$STAGING_LOGIC" ]; then
        print_color $RED "❌ Error: Staging logic script not found at $STAGING_LOGIC"
        return 1
    fi

    # Execute staging workflow
    if $STAGING_LOGIC execute_staging_workflow "$auto_stage" "integrated_commit"; then
        print_trace "STAGING_SUCCESS" "Staging workflow completed successfully"
        return 0
    else
        print_trace "STAGING_FAILED" "Staging workflow did not stage any files"
        return 1
    fi
}

# Full integrated commit workflow - staging + commit in one flow
integrated_commit_workflow() {
    local auto_stage="${1:-false}"
    local workflow_starter="${2:-commit_command}"

    print_trace "INTEGRATED_WORKFLOW_START" "Beginning integrated commit workflow"
    print_color $BLUE "🌿 Current branch: $(git rev-parse --abbrev-ref HEAD)"

    # Check initial staging status
    local staged_count=$(git diff --staged --name-only | wc -l | tr -d ' ')
    local unstaged_count=$(git diff --name-only | wc -l | tr -d ' ')
    local untracked_count=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
    local total_changes=$((staged_count + unstaged_count + untracked_count))

    print_trace "INITIAL_STATE" "Staged: $staged_count, Unstaged: $unstaged_count, Untracked: $untracked_count"

    # Handle different scenarios
    if [ "$total_changes" -eq 0 ]; then
        print_color $BLUE "ℹ️ No changes found. Working tree is clean - skipping commit."
        $PROMPTLET_READER workflow_complete \
            status="no_changes" \
            commit_message="none" \
            next_step="WORKFLOW_COMPLETE"
        return 0
    fi

    # If no staged files but have unstaged/untracked, run integrated staging
    if [ "$staged_count" -eq 0 ] && [ "$((unstaged_count + untracked_count))" -gt 0 ]; then
        print_color $BLUE "🔍 No staged files found. Running integrated staging..."

        local staging_result
        integrate_staging "$auto_stage" "$workflow_starter"
        staging_result=$?

        case $staging_result in
            0)
                # Staging succeeded - verify files were actually staged
                local new_staged_count=$(git diff --staged --name-only | wc -l | tr -d ' ')
                if [ "$new_staged_count" -eq 0 ]; then
                    print_color $YELLOW "⚠️ Staging workflow completed but no files were staged"
                    print_color $BLUE "💡 Manual staging may be required. Check git status and stage specific files."
                    return 1
                fi
                print_color $GREEN "✅ Staging completed. $new_staged_count files staged."
                ;;
            1)
                # No relevant files or staging failed - stop workflow
                print_color $YELLOW "⚠️ No relevant files for automatic staging"
                print_color $BLUE "💡 Manual intervention required. Check git status and stage specific files."
                return 1
                ;;
            2)
                # Agent decision required - workflow handed off to agent
                print_trace "AGENT_HANDOFF" "Workflow handed off to agent for staging decision"
                return 1  # Stop current execution, agent will continue
                ;;
            *)
                print_color $RED "❌ Staging workflow failed with error"
                return 1
                ;;
        esac
    elif [ "$staged_count" -gt 0 ]; then
        print_color $GREEN "📝 Found $staged_count staged file(s). Proceeding with commit..."
    fi

    # Now proceed with commit message generation and execution
    print_trace "COMMIT_GENERATION" "Starting commit message generation phase"

    # Generate commit context (similar to Makefile logic)
    local BASE=$(git merge-base origin/main HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)
    local PREVIEW=$(git-cliff --unreleased --bump 2>/dev/null | head -5 | tail -1 | sed 's/^## \[//' | sed 's/\].*//' || echo "preview unavailable")
    local DIFF_SUMMARY=$(git diff --staged --stat | head -10)
    local COMMIT_TYPES=$(grep -E '^\s*\{\s*message\s*=\s*"\^[a-z]+' cliff.toml 2>/dev/null | sed -E 's/.*"\^([a-z]+).*/\1/' | tr '\n' '|' | sed 's/|$//' || echo "feat|fix|docs|refactor|chore|test|ci|build|perf")
    local CLIFF_CONFIG_STATUS=$(if [ -f "cliff.toml" ]; then echo "✅ Using cliff.toml configuration"; else echo "⚠️ cliff.toml not found, using defaults"; fi)
    local SAMPLE_ANALYSIS=$(git-cliff --unreleased --context 2>/dev/null | jq -r '.commits[0].message // "No recent commits"' 2>/dev/null || echo "No context available")

    # Get current staged file count for promptlet
    local final_staged_count=$(git diff --staged --name-only | wc -l | tr -d ' ')

    print_trace "COMMIT_CONTEXT" "Generated context for commit message generation"

    # Call the conventional commit generation promptlet
    $PROMPTLET_READER conventional_commit_generation \
        staged_files="$final_staged_count" \
        suggested_version="$PREVIEW" \
        diff_summary="$DIFF_SUMMARY" \
        git_cliff_config="$CLIFF_CONFIG_STATUS" \
        allowed_types="$COMMIT_TYPES" \
        sample_analysis="$SAMPLE_ANALYSIS" \
        workflow_starter="$workflow_starter"

    print_trace "INTEGRATED_WORKFLOW_COMPLETE" "Handed off to agent for commit message generation and execution"
}

# Validate commit message format (single responsibility: validation only)
validate_commit_message_format() {
    local message="$1"
    local workflow_starter="${2:-commit_command}"

    print_trace "MESSAGE_VALIDATION" "Validating commit message format: $message"

    # Check conventional commit format (reuse existing validation logic)
    if echo "$message" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\(.+\))?: .+'; then
        print_color $GREEN "✅ Message follows conventional commit format"
        return 0
    else
        print_color $YELLOW "⚠️ Invalid format: Message does not follow conventional commit format"
        print_color $BLUE "Expected format: type(scope): description"
        print_color $BLUE "Examples: feat(ui): add dashboard, fix(api): resolve auth issue"

        # Generate format feedback promptlet for agent to fix message (validation loop)
        $PROMPTLET_READER commit_message_validation_failed \
            original_message="$message" \
            error="Invalid conventional commit format" \
            expected_format="type(scope): description" \
            workflow_starter="$workflow_starter"

        print_trace "VALIDATION_FAILED" "Generated format feedback promptlet for message correction"
        return 1
    fi
}

# Chain validation and execution (implements diagram flow: ValidateFormat -> ExecuteCommit)
validate_and_execute_commit() {
    local message="$1"
    local workflow_starter="${2:-commit_command}"

    # Step 1: Validate message format
    if validate_commit_message_format "$message" "$workflow_starter"; then
        print_trace "VALIDATION_PASSED" "Message validation passed, proceeding to execution"
        # Step 2: Execute commit with validated message
        execute_commit --message "$message"
        return $?
    else
        print_trace "VALIDATION_FAILED" "Message validation failed, stopping execution"
        return 1
    fi
}

# Execute commit with provided message
execute_commit() {
    local message=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --message) message="$2"; shift 2 ;;
            -h|--help)
                echo "Usage: execute_commit --message MESSAGE"
                echo "Validates and executes git commit with conventional commit message"
                return 0 ;;
            *) echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done

    if [ -z "$message" ]; then
        print_color $RED "❌ Error: Commit message required"
        echo "Usage: execute_commit --message \"feat(scope): description\""
        return 1
    fi

    print_trace "COMMIT_EXEC" "Executing commit with message: $message"

    # Check if there are staged changes
    local staged_files=$(git diff --staged --name-only | wc -l | tr -d ' ')
    if [ "$staged_files" -eq 0 ]; then
        print_color $RED "❌ No staged changes found"
        return 1
    fi

    print_color $GREEN "📝 Found $staged_files staged file(s)"

    # Execute the commit (this will trigger pre-commit hooks)
    print_color $BLUE "🚀 Executing: git commit -m \"$message\""

    if git commit -m "$message"; then
        print_color $GREEN "✅ Commit successful!"

        # Generate completion promptlet
        $PROMPTLET_READER commit_complete \
            message="$message" \
            status="success" \
            next_step="WORKFLOW_COMPLETE"

        print_trace "OUTPUT" "Generated commit completion promptlet"
    else
        print_color $RED "❌ Commit failed!"

        # Generate error promptlet
        $PROMPTLET_READER commit_error \
            message="$message" \
            error="commit_failed" \
            next_step="MANUAL_INTERVENTION_REQUIRED"

        print_trace "OUTPUT" "Generated commit error promptlet"
        return 1
    fi
}

# Main function dispatcher
main() {
    local function_name="$1"
    shift

    case "$function_name" in
        execute_commit) execute_commit "$@" ;;
        integrate_staging) integrate_staging "$@" ;;
        integrated_commit_workflow) integrated_commit_workflow "$@" ;;
        validate_commit_message_format) validate_commit_message_format "$@" ;;
        validate_and_execute_commit) validate_and_execute_commit "$@" ;;
        -h|--help|help)
            echo "Commit Workflow Functions:"
            echo "  execute_commit --message MESSAGE        - Execute git commit (no validation)"
            echo "  integrate_staging [auto_stage] [starter] - Run staging workflow integration"
            echo "  integrated_commit_workflow [auto_stage] [starter] - Full staging + commit workflow"
            echo "  validate_commit_message_format MESSAGE [starter] - Validate message format only"
            echo "  validate_and_execute_commit MESSAGE [starter] - Chain validation and execution"
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