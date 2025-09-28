#!/bin/bash

# Commit Workflow - Execute commit with message validation
# Validates conventional commit message and executes git commit

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

# Sanitize text for safe JSON processing
sanitize_for_json() {
    local input="$1"
    local max_length="${2:-500}"  # Default max length to prevent huge JSON strings

    # Remove ANSI escape sequences and color codes
    local cleaned=$(echo "$input" | sed 's/\x1b\[[0-9;]*m//g')

    # Replace problematic characters for JSON
    cleaned=$(echo "$cleaned" | tr -d '\000-\037' | tr -d '\177-\377')  # Remove control chars
    cleaned=$(echo "$cleaned" | sed 's/"/\\"/g')  # Escape quotes
    cleaned=$(echo "$cleaned" | sed 's/\\/\\\\/g')  # Escape backslashes
    cleaned=$(echo "$cleaned" | tr '\n' ' ')  # Convert newlines to spaces
    cleaned=$(echo "$cleaned" | sed 's/\t/ /g')  # Convert tabs to spaces
    cleaned=$(echo "$cleaned" | sed 's/  */ /g')  # Collapse multiple spaces

    # Truncate if too long
    if [ ${#cleaned} -gt $max_length ]; then
        cleaned="${cleaned:0:$max_length}... (truncated)"
    fi

    echo "$cleaned"
}

# Integrated staging functions (from staging-logic.sh)
analyze_changes() {
    local staged_count=$(git diff --staged --name-only | wc -l | tr -d ' ')
    local unstaged_count=$(git diff --name-only | wc -l | tr -d ' ')
    local untracked_count=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
    local total_changes=$((staged_count + unstaged_count + untracked_count))

    echo "$staged_count:$unstaged_count:$untracked_count:$total_changes"
}

detect_relevant_files() {
    # File patterns for automatic staging
    local relevant_patterns="\.md$|\.json$|\.js$|\.ts$|\.tsx$|\.py$|\.sh$|Makefile$|\.toml$|\.yaml$|\.yml$|\.env"
    local ignore_patterns="node_modules|\.next|dist|build|venv|\.git|\.agent|package-lock\.json|\.log$|\.tmp$"

    # Get all unstaged and untracked files that match relevant patterns
    local relevant_files=$(git diff --name-only && git ls-files --others --exclude-standard | grep -E "$relevant_patterns" | grep -vE "$ignore_patterns" || true)

    # Filter out empty lines and return
    echo "$relevant_files" | grep -v '^$' || true
}

auto_stage_relevant_files() {
    local relevant_files="$1"

    if [ -z "$relevant_files" ]; then
        print_color $YELLOW "⚠️ No relevant files found for staging"
        return 1
    fi

    print_color $GREEN "⚡ Auto-staging relevant files..."

    # Parse JSON array format: ["file1.txt", "file2.txt", "file3.txt"]
    local normalized_files
    if echo "$relevant_files" | grep -q '^\[.*\]$'; then
        # Parse JSON array to newline-separated files
        normalized_files=$(echo "$relevant_files" | sed 's/^\[//' | sed 's/\]$//' | sed 's/", */\n/g' | sed 's/"//g')
        print_trace "AUTO_STAGE" "Parsed JSON array format"
    else
        # Invalid format - expected JSON array
        print_color $RED "❌ Invalid file list format. Expected JSON array: [\"file1.txt\", \"file2.txt\"]"
        print_color $YELLOW "→ Received: $relevant_files"
        return 1
    fi

    # Process normalized file list
    local staged_count=0
    while IFS= read -r file; do
        # Clean up file path (remove quotes, trim whitespace)
        file=$(echo "$file" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/^"//' | sed 's/"$//')

        if [ -n "$file" ] && [ "$file" != "null" ] && [ "$file" != "undefined" ]; then
            if [ -f "$file" ] || git ls-files --error-unmatch "$file" >/dev/null 2>&1; then
                echo "  + $file"
                git add "$file" && ((staged_count++))
            else
                print_color $YELLOW "  ⚠️  Skipping non-existent file: $file"
            fi
        fi
    done <<< "$normalized_files"

    if [ $staged_count -gt 0 ]; then
        print_color $GREEN "✅ $staged_count file(s) staged automatically"
        return 0
    else
        print_color $YELLOW "⚠️ No valid files were staged"
        return 1
    fi
}

call_agent_staging_decision() {
    local total_changes="$1"
    local staged_count="$2"
    local unstaged_count="$3"
    local untracked_count="$4"
    local relevant_files="$5"
    local auto_stage="$6"
    local workflow_context="$7"
    local origin="$8"
    local caller="$9"

    print_color $BLUE "🤖 Agent staging decision required..."

    # Generate staging decision promptlet using new format
    $PROMPTLET_READER commit-wf.staging \
        total_changes="$total_changes" \
        staged_count="$staged_count" \
        untracked_count="$untracked_count" \
        relevant_files="$(echo "$relevant_files" | tr '\n' '|' | sed 's/|$//')" \
        workflow_context="$workflow_context" \
        origin="$origin" \
        caller="$caller" \
        auto_stage="$auto_stage"
}

auto_stage_files() {
    local files_to_stage="$1"

    print_color $GREEN "🤖 Agent decision: AUTO_STAGE - staging relevant files..."
    auto_stage_relevant_files "$files_to_stage"
    return $?
}

# Integrated staging workflow - handles staging before commit
integrate_staging() {
    local auto_stage="${1:-false}"
    local workflow_starter="${2:-commit_command}"

    print_trace "STAGING_INTEGRATION" "Starting integrated staging workflow (auto_stage=$auto_stage)"

    # Execute integrated staging workflow
    execute_staging_workflow "$auto_stage" "integrated_commit" "$workflow_starter" "commit_workflow"
    local staging_result=$?

    case $staging_result in
        0)
            print_trace "STAGING_SUCCESS" "Staging workflow completed successfully"
            return 0
            ;;
        2)
            print_trace "STAGING_AGENT_HANDOFF" "Staging workflow handed off to agent"
            return 2  # Pass through agent decision signal
            ;;
        *)
            print_trace "STAGING_FAILED" "Staging workflow did not stage any files"
            return 1
            ;;
    esac
}

