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

    # Validate conventional commit format
    if ! echo "$message" | grep -qE '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore)(\(.+\))?: .+'; then
        print_color $YELLOW "⚠️  Warning: Message may not follow conventional commit format"
        print_color $BLUE "Expected format: type(scope): description"
        print_color $BLUE "Examples: feat(ui): add dashboard, fix(api): resolve auth issue"
    else
        print_color $GREEN "✅ Message follows conventional commit format"
    fi

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
        -h|--help|help)
            echo "Commit Workflow Functions:"
            echo "  execute_commit --message MESSAGE - Validate and execute git commit"
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