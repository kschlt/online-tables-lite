#!/bin/bash

# Promptlet Reader - Agent Task Generation System
# Reads promptlets from promptlets.json and provides minimal runtime view

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTLETS_FILE="$SCRIPT_DIR/promptlets.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if jq is available
check_jq() {
    if ! command -v jq &> /dev/null; then
        print_color $RED "❌ jq is required but not installed. Please install jq to use this script."
        exit 1
    fi
}

# Read promptlet from promptlets library
read_promptlet() {
    local promptlet_id="$1"
    shift

    if [ ! -f "$PROMPTLETS_FILE" ]; then
        print_color $RED "❌ Promptlets file not found: $PROMPTLETS_FILE"
        exit 1
    fi

    check_jq

    # Find promptlet by ID in array
    local promptlet_json
    promptlet_json=$(jq --arg id "$promptlet_id" '.[] | select(.id == $id)' "$PROMPTLETS_FILE" 2>/dev/null)

    if [ -z "$promptlet_json" ]; then
        print_color $RED "❌ Promptlet '$promptlet_id' not found"
        print_color $YELLOW "→ Available promptlets: $(list_promptlets)"
        exit 1
    fi

    # Extract prompt payload first
    local prompt_payload
    prompt_payload=$(echo "$promptlet_json" | jq '.prompt_payload')

    # Parse input variables and substitute them
    while [ $# -gt 0 ]; do
        local var_assignment="$1"
        if [[ "$var_assignment" =~ ^([^=]+)=(.*)$ ]]; then
            local var_name="${BASH_REMATCH[1]}"
            local var_value="${BASH_REMATCH[2]}"

            # Use Python for safe variable substitution
            prompt_payload=$(VAR_NAME="$var_name" VAR_VALUE="$var_value" python3 -c "
import sys
import os
content = sys.stdin.read()
var_name = os.environ['VAR_NAME']
var_value = os.environ['VAR_VALUE']
print(content.replace('\${' + var_name + '}', var_value), end='')
" <<< "$prompt_payload")
        fi
        shift
    done

    # Create minimal runtime view (task format compatible with agent expectations)
    local runtime_view
    runtime_view=$(echo "$prompt_payload" | jq '{
        task: {
            type: .mode,
            instructions: .instructions,
            context: .context,
            next: .next
        }
    }')

    echo "$runtime_view"
}

# List available promptlets
list_promptlets() {
    if [ -f "$PROMPTLETS_FILE" ]; then
        check_jq && jq -r '.[].id' "$PROMPTLETS_FILE" 2>/dev/null | sort | tr '\n' ', ' | sed 's/,$//'
    else
        echo "No promptlets file found"
    fi
}

# Validate promptlet format and inputs
validate_promptlet() {
    local promptlet_id="$1"

    if [ ! -f "$PROMPTLETS_FILE" ]; then
        print_color $RED "❌ Promptlets file not found: $PROMPTLETS_FILE"
        return 1
    fi

    check_jq

    local promptlet_json
    promptlet_json=$(jq --arg id "$promptlet_id" '.[] | select(.id == $id)' "$PROMPTLETS_FILE" 2>/dev/null)

    if [ -z "$promptlet_json" ]; then
        print_color $RED "❌ Promptlet not found: $promptlet_id"
        return 1
    fi

    print_color $GREEN "✅ Valid promptlet: $promptlet_id"
    return 0
}

# Show usage information
show_usage() {
    echo "Promptlet Reader - Agent Task Generation System"
    echo ""
    echo "Usage: $0 <promptlet_id> [variable=value ...]"
    echo ""
    echo "Examples:"
    echo "  $0 pr-wf.description branch=\"feat/new-feature\" base=\"main\" cliff=\"changelog content\""
    echo "  $0 commit-wf.conventionalmessage staged_files=\"2\" diff_summary=\"Added new feature\""
    echo "  $0 docs-wf.update branch=\"feat/docs\" base=\"main\" changelog=\"Updated docs\""
    echo "  $0 commit-wf.staging total_changes=\"5\" staged_count=\"0\" untracked_count=\"3\""
    echo ""
    echo "Commands:"
    echo "  list       Show all available promptlets"
    echo "  validate   Validate a promptlet exists and is well-formed"
    echo ""
    echo "Available promptlets: $(list_promptlets)"
}

# Main execution logic
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi

    local command="$1"

    case "$command" in
        "list")
            echo "Available promptlets: $(list_promptlets)"
            ;;
        "validate")
            if [ $# -lt 2 ]; then
                echo "Usage: $0 validate <promptlet_id>"
                exit 1
            fi
            validate_promptlet "$2"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            read_promptlet "$@"
            ;;
    esac
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi