# Branch Protection Setup Guide

## 🛡️ GitHub Repository Settings

### Step 1: Enable Branch Protection Rules

1. Go to your GitHub repository
2. Click **Settings** → **Branches**
3. Click **Add rule** or **Add branch protection rule**

### Step 2: Configure Main Branch Protection

**Branch name pattern:** `main`

**Protection Settings:**
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: `1` (or more)
  - ✅ Dismiss stale PR approvals when new commits are pushed
  - ✅ Require review from code owners
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - ✅ Status checks: `PR Checks`, `Main Branch Checks`
- ✅ **Require conversation resolution before merging**
- ✅ **Restrict pushes that create files larger than 100 MB**
- ✅ **Do not allow bypassing the above settings** (even for admins)

### Step 3: Configure Production Branch Protection

**Branch name pattern:** `production`

**Protection Settings:**
- ✅ **Require a pull request before merging**
  - ✅ Require approvals: `1` (or more)
  - ✅ Dismiss stale PR approvals when new commits are pushed
- ✅ **Require status checks to pass before merging**
  - ✅ Require branches to be up to date before merging
  - ✅ Status checks: `Production Push Validation`
- ✅ **Require conversation resolution before merging**
- ✅ **Restrict pushes that create files larger than 100 MB**
- ✅ **Do not allow bypassing the above settings** (even for admins)

### Step 4: Additional Security Settings

**Repository Settings → General:**
- ✅ **Allow force pushes:** `Never` (for all branches)
- ✅ **Allow deletions:** `Never` (for protected branches)
- ✅ **Allow auto-merge:** `Enabled` (optional)

## 🔒 Cursor IDE Protection

### Option 1: Git Hooks (Recommended)

Create additional git hooks to prevent direct commits to main/production:

#### Pre-commit Hook for Main/Production
```bash
# Create .git/hooks/pre-commit
#!/bin/bash

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Check if we're on main or production
if [ "$current_branch" = "main" ] || [ "$current_branch" = "production" ]; then
    echo "❌ DIRECT COMMITS TO $current_branch ARE NOT ALLOWED!"
    echo "💡 Please create a feature branch and use pull requests instead."
    echo "💡 Use: git checkout -b feature/your-feature-name"
    exit 1
fi

echo "✅ Committing to feature branch: $current_branch"
```

#### Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### Option 2: Cursor Workspace Settings

Create `.vscode/settings.json` in your project root:

```json
{
  "git.enableSmartCommit": false,
  "git.confirmSync": true,
  "git.autofetch": true,
  "git.branchProtection": [
    "main",
    "production"
  ],
  "git.showProgress": true,
  "git.autoStash": false,
  "git.allowCommitSigning": true,
  "git.allowNoVerifyCommit": false,
  "git.enableCommitSigning": true,
  "git.postCommitCommand": "none",
  "git.showActionButton": {
    "commit": true,
    "publish": true,
    "sync": true
  },
  "git.branchSortOrder": "committerdate",
  "git.detectSubmodules": true,
  "git.detectSubmodulesLimit": 10,
  "git.enableStatusBarSync": true,
  "git.mergeEditor": true,
  "git.mergeConflictOnEnter": "ask",
  "git.mergeEditor.layout": "split",
  "git.mergeEditor.codeLens.enabled": true,
  "git.mergeEditor.codeLens.actions": true,
  "git.mergeEditor.codeLens.actions.layout": "flex",
  "git.mergeEditor.codeLens.actions.before": "always",
  "git.mergeEditor.codeLens.actions.after": "always",
  "git.mergeEditor.codeLens.actions.last": "always",
  "git.mergeEditor.codeLens.actions.separator": " | ",
  "git.mergeEditor.codeLens.actions.commands": [
    {
      "command": "git.mergeEditor.acceptCurrent",
      "title": "Accept Current",
      "icon": "check"
    },
    {
      "command": "git.mergeEditor.acceptIncoming",
      "title": "Accept Incoming",
      "icon": "check"
    },
    {
      "command": "git.mergeEditor.acceptBoth",
      "title": "Accept Both",
      "icon": "check"
    },
    {
      "command": "git.mergeEditor.acceptAllCurrent",
      "title": "Accept All Current",
      "icon": "check-all"
    },
    {
      "command": "git.mergeEditor.acceptAllIncoming",
      "title": "Accept All Incoming",
      "icon": "check-all"
    },
    {
      "command": "git.mergeEditor.acceptAllBoth",
      "title": "Accept All Both",
      "icon": "check-all"
    }
  ]
}
```

### Option 3: Custom Cursor Agent Instructions

Add this to your Cursor agent instructions or project README:

```
🚫 BRANCH PROTECTION RULES:
- NEVER commit directly to main branch
- NEVER commit directly to production branch
- ALWAYS create feature branches for any changes
- ALWAYS use pull requests to merge to main
- ALWAYS use pull requests to merge to production
- If you need to make changes, create a feature branch first

✅ CORRECT WORKFLOW:
1. git checkout main
2. git pull origin main
3. git checkout -b feature/your-feature-name
4. Make changes
5. git commit -m "your changes"
6. git push origin feature/your-feature-name
7. Create PR to main
8. After merge, update production via PR

❌ FORBIDDEN:
- git checkout main && git commit (direct commit to main)
- git checkout production && git commit (direct commit to production)
- Any direct modifications to main or production branches
```

## 🔧 Additional Protection Scripts

### Branch Protection Script
Create `scripts/protect-branches.sh`:

```bash
#!/bin/bash

# Check if we're trying to commit to protected branches
current_branch=$(git rev-parse --abbrev-ref HEAD)

if [ "$current_branch" = "main" ] || [ "$current_branch" = "production" ]; then
    echo "❌ ERROR: Direct commits to $current_branch are not allowed!"
    echo ""
    echo "🛡️ BRANCH PROTECTION ACTIVE"
    echo "💡 Please use the proper workflow:"
    echo "   1. git checkout main"
    echo "   2. git pull origin main"
    echo "   3. git checkout -b feature/your-feature-name"
    echo "   4. Make your changes"
    echo "   5. git commit -m 'your changes'"
    echo "   6. git push origin feature/your-feature-name"
    echo "   7. Create a pull request"
    echo ""
    exit 1
fi

echo "✅ Committing to feature branch: $current_branch"
```

### Make it executable and add to git hooks:
```bash
chmod +x scripts/protect-branches.sh
ln -sf ../../scripts/protect-branches.sh .git/hooks/pre-commit
```

## 🚨 Emergency Override (Use with Caution)

If you absolutely need to make a direct commit (emergency only):

```bash
# Temporarily disable pre-commit hook
mv .git/hooks/pre-commit .git/hooks/pre-commit.disabled

# Make your emergency commit
git commit -m "EMERGENCY: [describe the emergency]"

# Re-enable protection
mv .git/hooks/pre-commit.disabled .git/hooks/pre-commit
```

## 📋 Verification Checklist

After setting up protection:

- [ ] GitHub branch protection rules enabled for main
- [ ] GitHub branch protection rules enabled for production
- [ ] Pre-commit hook installed and executable
- [ ] Test: Try to commit directly to main (should fail)
- [ ] Test: Try to commit directly to production (should fail)
- [ ] Test: Commit to feature branch (should succeed)
- [ ] Cursor agent instructions updated
- [ ] Team members informed of new workflow

## 🎯 Benefits

- ✅ **Prevents accidental direct commits** to protected branches
- ✅ **Enforces proper workflow** through automation
- ✅ **Protects code quality** by requiring PR reviews
- ✅ **Maintains audit trail** of all changes
- ✅ **Prevents force pushes** to protected branches
- ✅ **Ensures all checks pass** before merging

## 🔍 Monitoring

You can monitor branch protection compliance by:
- Checking GitHub's branch protection status
- Reviewing commit history (should only show merges to main/production)
- Monitoring failed push attempts in GitHub logs
- Using GitHub's audit log for compliance tracking
