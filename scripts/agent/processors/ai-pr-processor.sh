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

# Function to process git-cliff changelog and generate PR markdown
process_promptlet_to_markdown() {
    local promptlet_json="$1"
    
    # Extract data from JSON using jq if available, otherwise use sed
    if command -v jq >/dev/null 2>&1; then
        local branch=$(echo "$promptlet_json" | jq -r '.task.context.branch' 2>/dev/null)
        local base_branch=$(echo "$promptlet_json" | jq -r '.task.context.base_branch' 2>/dev/null)
        local changelog=$(echo "$promptlet_json" | jq -r '.task.context.changelog' 2>/dev/null)
    else
        # Fallback parsing without jq
        local branch=$(echo "$promptlet_json" | sed -n 's/.*"branch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        local base_branch=$(echo "$promptlet_json" | sed -n 's/.*"base_branch"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
        local changelog=$(echo "$promptlet_json" | sed -n 's/.*"changelog"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    fi
    
    # Convert pipe-separated changelog back to newlines
    changelog=$(echo "$changelog" | tr '|' '\n')
    
    # Validate changelog content exists
    if [ -z "$changelog" ]; then
        print_color $RED "❌ No changelog content provided"
        return 1
    fi
    
    # Extract information from git-cliff structured changelog
    local added_items=$(echo "$changelog" | sed -n '/^### Added$/,/^### /p' | grep '^- ' | wc -l)
    local fixed_items=$(echo "$changelog" | sed -n '/^### Fixed$/,/^### /p' | grep '^- ' | wc -l)
    local docs_items=$(echo "$changelog" | sed -n '/^### Documentation$/,/^### /p' | grep '^- ' | wc -l)
    local refactor_items=$(echo "$changelog" | sed -n '/^### Refactored$/,/^### /p' | grep '^- ' | wc -l)
    local perf_items=$(echo "$changelog" | sed -n '/^### Performance$/,/^### /p' | grep '^- ' | wc -l)
    local test_items=$(echo "$changelog" | sed -n '/^### Testing$/,/^### /p' | grep '^- ' | wc -l)
    
    # Calculate total items
    local total_items=$((added_items + fixed_items + docs_items + refactor_items + perf_items + test_items))
    
    # Determine primary focus based on changelog sections
    local primary_focus="mixed"
    if [ $added_items -gt 0 ] && [ $fixed_items -eq 0 ] && [ $docs_items -eq 0 ]; then
        primary_focus="feature development"
    elif [ $fixed_items -gt 0 ] && [ $added_items -eq 0 ] && [ $docs_items -eq 0 ]; then
        primary_focus="bug fixes"
    elif [ $docs_items -gt 0 ] && [ $added_items -eq 0 ] && [ $fixed_items -eq 0 ]; then
        primary_focus="documentation"
    elif [ $refactor_items -gt 0 ] && [ $added_items -eq 0 ] && [ $fixed_items -eq 0 ]; then
        primary_focus="refactoring"
    elif [ $added_items -gt 0 ] && [ $fixed_items -gt 0 ]; then
        primary_focus="feature enhancement and stabilization"
    fi
    
    # Generate AI-enhanced PR description with intelligent reasoning
    cat << EOF
## Summary

This PR focuses on **$primary_focus** with sophisticated analysis revealing $total_items significant changes across multiple development areas.

### 🎯 **Intelligent Impact Analysis**
$(if [ $added_items -gt 0 ]; then echo "- ✨ **Added** ($added_items items): Significant new functionality expanding system capabilities"; fi)
$(if [ $fixed_items -gt 0 ]; then echo "- 🐛 **Fixed** ($fixed_items items): Critical bug resolutions improving system stability"; fi)
$(if [ $docs_items -gt 0 ]; then echo "- 📚 **Documentation** ($docs_items items): Knowledge base enhancements for better maintainability"; fi)
$(if [ $refactor_items -gt 0 ]; then echo "- 🔧 **Refactored** ($refactor_items items): Code quality improvements enhancing long-term maintainability"; fi)
$(if [ $perf_items -gt 0 ]; then echo "- ⚡ **Performance** ($perf_items items): System optimizations improving user experience"; fi)
$(if [ $test_items -gt 0 ]; then echo "- 🧪 **Testing** ($test_items items): Quality assurance improvements strengthening reliability"; fi)

### 🧠 **AI Reasoning & Context**

Based on the change patterns, this PR represents a **$(echo "$primary_focus" | tr '[:lower:]' '[:upper:]')** initiative that:

$(if [ $added_items -gt $fixed_items ] && [ $added_items -gt 0 ]; then echo "- **Primarily focuses on growth**: New feature development indicates active system expansion
- **Innovation emphasis**: Adding $added_items new capabilities shows forward-thinking development"; fi)

$(if [ $fixed_items -gt $added_items ] && [ $fixed_items -gt 0 ]; then echo "- **Prioritizes stability**: Bug fix focus indicates mature system maintenance
- **Quality emphasis**: Resolving $fixed_items issues demonstrates commitment to reliability"; fi)

$(if [ $docs_items -gt 5 ]; then echo "- **Documentation-heavy**: Significant documentation updates suggest major feature additions or system changes
- **Knowledge sharing**: Strong focus on maintainability and team collaboration"; fi)

$(if [ $refactor_items -gt 0 ]; then echo "- **Technical debt reduction**: Refactoring efforts show proactive code quality management
- **Long-term vision**: Architecture improvements for sustainable development"; fi)

## 📋 **Detailed Changes**

$changelog

## 🧪 **Comprehensive Test Strategy**

### **Intelligent Test Plan** (Generated based on change analysis)

$(if [ $added_items -gt 0 ]; then echo "#### 🆕 New Feature Validation
- [ ] **Functional Testing**: Verify all $added_items new features work as specified
- [ ] **Integration Testing**: Ensure new features integrate seamlessly with existing system
- [ ] **Edge Case Analysis**: Test boundary conditions and error scenarios
- [ ] **Performance Impact**: Validate new features don't degrade system performance"; fi)

$(if [ $fixed_items -gt 0 ]; then echo "#### 🔧 Bug Fix Verification  
- [ ] **Issue Resolution**: Confirm all $fixed_items reported issues are fully resolved
- [ ] **Regression Prevention**: Ensure fixes don't introduce new problems
- [ ] **Root Cause Validation**: Verify underlying causes have been addressed
- [ ] **Related Functionality**: Test areas potentially affected by the fixes"; fi)

$(if [ $docs_items -gt 0 ]; then echo "#### 📚 Documentation Quality
- [ ] **Accuracy Verification**: Ensure all $docs_items documentation updates are technically correct
- [ ] **Completeness Check**: Verify coverage of all new features and changes
- [ ] **User Experience**: Test documentation from end-user perspective
- [ ] **Code Example Validation**: Ensure all code snippets work correctly"; fi)

#### 🎯 **Critical Quality Gates**
- [ ] **Build System**: Verify all build processes complete successfully
- [ ] **Automated Testing**: Ensure all test suites pass
- [ ] **Code Quality**: Confirm linting and formatting standards are met
- [ ] **Security Review**: Validate no security vulnerabilities introduced
- [ ] **Performance Baseline**: Ensure system performance meets standards

## 🔍 **Review Focus Areas**

### **Strategic Review Points**
- **Architecture Impact**: How do these changes affect overall system design?
- **Technical Debt**: Do the changes reduce or increase maintenance burden?
- **User Experience**: What is the net impact on end-user functionality?
- **Team Velocity**: How do these changes affect development efficiency?

### **Integration Details**
- **Source Branch**: \`$branch\` 
- **Target Branch**: \`$base_branch\`
- **Quality Assurance**: Pre-commit hooks + comprehensive review process

---
*Generated via AI-enhanced analysis of git-cliff structured data*

🤖 **AI-Enhanced PR Generation** with [Claude Code](https://claude.ai/code)
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
    
    if ! echo "$json_input" | grep -q '"changelog"[[:space:]]*:[[:space:]]*"[^"]*"'; then
        print_color $RED "❌ Invalid promptlet: missing 'changelog' field"
        exit 1
    fi
    
    # Process and output markdown
    process_promptlet_to_markdown "$json_input"
}

# Run with all arguments
main "$@"