# Execute staging workflow (integrated from staging-logic.sh)
execute_staging_workflow() {
    local auto_stage="${1:-false}"
    local workflow_context="${2:-integrated_commit}"
    local origin="${3:-commit_command}"
    local caller="${4:-commit_workflow}"

    print_trace "STAGING_START" "Beginning staging analysis for $workflow_context"

    # Analyze current state
    local counts=$(analyze_changes)
    local staged_count=$(echo "$counts" | cut -d: -f1)
    local unstaged_count=$(echo "$counts" | cut -d: -f2)
    local untracked_count=$(echo "$counts" | cut -d: -f3)
    local total_changes=$(echo "$counts" | cut -d: -f4)

    print_color $BLUE "📊 Change Summary:"
    print_color $BLUE "  📝 Staged: $staged_count files"
    print_color $BLUE "  ✏️  Modified: $unstaged_count files"
    print_color $BLUE "  🆕 Untracked: $untracked_count files"

    # Show current files
    if [ "$staged_count" -gt 0 ]; then
        print_color $BLUE "📋 Staged files:"
        git diff --staged --name-only | sed 's/^/  📝 /'
    fi

    if [ "$unstaged_count" -gt 0 ]; then
        print_color $BLUE "📋 Modified files:"
        git diff --name-only | sed 's/^/  ✏️  /'
    fi

    if [ "$untracked_count" -gt 0 ]; then
        print_color $BLUE "📋 Untracked files:"
        git ls-files --others --exclude-standard | sed 's/^/  🆕 /'
    fi

    # Check for relevant files if no staged files
    if [ "$staged_count" -eq 0 ]; then
        local relevant_files=$(detect_relevant_files)

        if [ -n "$relevant_files" ]; then
            print_color $GREEN "🎯 Relevant files detected for staging:"
            echo "$relevant_files" | sed 's/^/  + /'

            if [ "$auto_stage" = "true" ]; then
                auto_stage_relevant_files "$relevant_files"
                return $?
            else
                call_agent_staging_decision "$total_changes" "$staged_count" "$unstaged_count" "$untracked_count" "$relevant_files" "$auto_stage" "$workflow_context" "$origin" "$caller"
                return 2  # Indicates agent decision required
            fi
        else
            print_color $YELLOW "⚠️ No relevant files found for automatic staging"
            return 1
        fi
    else
        print_color $GREEN "✅ Files already staged, proceeding with commit"
        return 0
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
        print_trace "WORKFLOW_COMPLETE" "No changes detected - workflow complete"
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
                print_color $BLUE "🤖 Promptlet generated - awaiting agent decision"
                return 0  # Clean exit for ping-pong pattern, agent will continue
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

    # Generate commit context (similar to Makefile logic) with sanitization
    local BASE=$(git merge-base origin/main HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1)
    local PREVIEW=$(git-cliff --unreleased --bump 2>/dev/null | head -5 | tail -1 | sed 's/^## \[//' | sed 's/\].*//' || echo "preview unavailable")

    # Sanitize git diff output to prevent JSON parsing errors
    local DIFF_SUMMARY_RAW=$(git diff --staged --stat 2>/dev/null | head -10 || echo "No diff available")
    local DIFF_SUMMARY=$(sanitize_for_json "$DIFF_SUMMARY_RAW" 300)

    local COMMIT_TYPES=$(grep -E '^\s*\{\s*message\s*=\s*"\^[a-z]+' cliff.toml 2>/dev/null | sed -E 's/.*"\^([a-z]+).*/\1/' | tr '\n' '|' | sed 's/|$//' || echo "feat|fix|docs|refactor|chore|test|ci|build|perf")
    local CLIFF_CONFIG_STATUS=$(if [ -f "cliff.toml" ]; then echo "Using cliff.toml configuration"; else echo "cliff.toml not found, using defaults"; fi)

    # Sanitize git-cliff analysis output
    local SAMPLE_ANALYSIS_RAW=$(git-cliff --unreleased --context 2>/dev/null | jq -r '.commits[0].message // "No recent commits"' 2>/dev/null || echo "No context available")
    local SAMPLE_ANALYSIS=$(sanitize_for_json "$SAMPLE_ANALYSIS_RAW" 200)

    # Get current staged file count for promptlet
    local final_staged_count=$(git diff --staged --name-only | wc -l | tr -d ' ')

    print_trace "COMMIT_CONTEXT" "Generated context for commit message generation"

    # Add fallback validation for critical variables
    if [ -z "$final_staged_count" ] || [ "$final_staged_count" -eq 0 ]; then
        print_color $RED "❌ No staged files detected for commit message generation"
        print_color $BLUE "→ Run 'git status' to check repository state"
        return 1
    fi

    if [ -z "$DIFF_SUMMARY" ]; then
        DIFF_SUMMARY="No diff summary available"
        print_color $YELLOW "⚠️ Using fallback diff summary"
    fi

    if [ -z "$COMMIT_TYPES" ]; then
        COMMIT_TYPES="feat|fix|docs|refactor|chore|test|ci|build|perf"
        print_color $YELLOW "⚠️ Using fallback commit types"
    fi

    print_trace "COMMIT_PROMPTLET" "Calling commit message generation with sanitized context"

    # Call the conventional commit generation promptlet using new format with error handling
    if ! $PROMPTLET_READER commit-wf.conventionalmessage \
        staged_files="$final_staged_count" \
        suggested_version="$PREVIEW" \
        diff_summary="$DIFF_SUMMARY" \
        git_cliff_config="$CLIFF_CONFIG_STATUS" \
        allowed_types="$COMMIT_TYPES"; then

        print_color $RED "❌ Failed to generate commit message promptlet"
        print_color $YELLOW "→ Possible causes: JSON parsing error, missing promptlet, invalid context"
        print_color $BLUE "→ Try: ./scripts/agent/promptlets/promptlet-reader.sh list (to see available promptlets)"
        print_color $BLUE "→ Try: git status (to check repository state)"
        return 1
    fi

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

        # Direct error feedback - no agent needed for simple validation errors
        print_color $RED "❌ Commit message validation failed"
        print_color $YELLOW "→ Message: '$message'"
        print_color $YELLOW "→ Error: Invalid conventional commit format"
        print_color $YELLOW "→ Expected format: type(scope): description"

        print_trace "VALIDATION_FAILED" "Commit message format validation failed"
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
        print_trace "WORKFLOW_COMPLETE" "Commit workflow completed successfully"
        return 0
    else
        print_color $RED "❌ Commit failed!"

        # Direct error handling - no agent needed for commit failures
        print_color $RED "❌ Git commit execution failed"
        print_color $YELLOW "→ Message: '$message'"
        print_color $YELLOW "→ Manual intervention required"
        print_color $BLUE "→ Check git status and resolve any issues"

        print_trace "OUTPUT" "Commit execution failed, manual intervention required"
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
        auto_stage_files) auto_stage_files "$@" ;;
        execute_staging_workflow) execute_staging_workflow "$@" ;;
        -h|--help|help)
            echo "Commit Workflow Functions:"
            echo "  execute_commit --message MESSAGE        - Execute git commit (no validation)"
            echo "  integrate_staging [auto_stage] [starter] - Run staging workflow integration"
            echo "  integrated_commit_workflow [auto_stage] [starter] - Full staging + commit workflow"
            echo "  validate_commit_message_format MESSAGE [starter] - Validate message format only"
            echo "  validate_and_execute_commit MESSAGE [starter] - Chain validation and execution"
            echo "  auto_stage_files FILES_STRING           - Auto-stage specific files (agent callable)"
            echo "  execute_staging_workflow [auto_stage] [context] [origin] [caller] - Internal staging logic"
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