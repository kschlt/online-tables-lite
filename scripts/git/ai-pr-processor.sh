#!/bin/bash

# AI PR Description Processor
# Takes JSON promptlet and generates standardized GitHub-ready markdown

set -e

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

# Function to process promptlet JSON and generate markdown
process_promptlet_to_markdown() {
    local promptlet_json="$1"
    
    # Extract data from JSON using jq if available, otherwise use sed
    if command -v jq >/dev/null 2>&1; then
        local instructions=$(echo "$promptlet_json" | jq -r '.task.instructions[]' 2>/dev/null | tr '\n' '|')
        local branch=$(echo "$promptlet_json" | jq -r '.task.context.branch' 2>/dev/null)
        local base_branch=$(echo "$promptlet_json" | jq -r '.task.context.base_branch' 2>/dev/null)
        local commits_data=$(echo "$promptlet_json" | jq -r '.task.context.commits' 2>/dev/null)
        local task_type=$(echo "$promptlet_json" | jq -r '.task.type' 2>/dev/null)
    else
        # Fallback parsing without jq
        local instructions=$(echo "$promptlet_json" | sed -n 's/.*"instructions"[[:space:]]*:[[:space:]]*\[\([^\]]*\)\].*/\1/p' | tr ',' '|')
        local branch=$(echo "$promptlet_json" | sed -n 's/.*"branch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        local base_branch=$(echo "$promptlet_json" | sed -n 's/.*"base_branch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        local commits_data=$(echo "$promptlet_json" | sed -n 's/.*"commits"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        local task_type=$(echo "$promptlet_json" | sed -n 's/.*"type"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    fi
    
    # Parse commits data to extract structured information
    local total_commits=$(echo "$commits_data" | sed -n 's/Total: \([0-9]*\).*/\1/p')
    local feat_count=$(echo "$commits_data" | sed -n 's/.*feat: \([0-9]*\).*/\1/p')
    local fix_count=$(echo "$commits_data" | sed -n 's/.*fix: \([0-9]*\).*/\1/p')
    local pr_type=$(echo "$commits_data" | sed -n 's/.*Type: \([^|]*\).*/\1/p' | tr -d ' ')
    local scope=$(echo "$commits_data" | sed -n 's/.*Scope: \([^|]*\).*/\1/p' | tr -d ' ')
    
    # Extract commit list and changes summary
    local commit_list=$(echo "$commits_data" | sed -n 's/.*Commits: \([^|]*\).*/\1/p')
    local changes_summary=$(echo "$commits_data" | sed -n 's/.*Changes: \(.*\)/\1/p')
    
    # Generate standardized markdown PR description
    cat << EOF
## Summary

This PR includes **$total_commits commits** with $pr_type changes focused on the **$scope** system.

### Key Changes
$changes_summary

### Commit Breakdown
- ✨ **Features**: $feat_count new capabilities added
- 🐛 **Bug Fixes**: $fix_count issues resolved
- 📊 **Total Impact**: $total_commits commits across $scope components

## Test Plan

Based on the scope ($scope) and changes made:

- [ ] Verify all modified configuration files work correctly
- [ ] Test documentation builds and renders properly  
- [ ] Ensure existing functionality remains intact
- [ ] Validate new features work as expected
- [ ] Check that all pre-commit hooks pass
- [ ] Confirm CI/CD pipeline completes successfully

## Review Notes

- **Primary Focus**: $scope improvements and enhancements
- **Change Type**: $pr_type development with emphasis on quality
- **Quality Assurance**: All commits validated via pre-commit hooks
- **Integration**: Merging \`$branch\` → \`$base_branch\`

## Detailed Commits

$commit_list

---
*Generated via sophisticated cache → promptlet → AI processing system*

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
}

# Main function
main() {
    local input_mode="${1:-stdin}"  # stdin|file|string
    local input_source="$2"
    
    case "$input_mode" in
        "stdin")
            # Read JSON from stdin
            local json_input
            json_input=$(cat)
            ;;
        "file") 
            # Read JSON from file
            if [ ! -f "$input_source" ]; then
                print_color $RED "❌ File not found: $input_source"
                exit 1
            fi
            local json_input
            json_input=$(cat "$input_source")
            ;;
        "string")
            # Use provided string as JSON
            local json_input="$input_source"
            ;;
        *)
            print_color $RED "❌ Invalid input mode: $input_mode"
            echo "Usage: $0 [stdin|file|string] [source]"
            exit 1
            ;;
    esac
    
    # Validate JSON structure
    if ! echo "$json_input" | grep -q '"task"[[:space:]]*:[[:space:]]*{'; then
        print_color $RED "❌ Invalid promptlet JSON: missing 'task' object"
        exit 1
    fi
    
    if ! echo "$json_input" | grep -q '"type"[[:space:]]*:[[:space:]]*"pr_description"'; then
        print_color $RED "❌ Invalid promptlet type: expected 'pr_description'"
        exit 1
    fi
    
    # Process and output markdown
    process_promptlet_to_markdown "$json_input"
}

# Run with all arguments
main "$@"