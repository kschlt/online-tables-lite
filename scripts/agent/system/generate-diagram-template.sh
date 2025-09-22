#!/bin/bash

# =============================================================================
# Mermaid Diagram Template Generator
# =============================================================================
#
# Generates a complete Mermaid diagram template using the centralized design
# system configuration from diagram-config.json
#
# Usage:
#   ./generate-diagram-template.sh [template_type]
#   ./generate-diagram-template.sh                    # Standard workflow template
#   ./generate-diagram-template.sh minimal            # Minimal template
#   ./generate-diagram-template.sh architecture       # System architecture template
#
# Output:
#   Complete Mermaid diagram template with all required styling
#
# Examples:
#   ./generate-diagram-template.sh > my-workflow.mmd
#   ./generate-diagram-template.sh minimal > simple-diagram.mmd
# =============================================================================

set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/diagram-config.json"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Configuration file not found: $CONFIG_FILE" >&2
    exit 2
fi

# Check if jq is available
if ! command -v jq >/dev/null 2>&1; then
    echo "❌ Error: jq is required but not installed" >&2
    echo "   Install with: brew install jq (macOS) or apt-get install jq (Ubuntu)" >&2
    exit 2
fi

# =============================================================================
# Template Generation Functions
# =============================================================================

generate_header() {
    echo "$(jq -r '.template.header' "$CONFIG_FILE")"
}

generate_sample_workflow() {
    local template_type="${1:-standard}"

    echo "    %% Entry Point"
    echo "    UserTrigger[\"👤 User: 'action description'\"]"
    echo "    ClaudeDetects[\"🤖 Claude detects trigger\"]"
    echo "    ClaudeExec[\"🤖 Claude executes: make command\"]"
    echo ""
    echo "    %% Main Flow"
    echo "    Step1[\"Process step\"]"
    echo "    Decision1{\"Decision point?\"}"
    echo "    Success[\"✅ Workflow Complete\"]"
    echo "    Stop[\"❌ STOP: Error condition<br/>USER ACTION: What to do\"]"
    echo ""

    if [ "$template_type" = "architecture" ]; then
        echo "    %% System Components"
        echo "    System1[\"📁 System Component\"]"
        echo "    External[\"🐙 External Service\"]"
        echo ""
        echo "    %% Additional Connections"
        echo "    Step1 --> System1"
        echo "    System1 --> External"
        echo ""
    fi

    echo "    %% Connections"
    echo "    UserTrigger --> ClaudeDetects"
    echo "    ClaudeDetects --> ClaudeExec"
    echo "    ClaudeExec --> Step1"
    echo "    Step1 --> Decision1"
    echo "    Decision1 -->|Yes| Success"
    echo "    Decision1 -->|No| Stop"
}

generate_minimal_workflow() {
    echo "    %% Simple Flow"
    echo "    Start[\"🚀 Start Process\"]"
    echo "    Process[\"Process Step\"]"
    echo "    End[\"✅ Complete\"]"
    echo ""
    echo "    %% Connections"
    echo "    Start --> Process"
    echo "    Process --> End"
}

generate_styling() {
    local template_type="${1:-standard}"

    echo ""
    echo "    %% Styling"
    echo "    UserTrigger@{ shape: rect}"

    if [ "$template_type" = "minimal" ]; then
        echo "    Start:::entryPoint"
        echo "    Process:::automationStep"
        echo "    End:::successNode"
    elif [ "$template_type" = "architecture" ]; then
        echo "    UserTrigger:::userLayer"
        echo "    ClaudeDetects:::agentLayer"
        echo "    ClaudeExec:::agentLayer"
        echo "    Step1:::automationStep"
        echo "    Decision1:::automationStep"
        echo "    Success:::successNode"
        echo "    Stop:::stopNode"
        echo "    System1:::automationStep"
        echo "    External:::blackBoxStep"
    else
        echo "    UserTrigger:::userLayer"
        echo "    ClaudeDetects:::agentLayer"
        echo "    ClaudeExec:::agentLayer"
        echo "    Step1:::automationStep"
        echo "    Decision1:::automationStep"
        echo "    Success:::successNode"
        echo "    Stop:::stopNode"
    fi
}

generate_classdefs() {
    echo ""
    echo "    %% Required classDef definitions"

    # Read classDefs from config and output them
    jq -r '.classDefs | to_entries[] | "    classDef \(.key) \(.value)"' "$CONFIG_FILE"
}

generate_subgraph_example() {
    echo ""
    echo "    %% Optional: Subgraph Example"
    echo "    %% subgraph WorkflowBox[\"🤖 WORKFLOW NAME<br>📄 <i>See: script-name.sh</i>\"]"
    echo "    %%     direction TB"
    echo "    %%     SubContent[\"Workflow content\"]"
    echo "    %% end"
    echo "    %% WorkflowBox:::subgraphStyle"
}

# =============================================================================
# Main Template Generation
# =============================================================================

generate_template() {
    local template_type="${1:-standard}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Header with metadata
    echo "#!/usr/bin/mermaid"
    echo "%% Generated by: $(basename "$0")"
    echo "%% Template type: $template_type"
    echo "%% Generated: $timestamp"
    echo "%% Config version: $(jq -r '.metadata.version' "$CONFIG_FILE")"
    echo ""

    # Mermaid diagram
    generate_header

    case "$template_type" in
        "minimal")
            generate_minimal_workflow
            generate_styling "minimal"
            ;;
        "architecture")
            generate_sample_workflow "architecture"
            generate_styling "architecture"
            ;;
        *)
            generate_sample_workflow "standard"
            generate_styling "standard"
            ;;
    esac

    generate_classdefs
    generate_subgraph_example
}

# =============================================================================
# Usage and Help
# =============================================================================

show_usage() {
    echo "Usage: $(basename "$0") [template_type]"
    echo ""
    echo "Template types:"
    echo "  standard      Standard workflow template (default)"
    echo "  minimal       Minimal diagram template"
    echo "  architecture  System architecture template"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") > my-workflow.mmd"
    echo "  $(basename "$0") minimal > simple-diagram.mmd"
    echo "  $(basename "$0") architecture > system-overview.mmd"
    echo ""
    echo "Configuration:"
    echo "  Design system: $CONFIG_FILE"
    echo "  Version: $(jq -r '.metadata.version' "$CONFIG_FILE" 2>/dev/null || echo "unknown")"
}

show_config_info() {
    echo "📋 Current Design System Configuration:"
    echo "=================================================="
    echo "Version: $(jq -r '.metadata.version' "$CONFIG_FILE")"
    echo "Last updated: $(jq -r '.metadata.last_updated' "$CONFIG_FILE")"
    echo ""
    echo "Color Classes:"
    jq -r '.colors | to_entries[] | "  🎨 \(.key): \(.value.hex) (\(.value.name))"' "$CONFIG_FILE"
    echo ""
    echo "Validation Rules: $(jq -r '.validation.consistency_rules | length' "$CONFIG_FILE") rules defined"
    echo "Allowed Colors: $(jq -r '.validation.allowed_colors | length' "$CONFIG_FILE") colors"
    echo "Required Classes: $(jq -r '.validation.required_classdefs | length' "$CONFIG_FILE") classes"
}

# =============================================================================
# Main Script Logic
# =============================================================================

main() {
    local template_type="${1:-standard}"

    case "$template_type" in
        "-h"|"--help"|"help")
            show_usage
            exit 0
            ;;
        "--config"|"config")
            show_config_info
            exit 0
            ;;
        "standard"|"minimal"|"architecture")
            generate_template "$template_type"
            ;;
        *)
            echo "❌ Error: Unknown template type '$template_type'" >&2
            echo "" >&2
            show_usage >&2
            exit 1
            ;;
    esac
}

# =============================================================================
# Script Entry Point
# =============================================================================

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi