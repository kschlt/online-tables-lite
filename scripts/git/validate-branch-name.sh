#!/bin/bash

# Branch name validation script for Online Tables Lite
# Enforces feat/ and fix/ prefix naming standard with kebab-case format

set -e

# Configuration
MAX_LENGTH=48
ALLOWED_PREFIXES="feat fix"

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

# Function to generate compliant branch name suggestion
suggest_branch_name() {
    local input="$1"
    local suggested_type="$2"
    
    # Remove existing prefix if present
    local clean_name=$(echo "$input" | sed -E 's/^(feature\/|feat\/|fix\/|bugfix\/|hotfix\/)//')
    
    # Convert to lowercase and create kebab-case
    local kebab_name=$(echo "$clean_name" | tr '[:upper:]' '[:lower:]' | \
        sed -E 's/[àáâãäå]/a/g; s/[èéêë]/e/g; s/[ìíîï]/i/g; s/[òóôõö]/o/g; s/[ùúûü]/u/g; s/ç/c/g; s/ñ/n/g; s/ß/ss/g' | \
        sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-+/-/g')
    
    # Truncate if needed (leave room for prefix)
    local max_suffix=$((MAX_LENGTH - ${#suggested_type} - 1))
    if [ ${#kebab_name} -gt $max_suffix ]; then
        kebab_name=$(echo "$kebab_name" | cut -c1-$max_suffix | sed 's/-$//')
    fi
    
    echo "${suggested_type}/${kebab_name}"
}

# Function to validate branch name format
validate_branch_name() {
    local branch_name="$1"
    local errors=()
    
    # Check if it's a protected branch
    if [[ "$branch_name" == "main" || "$branch_name" == "production" ]]; then
        return 0  # Protected branches are always valid
    fi
    
    # Check prefix
    local has_valid_prefix=false
    for prefix in $ALLOWED_PREFIXES; do
        if [[ "$branch_name" =~ ^${prefix}/ ]]; then
            has_valid_prefix=true
            break
        fi
    done
    
    if [ "$has_valid_prefix" = false ]; then
        errors+=("Invalid prefix. Must start with: $(echo $ALLOWED_PREFIXES | sed 's/ /\/ or /g')/")
    fi
    
    # Check length
    if [ ${#branch_name} -gt $MAX_LENGTH ]; then
        errors+=("Name too long (${#branch_name} chars). Maximum: $MAX_LENGTH characters")
    fi
    
    # Check format (kebab-case after prefix)
    if [[ "$branch_name" =~ ^(feat|fix)/([a-z0-9-]+)$ ]]; then
        local suffix="${BASH_REMATCH[2]}"
        if [[ ! "$suffix" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || [[ "$suffix" =~ ^-|-$ ]] || [[ "$suffix" =~ -- ]]; then
            errors+=("Invalid format. Use kebab-case: lowercase letters, numbers, and hyphens only")
        fi
    elif [ "$has_valid_prefix" = true ]; then
        errors+=("Invalid format. Use kebab-case: lowercase letters, numbers, and hyphens only")
    fi
    
    if [ ${#errors[@]} -eq 0 ]; then
        return 0
    else
        printf '%s\n' "${errors[@]}"
        return 1
    fi
}

# Function to generate agent promptlet for branch naming
generate_naming_promptlet() {
    local current_branch="$1"
    local suggested_name="$2"
    local validation_errors="$3"
    
    echo "{"
    echo '  "task": {'
    echo '    "type": "branch_name_compliance",'
    echo '    "instructions": ['
    echo '      "Current branch name violates naming policy",'
    echo '      "Rename branch to comply with feat/ or fix/ standard",'
    echo '      "Use: make branch-rename NAME=suggested-name",'
    echo '      "Or create new compliant branch: make branch-new NAME=suggested-name"'
    echo '    ],'
    echo '    "context": {'
    printf '      "current_branch": "%s",\n' "$current_branch"
    printf '      "suggested_name": "%s",\n' "$suggested_name"
    printf '      "validation_errors": "%s",\n' "$(echo "$validation_errors" | tr '\n' '; ')"
    echo '      "policy": {'
    echo '        "prefixes": ["feat/", "fix/"],'
    echo '        "format": "kebab-case (lowercase, hyphens only)",'
    echo '        "max_length": '$MAX_LENGTH','
    echo '        "examples": ["feat/user-dashboard", "fix/login-bug", "feat/table-export"]'
    echo '      },'
    echo '      "transliteration": {'
    echo '        "guidelines": "ä→ae, ö→oe, ü→ue, ß→ss, é→e, etc.",'
    echo '        "example": "feat/müller-straße → feat/mueller-strasse"'
    echo '      }'
    echo '    }'
    echo '  }'
    echo "}"
}

# Main validation function
main() {
    local branch_name="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    local mode="${2:-validate}"  # validate|suggest|promptlet
    
    if [ -z "$branch_name" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        exit 1
    fi
    
    case "$mode" in
        "validate")
            if validation_errors=$(validate_branch_name "$branch_name"); then
                print_color $GREEN "✅ Branch name '$branch_name' is compliant"
                exit 0
            else
                print_color $RED "❌ Branch name '$branch_name' violates naming policy:"
                echo "$validation_errors" | while read -r error; do
                    print_color $RED "  • $error"
                done
                exit 1
            fi
            ;;
        "suggest")
            # Determine suggested type based on current name or default to feat
            local suggested_type="feat"
            if [[ "$branch_name" =~ (fix|bug|hotfix) ]]; then
                suggested_type="fix"
            fi
            
            local suggested_name=$(suggest_branch_name "$branch_name" "$suggested_type")
            echo "$suggested_name"
            ;;
        "promptlet")
            local validation_errors=$(validate_branch_name "$branch_name" 2>&1 || true)
            local suggested_name=$(suggest_branch_name "$branch_name" "feat")
            generate_naming_promptlet "$branch_name" "$suggested_name" "$validation_errors"
            ;;
        *)
            print_color $RED "❌ Invalid mode: $mode"
            echo "Usage: $0 [branch_name] [validate|suggest|promptlet]"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"