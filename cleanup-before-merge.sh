#!/bin/bash

# Cleanup script to run before merging to main or pushing to production
# This ensures no temporary files, backup files, or agent-generated files end up in production

echo "🧹 Cleaning up before merge/push to production..."

# Create .agent directory structure if it doesn't exist
mkdir -p .agent/backups .agent/temp

# Find and move backup files
echo "📦 Moving backup files to .agent/backups..."
find . -name "*.backup" -not -path "./.agent/*" -exec mv {} .agent/backups/ \; 2>/dev/null || true
find . -name "*.bak" -not -path "./.agent/*" -exec mv {} .agent/backups/ \; 2>/dev/null || true
find . -name "*.orig" -not -path "./.agent/*" -exec mv {} .agent/backups/ \; 2>/dev/null || true

# Find and move temporary files
echo "🗑️ Moving temporary files to .agent/temp..."
find . -name "*.tmp" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*.temp" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*~" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name ".#*" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true

# Find and move agent-generated markdown files
echo "📝 Moving agent-generated markdown files to .agent/temp..."
find . -name "*.agent.md" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*.temp.md" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*.draft.md" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*.notes.md" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true

# Find and move temporary config files
echo "⚙️ Moving temporary config files to .agent/temp..."
find . -name "*.temp.json" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*.temp.js" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*.temp.ts" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true
find . -name "*.temp.tsx" -not -path "./.agent/*" -exec mv {} .agent/temp/ \; 2>/dev/null || true

# Check for any remaining problematic files
echo "🔍 Checking for remaining problematic files..."
REMAINING_BACKUPS=$(find . -name "*.backup" -not -path "./.agent/*" | wc -l)
REMAINING_TEMP=$(find . -name "*.tmp" -not -path "./.agent/*" | wc -l)
REMAINING_AGENT_MD=$(find . -name "*.agent.md" -not -path "./.agent/*" | wc -l)

if [ "$REMAINING_BACKUPS" -gt 0 ] || [ "$REMAINING_TEMP" -gt 0 ] || [ "$REMAINING_AGENT_MD" -gt 0 ]; then
    echo "⚠️  Warning: Some files still need attention:"
    find . -name "*.backup" -not -path "./.agent/*" 2>/dev/null || true
    find . -name "*.tmp" -not -path "./.agent/*" 2>/dev/null || true
    find . -name "*.agent.md" -not -path "./.agent/*" 2>/dev/null || true
    echo ""
    echo "Please review these files and move them to .agent/ if they're temporary."
else
    echo "✅ All temporary and backup files have been moved to .agent/"
fi

# Show what's in .agent directory
echo ""
echo "📁 Contents of .agent directory:"
if [ -d ".agent" ]; then
    find .agent -type f | head -10
    TOTAL_FILES=$(find .agent -type f | wc -l)
    echo "... and $((TOTAL_FILES - 10)) more files" 2>/dev/null || echo "... and more files"
else
    echo "No .agent directory found"
fi

echo ""
echo "✅ Cleanup complete! Ready for merge/push to production."
echo "💡 Remember: .agent/ directory is ignored by git and won't be pushed to GitHub."
