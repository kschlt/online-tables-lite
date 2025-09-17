#!/bin/bash

# Comprehensive Promptlet Compliance Validator
# Uses configuration-driven approach to validate all promptlet sources across the codebase

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/promptlet-sources.json"
PROMPTLETS_FILE="$SCRIPT_DIR/../promptlets/promptlets.json"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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
    echo -e "${color}${message}${NC}"
}

# Check dependencies
check_dependencies() {
    if ! command -v jq >/dev/null 2>&1; then
        print_color $RED "❌ Error: jq is required but not installed"
        print_color $YELLOW "→ Install with: brew install jq (macOS) or apt-get install jq (Ubuntu)"
        exit 1
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_color $RED "❌ Error: Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    if [ ! -f "$PROMPTLETS_FILE" ]; then
        print_color $RED "❌ Error: Promptlets library not found: $PROMPTLETS_FILE"
        exit 1
    fi
}

# Get list of files to monitor from config
get_monitored_files() {
    local source_type="$1"
    jq -r ".monitored_sources.${source_type}.files[]" "$CONFIG_FILE" 2>/dev/null || echo ""
}

# Get patterns for a source type
get_patterns() {
    local source_type="$1"
    jq -r ".monitored_sources.${source_type}.patterns[]" "$CONFIG_FILE" 2>/dev/null || echo ""
}

# Get enforcement level
get_enforcement_level() {
    local source_type="$1"
    jq -r ".monitored_sources.${source_type}.enforcement_level" "$CONFIG_FILE" 2>/dev/null || echo "warning"
}

# Check if file has exceptions
has_exception() {
    local file="$1"
    local filename=$(basename "$file")
    jq -e ".validation_rules.single_source_of_truth.exceptions.\"$filename\"" "$CONFIG_FILE" >/dev/null 2>&1
}

# Get exception reason
get_exception_reason() {
    local file="$1"
    local filename=$(basename "$file")
    jq -r ".validation_rules.single_source_of_truth.exceptions.\"$filename\".reason" "$CONFIG_FILE" 2>/dev/null || echo ""
}

# Validate Makefile targets compliance
validate_makefile_compliance() {
    print_color $BLUE "🔍 Stage 1: Validating Makefile compliance..."
    local issues=0
    
    local patterns
    while IFS= read -r pattern; do
        if [ -n "$pattern" ]; then
            if grep -q "$pattern" "$PROJECT_ROOT/Makefile" 2>/dev/null; then
                local line_nums=$(grep -n "$pattern" "$PROJECT_ROOT/Makefile" | cut -d: -f1 | tr '\n' ', ' | sed 's/,$//')
                print_color $RED "❌ Makefile lines $line_nums: Direct agent task generation detected"
                print_color $YELLOW "→ Pattern: $pattern"
                print_color $YELLOW "→ Replace with: ./scripts/git/promptlet-reader.sh <promptlet_name> [variables...]"
                ((issues++))
            fi
        fi
    done < <(get_patterns "makefile_targets")
    
    if [ $issues -eq 0 ]; then
        print_color $GREEN "✅ Stage 1: Makefile compliance verified"
    else
        print_color $RED "❌ Stage 1: $issues compliance violations found"
    fi
    
    return $issues
}

# Validate git scripts compliance
validate_git_scripts_compliance() {
    print_color $BLUE "🔍 Stage 2: Validating git scripts compliance..."
    local issues=0
    
    local files
    while IFS= read -r file; do
        if [ -n "$file" ] && [ -f "$PROJECT_ROOT/$file" ]; then
            print_color $BLUE "  Checking: $file"
            
            # Check if file has exceptions
            if has_exception "$file"; then
                local reason=$(get_exception_reason "$file")
                print_color $YELLOW "  ⚠️  Exception granted: $reason"
                continue
            fi
            
            local file_issues=0
            local patterns
            while IFS= read -r pattern; do
                if [ -n "$pattern" ]; then
                    if grep -q "$pattern" "$PROJECT_ROOT/$file" 2>/dev/null; then
                        local line_nums=$(grep -n "$pattern" "$PROJECT_ROOT/$file" | cut -d: -f1 | tr '\n' ', ' | sed 's/,$//')
                        local enforcement=$(get_enforcement_level "git_scripts")
                        
                        if [ "$enforcement" = "error" ]; then
                            print_color $RED "❌ $file lines $line_nums: Direct agent task generation detected"
                            ((file_issues++))
                        else
                            print_color $YELLOW "⚠️  $file lines $line_nums: Consider using promptlet library"
                        fi
                        print_color $YELLOW "    Pattern: $pattern"
                    fi
                fi
            done < <(get_patterns "git_scripts")
            
            if [ $file_issues -eq 0 ]; then
                print_color $GREEN "  ✅ $file: Compliant"
            else
                issues=$((issues + file_issues))
            fi
        fi
    done < <(get_monitored_files "git_scripts")
    
    if [ $issues -eq 0 ]; then
        print_color $GREEN "✅ Stage 2: Git scripts compliance verified"
    else
        print_color $RED "❌ Stage 2: $issues compliance violations found"
    fi
    
    return $issues
}

