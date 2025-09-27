#!/bin/bash

# =============================================================================
# Agent System Validation Script
# =============================================================================
#
# Comprehensive validation of the entire agent system including:
# - Mermaid diagram compliance and consistency
# - Promptlet system validation and patterns
# - Agent script validation
#
# Usage:
#   ./validate-agent-system.sh [--force]
#   ./validate-agent-system.sh                    # Smart change detection
#   ./validate-agent-system.sh --force            # Force validation regardless of changes
#
# Exit codes:
#   0 - All validations passed
#   1 - Validation failures found
#   2 - Script error (missing dependencies, etc.)
# =============================================================================

set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$AGENT_DIR/.." && pwd)"

# Validation scripts
VALIDATE_DIAGRAMS="$SCRIPT_DIR/validate-diagrams.sh"
VALIDATE_PROMPTLETS="$SCRIPT_DIR/validate-promptlet-compliance.sh"

# Paths to validate
DIAGRAMS_DIR="$AGENT_DIR/docs/diagrams"
PROMPTLETS_FILE="$AGENT_DIR/promptlets/promptlets.json"

# Global counters
TOTAL_VALIDATIONS=0
PASSED_VALIDATIONS=0
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

log_header() {
    echo
    echo "=================================================="
    echo "🔍 $*"
    echo "=================================================="
}

# =============================================================================
# Change Detection Functions
# =============================================================================

has_git_changes() {
    local path="$1"

    # Check if we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        # Not in git repo, always validate
        return 0
    fi

    # Check for unstaged changes
    if git diff --quiet HEAD -- "$path" 2>/dev/null; then
        # Check for staged changes
        if git diff --cached --quiet HEAD -- "$path" 2>/dev/null; then
            # No changes detected
            return 1
        fi
    fi

    # Changes detected
    return 0
}

should_validate_component() {
    local component_name="$1"
    local path="$2"
    local force="$3"

    if [ "$force" = true ]; then
        log_info "$component_name: Force mode - validating regardless of changes"
        return 0
    fi

    if [ ! -e "$path" ]; then
        log_warning "$component_name: Path does not exist: $path"
        return 1
    fi

    if has_git_changes "$path"; then
        log_info "$component_name: Changes detected - validation required"
        return 0
    else
        log_info "$component_name: No changes detected - skipping validation"
        return 1
    fi
}

# =============================================================================
# Validation Functions
# =============================================================================

validate_diagrams() {
    log_header "DIAGRAM VALIDATION"

    if ! should_validate_component "Diagrams" "$DIAGRAMS_DIR" "$FORCE_VALIDATION"; then
        log_info "Skipping diagram validation - no changes detected"
        return 0
    fi

    ((TOTAL_VALIDATIONS++))

    if [ ! -f "$VALIDATE_DIAGRAMS" ]; then
        log_error "Diagram validation script not found: $VALIDATE_DIAGRAMS"
        return 1
    fi

    if [ ! -d "$DIAGRAMS_DIR" ]; then
        log_error "Diagrams directory not found: $DIAGRAMS_DIR"
        return 1
    fi

    log_info "Running diagram validation on: $DIAGRAMS_DIR"

    if "$VALIDATE_DIAGRAMS" >/dev/null 2>&1; then
        log_success "All diagrams passed validation"
        ((PASSED_VALIDATIONS++))
        return 0
    else
        log_error "Diagram validation failed - running detailed check:"
        echo
        "$VALIDATE_DIAGRAMS" || true
        return 1
    fi
}

validate_promptlets() {
    log_header "PROMPTLET VALIDATION"

    if ! should_validate_component "Promptlets" "$PROMPTLETS_FILE" "$FORCE_VALIDATION"; then
        log_info "Skipping promptlet validation - no changes detected"
        return 0
    fi

    ((TOTAL_VALIDATIONS++))

    if [ ! -f "$VALIDATE_PROMPTLETS" ]; then
        log_error "Promptlet validation script not found: $VALIDATE_PROMPTLETS"
        return 1
    fi

    if [ ! -f "$PROMPTLETS_FILE" ]; then
        log_error "Promptlets file not found: $PROMPTLETS_FILE"
        return 1
    fi

    log_info "Running promptlet validation on: $PROMPTLETS_FILE"

    if "$VALIDATE_PROMPTLETS" >/dev/null 2>&1; then
        log_success "All promptlets passed validation"
        ((PASSED_VALIDATIONS++))
        return 0
    else
        log_error "Promptlet validation failed - running detailed check:"
        echo
        "$VALIDATE_PROMPTLETS" || true
        return 1
    fi
}

validate_system_integration() {
    log_header "SYSTEM INTEGRATION CHECK"

    ((TOTAL_VALIDATIONS++))

    # Check that all required scripts exist
    local required_scripts=(
        "$VALIDATE_DIAGRAMS"
        "$VALIDATE_PROMPTLETS"
    )

    local missing_scripts=0
    for script in "${required_scripts[@]}"; do
        if [ ! -f "$script" ]; then
            log_error "Required validation script missing: $script"
            ((missing_scripts++))
        fi
    done

    if [ $missing_scripts -gt 0 ]; then
        log_error "System integration check failed: $missing_scripts required scripts missing"
        return 1
    fi

    # Check that all required directories exist
    local required_dirs=(
        "$DIAGRAMS_DIR"
        "$(dirname "$PROMPTLETS_FILE")"
    )

    local missing_dirs=0
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            log_error "Required directory missing: $dir"
            ((missing_dirs++))
        fi
    done

    if [ $missing_dirs -gt 0 ]; then
        log_error "System integration check failed: $missing_dirs required directories missing"
        return 1
    fi

    log_success "System integration check passed"
    ((PASSED_VALIDATIONS++))
    return 0
}

# =============================================================================
# Main Validation Function
# =============================================================================

run_all_validations() {
    log_header "AGENT SYSTEM VALIDATION"
    log_info "Agent directory: $AGENT_DIR"
    log_info "Project root: $PROJECT_ROOT"
    echo

    # Check if force mode is enabled
    if [ "$FORCE_VALIDATION" = true ]; then
        log_info "Force mode enabled - all validations will run"
    else
        log_info "Smart mode enabled - only changed components will be validated"
    fi

    local overall_result=0

    # Run system integration check first
    if ! validate_system_integration; then
        overall_result=1
    fi

    # Run diagram validation
    if ! validate_diagrams; then
        overall_result=1
    fi

    # Run promptlet validation
    if ! validate_promptlets; then
        overall_result=1
    fi

    return $overall_result
}

# =============================================================================
# Summary and Exit
# =============================================================================

show_summary() {
    local exit_code=$1

    echo
    log_header "VALIDATION SUMMARY"
    echo "Total validations: $TOTAL_VALIDATIONS"
    echo "Passed validations: $PASSED_VALIDATIONS"
    echo "Failed validations: $((TOTAL_VALIDATIONS - PASSED_VALIDATIONS))"
    echo "Total issues: $TOTAL_ISSUES"
    echo

    if [ $exit_code -eq 0 ]; then
        if [ $TOTAL_VALIDATIONS -eq 0 ]; then
            log_info "No validations required - no changes detected"
        else
            log_success "All agent system validations passed! 🎉"
        fi
    else
        log_error "Some agent system validations failed"
        echo
        log_info "To fix issues:"
        log_info "- Check diagram compliance: $VALIDATE_DIAGRAMS"
        log_info "- Check promptlet compliance: $VALIDATE_PROMPTLETS"
        log_info "- Force validation: $0 --force"
    fi
}

# =============================================================================
# Usage and Help
# =============================================================================

show_usage() {
    echo "Usage: $(basename "$0") [options]"
    echo ""
    echo "Options:"
    echo "  --force     Force validation regardless of file changes"
    echo "  --help      Show this help message"
    echo ""
    echo "Agent System Validation includes:"
    echo "  🎨 Diagram compliance (Mermaid files in $DIAGRAMS_DIR)"
    echo "  📋 Promptlet validation ($PROMPTLETS_FILE)"
    echo "  🔧 System integration checks"
    echo ""
    echo "Smart Change Detection:"
    echo "  - Only validates components with git changes (default)"
    echo "  - Use --force to validate all components regardless of changes"
    echo "  - Optimizes CI/CD performance by skipping unchanged components"
}

# =============================================================================
# Main Script Logic
# =============================================================================

main() {
    local force_validation=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                force_validation=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage >&2
                exit 2
                ;;
        esac
    done

    # Export force flag for use in functions
    export FORCE_VALIDATION=$force_validation

    # Check dependencies
    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq is required but not installed"
        log_info "Install with: brew install jq (macOS) or apt-get install jq (Ubuntu)"
        exit 2
    fi

    # Run validations
    local exit_code=0
    if ! run_all_validations; then
        exit_code=1
    fi

    # Show summary
    show_summary $exit_code

    exit $exit_code
}

# =============================================================================
# Script Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi