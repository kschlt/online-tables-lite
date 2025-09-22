#!/bin/bash

# =============================================================================
# Diagram Consistency Validation Script
# =============================================================================
#
# Validates all Mermaid workflow diagrams against established color and style
# guidelines defined in docs/diagrams/README.md
#
# Usage:
#   ./validate-diagrams.sh [diagram_file]
#   ./validate-diagrams.sh                    # Validates all .mmd files
#   ./validate-diagrams.sh pr-workflow.mmd    # Validates specific file
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation failures found
#   2 - Script error (missing files, etc.)
# =============================================================================

set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")/docs"
DIAGRAMS_DIR="$DOCS_DIR/diagrams"
CONFIG_FILE="$SCRIPT_DIR/diagram-config.json"

# Check if config file exists and jq is available
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Configuration file not found: $CONFIG_FILE" >&2
    exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "❌ Error: jq is required but not installed" >&2
    echo "   Install with: brew install jq (macOS) or apt-get install jq (Ubuntu)" >&2
    exit 2
fi

# Load configuration from JSON
load_config() {
    # Build allowed colors array from config (bash 3.2 compatible)
    local temp_file
    temp_file=$(mktemp)
    jq -r '.validation.allowed_colors[]' "$CONFIG_FILE" > "$temp_file"
    ALLOWED_COLORS=()
    while IFS= read -r line; do
        ALLOWED_COLORS+=("$line")
    done < "$temp_file"
    rm "$temp_file"

    # Load validation patterns
    CLAUDE_PATTERN=$(jq -r '.validation.emoji_patterns.agent_nodes' "$CONFIG_FILE")
    USER_PATTERN=$(jq -r '.validation.emoji_patterns.user_nodes' "$CONFIG_FILE")
    STOP_PATTERN=$(jq -r '.validation.emoji_patterns.stop_nodes' "$CONFIG_FILE")
    SUCCESS_PATTERN=$(jq -r '.validation.emoji_patterns.success_nodes' "$CONFIG_FILE")
}

# Load configuration at startup
load_config

# Global counters
TOTAL_FILES=0
PASSED_FILES=0
TOTAL_ISSUES=0

# =============================================================================
# Utility Functions
# =============================================================================

log_info() {
    echo "ℹ️  $*"
}

log_success() {
    echo "✅ $*"
}

log_warning() {
    echo "⚠️  $*"
}

log_error() {
    echo "❌ $*"
}

# =============================================================================
# Validation Functions
# =============================================================================

validate_required_classdefs() {
    local file="$1"
    local issues=0

    log_info "Checking classDef definitions..."

    # Check that all used classes have corresponding classDef definitions
    local used_classes
    used_classes=$(grep -o ":::[a-zA-Z][a-zA-Z0-9]*" "$file" | sort -u | sed 's/::://' || true)

    if [ -n "$used_classes" ]; then
        while IFS= read -r class_name; do
            if [ -n "$class_name" ]; then
                # Check if there's a classDef definition for this class
                if ! grep -q "classDef $class_name " "$file"; then
                    log_error "Missing classDef definition for used class: $class_name"
                    ((issues++))
                fi
            fi
        done <<< "$used_classes"
    fi

    if [ $issues -eq 0 ]; then
        log_success "All used classes have classDef definitions"
    fi

    return $issues
}

validate_color_palette() {
    local file="$1"
    local issues=0

    log_info "Checking color palette compliance..."

    # Extract all color codes from the file
    local colors
    colors=$(grep -oE '#[0-9a-fA-F]{6}' "$file" | sort -u || true)

    if [ -n "$colors" ]; then
        while IFS= read -r color; do
            local found=false
            for allowed in "${ALLOWED_COLORS[@]}"; do
                if [ "$color" = "$allowed" ]; then
                    found=true
                    break
                fi
            done

            if [ "$found" = false ]; then
                log_error "Non-standard color found: $color (not in approved palette)"
                ((issues++))
            fi
        done <<< "$colors"
    fi

    if [ $issues -eq 0 ]; then
        log_success "All colors comply with standard palette"
    fi

    return $issues
}

validate_node_styling() {
    local file="$1"
    local issues=0

    log_info "Checking node styling patterns..."

    # Simple approach: check for key patterns and suggest improvements
    # This is more about guidance than strict enforcement

    # Check if Claude nodes have appropriate styling
    local claude_count user_count stop_count success_count
    claude_count=$(grep -c "🤖\|Claude" "$file" || true)
    user_count=$(grep -c "👤\|User:" "$file" || true)
    stop_count=$(grep -c "❌.*STOP\|STOP.*❌" "$file" || true)
    success_count=$(grep -c "✅.*Complete\|Complete.*✅" "$file" || true)

    local agent_styling_count user_styling_count stop_styling_count success_styling_count
    agent_styling_count=$(grep -c ":::agentLayer" "$file" || true)
    user_styling_count=$(grep -c ":::userLayer" "$file" || true)
    stop_styling_count=$(grep -c ":::stopNode" "$file" || true)
    success_styling_count=$(grep -c ":::successNode" "$file" || true)

    # Provide guidance based on counts
    if [ "$claude_count" -gt 0 ] && [ "$agent_styling_count" -eq 0 ]; then
        log_warning "Found $claude_count Claude/🤖 nodes but no agentLayer styling applied"
        ((issues++))
    fi

    if [ "$user_count" -gt 0 ] && [ "$user_styling_count" -eq 0 ]; then
        log_warning "Found $user_count User/👤 nodes but no userLayer styling applied"
        ((issues++))
    fi

    if [ "$stop_count" -gt 0 ] && [ "$stop_styling_count" -eq 0 ]; then
        log_warning "Found $stop_count STOP nodes but no stopNode styling applied"
        ((issues++))
    fi

    if [ "$success_count" -gt 0 ] && [ "$success_styling_count" -eq 0 ]; then
        log_warning "Found $success_count success nodes but no successNode styling applied"
        ((issues++))
    fi

    if [ $issues -eq 0 ]; then
        log_success "Node styling patterns look good"
    fi

    return $issues
}

validate_subgraph_styling() {
    local file="$1"
    local issues=0

    log_info "Checking subgraph styling..."

    # Check if subgraphs exist and if they use proper styling
    if grep -q "subgraph" "$file"; then
        if ! grep -q "subgraphStyle" "$file"; then
            log_warning "Subgraphs found but subgraphStyle class not applied"
            ((issues++))
        fi
    fi

    if [ $issues -eq 0 ]; then
        log_success "Subgraph styling is correct"
    fi

    return $issues
}

validate_emoji_consistency() {
    local file="$1"
    local issues=0

    log_info "Checking emoji consistency..."

    # Load emoji standards from config
    local user_emoji agent_emoji
    user_emoji=$(jq -r '.standard_emojis.user' "$CONFIG_FILE")
    agent_emoji=$(jq -r '.standard_emojis.agent' "$CONFIG_FILE")

    # Check for proper emoji usage
    if grep -q "Claude" "$file" && ! grep -q "$agent_emoji" "$file"; then
        log_warning "Claude mentioned but no $agent_emoji emoji found"
        ((issues++))
    fi

    # Check for user interaction patterns
    if grep -q "User:" "$file" && ! grep -q "$user_emoji" "$file"; then
        log_warning "User interactions found but no $user_emoji emoji used"
        ((issues++))
    fi

    # Check for stop nodes without proper emoji
    if grep -q "STOP" "$file" && ! grep -q "❌\|⚠️" "$file"; then
        log_warning "Stop nodes found but missing error/warning emojis"
        ((issues++))
    fi

    if [ $issues -eq 0 ]; then
        log_success "Emoji usage is consistent"
    fi

    return $issues
}

# =============================================================================
# Main Validation Function
# =============================================================================

validate_diagram() {
    local file="$1"
    local filename
    filename=$(basename "$file")

    echo
    echo "🔍 Validating: $filename"
    echo "=================================================="

    local total_issues=0

    # Run all validation checks
    validate_required_classdefs "$file" || total_issues=$((total_issues + $?))
    validate_color_palette "$file" || total_issues=$((total_issues + $?))
    validate_node_styling "$file" || total_issues=$((total_issues + $?))
    validate_subgraph_styling "$file" || total_issues=$((total_issues + $?))
    validate_emoji_consistency "$file" || total_issues=$((total_issues + $?))

    echo
    if [ $total_issues -eq 0 ]; then
        log_success "$filename: All validations passed ✨"
        ((PASSED_FILES++))
    else
        log_error "$filename: $total_issues issues found"
    fi

    ((TOTAL_FILES++))
    TOTAL_ISSUES=$((TOTAL_ISSUES + total_issues))

    return $total_issues
}

# =============================================================================
# Main Script Logic
# =============================================================================

main() {
    log_info "Mermaid Diagram Validation"
    log_info "Config: $CONFIG_FILE (v$(jq -r '.metadata.version' "$CONFIG_FILE"))"
    log_info "Guidelines: $DOCS_DIR/diagrams/README.md"
    echo

    # Check if diagrams directory exists
    if [ ! -d "$DIAGRAMS_DIR" ]; then
        log_error "Diagrams directory not found: $DIAGRAMS_DIR"
        exit 2
    fi

    # Determine files to validate
    local files_to_check=()

    if [ $# -eq 0 ]; then
        # No arguments - validate all .mmd files
        while IFS= read -r -d '' file; do
            files_to_check+=("$file")
        done < <(find "$DIAGRAMS_DIR" -name "*.mmd" -print0)

        if [ ${#files_to_check[@]} -eq 0 ]; then
            log_warning "No .mmd files found in $DIAGRAMS_DIR"
            exit 0
        fi

        log_info "Found ${#files_to_check[@]} diagram files to validate"
    else
        # Specific file provided
        local target_file="$1"

        # Check if it's a relative path from diagrams directory
        if [ -f "$DIAGRAMS_DIR/$target_file" ]; then
            files_to_check+=("$DIAGRAMS_DIR/$target_file")
        elif [ -f "$target_file" ]; then
            files_to_check+=("$target_file")
        else
            log_error "File not found: $target_file"
            exit 2
        fi
    fi

    # Validate each file
    local overall_result=0

    for file in "${files_to_check[@]}"; do
        if ! validate_diagram "$file"; then
            overall_result=1
        fi
    done

    # Summary
    echo
    echo "=================================================="
    echo "📊 VALIDATION SUMMARY"
    echo "=================================================="
    echo "Files validated: $TOTAL_FILES"
    echo "Files passed: $PASSED_FILES"
    echo "Files failed: $((TOTAL_FILES - PASSED_FILES))"
    echo "Total issues: $TOTAL_ISSUES"
    echo

    if [ $overall_result -eq 0 ]; then
        log_success "All diagram validations passed! 🎉"
    else
        log_error "Some validations failed. See issues above."
        echo
        log_info "Refer to diagram guidelines: $DOCS_DIR/diagrams/README.md"
    fi

    exit $overall_result
}

# =============================================================================
# Script Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi