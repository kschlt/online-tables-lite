#!/bin/bash

# Documentation Discovery Script
# Uses docs-config.json to find and categorize all documentation files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../../" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/docs-config.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "${GREEN}[DOCS-DISCOVERY]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[DOCS-DISCOVERY]${NC} $1"
}

error() {
    echo -e "${RED}[DOCS-DISCOVERY]${NC} $1"
}

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Function to check if jq is available
check_jq() {
    if ! command -v jq &> /dev/null; then
        error "jq is required but not installed. Please install jq to use this script."
        exit 1
    fi
}

# Function to discover files using patterns
discover_files() {
    local pattern="$1"
    local exclude_patterns="$2"

    cd "$PROJECT_ROOT"

    # Build find command with exclusions
    local find_cmd="find . -type f -name '$pattern'"

    # Add exclusions
    if [[ -n "$exclude_patterns" ]]; then
        while read -r exclude; do
            if [[ -n "$exclude" ]]; then
                find_cmd="$find_cmd ! -path '$exclude'"
            fi
        done <<< "$exclude_patterns"
    fi

    # Execute find command and clean up paths
    eval "$find_cmd" | sed 's|^\./||' | sort
}

# Function to get all documentation files
get_all_docs() {
    local output_format="${1:-paths_only}"

    check_jq

    cd "$PROJECT_ROOT"

    case "$output_format" in
        "list")
            echo "# Documentation Files"
            echo ""
            ;;
        "json")
            echo "{"
            echo '  "discovered_files": {'
            ;;
    esac

    # Get static paths from config
    local categories=(
        "root_docs"
        "app_docs"
        "agent_docs"
        "scripts_docs"
        "infrastructure_docs"
        "config_docs"
    )

    # Create temporary file to store file mappings
    local temp_files=$(mktemp)

    # Add static files from config
    for category in "${categories[@]}"; do
        local files
        files=$(jq -r ".documentation_paths.${category}[]?" "$CONFIG_FILE" 2>/dev/null || true)

        if [[ -n "$files" ]]; then
            while IFS= read -r file; do
                if [[ -n "$file" && -f "$file" ]]; then
                    echo "$file|$category" >> "$temp_files"
                fi
            done <<< "$files"
        fi
    done

    # Add auto-discovered files
    local patterns
    patterns=$(jq -r '.auto_discovery.patterns[].pattern' "$CONFIG_FILE")

    while IFS= read -r pattern; do
        if [[ -n "$pattern" ]]; then
            local exclude_patterns
            exclude_patterns=$(jq -r --arg pat "$pattern" '.auto_discovery.patterns[] | select(.pattern == $pat) | .exclude_patterns[]?' "$CONFIG_FILE" 2>/dev/null || echo "")

            local discovered_files
            discovered_files=$(discover_files "$pattern" "$exclude_patterns")

            while IFS= read -r file; do
                if [[ -n "$file" && -f "$file" ]]; then
                    # Categorize the file
                    local category="auto_discovered"

                    # Check categorization rules
                    local cats
                    cats=$(jq -r '.categorization | keys[]' "$CONFIG_FILE")

                    while IFS= read -r cat; do
                        local cat_patterns
                        cat_patterns=$(jq -r --arg cat "$cat" '.categorization[$cat].patterns[]' "$CONFIG_FILE")

                        while IFS= read -r cat_pattern; do
                            if [[ "$file" == $cat_pattern ]]; then
                                category="$cat"
                                break 2
                            fi
                        done <<< "$cat_patterns"
                    done <<< "$cats"

                    echo "$file|$category" >> "$temp_files"
                fi
            done <<< "$discovered_files"
        fi
    done <<< "$patterns"

    # Output results
    case "$output_format" in
        "list")
            while IFS='|' read -r file category; do
                echo "- $file ($category)"
            done < "$temp_files" | sort
            ;;
        "paths_only")
            cut -d'|' -f1 "$temp_files" | sort
            ;;
        "json")
            echo "{"
            echo '  "discovered_files": {'
            local categories_seen=()
            local first=true

            for category in $(cut -d'|' -f2 "$temp_files" | sort -u); do
                if [[ "$first" == true ]]; then
                    first=false
                else
                    echo ","
                fi
                echo -n "    \"$category\": ["

                local cat_first=true
                while IFS='|' read -r file cat; do
                    if [[ "$cat" == "$category" ]]; then
                        if [[ "$cat_first" == true ]]; then
                            cat_first=false
                        else
                            echo -n ","
                        fi
                        echo -n "\"$file\""
                    fi
                done < "$temp_files"
                echo -n "]"
            done
            echo ""
            echo "  },"
            echo "  \"total_files\": $(wc -l < "$temp_files" | tr -d ' '),"
            echo "  \"scan_timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\""
            echo "}"
            ;;
        "categories")
            for category in $(cut -d'|' -f2 "$temp_files" | sort -u); do
                echo "## $category"
                while IFS='|' read -r file cat; do
                    if [[ "$cat" == "$category" ]]; then
                        echo "- $file"
                    fi
                done < "$temp_files"
                echo ""
            done
            ;;
    esac

    # Cleanup temporary file
    rm -f "$temp_files"
}

# Function to validate required files
validate_docs() {
    check_jq

    cd "$PROJECT_ROOT"

    log "Validating documentation structure..."

    local required_files
    required_files=$(jq -r '.validation.required_files[]' "$CONFIG_FILE")

    local missing_files=()

    while IFS= read -r file; do
        if [[ -n "$file" && ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done <<< "$required_files"

    if [[ ${#missing_files[@]} -gt 0 ]]; then
        error "Missing required documentation files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    else
        log "All required documentation files are present"
    fi

    local recommended_files
    recommended_files=$(jq -r '.validation.recommended_files[]' "$CONFIG_FILE")

    local missing_recommended=()

    while IFS= read -r file; do
        if [[ -n "$file" && ! -f "$file" ]]; then
            missing_recommended+=("$file")
        fi
    done <<< "$recommended_files"

    if [[ ${#missing_recommended[@]} -gt 0 ]]; then
        warn "Missing recommended documentation files:"
        for file in "${missing_recommended[@]}"; do
            echo "  - $file"
        done
    fi

    return 0
}

# Function to update config with current scan
update_scan_metadata() {
    check_jq

    local file_count
    file_count=$(get_all_docs "paths_only" | wc -l | tr -d ' ')

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update metadata in config file
    local temp_config
    temp_config=$(mktemp)

    jq --arg timestamp "$timestamp" --arg count "$file_count" '
        .metadata.last_scan = $timestamp |
        .metadata.total_files = ($count | tonumber) |
        .metadata.scan_history += [{"timestamp": $timestamp, "file_count": ($count | tonumber)}] |
        .metadata.scan_history |= if length > 10 then .[1:] else . end
    ' "$CONFIG_FILE" > "$temp_config"

    mv "$temp_config" "$CONFIG_FILE"

    log "Updated scan metadata: $file_count files found at $timestamp"
}

# Main function
main() {
    local command="${1:-list}"
    local format="${2:-paths_only}"

    case "$command" in
        "discover"|"list")
            get_all_docs "$format"
            ;;
        "validate")
            validate_docs
            ;;
        "update")
            update_scan_metadata
            ;;
        "scan")
            log "Scanning for documentation files..."
            get_all_docs "$format"
            update_scan_metadata
            ;;
        "help"|"-h"|"--help")
            echo "Documentation Discovery Script"
            echo ""
            echo "Usage: $0 [command] [format]"
            echo ""
            echo "Commands:"
            echo "  discover, list    Discover and list documentation files (default)"
            echo "  validate         Validate required documentation files exist"
            echo "  update           Update scan metadata in config"
            echo "  scan             Discover files and update metadata"
            echo "  help             Show this help message"
            echo ""
            echo "Formats (for discover/list/scan):"
            echo "  paths_only       Just file paths, one per line (default)"
            echo "  list             Formatted list with categories"
            echo "  json             JSON output with categorization"
            echo "  categories       Grouped by categories"
            echo ""
            echo "Examples:"
            echo "  $0 discover paths_only"
            echo "  $0 scan json"
            echo "  $0 validate"
            ;;
        *)
            error "Unknown command: $command"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"