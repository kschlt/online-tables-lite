#!/bin/bash

# Work context validation script for Online Tables Lite
# Analyzes actual changes and suggests if branch name matches the work being done

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to analyze file changes and suggest work category
analyze_work_category() {
    local branch="$1"
    local base_ref="${2:-main}"
    
    # Get changed files
    local changed_files=$(git diff --name-only "$base_ref"...HEAD 2>/dev/null || echo "")
    
    if [ -z "$changed_files" ]; then
        echo "unknown"
        return 0
    fi
    
    # Analyze patterns to determine work category
    local has_ui=false
    local has_api=false
    local has_scripts=false
    local has_docs=false
    local has_config=false
    local has_tests=false
    
    while read -r file; do
        case "$file" in
            apps/web/src/components/*|apps/web/src/pages/*|*.tsx|*.css|*.scss)
                has_ui=true ;;
            apps/api/*|*api*|*.py)
                has_api=true ;;
            scripts/*|Makefile|*.sh)
                has_scripts=true ;;
            *.md|docs/*|README*)
                has_docs=true ;;
            *.json|*.toml|*.yaml|*.yml|*.config.*|.*rc*)
                has_config=true ;;
            *test*|*spec*|*.test.*|*.spec.*)
                has_tests=true ;;
        esac
    done <<< "$changed_files"
    
    # Determine primary work category
    if [ "$has_scripts" = true ] && [ "$has_ui" = false ] && [ "$has_api" = false ]; then
        echo "scripts-refactor"
    elif [ "$has_ui" = true ] && [ "$has_api" = false ]; then
        echo "ui-enhancement"
    elif [ "$has_api" = true ] && [ "$has_ui" = false ]; then
        echo "api-enhancement"
    elif [ "$has_ui" = true ] && [ "$has_api" = true ]; then
        echo "fullstack-feature"
    elif [ "$has_config" = true ]; then
        echo "configuration"
    elif [ "$has_tests" = true ]; then
        echo "testing"
    elif [ "$has_docs" = true ]; then
        echo "documentation"
    else
        echo "mixed-changes"
    fi
}

# Function to validate if branch name matches work being done
validate_work_context() {
    local branch="$1"
    local base_ref="${2:-main}"
    
    local work_category=$(analyze_work_category "$branch" "$base_ref")
    local branch_name_clean=$(echo "$branch" | sed 's|^[^/]*/||') # Remove prefix
    
    # Check for obvious mismatches
    case "$work_category" in
        "scripts-refactor")
            if [[ "$branch_name_clean" =~ (ui|frontend|component|page) ]]; then
                echo "mismatch: Branch suggests UI work, but changes are script/tooling focused"
                return 1
            fi
            ;;
        "ui-enhancement")
            if [[ "$branch_name_clean" =~ (api|backend|server|database) ]]; then
                echo "mismatch: Branch suggests API work, but changes are UI focused"
                return 1
            fi
            ;;
        "api-enhancement")
            if [[ "$branch_name_clean" =~ (ui|frontend|component|style) ]]; then
                echo "mismatch: Branch suggests UI work, but changes are API focused"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Function to suggest better branch name based on work
suggest_work_based_name() {
    local current_branch="$1"
    local base_ref="${2:-main}"
    
    local work_category=$(analyze_work_category "$current_branch" "$base_ref")
    local prefix="feat" # Default
    
    # Analyze commits for fix vs feat
    local commit_messages=$(git log --oneline "$base_ref"..HEAD 2>/dev/null | head -5)
    if echo "$commit_messages" | grep -qiE "(fix|bug|error|resolve|repair)"; then
        prefix="fix"
    fi
    
    case "$work_category" in
        "scripts-refactor")
            echo "${prefix}/script-architecture-improvements"
            ;;
        "ui-enhancement")
            echo "${prefix}/ui-component-enhancements"
            ;;
        "api-enhancement")
            echo "${prefix}/api-functionality-updates"
            ;;
        "fullstack-feature")
            echo "${prefix}/fullstack-feature-implementation"
            ;;
        "configuration")
            echo "${prefix}/configuration-updates"
            ;;
        "testing")
            echo "${prefix}/test-improvements"
            ;;
        "documentation")
            echo "docs/documentation-updates"
            ;;
        *)
            echo "${prefix}/mixed-improvements"
            ;;
    esac
}

# Main function
main() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    local mode="${2:-validate}"  # validate|suggest|analyze
    local base_ref="${3:-main}"
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        exit 1
    fi
    
    case "$mode" in
        "validate")
            if mismatch_msg=$(validate_work_context "$branch" "$base_ref"); then
                print_color $GREEN "✅ Branch name appears to match the work being done"
                exit 0
            else
                print_color $YELLOW "⚠️  Potential mismatch detected:"
                print_color $YELLOW "  $mismatch_msg"
                print_color $BLUE "💡 Consider: $(suggest_work_based_name "$branch" "$base_ref")"
                exit 1
            fi
            ;;
        "suggest")
            echo "$(suggest_work_based_name "$branch" "$base_ref")"
            ;;
        "analyze")
            local work_category=$(analyze_work_category "$branch" "$base_ref")
            echo "Work category: $work_category"
            echo "Suggested name: $(suggest_work_based_name "$branch" "$base_ref")"
            ;;
        *)
            print_color $RED "❌ Invalid mode: $mode"
            echo "Usage: $0 [branch_name] [validate|suggest|analyze] [base_ref]"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"