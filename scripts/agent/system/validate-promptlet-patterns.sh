#!/bin/bash

# Configuration-Driven Promptlet Pattern Validator for Online Tables Lite
# Ensures consistent JSON promptlet formats using centralized templates

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_FILE="$SCRIPT_DIR/promptlet-templates.json"

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

# Check if validation should run based on changed files
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
    if echo "$changed_files" | grep -E "(Makefile|scripts/git/.*\\.sh|scripts/git/promptlet-templates\\.json)" >/dev/null 2>&1; then
        return 0
    fi
    
    return 1
}

# Load validation patterns from configuration
load_patterns() {
    if [ ! -f "$TEMPLATES_FILE" ]; then
        print_color $RED "❌ Templates file not found: $TEMPLATES_FILE"
        return 1
    fi
    
    # Extract patterns using basic JSON parsing (avoiding jq dependency)
    JSON_START_PATTERN=$(grep -o '"json_start": "[^"]*"' "$TEMPLATES_FILE" | cut -d'"' -f4)
    AGENT_PATTERN=$(grep -o '"agent_instruction": "[^"]*"' "$TEMPLATES_FILE" | cut -d'"' -f4)
    SECTION_PATTERN=$(grep -o '"section_header": "[^"]*"' "$TEMPLATES_FILE" | cut -d'"' -f4)
}

# Stage 1: Detect forbidden non-JSON promptlet patterns
detect_forbidden_patterns() {
    local line="$1"
    local line_num="$2"
    
    # Forbidden patterns that must be converted to JSON
    local forbidden_patterns=(
        "🤖 Rename when:"
        "🤖 Keep current when:"
        "🤖 Keep when:"
        "🤖.*when:"
        "🤖 .*Task.*:"
        "🤖 [A-Z].*:"
    )
    
    for pattern in "${forbidden_patterns[@]}"; do
        if echo "$line" | grep -q "$pattern"; then
            print_color $RED "❌ Line $line_num: Non-JSON promptlet detected"
            print_color $YELLOW "→ Convert to JSON format using appropriate template"
            print_color $YELLOW "→ Replace with structured JSON object"
            return 1
        fi
    done
    
    return 0
}

# Stage 2: Extract and validate JSON structure
extract_json_block() {
    local file="$1"
    local start_line="$2"
    local json_block=""
    local brace_count=0
    local in_json=false
    local line_count=0
    
    while IFS= read -r line; do
        ((line_count++))
        
        if [ $line_count -ge $start_line ]; then
            if echo "$line" | grep -q '^\s*{\s*$' && [ "$in_json" = false ]; then
                in_json=true
                json_block="$line"
                brace_count=1
                continue
            fi
            
            if [ "$in_json" = true ]; then
                json_block="$json_block"$'\n'"$line"
                
                # Count braces to find JSON end
                local open_braces=$(echo "$line" | grep -o '{' | wc -l | tr -d ' ')
                local close_braces=$(echo "$line" | grep -o '}' | wc -l | tr -d ' ')
                brace_count=$((brace_count + open_braces - close_braces))
                
                if [ $brace_count -eq 0 ]; then
                    echo "$json_block"
                    return 0
                fi
            fi
        fi
    done < "$file"
    
    return 1
}

# Check if line matches valid patterns from configuration  
is_valid_pattern() {
    local line="$1"
    local line_num="$2"
    
    # Stage 1: Check for forbidden non-JSON patterns first
    if ! detect_forbidden_patterns "$line" "$line_num"; then
        return 1
    fi
    
    # Load patterns if not already loaded
    if [ -z "$JSON_START_PATTERN" ]; then
        load_patterns || return 1
    fi
    
    # JSON Task Pattern - proceed to Stage 2 validation
    if echo "$line" | grep -q "$JSON_START_PATTERN"; then
        return 0
    fi
    
    # Agent Instruction Pattern (allowed)
    if echo "$line" | grep -q "$AGENT_PATTERN"; then
        return 0
    fi
    
    # Section Header Pattern (allowed)
    if echo "$line" | grep -q "$SECTION_PATTERN"; then
        return 0
    fi
    
    return 1
}

# Stage 2: Validate JSON structure against templates
validate_json_structure() {
    local file="$1" 
    local start_line="$2"
    
    # Extract complete JSON block
    local json_block
    json_block=$(extract_json_block "$file" "$start_line")
    
    if [ $? -ne 0 ] || [ -z "$json_block" ]; then
        print_color $RED "❌ Line $start_line: Incomplete JSON block"
        print_color $YELLOW "→ Ensure JSON has matching opening and closing braces"
        return 1
    fi
    
    # Validate required structure
    if ! echo "$json_block" | grep -q '"task":\s*{'; then
        print_color $RED "❌ Line $start_line: Missing required 'task' object"
        print_color $YELLOW "→ Add 'task' as root object key"
        print_color $YELLOW "→ Structure: { \"task\": { \"type\": \"...\", \"instructions\": [...] } }"
        return 1
    fi
    
    # Validate required fields
    if ! echo "$json_block" | grep -q '"type":\s*"[^"]*"'; then
        print_color $RED "❌ Line $start_line: Missing required 'task.type' field"
        print_color $YELLOW "→ Add type field: \"type\": \"task_name\""
        print_color $YELLOW "→ Available types: branch_evaluation, branch_name_compliance, pr_description"
        return 1
    fi
    
    if ! echo "$json_block" | grep -q '"instructions":\s*\['; then
        print_color $RED "❌ Line $start_line: Missing required 'task.instructions' field"  
        print_color $YELLOW "→ Add instructions array: \"instructions\": [\"step1\", \"step2\"]"
        return 1
    fi
    
    # Extract and validate task type against templates
    local task_type
    task_type=$(echo "$json_block" | grep -o '"type":\s*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
    
    if [ -n "$task_type" ]; then
        validate_template_match "$task_type" "$start_line" "$json_block"
        if [ $? -ne 0 ]; then
            return 1
        fi
    fi
    
    print_color $GREEN "✅ Line $start_line: Valid JSON structure ($task_type)"
    return 0
}

# Validate JSON against specific template
validate_template_match() {
    local task_type="$1"
    local line_num="$2" 
    local json_block="$3"
    
    # Check if template exists in configuration
    if ! grep -q "\"$task_type\":" "$TEMPLATES_FILE" 2>/dev/null; then
        print_color $YELLOW "⚠️  Line $line_num: Unknown task type '$task_type'"
        print_color $YELLOW "→ Add template for '$task_type' to promptlet-templates.json"
        print_color $YELLOW "→ Or use existing type: branch_evaluation, pr_description, generic_task"
        return 1
    fi
    
    # Template-specific validations
    case "$task_type" in
        "branch_evaluation")
            if ! echo "$json_block" | grep -q '"current_branch":\|"suggested_name":'; then
                print_color $RED "❌ Line $line_num: Missing context fields for branch_evaluation"
                print_color $YELLOW "→ Add: \"current_branch\": \"branch-name\", \"suggested_name\": \"new-name\""
                return 1
            fi
            ;;
        "branch_name_compliance")
            if ! echo "$json_block" | grep -q '"current_branch":\|"validation_errors":'; then
                print_color $RED "❌ Line $line_num: Missing context fields for branch_name_compliance"
                print_color $YELLOW "→ Add: \"current_branch\": \"branch-name\", \"validation_errors\": [...]"
                return 1
            fi
            ;;
        "pr_description")
            if ! echo "$json_block" | grep -q '"branch":\|"commits":'; then
                print_color $RED "❌ Line $line_num: Missing context fields for pr_description"
                print_color $YELLOW "→ Add: \"branch\": \"branch-name\", \"commits\": \"metadata\""
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Validate Makefile JSON generation (echo-based JSON)
validate_makefile_json_generation() {
    local file="$1"
    local start_line="$2"
    
    # Extract all echo statements from the Makefile starting from the JSON block
    local json_lines=""
    local found_echo_statements=()
    
    # Find all echo statements that generate JSON content, starting from the opening brace
    while IFS= read -r line; do
        local line_num=$(echo "$line" | cut -d: -f1)
        local content=$(echo "$line" | cut -d: -f2-)
        
        if [ "$line_num" -ge "$start_line" ]; then
            if echo "$content" | grep -q 'echo.*["\x27]'; then
                # Extract JSON content from echo statement (handle both ' and " quotes)
                local json_part
                if echo "$content" | grep -q "echo.*'"; then
                    json_part=$(echo "$content" | sed "s/.*echo.*'\([^']*\)'.*/\1/")
                else
                    json_part=$(echo "$content" | sed 's/.*echo.*"\([^"]*\)".*/\1/' | sed 's/\\"/"/g')
                fi
                
                found_echo_statements+=("$json_part")
                
                # Stop when we find the closing brace of the JSON
                if echo "$json_part" | grep -q '^[[:space:]]*}[[:space:]]*$'; then
                    break
                fi
            elif echo "$content" | grep -q 'printf.*'; then
                # Handle printf statements for dynamic content
                local printf_content
                printf_content="DYNAMIC_CONTENT"
                found_echo_statements+=("$printf_content")
            fi
        fi
    done < <(grep -n -E "(echo[[:space:]]*[\"']|printf)" "$file")
    
    # Build the complete JSON from found echo statements
    for stmt in "${found_echo_statements[@]}"; do
        if [ -z "$json_lines" ]; then
            json_lines="$stmt"
        else
            json_lines="$json_lines"$'\n'"$stmt"
        fi
    done
    
    if [ -z "$json_lines" ] || [ ${#found_echo_statements[@]} -eq 0 ]; then
        print_color $RED "❌ Line $start_line: Could not extract JSON from echo statements"
        print_color $YELLOW "→ Ensure JSON generation follows proper format"
        return 1
    fi
    
    # Validate the generated JSON structure
    validate_generated_json "$json_lines" "$start_line"
    return $?
}

# Validate generated JSON content
validate_generated_json() {
    local json_content="$1"
    local line_num="$2"
    
    # Basic structure validation
    if ! echo "$json_content" | grep -q '"task"[[:space:]]*:[[:space:]]*{'; then
        print_color $RED "❌ Line $line_num: Generated JSON missing 'task' object"
        print_color $YELLOW "→ Ensure echo statements generate: \"task\": {"
        return 1
    fi
    
    if ! echo "$json_content" | grep -q '"type"[[:space:]]*:[[:space:]]*"[^"]*"'; then
        print_color $RED "❌ Line $line_num: Generated JSON missing 'type' field"
        print_color $YELLOW "→ Add echo statement for: \"type\": \"task_type\""
        return 1
    fi
    
    if ! echo "$json_content" | grep -q '"instructions"[[:space:]]*:[[:space:]]*\['; then
        print_color $RED "❌ Line $line_num: Generated JSON missing 'instructions' array"
        print_color $YELLOW "→ Add echo statements for: \"instructions\": [...]"
        return 1
    fi
    
    # Extract task type for template validation
    local task_type
    task_type=$(echo "$json_content" | grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)".*/\1/')
    
    if [ -n "$task_type" ]; then
        # Template-specific validation
        case "$task_type" in
            "branch_evaluation")
                if ! echo "$json_content" | grep -q '"current_branch"\|"suggested_name"'; then
                    print_color $RED "❌ Line $line_num: Missing context fields for branch_evaluation"
                    print_color $YELLOW "→ Add echo statements for current_branch and suggested_name"
                    return 1
                fi
                ;;
            "documentation_update")
                if ! echo "$json_content" | grep -q '"diff_base"\|"branch"\|"changed_code_files"'; then
                    print_color $RED "❌ Line $line_num: Missing context fields for documentation_update"
                    print_color $YELLOW "→ Add echo/printf statements for diff_base, branch, changed_code_files"
                    return 1
                fi
                ;;
        esac
        
        print_color $GREEN "✅ Line $line_num: Valid generated JSON structure ($task_type)"
    else
        print_color $YELLOW "⚠️  Line $line_num: Could not determine task type from generated JSON"
    fi
    
    return 0
}

# Files to check
check_makefile_patterns() {
    local file="Makefile"
    local issues=0
    
    print_color $BLUE "🔍 Checking Makefile promptlet patterns..."
    
    # Check for robot emoji usage and JSON generation patterns
    local found_json_start=false
    local json_start_line=0
    
    while IFS= read -r line; do
        local line_num=$(echo "$line" | cut -d: -f1)
        local content=$(echo "$line" | cut -d: -f2-)
        
        # Check for JSON generation start (echo "{")
        if echo "$content" | grep -q 'echo[[:space:]]*"{"'; then
            found_json_start=true
            json_start_line=$line_num
            validate_makefile_json_generation "$file" "$line_num"
            if [ $? -ne 0 ]; then
                ((issues++))
            fi
            continue
        fi
        
        # Check for robot emoji patterns
        if echo "$line" | grep -q '🤖'; then
            # Skip simple echo statements that just contain robot emoji for informational purposes
            if echo "$content" | grep -q '^[[:space:]]*@\?echo.*"🤖.*"[[:space:]]*$'; then
                print_color $BLUE "ℹ️  Line $line_num: Informational echo (skipped)"
                continue
            fi
            
            if is_valid_pattern "$content" "$line_num"; then
                # Check if it's a JSON pattern that needs Stage 2 validation
                if echo "$content" | grep -q '^\s*{\s*$'; then
                    validate_json_structure "$file" "$line_num"
                    if [ $? -ne 0 ]; then
                        ((issues++))
                    fi
                else
                    print_color $GREEN "✅ Line $line_num: Valid pattern"
                fi
            else
                ((issues++))
            fi
        fi
    done < <(grep -n -E "(🤖|echo.*\"{\")" "$file" 2>/dev/null || true)
    
    return $issues
}

