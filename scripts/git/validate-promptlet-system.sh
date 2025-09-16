#!/bin/bash

# Multi-Stage Promptlet System Validator
# Ensures complete compliance with single source of truth architecture

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/promptlet-template.json"
PROMPTLETS_FILE="$SCRIPT_DIR/promptlets.json"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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

# Check if validation should run (performance optimization)
should_validate() {
    # Always run if explicitly called
    if [ "$1" = "--force" ]; then
        return 0
    fi
    
    # Check if we're in git context and have staged changes
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        return 0  # Not in git, run validation
    fi
    
    # Get list of staged and modified files
    local changed_files
    changed_files=$(git diff --cached --name-only 2>/dev/null || git diff --name-only 2>/dev/null || true)
    
    # Check if any trigger files are changed
    if echo "$changed_files" | grep -E "(Makefile|scripts/git/.*\\.sh|scripts/git/promptlet.*\\.json)" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Stage 1: Makefile Compliance Validation
# Ensures all agent tasks use promptlet library (no direct echo statements)
validate_makefile_compliance() {
    print_color $BLUE "🔍 Stage 1: Validating Makefile compliance..."
    local issues=0
    
    # Check for forbidden direct echo patterns (agent tasks bypassing promptlet system)
    local forbidden_patterns=(
        "echo.*\"task\".*:"
        "echo.*\"type\".*:"
        "echo.*\"instructions\".*:"
        "printf.*\"task\".*:"
    )
    
    for pattern in "${forbidden_patterns[@]}"; do
        if grep -n "$pattern" "$PROJECT_ROOT/Makefile" >/dev/null 2>&1; then
            local line_nums=$(grep -n "$pattern" "$PROJECT_ROOT/Makefile" | cut -d: -f1 | tr '\n' ', ' | sed 's/,$//')
            print_color $RED "❌ Lines $line_nums: Direct agent task echo detected (bypasses promptlet system)"
            print_color $YELLOW "→ Replace with: ./scripts/git/promptlet-reader.sh <promptlet_name> [variables...]"
            print_color $YELLOW "→ All agent tasks must use promptlet library"
            ((issues++))
        fi
    done
    
    # Check that all promptlet-reader.sh calls reference valid promptlets
    while IFS= read -r line; do
        local line_num=$(echo "$line" | cut -d: -f1)
        local content=$(echo "$line" | cut -d: -f2-)
        
        # Extract promptlet name from the call
        local promptlet_name
        promptlet_name=$(echo "$content" | sed -n 's/.*promptlet-reader\.sh[[:space:]]\+\([^[:space:]]\+\).*/\1/p')
        
        if [ -n "$promptlet_name" ]; then
            # Check if promptlet exists in library
            if ! grep -q "\"$promptlet_name\":" "$PROMPTLETS_FILE" 2>/dev/null; then
                print_color $RED "❌ Line $line_num: Referenced promptlet '$promptlet_name' not found in library"
                print_color $YELLOW "→ Add promptlet to $PROMPTLETS_FILE"
                print_color $YELLOW "→ Or fix reference: available promptlets are $(list_available_promptlets)"
                ((issues++))
            else
                print_color $GREEN "✅ Line $line_num: Valid promptlet reference '$promptlet_name'"
            fi
        fi
    done < <(grep -n "promptlet-reader\.sh" "$PROJECT_ROOT/Makefile" 2>/dev/null || true)
    
    if [ $issues -eq 0 ]; then
        print_color $GREEN "✅ Stage 1: Makefile compliance verified"
    else
        print_color $RED "❌ Stage 1: $issues compliance violations found"
    fi
    
    return $issues
}

# Stage 2: Library Consistency Validation
# Ensures all promptlets in library follow template structure
validate_library_consistency() {
    print_color $BLUE "🔍 Stage 2: Validating library consistency..."
    local issues=0
    
    if [ ! -f "$PROMPTLETS_FILE" ]; then
        print_color $RED "❌ Promptlets library not found: $PROMPTLETS_FILE"
        return 1
    fi
    
    # Get list of promptlets in library (top-level keys only - indented with 2 spaces)
    local promptlets
    promptlets=$(grep '^  "[^"]*"[[:space:]]*:[[:space:]]*{' "$PROMPTLETS_FILE" | sed 's/^  "//; s/"[[:space:]]*:[[:space:]]*{.*//')
    
    for promptlet in $promptlets; do
        print_color $BLUE "  Validating promptlet: $promptlet"
        
        # Extract promptlet JSON
        local promptlet_json
        promptlet_json=$(extract_promptlet_json "$promptlet")
        
        if [ $? -ne 0 ] || [ -z "$promptlet_json" ]; then
            print_color $RED "❌ Promptlet '$promptlet': Failed to extract JSON"
            print_color $YELLOW "→ Check JSON syntax in $PROMPTLETS_FILE"
            ((issues++))
            continue
        fi
        
        # Validate required structure against template
        if ! echo "$promptlet_json" | grep -q '"task"[[:space:]]*:[[:space:]]*{'; then
            print_color $RED "❌ Promptlet '$promptlet': Missing required 'task' object"
            print_color $YELLOW "→ Structure must be: { \"task\": { ... } }"
            ((issues++))
            continue
        fi
        
        if ! echo "$promptlet_json" | grep -q '"type"[[:space:]]*:[[:space:]]*"[^"]*"'; then
            print_color $RED "❌ Promptlet '$promptlet': Missing required 'task.type' field"
            print_color $YELLOW "→ Add: \"type\": \"descriptive_name\""
            ((issues++))
            continue
        fi
        
        if ! echo "$promptlet_json" | grep -q '"instructions"[[:space:]]*:[[:space:]]*\['; then
            print_color $RED "❌ Promptlet '$promptlet': Missing required 'task.instructions' array"
            print_color $YELLOW "→ Add: \"instructions\": [\"step1\", \"step2\"]"
            ((issues++))
            continue
        fi
        
        # Validate type naming convention (snake_case)
        local task_type
        task_type=$(echo "$promptlet_json" | grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
        
        if ! echo "$task_type" | grep -q '^[a-z][a-z0-9_]*$'; then
            print_color $RED "❌ Promptlet '$promptlet': Invalid type format '$task_type'"
            print_color $YELLOW "→ Use snake_case: letters, numbers, underscores only"
            ((issues++))
            continue
        fi
        
        print_color $GREEN "✅ Promptlet '$promptlet': Valid structure ($task_type)"
    done
    
    if [ $issues -eq 0 ]; then
        print_color $GREEN "✅ Stage 2: Library consistency verified"
    else
        print_color $RED "❌ Stage 2: $issues consistency violations found"
    fi
    
    return $issues
}

# Stage 3: Reference Integrity Validation
# Cross-references Makefile usage with library definitions
validate_reference_integrity() {
    print_color $BLUE "🔍 Stage 3: Validating reference integrity..."
    local issues=0
    
    # Get all promptlet references from Makefile
    local referenced_promptlets=()
    while IFS= read -r line; do
        local content=$(echo "$line" | cut -d: -f2-)
        local promptlet_name
        promptlet_name=$(echo "$content" | sed -n 's/.*promptlet-reader\.sh[[:space:]]\+\([^[:space:]]\+\).*/\1/p')
        if [ -n "$promptlet_name" ]; then
            referenced_promptlets+=("$promptlet_name")
        fi
    done < <(grep -n "promptlet-reader\.sh" "$PROJECT_ROOT/Makefile" 2>/dev/null || true)
    
    # Get all promptlets defined in library
    local defined_promptlets=()
    if [ -f "$PROMPTLETS_FILE" ]; then
        while IFS= read -r promptlet; do
            defined_promptlets+=("$promptlet")
        done < <(grep -o '"[^"]*"[[:space:]]*:[[:space:]]*{' "$PROMPTLETS_FILE" | sed 's/"//g' | sed 's/[[:space:]]*:[[:space:]]*{//')
    fi
    
    # Check for missing definitions (referenced but not defined)
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
    
    # Check for orphaned definitions (defined but never used)
    local orphaned_definitions=()
    for def in "${defined_promptlets[@]}"; do
        if [[ ! " ${referenced_promptlets[@]} " =~ " $def " ]]; then
            orphaned_definitions+=("$def")
        fi
    done
    
    if [ ${#orphaned_definitions[@]} -gt 0 ]; then
        print_color $YELLOW "⚠️  Orphaned promptlet definitions (defined but not used): ${orphaned_definitions[*]}"
        print_color $YELLOW "→ Consider removing unused promptlets or add Makefile references"
        # Note: Don't count as hard errors, just warnings
    fi
    
    # Summary
    if [ $issues -eq 0 ]; then
        print_color $GREEN "✅ Stage 3: Reference integrity verified"
        if [ ${#orphaned_definitions[@]} -gt 0 ]; then
            print_color $YELLOW "   (${#orphaned_definitions[@]} orphaned definitions - warnings only)"
        fi
    else
        print_color $RED "❌ Stage 3: $issues integrity violations found"
    fi
    
    return $issues
}

# Helper function to extract promptlet JSON (same as promptlet-reader.sh)
extract_promptlet_json() {
    local promptlet_name="$1"
    local in_promptlet=false
    local brace_count=0
    local json_block=""
    
    while IFS= read -r line; do
        if echo "$line" | grep -q "\"$promptlet_name\"[[:space:]]*:[[:space:]]*{"; then
            in_promptlet=true
            brace_count=1
            json_block="{"
            continue
        fi
        
        if [ "$in_promptlet" = true ]; then
            json_block="$json_block"$'\n'"$line"
            
            local open_braces=$(echo "$line" | grep -o '{' | wc -l | tr -d ' ')
            local close_braces=$(echo "$line" | grep -o '}' | wc -l | tr -d ' ')
            brace_count=$((brace_count + open_braces - close_braces))
            
            if [ $brace_count -eq 0 ]; then
                echo "$json_block"
                return 0
            fi
        fi
    done < "$PROMPTLETS_FILE"
    
    return 1
}

# Helper function to list available promptlets
list_available_promptlets() {
    if [ -f "$PROMPTLETS_FILE" ]; then
        grep -o '"[^"]*"[[:space:]]*:[[:space:]]*{' "$PROMPTLETS_FILE" | sed 's/"//g' | sed 's/[[:space:]]*:[[:space:]]*{//' | tr '\n' ', ' | sed 's/,$//'
    else
        echo "none (file not found)"
    fi
}

# Main validation function
main() {
    local total_issues=0
    
    # Performance optimization: check if validation is needed
    if ! should_validate "$@"; then
        print_color $GREEN "⚡ Skipping promptlet validation (no relevant files changed)"
        print_color $BLUE "    Use --force to run anyway"
        return 0
    fi
    
    print_color $BLUE "🔍 Multi-Stage Promptlet System Validation"
    echo
    
    # Stage 1: Makefile Compliance
    validate_makefile_compliance
    total_issues=$((total_issues + $?))
    echo
    
    # Stage 2: Library Consistency
    validate_library_consistency  
    total_issues=$((total_issues + $?))
    echo
    
    # Stage 3: Reference Integrity
    validate_reference_integrity
    total_issues=$((total_issues + $?))
    echo
    
    # Final summary
    if [ $total_issues -eq 0 ]; then
        print_color $GREEN "✅ All stages passed! Promptlet system is compliant."
        return 0
    else
        print_color $RED "❌ Found $total_issues total violations across all stages"
        print_color $YELLOW "💡 Fix violations above to ensure single source of truth compliance"
        return 1
    fi
}

# Run validation
main "$@"