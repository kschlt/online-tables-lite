# 📜 Scripts Directory

This directory contains all executable scripts organized by purpose with clear separation between automation and agent interaction.

## 📁 Directory Structure

```
scripts/
├── README.md              # This file
├── agent/                 # Agent interaction & workflow scripts
│   ├── promptlets/        # Core promptlet system
│   │   ├── promptlet-reader.sh    # Promptlet library reader with variable substitution
│   │   └── promptlets.json        # Single source of truth promptlet library
│   ├── workflows/         # Complete workflow chains (ping-pong pattern)
│   │   ├── docs-workflow.sh       # Documentation workflow functions
│   │   └── pr-workflow.sh         # PR creation workflow functions
│   ├── processors/        # Data processing for agents
│   │   ├── aggregate-pr-metadata.sh   # PR metadata aggregation
│   │   └── ai-pr-processor.sh         # AI PR processing
│   ├── utils/             # Utilities FOR agents
│   │   ├── protect-main-branch.sh     # Main branch protection with promptlets
│   │   └── validate-branch-name.sh    # Branch naming validation with promptlets
│   └── system/            # System maintenance
│       ├── promptlet-sources.json         # Promptlet compliance configuration
│       ├── promptlet-template.json        # Template structure for validation
│       └── validate-promptlet-compliance.sh   # Unified 5-stage promptlet validation
├── dev/                   # Development environment scripts
│   ├── setup-dev.sh       # Development environment setup
│   └── start-dev.sh       # Development server startup
└── git/                   # Pure git automation (no agent interaction)
    ├── cleanup-before-merge.sh    # Pre-merge cleanup
    └── verify-clean-commit.sh     # Commit verification
```

## 🚀 Usage

### Agent Workflows (Ping-Pong Pattern)

**Entry Points (via Makefile):**
```bash
# Validate changes before PR creation
make pr-validate

# Generate PR description 
make pr-body

# Generate documentation update
make ship
```

**Direct Workflow Functions:**
```bash
# PR workflow chain
./scripts/agent/workflows/pr-workflow.sh validate_changes
./scripts/agent/workflows/pr-workflow.sh pr_body
./scripts/agent/workflows/pr-workflow.sh create_pr
./scripts/agent/workflows/pr-workflow.sh finalize_pr

# Documentation workflow chain  
./scripts/agent/workflows/docs-workflow.sh generate_docs
./scripts/agent/workflows/docs-workflow.sh apply_docs
./scripts/agent/workflows/docs-workflow.sh commit_docs
```

### Development Scripts
```bash
# Setup development environment
./scripts/dev/setup-dev.sh

# Start development servers
./scripts/dev/start-dev.sh
```

### Git Automation Scripts
```bash
# Pre-merge cleanup
./scripts/git/cleanup-before-merge.sh

# Commit verification
./scripts/git/verify-clean-commit.sh
```

## 🔄 Ping-Pong Architecture

The agent workflows follow a **ping-pong pattern** for clean separation of concerns:

1. **Agent** calls make command (entry point)
2. **Automation** runs script, generates promptlet, **STOPS**
3. **Agent** processes promptlet, makes decisions  
4. **Agent** calls next step, cycle continues

```
Agent → make pr-validate → promptlet → STOP → Agent → next_step
```

**Key Principles:**
- Each script stops at promptlet generation
- Agent controls the flow and decisions
- Single clear next_step in every promptlet
- No auto-executing chains

## 🔧 Path Constants

All scripts use path constants for maintainability:

**Makefile Constants:**
```makefile
AGENT_BASE := ./scripts/agent
AGENT_WORKFLOWS := $(AGENT_BASE)/workflows
AGENT_PROMPTLETS := $(AGENT_BASE)/promptlets
```

**Shell Script Constants:**
```bash
AGENT_BASE="./scripts/agent"
PROMPTLET_READER="$AGENT_BASE/promptlets/promptlet-reader.sh"
```

**Benefits:**
- Single point of maintenance
- Easy directory reorganization
- Reduced hardcoded paths
- Clear dependencies

## 🤖 Promptlet System

**Core Components:**
- **`promptlets.json`**: Single source of truth for all agent tasks
- **`promptlet-reader.sh`**: Core reader with variable substitution
- **System validation**: Comprehensive compliance checking

**Usage:**
```bash
# Access promptlets with variable substitution
./scripts/agent/promptlets/promptlet-reader.sh [promptlet_name] [key=value...]

# System validation (enforced by pre-commit hook)
./scripts/agent/system/validate-promptlet-compliance.sh
```

## 🔗 Git Hooks Integration

**Automatic Execution via Husky:**
- **`.husky/pre-commit`**: Quality checks, validation, metadata collection
- **`.husky/pre-push`**: Changelog automation, documentation workflows
- **Team consistency**: Hooks install automatically via `npm install`

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
