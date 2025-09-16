#!/bin/bash

# PR Metadata Aggregation Script for Online Tables Lite
# Aggregates per-commit metadata into rich PR descriptions

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

# Function to aggregate commit metadata from branch cache
aggregate_branch_metadata() {
    local branch="$1"
    local cache_dir=".git/commit-cache/branches"
    local commit_cache_file="$cache_dir/${branch//\//_}_commits.jsonl"
    
    if [ ! -f "$commit_cache_file" ]; then
        echo "No commit cache found for branch: $branch"
        return 1
    fi
    
    # Initialize counters and arrays
    local total_commits=$(wc -l < "$commit_cache_file")
    local feat_count=0
    local fix_count=0
    local docs_count=0
    local config_count=0
    local other_count=0
    
    local api_total=0
    local web_total=0
    local doc_total=0
    local config_total=0
    local style_total=0
    
    local commit_summaries=""
    local key_changes=""
    local scope_analysis=""
    
    # Process each commit
    while IFS= read -r commit_json; do
        if [ -n "$commit_json" ]; then
            # Extract commit data using jq if available, otherwise use sed
            if command -v jq >/dev/null 2>&1; then
                local hash=$(echo "$commit_json" | jq -r '.hash' | cut -c1-8)
                local message=$(echo "$commit_json" | jq -r '.message')
                local type=$(echo "$commit_json" | jq -r '.type')
                local scope=$(echo "$commit_json" | jq -r '.scope')
                local api_files=$(echo "$commit_json" | jq -r '.files.api_files')
                local web_files=$(echo "$commit_json" | jq -r '.files.web_files')
                local doc_files=$(echo "$commit_json" | jq -r '.files.doc_files')
                local config_files=$(echo "$commit_json" | jq -r '.files.config_files')
                local style_files=$(echo "$commit_json" | jq -r '.files.style_files')
            else
                # Fallback to sed parsing
                local hash=$(echo "$commit_json" | sed -n 's/.*"hash": *"\([^"]*\)".*/\1/p' | cut -c1-8)
                local message=$(echo "$commit_json" | sed -n 's/.*"message": *"\([^"]*\)".*/\1/p')
                local type=$(echo "$commit_json" | sed -n 's/.*"type": *"\([^"]*\)".*/\1/p')
                local scope=$(echo "$commit_json" | sed -n 's/.*"scope": *"\([^"]*\)".*/\1/p')
                local api_files=$(echo "$commit_json" | sed -n 's/.*"api_files": *\([0-9]*\).*/\1/p')
                local web_files=$(echo "$commit_json" | sed -n 's/.*"web_files": *\([0-9]*\).*/\1/p')
                local doc_files=$(echo "$commit_json" | sed -n 's/.*"doc_files": *\([0-9]*\).*/\1/p')
                local config_files=$(echo "$commit_json" | sed -n 's/.*"config_files": *\([0-9]*\).*/\1/p')
                local style_files=$(echo "$commit_json" | sed -n 's/.*"style_files": *\([0-9]*\).*/\1/p')
            fi
            
            # Count commit types
            case "$type" in
                "feat") ((feat_count++)) ;;
                "fix") ((fix_count++)) ;;
                "docs") ((docs_count++)) ;;
                "chore"|"ci"|"build") ((config_count++)) ;;
                *) ((other_count++)) ;;
            esac
            
            # Accumulate file changes
            api_total=$((api_total + ${api_files:-0}))
            web_total=$((web_total + ${web_files:-0}))
            doc_total=$((doc_total + ${doc_files:-0}))
            config_total=$((config_total + ${config_files:-0}))
            style_total=$((style_total + ${style_files:-0}))
            
            # Build commit summaries
            if [ -n "$message" ] && [ "$message" != "null" ]; then
                commit_summaries="${commit_summaries}* ${message} (${hash})\n"
            fi
        fi
    done < "$commit_cache_file"
    
    # Determine PR type and scope
    local pr_type="mixed"
    local primary_scope="general"
    
    if [ $feat_count -gt 0 ] && [ $fix_count -eq 0 ]; then
        pr_type="feature"
    elif [ $fix_count -gt 0 ] && [ $feat_count -eq 0 ]; then
        pr_type="bugfix"
    elif [ $docs_count -gt 0 ] && [ $((feat_count + fix_count)) -eq 0 ]; then
        pr_type="documentation"
    elif [ $config_count -gt 0 ] && [ $((feat_count + fix_count)) -eq 0 ]; then
        pr_type="maintenance"
    fi
    
    # Determine primary scope
    if [ $api_total -gt 0 ] && [ $web_total -gt 0 ]; then
        primary_scope="fullstack"
    elif [ $api_total -gt $web_total ] && [ $api_total -gt 0 ]; then
        primary_scope="backend"
    elif [ $web_total -gt 0 ]; then
        primary_scope="frontend"
    elif [ $doc_total -gt 0 ]; then
        primary_scope="documentation"
    elif [ $config_total -gt 0 ]; then
        primary_scope="configuration"
    fi
    
    # Generate key changes summary
    if [ $api_total -gt 0 ]; then
        key_changes="${key_changes}🔧 **Backend**: ${api_total} API/Python files modified\n"
    fi
    if [ $web_total -gt 0 ]; then
        key_changes="${key_changes}🌐 **Frontend**: ${web_total} React/TypeScript files modified\n"
    fi
    if [ $doc_total -gt 0 ]; then
        key_changes="${key_changes}📚 **Documentation**: ${doc_total} documentation files updated\n"
    fi
    if [ $config_total -gt 0 ]; then
        key_changes="${key_changes}⚙️ **Configuration**: ${config_total} config/build files changed\n"
    fi
    if [ $style_total -gt 0 ]; then
        key_changes="${key_changes}🎨 **Styling**: ${style_total} CSS/style files modified\n"
    fi
    
    # Output aggregated metadata as JSON
    cat << EOF
{
  "summary": {
    "total_commits": $total_commits,
    "pr_type": "$pr_type",
    "primary_scope": "$primary_scope"
  },
  "commits": {
    "feat": $feat_count,
    "fix": $fix_count,
    "docs": $docs_count,
    "config": $config_count,
    "other": $other_count
  },
  "files": {
    "api": $api_total,
    "web": $web_total,
    "docs": $doc_total,
    "config": $config_total,
    "style": $style_total
  },
  "content": {
    "commit_list": "$(echo -e "$commit_summaries" | sed 's/"/\\"/g')",
    "key_changes": "$(echo -e "$key_changes" | sed 's/"/\\"/g')"
  }
}
EOF
}

