#!/bin/bash

# Branch Protection Script
# Prevents direct commits to main and production branches

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if we're on a protected branch
if [ "$current_branch" = "main" ] || [ "$current_branch" = "production" ]; then
    echo ""
    echo "🚨 BRANCH PROTECTION VIOLATION DETECTED! 🚨"
    echo ""
    echo "❌ ERROR: Direct commits to '$current_branch' are NOT ALLOWED!"
    echo ""
    echo "🛡️ PROTECTION RULES:"
    echo "   • main branch: Only accepts merges from pull requests"
    echo "   • production branch: Only accepts merges from pull requests"
    echo ""
    echo "💡 CORRECT WORKFLOW:"
    echo "   1. git checkout main"
    echo "   2. git pull origin main"
    echo "   3. git checkout -b feature/your-feature-name"
    echo "   4. Make your changes"
    echo "   5. git commit -m 'your changes'"
    echo "   6. git push origin feature/your-feature-name"
    echo "   7. Create a pull request to main"
    echo "   8. After merge, update production via pull request"
    echo ""
    echo "🔒 This commit has been BLOCKED to protect code quality."
    echo ""
    exit 1
fi

# Allow commits to feature branches
echo "✅ Committing to feature branch: $current_branch"
echo "🛡️ Branch protection: ACTIVE"
