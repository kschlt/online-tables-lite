# 📜 Scripts Directory

This directory contains all executable scripts organized by purpose. This follows modern project organization best practices for maintainability and clarity.

## 📁 Directory Structure

```
scripts/
├── README.md              # This file
├── dev/                   # Development environment scripts
│   ├── setup-dev.sh       # Development environment setup
│   └── start-dev.sh       # Development server startup
├── git/                   # Git workflow scripts
│   ├── aggregate-pr-metadata.sh      # PR description generation from commit cache
│   ├── cleanup-before-merge.sh       # Pre-merge cleanup
│   ├── protect-main-branch.sh        # Main branch protection guardrails
│   ├── promptlet-reader.sh           # Promptlet library reader with variable substitution
│   ├── promptlet-sources.json        # Configuration for promptlet compliance monitoring
│   ├── promptlet-template.json       # Template structure for promptlet validation
│   ├── promptlets.json               # Single source of truth promptlet library
│   ├── validate-branch-name.sh       # Branch naming policy enforcement
│   ├── validate-promptlet-compliance.sh  # Comprehensive 4-stage promptlet validation
│   ├── validate-promptlet-patterns.sh    # Legacy promptlet pattern validation
│   ├── validate-promptlet-system.sh      # Basic promptlet system validation
│   └── verify-clean-commit.sh        # Commit verification
├── deploy/                # Deployment scripts
│   └── (future deployment scripts)
└── utils/                 # Utility scripts
    └── (general utility scripts)
```

## 🚀 Usage

### Development Scripts
```bash
# Setup development environment
./scripts/dev/setup-dev.sh

# Start development servers
./scripts/dev/start-dev.sh
```

### Git Workflow Scripts
```bash
# Branch naming validation (enforces feat/fix prefixes)
./scripts/git/validate-branch-name.sh [branch-name] [suggest|promptlet]

# Main branch protection (prevents accidental commits to main)
./scripts/git/protect-main-branch.sh

# PR description generation from commit metadata
./scripts/git/aggregate-pr-metadata.sh [branch] [metadata|description|promptlet|json]

# Clean up before merging (used by Husky pre-commit hook)
./scripts/git/cleanup-before-merge.sh

# Verify clean commit (used by Husky pre-commit hook)
./scripts/git/verify-clean-commit.sh
```

**Note**: Most scripts are automatically executed by Husky git hooks (`.husky/pre-commit` and `.husky/pre-push`) as part of the modern git workflow. Manual execution is available for testing or special cases.

### Promptlet Compliance System
This project implements a comprehensive **single source of truth** promptlet system that eliminates duplication and ensures consistency across all agent tasks:

```bash
# Comprehensive 4-stage validation (enforced by pre-commit hook)
./scripts/git/validate-promptlet-compliance.sh

# Access promptlets with variable substitution
./scripts/git/promptlet-reader.sh [promptlet_name] [key=value...]

# Basic system validation
./scripts/git/validate-promptlet-system.sh
```

**Architecture Components**:
- **`promptlets.json`**: Single source of truth library containing all agent task definitions
- **`promptlet-template.json`**: Template structure rules for validation
- **`promptlet-sources.json`**: Configuration defining monitored files and patterns
- **`promptlet-reader.sh`**: Core reader function with Python-based variable substitution
- **`validate-promptlet-compliance.sh`**: 4-stage comprehensive validation system

**Key Benefits**:
- ✅ **Zero Duplication**: All promptlets defined once, referenced everywhere
- ✅ **Type Safety**: Template validation ensures structural consistency
- ✅ **Automatic Enforcement**: Pre-commit hooks prevent non-compliant code
- ✅ **Variable Substitution**: Dynamic content injection (`${variable}` → actual values)
- ✅ **Agent-Ready**: JSON tasks consumable by AI agents without modification

### Modern Git Hooks Integration
The git workflow scripts integrate seamlessly with Husky-managed git hooks:
- **`.husky/pre-commit`**: 
  - Branch validation (`validate-branch-name.sh`, `protect-main-branch.sh`)
  - Quality checks (`cleanup-before-merge.sh`, `verify-clean-commit.sh`)
  - **Promptlet compliance** (`validate-promptlet-compliance.sh`) - 4-stage validation
  - Metadata collection for incremental PR building (`aggregate-pr-metadata.sh`)
- **`.husky/pre-push`**: Handles changelog automation and documentation workflows
- **Automatic execution**: No manual intervention needed for quality checks
- **Team consistency**: Hooks install automatically via `npm install`
- **Enhanced PR workflow**: Commit metadata accumulates automatically for rich PR descriptions

## 🎯 Benefits

1. **Clear Organization**: Scripts are grouped by purpose
2. **Easy Discovery**: Developers know where to find specific scripts
3. **Maintainability**: Easier to update and manage scripts
4. **Scalability**: Easy to add new scripts without cluttering root
5. **Professional Structure**: Follows industry best practices

## 📋 Best Practices

- **Naming**: Use descriptive names with `.sh` extension
- **Permissions**: Ensure scripts are executable (`chmod +x`)
- **Documentation**: Document what each script does
- **Testing**: Test scripts before committing
- **Version Control**: All scripts should be version controlled

## 🔧 Adding New Scripts

1. Choose the appropriate subdirectory based on purpose
2. Create the script with descriptive name
3. Make it executable: `chmod +x script-name.sh`
4. Update this README if needed
5. Test the script thoroughly

## 🚫 What NOT to Put Here

- **Configuration files** (use `config/` directory)
- **Source code** (use `src/` or `apps/` directories)
- **Documentation** (use `docs/` directory)
- **Temporary files** (use `.agent/` directory)