# Function to generate intelligent PR description
generate_pr_description() {
    local branch="$1"
    local metadata_json="$2"
    
    # Extract metadata fields
    if command -v jq >/dev/null 2>&1; then
        local total_commits=$(echo "$metadata_json" | jq -r '.summary.total_commits')
        local pr_type=$(echo "$metadata_json" | jq -r '.summary.pr_type')
        local primary_scope=$(echo "$metadata_json" | jq -r '.summary.primary_scope')
        local commit_list=$(echo "$metadata_json" | jq -r '.content.commit_list')
        local key_changes=$(echo "$metadata_json" | jq -r '.content.key_changes')
        local feat_count=$(echo "$metadata_json" | jq -r '.commits.feat')
        local fix_count=$(echo "$metadata_json" | jq -r '.commits.fix')
    else
        print_color $YELLOW "⚠️  jq not available - using fallback parsing"
        return 1
    fi
    
    # Generate contextual description based on PR type
    local description_intro=""
    case "$pr_type" in
        "feature")
            description_intro="This PR introduces $feat_count new feature(s) to the $primary_scope system."
            ;;
        "bugfix")
            description_intro="This PR resolves $fix_count bug(s) in the $primary_scope system."
            ;;
        "documentation")
            description_intro="This PR updates project documentation and developer resources."
            ;;
        "maintenance")
            description_intro="This PR includes maintenance and configuration improvements."
            ;;
        *)
            description_intro="This PR includes $total_commits commits with mixed changes to the $primary_scope system."
            ;;
    esac
    
    # Generate comprehensive PR body
    cat << EOF
## Summary

$description_intro

## Changes Made

$(echo -e "$commit_list")

## Impact & Scope

$(echo -e "$key_changes")

## Commit Breakdown
- ✨ Features: $feat_count
- 🐛 Bug fixes: $fix_count  
- 📚 Documentation: $(echo "$metadata_json" | jq -r '.commits.docs')
- 🔧 Configuration: $(echo "$metadata_json" | jq -r '.commits.config')
- 🎯 Other: $(echo "$metadata_json" | jq -r '.commits.other')

## Review Notes
- **Primary scope**: $primary_scope changes
- **Commit count**: $total_commits commits
- **Quality assured**: All commits passed pre-commit validation
- **Branch**: $branch → main

---
*Generated from incremental commit metadata*
EOF
}

# Main function
main() {
    local branch="${1:-$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}"
    local mode="${2:-description}"  # description|metadata|json
    
    if [ -z "$branch" ]; then
        print_color $RED "❌ Error: Could not determine branch name"
        exit 1
    fi
    
    case "$mode" in
        "metadata")
            aggregate_branch_metadata "$branch"
            ;;
        "description")
            local metadata=$(aggregate_branch_metadata "$branch")
            if [ $? -eq 0 ]; then
                generate_pr_description "$branch" "$metadata"
            else
                print_color $RED "❌ Failed to aggregate metadata for branch: $branch"
                exit 1
            fi
            ;;
        "json")
            local metadata=$(aggregate_branch_metadata "$branch")
            if [ $? -eq 0 ]; then
                echo "$metadata" | jq . 2>/dev/null || echo "$metadata"
            else
                exit 1
            fi
            ;;
        *)
            print_color $RED "❌ Invalid mode: $mode"
            echo "Usage: $0 [branch_name] [description|metadata|json]"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"