# Validate promptlet references
validate_promptlet_references() {
    print_color $BLUE "🔍 Stage 3: Validating promptlet references..."
    local issues=0
    
    # Get all promptlet references across all monitored files
    local referenced_promptlets=()
    
    # Check Makefile
    while IFS= read -r line; do
        local content=$(echo "$line" | cut -d: -f2-)
        local promptlet_name
        promptlet_name=$(echo "$content" | sed 's/.*promptlet-reader\.sh \([^ ]*\).*/\1/')
        if [ -n "$promptlet_name" ]; then
            referenced_promptlets+=("$promptlet_name")
        fi
    done < <(grep -n "promptlet-reader\.sh" "$PROJECT_ROOT/Makefile" 2>/dev/null || true)
    
    # Check git scripts
    local files
    while IFS= read -r file; do
        if [ -n "$file" ] && [ -f "$PROJECT_ROOT/$file" ]; then
            while IFS= read -r line; do
                local content=$(echo "$line" | cut -d: -f2-)
                local promptlet_name
                promptlet_name=$(echo "$content" | sed 's/.*promptlet-reader\.sh \([^ ]*\).*/\1/')
                if [ -n "$promptlet_name" ]; then
                    referenced_promptlets+=("$promptlet_name")
                fi
            done < <(grep -n "promptlet-reader\.sh" "$PROJECT_ROOT/$file" 2>/dev/null || true)
        fi
    done < <(get_monitored_files "git_scripts")
    
    # Get all defined promptlets
    local defined_promptlets=()
    if [ -f "$PROMPTLETS_FILE" ]; then
        while IFS= read -r promptlet; do
            defined_promptlets+=("$promptlet")
        done < <(grep '^  "[^"]*"[[:space:]]*:[[:space:]]*{' "$PROMPTLETS_FILE" | sed 's/^  "//; s/"[[:space:]]*:[[:space:]]*{.*//')
    fi
    
    # Check for missing definitions
    local missing_definitions=()
    for ref in "${referenced_promptlets[@]}"; do
        if [[ ! " ${defined_promptlets[@]} " =~ " $ref " ]]; then
            missing_definitions+=("$ref")
        fi
    done
    
    if [ ${#missing_definitions[@]} -gt 0 ]; then
        print_color $RED "❌ Missing promptlet definitions: ${missing_definitions[*]}"
        print_color $YELLOW "→ Add missing promptlets to $PROMPTLETS_FILE"
        issues=$((issues + ${#missing_definitions[@]}))
    fi
    
    # Check for orphaned definitions
    local orphaned_definitions=()
    for def in "${defined_promptlets[@]}"; do
        if [[ ! " ${referenced_promptlets[@]} " =~ " $def " ]]; then
            orphaned_definitions+=("$def")
        fi
    done
    
    if [ ${#orphaned_definitions[@]} -gt 0 ]; then
        print_color $YELLOW "⚠️  Orphaned promptlet definitions: ${orphaned_definitions[*]}"
        print_color $YELLOW "→ Consider removing unused promptlets or adding references"
        print_color $BLUE "   Note: Some orphaned promptlets may be used by agent workflows"
    fi
    
    # Summary
    print_color $BLUE "📊 Promptlet Reference Summary:"
    print_color $BLUE "   Referenced: ${#referenced_promptlets[@]} promptlets"
    print_color $BLUE "   Defined: ${#defined_promptlets[@]} promptlets" 
    print_color $BLUE "   Missing: ${#missing_definitions[@]} definitions"
    print_color $BLUE "   Orphaned: ${#orphaned_definitions[@]} definitions"
    
    if [ $issues -eq 0 ]; then
        print_color $GREEN "✅ Stage 3: Promptlet references validated"
    else
        print_color $RED "❌ Stage 3: $issues reference violations found"
    fi
    
    return $issues
}

# Validate no duplicate definitions
validate_no_duplicates() {
    print_color $BLUE "🔍 Stage 4: Validating no duplicate promptlet definitions..."
    local issues=0
    
    # Get list of promptlet names from library
    local defined_promptlets=()
    if [ -f "$PROMPTLETS_FILE" ]; then
        while IFS= read -r promptlet; do
            defined_promptlets+=("$promptlet")
        done < <(grep '^  "[^"]*"[[:space:]]*:[[:space:]]*{' "$PROMPTLETS_FILE" | sed 's/^  "//; s/"[[:space:]]*:[[:space:]]*{.*//')
    fi
    
    # Check for forbidden duplicate definitions
    local forbidden_patterns
    while IFS= read -r pattern; do
        if [ -n "$pattern" ]; then
            # Search all monitored files for this pattern
            local all_files=()
            while IFS= read -r file; do
                [ -n "$file" ] && [ -f "$PROJECT_ROOT/$file" ] && all_files+=("$PROJECT_ROOT/$file")
            done < <(get_monitored_files "makefile_targets"; get_monitored_files "git_scripts")
            
            for file in "${all_files[@]}"; do
                if grep -q "$pattern" "$file" 2>/dev/null; then
                    local matches=$(grep -n "$pattern" "$file" | cut -d: -f1 | tr '\n' ', ' | sed 's/,$//')
                    print_color $RED "❌ $file lines $matches: Duplicate promptlet definition detected"
                    print_color $YELLOW "→ Pattern: $pattern"
                    print_color $YELLOW "→ Remove duplicate and use promptlet library instead"
                    ((issues++))
                fi
            done
        fi
    done < <(jq -r '.validation_rules.no_duplicate_definitions.forbidden_patterns[]' "$CONFIG_FILE" 2>/dev/null || echo "")
    
    if [ $issues -eq 0 ]; then
        print_color $GREEN "✅ Stage 4: No duplicate definitions found"
    else
        print_color $RED "❌ Stage 4: $issues duplicate definition violations found"
    fi
    
    return $issues
}

# Performance check
should_validate() {
    if [ "$1" = "--force" ]; then
        return 0
    fi
    
    # Check if we're in git context and have relevant changes
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        return 0  # Not in git, run validation
    fi
    
    local changed_files
    changed_files=$(git diff --cached --name-only 2>/dev/null || git diff --name-only 2>/dev/null || true)
    
    # Check if any monitored files are changed
    local all_monitored_files=()
    while IFS= read -r file; do
        [ -n "$file" ] && all_monitored_files+=("$file")
    done < <(get_monitored_files "makefile_targets"; get_monitored_files "git_scripts"; echo "$CONFIG_FILE"; echo "$PROMPTLETS_FILE")
    
    for file in "${all_monitored_files[@]}"; do
        if echo "$changed_files" | grep -q "$file" 2>/dev/null; then
            return 0
        fi
    done
    
    return 1
}

# Main validation function
main() {
    local total_issues=0
    
    # Performance optimization
    if ! should_validate "$@"; then
        print_color $GREEN "⚡ Skipping comprehensive promptlet validation (no relevant files changed)"
        print_color $BLUE "    Use --force to run anyway"
        return 0
    fi
    
    check_dependencies
    
    print_color $PURPLE "🔍 Comprehensive Promptlet Compliance Validation"
    print_color $BLUE "📋 Configuration: $CONFIG_FILE"
    echo
    
    # Stage 1: Makefile compliance
    validate_makefile_compliance
    total_issues=$((total_issues + $?))
    echo
    
    # Stage 2: Git scripts compliance  
    validate_git_scripts_compliance
    total_issues=$((total_issues + $?))
    echo
    
    # Stage 3: Promptlet references
    validate_promptlet_references
    total_issues=$((total_issues + $?))
    echo
    
    # Stage 4: No duplicate definitions
    validate_no_duplicates
    total_issues=$((total_issues + $?))
    echo
    
    # Final summary
    if [ $total_issues -eq 0 ]; then
        print_color $GREEN "✅ All validation stages passed! Comprehensive promptlet compliance verified."
        return 0
    else
        print_color $RED "❌ Found $total_issues total violations across all stages"
        print_color $YELLOW "💡 Review configuration in $CONFIG_FILE for compliance requirements"
        return 1
    fi
}

# Run validation
main "$@"