#!/bin/bash

# Promptlet Reader - Single Source of Truth for Agent Tasks
# Reads promptlets from JSON library and performs variable substitution

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTLETS_FILE="$SCRIPT_DIR/../data/promptlets.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Read promptlet from library and substitute variables
read_promptlet() {
    local promptlet_name="$1"
    shift # Remove first argument, remaining are variable assignments
    
    # Check if promptlets file exists
    if [ ! -f "$PROMPTLETS_FILE" ]; then
        print_color $RED "❌ Promptlets library not found: $PROMPTLETS_FILE"
        return 1
    fi
    
    # Check if promptlet exists in library
    if ! grep -q "\"$promptlet_name\":" "$PROMPTLETS_FILE"; then
        print_color $RED "❌ Promptlet '$promptlet_name' not found in library"
        print_color $YELLOW "→ Add promptlet to $PROMPTLETS_FILE"
        print_color $YELLOW "→ Available promptlets: $(list_promptlets)"
        return 1
    fi
    
    # Extract promptlet JSON block using basic parsing (avoiding jq dependency)
    local promptlet_json
    promptlet_json=$(extract_promptlet_json "$promptlet_name")
    
    if [ $? -ne 0 ] || [ -z "$promptlet_json" ]; then
        print_color $RED "❌ Failed to extract promptlet '$promptlet_name' from library"
        return 1
    fi
    
    # Perform variable substitution using Python (most robust approach)
    local substituted_json="$promptlet_json"
    while [ $# -gt 0 ]; do
        local var_assignment="$1"
        if [[ "$var_assignment" =~ ^([^=]+)=(.*)$ ]]; then
            local var_name="${BASH_REMATCH[1]}"
            local var_value="${BASH_REMATCH[2]}"
            # Use Python for safe string replacement (handles all content types)
            substituted_json=$(VAR_NAME="$var_name" VAR_VALUE="$var_value" python3 -c "
import sys
import os
content = sys.stdin.read()
var_name = os.environ['VAR_NAME']
var_value = os.environ['VAR_VALUE'] 
print(content.replace('\${' + var_name + '}', var_value), end='')
" <<< "$substituted_json")
        fi
        shift
    done
    
    # Output the substituted JSON
    echo "$substituted_json"
    return 0
}

# Extract promptlet JSON block from library file
extract_promptlet_json() {
    local promptlet_name="$1"
    local in_promptlet=false
    local brace_count=0
    local json_block=""
    
    while IFS= read -r line; do
        # Check if we found the start of our promptlet
        if echo "$line" | grep -q "\"$promptlet_name\"[[:space:]]*:[[:space:]]*{"; then
            in_promptlet=true
            brace_count=1
            json_block="{"
            continue
        fi
        
        # If we're inside our promptlet, collect lines and count braces
        if [ "$in_promptlet" = true ]; then
            json_block="$json_block"$'\n'"$line"
            
            # Count opening and closing braces
            local open_braces=$(echo "$line" | grep -o '{' | wc -l | tr -d ' ')
            local close_braces=$(echo "$line" | grep -o '}' | wc -l | tr -d ' ')
            brace_count=$((brace_count + open_braces - close_braces))
            
            # If brace count reaches 0, we've found the end of this promptlet
            if [ $brace_count -eq 0 ]; then
                echo "$json_block"
                return 0
            fi
        fi
    done < "$PROMPTLETS_FILE"
    
    return 1
}

# List available promptlets in library
list_promptlets() {
    grep -o '"[^"]*"[[:space:]]*:[[:space:]]*{' "$PROMPTLETS_FILE" | sed 's/"//g' | sed 's/[[:space:]]*:[[:space:]]*{//' | tr '\n' ', ' | sed 's/,$//'
}

# Validate that promptlet exists and has valid structure
validate_promptlet() {
    local promptlet_name="$1"
    
    # Check if promptlet exists
    if ! grep -q "\"$promptlet_name\":" "$PROMPTLETS_FILE"; then
        return 1
    fi
    
    # Extract and validate structure
    local promptlet_json
    promptlet_json=$(extract_promptlet_json "$promptlet_name")
    
    if [ $? -ne 0 ]; then
        return 1
    fi
    
    # Check required structure: task.type and task.instructions
    if ! echo "$promptlet_json" | grep -q '"task"[[:space:]]*:[[:space:]]*{'; then
        return 1
    fi
    
    if ! echo "$promptlet_json" | grep -q '"type"[[:space:]]*:[[:space:]]*"'; then
        return 1
    fi
    
    if ! echo "$promptlet_json" | grep -q '"instructions"[[:space:]]*:[[:space:]]*\['; then
        return 1
    fi
    
    return 0
}

# Show usage information
show_usage() {
    echo "Usage: read_promptlet <promptlet_name> [variable=value ...]"
    echo ""
    echo "Examples:"
    echo "  read_promptlet branch_evaluation current_branch=\"feat/new-feature\" suggested_name=\"feat/better-name\""
    echo "  read_promptlet documentation_update diff_base=\"abc123\" branch=\"feat/docs\""
    echo ""
    echo "Available promptlets: $(list_promptlets)"
}

# Main function for command line usage
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    read_promptlet "$@"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi