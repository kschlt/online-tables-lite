#!/bin/bash

# Staging Logic Utilities
# Extracted from Makefile staging workflow for reuse in integrated commit workflow

set -e

# Path constants
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"

# Colors for output
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

# Analyze current changes and return counts
analyze_changes() {
    local staged_count=$(git diff --staged --name-only | wc -l | tr -d ' ')
    local unstaged_count=$(git diff --name-only | wc -l | tr -d ' ')
    local untracked_count=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')
    local total_changes=$((staged_count + unstaged_count + untracked_count))

    echo "$staged_count:$unstaged_count:$untracked_count:$total_changes"
}

# Check if there are relevant files for automatic staging
detect_relevant_files() {
    # File patterns for automatic staging
    local relevant_patterns="\.md$|\.json$|\.js$|\.ts$|\.tsx$|\.py$|\.sh$|Makefile$|\.toml$|\.yaml$|\.yml$|\.env"
    local ignore_patterns="node_modules|\.next|dist|build|venv|\.git|\.agent|package-lock\.json|\.log$|\.tmp$"

    # Get all unstaged and untracked files that match relevant patterns
    local relevant_files=$(git diff --name-only && git ls-files --others --exclude-standard | grep -E "$relevant_patterns" || true)

    # Filter out ignored patterns
    local filtered_files=$(echo "$relevant_files" | grep -vE "$ignore_patterns" || true)

    echo "$filtered_files"
}

# Auto-stage relevant files without agent interaction
auto_stage_relevant_files() {
    local relevant_files="$1"

    if [ -n "$relevant_files" ]; then
        print_color $GREEN "⚡ Auto-staging relevant files..."
        echo "$relevant_files" | while IFS= read -r file; do
            [ -n "$file" ] && echo "  + $file"
        done
        echo "$relevant_files" | xargs git add
        print_color $GREEN "✅ Relevant files staged automatically"
        return 0
    else
        return 1
    fi
}

# Use agent to make staging decisions for complex cases
call_agent_staging_decision() {
    local total_changes="$1"
    local staged_count="$2"
    local unstaged_count="$3"
    local untracked_count="$4"
    local relevant_files="$5"

    print_color $BLUE "🤖 Agent staging decision required..."

    $PROMPTLET_READER file_staging_decision \
        total_changes="$total_changes" \
        staged_count="$staged_count" \
        modified_count="$unstaged_count" \
        untracked_count="$untracked_count" \
        relevant_files="$(echo "$relevant_files" | tr '\n' '|' | sed 's/|$//')" \
        auto_stage_command="AUTO_STAGE=true staging workflow" \
        manual_stage_help="git add <specific-files>"
}

# Handle case when no relevant files are detected
handle_no_relevant_files() {
    local total_changes="$1"
    local unstaged_files="$2"
    local untracked_files="$3"

    print_color $YELLOW "⚠️ No obviously relevant files detected for automatic staging"
    print_color $BLUE "💡 Manual staging may be required"

    $PROMPTLET_READER manual_staging_required \
        total_changes="$total_changes" \
        modified_files="$(echo "$unstaged_files" | tr '\n' '|' | sed 's/|$//')" \
        untracked_files="$(echo "$untracked_files" | tr '\n' '|' | sed 's/|$//')" \
        staging_help="Use git add to stage specific files, then continue commit"

    return 1  # Indicate that staging was not successful
}

# Main staging workflow function
# Returns 0 if files were staged, 1 if no staging occurred, 2 if error
execute_staging_workflow() {
    local auto_stage="${1:-false}"
    local workflow_context="${2:-integrated_commit}"

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
    echo

    # If no unstaged/untracked changes, staging is not needed
    if [ "$((unstaged_count + untracked_count))" -eq 0 ]; then
        if [ "$staged_count" -gt 0 ]; then
            print_color $GREEN "✅ All changes are already staged ($staged_count files)"
            return 0
        else
            print_color $BLUE "ℹ️ No changes found. Working tree is clean."
            return 1
        fi
    fi

    # Show what files would be affected
    if [ "$unstaged_count" -gt 0 ]; then
        print_color $BLUE "📋 Modified files:"
        git diff --name-only | head -10 | sed 's/^/  - /' || true
    fi

    if [ "$untracked_count" -gt 0 ]; then
        print_color $BLUE "📋 Untracked files:"
        git ls-files --others --exclude-standard | head -10 | sed 's/^/  - /' || true
    fi
    echo

    # Detect relevant files for staging
    local relevant_files=$(detect_relevant_files)

    if [ -n "$relevant_files" ]; then
        print_color $GREEN "🎯 Relevant files detected for staging:"
        echo "$relevant_files" | sed 's/^/  + /' | head -15

        if [ "$auto_stage" = "true" ]; then
            auto_stage_relevant_files "$relevant_files"
            return 0
        else
            call_agent_staging_decision "$total_changes" "$staged_count" "$unstaged_count" "$untracked_count" "$relevant_files"
            return 0  # Agent will handle the decision
        fi
    else
        # No relevant files detected
        local unstaged_files=$(git diff --name-only)
        local untracked_files=$(git ls-files --others --exclude-standard)
        handle_no_relevant_files "$total_changes" "$unstaged_files" "$untracked_files"
        return 1
    fi
}

# Display staging status for debugging
show_staging_status() {
    local counts=$(analyze_changes)
    local staged_count=$(echo "$counts" | cut -d: -f1)
    local unstaged_count=$(echo "$counts" | cut -d: -f2)
    local untracked_count=$(echo "$counts" | cut -d: -f3)

    print_color $BLUE "Current staging status:"
    print_color $BLUE "  Staged: $staged_count | Unstaged: $unstaged_count | Untracked: $untracked_count"
}

# Main function dispatcher
main() {
    local function_name="$1"
    shift

    case "$function_name" in
        analyze_changes) analyze_changes "$@" ;;
        detect_relevant_files) detect_relevant_files "$@" ;;
        auto_stage_relevant_files) auto_stage_relevant_files "$@" ;;
        call_agent_staging_decision) call_agent_staging_decision "$@" ;;
        handle_no_relevant_files) handle_no_relevant_files "$@" ;;
        execute_staging_workflow) execute_staging_workflow "$@" ;;
        show_staging_status) show_staging_status "$@" ;;
        -h|--help|help)
            echo "Staging Logic Utility Functions:"
            echo "  analyze_changes                 - Get counts of staged/unstaged/untracked files"
            echo "  detect_relevant_files          - Find files matching staging patterns"
            echo "  auto_stage_relevant_files      - Stage files automatically"
            echo "  execute_staging_workflow       - Run complete staging workflow"
            echo "  show_staging_status            - Display current git status summary"
            ;;
        *)
            echo "Unknown function: $function_name" >&2
            echo "Use --help to see available functions" >&2
            exit 1
            ;;
    esac
}

# Run main function with all arguments if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi