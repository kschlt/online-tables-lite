# Git-cliff & Conventional Commits Setup Dependencies

This document tracks all dependencies and setup requirements for the git-cliff + conventional commits integration.

## New Dependencies Added

### System Dependencies
- **git-cliff** (v2.10.0+)
  - Installation: `brew install git-cliff` (macOS) or see https://git-cliff.org/docs/installation
  - Purpose: Automated changelog generation from conventional commits
  - Status: ✅ Installed via Homebrew

### Node.js Dependencies (apps/web)
- **@commitlint/cli** (dev dependency)
  - Purpose: Commit message linting and validation
  - Installation: `npm install --save-dev @commitlint/cli @commitlint/config-conventional`
  - Status: ✅ Added to package.json

- **@commitlint/config-conventional** (dev dependency)
  - Purpose: Conventional commits configuration for commitlint
  - Status: ✅ Added to package.json

## New Configuration Files

### 1. `/cliff.toml`
- **Purpose**: Git-cliff configuration for changelog generation
- **Format**: Keep-a-Changelog compatible output
- **Features**: 
  - Conventional commits parsing
  - Semantic versioning support
  - Automatic categorization (Added, Fixed, Documentation, etc.)
- **Status**: ✅ Created

### 2. `/commitlint.config.js`
- **Purpose**: Commit message validation rules
- **Rules**: Enforces conventional commit format
- **Types**: feat, fix, docs, refactor, chore, test, ci, build, perf, revert
- **Status**: ✅ Created

### 3. `/CHANGELOG.md`
- **Purpose**: Project changelog following Keep-a-Changelog format
- **Auto-updates**: Via git-cliff during pre-push hook
- **Initial content**: Project history from git commits
- **Status**: ✅ Created

## Modified Files

### 1. `/Makefile`
- **New commands**:
  - `make commit` - Generate conventional commit messages via JSON promptlet
  - `make setup-git-tools` - Install and verify git-cliff dependencies
- **Enhanced commands**:
  - `make setup` - Now includes git-cliff setup
  - `make ship` - Now includes changelog analysis in JSON output
  - `make check` - Now validates conventional commits and CHANGELOG.md
  - `make help` - Updated with new commands
- **Status**: ✅ Updated

### 2. `/.git/hooks/pre-push`
- **New feature**: Automatic CHANGELOG.md updates via git-cliff
- **Process**: 
  1. Generates changelog from conventional commits
  2. Updates CHANGELOG.md if changes detected
  3. Amends last commit with changelog updates
- **Status**: ✅ Updated

### 3. `/CLAUDE.md`
- **Enhanced workflow**: 
  - Conventional commit format requirements
  - Updated commit process using `make commit`
  - Changelog automation documentation
- **Status**: ✅ Updated

## Workflow Changes

### Old Commit Workflow
1. `git add -A`
2. `git commit -m "message"`
3. If hook fails: fix and retry

### New Commit Workflow
1. `git add -A`
2. `make commit` (generates JSON task for conventional message)
3. Agent creates conventional commit message
4. `git commit -m "generated-conventional-message"`
5. Pre-commit hook runs (cleanup → fix → verify)

### Enhanced Push Workflow
1. `make ship` (now includes changelog analysis)
2. Follow JSON task for documentation updates
3. `git push origin branch-name`
4. Pre-push hook automatically updates CHANGELOG.md
5. `make pr-open` for GitHub PR

## Setup for New Developers

### Automatic Setup
```bash
make setup  # Includes git-cliff installation and verification
```

### Manual Verification
```bash
# Verify git-cliff
git-cliff --version

# Verify commitlint
cd apps/web && npx commitlint --version

# Test conventional commit validation
echo "feat: test message" | npx commitlint --from-stdin
```

## Dependencies Integration Status

- ✅ **git-cliff**: Integrated into Makefile setup process
- ✅ **commitlint**: Added to npm dependencies
- ✅ **CHANGELOG.md**: Auto-generated and maintained
- ✅ **cliff.toml**: Version controlled configuration
- ✅ **commitlint.config.js**: Version controlled configuration
- ✅ **Makefile**: Enhanced with new commands and setup
- ✅ **Git hooks**: Updated for automation
- ✅ **CLAUDE.md**: Updated with new workflow

## Verification Commands

```bash
# Test the complete workflow
git add -A
make commit  # Follow JSON task
git commit -m "feat: test conventional commit integration"

# Verify changelog generation
git-cliff --unreleased

# Test quality checks
make check
```

All dependencies are now properly integrated into the project setup and workflow!