# Check git scripts
check_git_scripts() {
    local issues=0
    
    print_color $BLUE "🔍 Checking git scripts promptlet patterns..."
    
    for script in scripts/git/*.sh; do
        if [ "$script" = "scripts/git/validate-promptlet-patterns.sh" ]; then
            continue  # Skip self
        fi
        
        if grep -q "🤖\|\"task\":" "$script" 2>/dev/null; then
            print_color $GREEN "✅ $script: Contains promptlet patterns"
            
            # Validate JSON structure if present
            if grep -q "\"task\":" "$script"; then
                # Extract and validate JSON (simplified check)
                if ! grep -A 20 "\"task\":" "$script" | grep -q "\"type\":\|\"instructions\":"; then
                    print_color $RED "❌ $script: Invalid JSON task structure"
                    ((issues++))
                fi
            fi
        fi
    done
    
    return $issues
}

# Suggest standardization
suggest_fixes() {
    print_color $YELLOW "💡 ONLY JSON Pattern Allowed:"
    echo
    echo "1. JSON Task Pattern (ONLY valid format):"
    echo '   {'
    echo '     "task": {'
    echo '       "type": "task_name",'
    echo '       "instructions": ["instruction1", "instruction2"],'
    echo '       "context": { "key": "value" }'
    echo '     }'
    echo '   }'
    echo
    echo "2. Agent Instruction Pattern:"
    echo '   🤖 Agent: Execute JSON task above, then run: make command1 command2'
    echo
    echo "❌ FORBIDDEN Patterns:"
    echo '   - **TASK**: ... (use JSON instead)'
    echo '   - 🤖 Rename when: ... (use JSON task instead)'
    echo '   - Any non-JSON promptlet formats'
}

# Main validation
main() {
    # Performance optimization: only run when relevant files changed
    if ! should_validate "$@"; then
        print_color $GREEN "⚡ Skipping promptlet validation (no relevant files changed)"
        print_color $BLUE "    Use --force to run anyway"
        return 0
    fi
    
    local total_issues=0
    
    print_color $BLUE "🔍 Validating promptlet patterns using configuration..."
    echo
    
    # Check Makefile
    check_makefile_patterns
    total_issues=$((total_issues + $?))
    
    echo
    
    # Check git scripts  
    check_git_scripts
    total_issues=$((total_issues + $?))
    
    echo
    
    if [ $total_issues -eq 0 ]; then
        print_color $GREEN "✅ All promptlet patterns are consistent!"
        return 0
    else
        print_color $RED "❌ Found $total_issues pattern inconsistencies"
        echo
        suggest_fixes
        return 1
    fi
}

# Run validation
main "$@"