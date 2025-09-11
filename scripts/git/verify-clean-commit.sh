#!/bin/bash

# Verification script to ensure clean commits
# Run this before merging to main or pushing to production

echo "🔍 Verifying clean commit..."

# Check for problematic files in staged changes
PROBLEMATIC_FILES=$(git diff --cached --name-only | grep -E '\.(backup|bak|orig|tmp|temp|agent\.md|temp\.md|draft\.md|notes\.md)$')

if [ -n "$PROBLEMATIC_FILES" ]; then
    echo "❌ ERROR: Found problematic files in staged changes:"
    echo "$PROBLEMATIC_FILES"
    echo ""
    echo "🚨 These files should NOT be committed!"
    echo "💡 Move them to .agent/ directory:"
    echo "   ./cleanup-before-merge.sh"
    echo ""
    exit 1
fi

# Check for .agent files in staged changes
AGENT_FILES=$(git diff --cached --name-only | grep '^\.agent/')

if [ -n "$AGENT_FILES" ]; then
    echo "❌ ERROR: Found .agent/ files in staged changes:"
    echo "$AGENT_FILES"
    echo ""
    echo "💡 Check your .gitignore file"
    echo ""
    exit 1
fi

# Check for backup files in working directory
BACKUP_FILES=$(find . -name "*.backup" -not -path "./.agent/*" | wc -l)
TEMP_FILES=$(find . -name "*.tmp" -not -path "./.agent/*" | wc -l)

if [ "$BACKUP_FILES" -gt 0 ] || [ "$TEMP_FILES" -gt 0 ]; then
    echo "⚠️  WARNING: Found backup/temp files in working directory:"
    find . -name "*.backup" -not -path "./.agent/*" 2>/dev/null || true
    find . -name "*.tmp" -not -path "./.agent/*" 2>/dev/null || true
    echo ""
    echo "💡 Consider running: ./cleanup-before-merge.sh"
    echo ""
fi

echo "✅ Commit verification passed!"
