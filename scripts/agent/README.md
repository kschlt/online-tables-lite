# Agent System Documentation

This directory contains the agent-driven automation system for the project, including workflow orchestration, promptlet management, and intelligent decision-making capabilities.

## 📁 Directory Structure

```
scripts/agent/
├── README.md                     # This file - system overview
├── workflows/                    # Workflow orchestration scripts
│   ├── pr-workflow.sh            # Complete PR creation pipeline
│   ├── docs-workflow.sh          # Documentation update automation
│   └── commit-workflow.sh        # Commit message generation
├── promptlets/                   # Agent task definitions
│   ├── promptlets.json           # Promptlet template library
│   └── promptlet-reader.sh       # Promptlet execution engine
├── processors/                   # Data processing utilities
├── system/                       # System configuration and validation
│   ├── promptlet-template.json   # Promptlet structure guidelines
│   ├── promptlet-sources.json    # Compliance monitoring config
│   └── validate-*.sh            # System validation scripts
└── utils/                        # Utility functions
    ├── validate-branch-name.sh   # Branch naming enforcement
    └── validate-work-context.sh  # Work context analysis
```

## 🚀 Core Workflows

### PR Workflow (`workflows/pr-workflow.sh`)
Complete pull request creation pipeline with intelligent validation and automation.

**Functions:**
- `validate_changes` - Validates branch changes and detects conflicts
- `push_branch` - Pushes branch with pre-push hook integration
- `pr_body` - Generates PR description using git-cliff data
- `create_pr` - Creates or updates GitHub PRs intelligently
- `finalize_pr` - Post-creation tasks and deployment checks

**Key Features:**
- ✅ Smart conflict detection (fast-forward merge awareness)
- ✅ Existing PR detection and update capability
- ✅ Workflow-origin parameter tracking throughout chain
- ✅ Auto-chaining between workflow steps
- ✅ Comprehensive error handling with actionable messages

### Documentation Workflow (`workflows/docs-workflow.sh`)
Automated documentation maintenance based on changelog analysis.

**Functions:**
- `generate_docs` - Analyzes changelog for documentation impacts
- `no_docs_changes` - Handles cases when no updates are needed
- `apply_docs` - Validates and processes documentation changes
- `commit_docs` - Commits documentation updates

**Key Features:**
- ✅ Intelligent changelog analysis for doc impacts
- ✅ Agent-driven documentation updates
- ✅ Proper NO-OP case handling
- ✅ Auto-chaining to continue workflows

### Commit Workflow (`workflows/commit-workflow.sh`)
Conventional commit message generation with git-cliff integration.

**Functions:**
- `execute_commit` - Generates and executes conventional commits

**Key Features:**
- ✅ git-cliff integration for commit message generation
- ✅ Conventional commit format compliance
- ✅ Pre-commit hook integration

## 🎯 Promptlet System

The promptlet system provides structured task definitions for agent interactions.

### Promptlet Library (`promptlets/promptlets.json`)
Central repository of all agent task templates with standardized structure:

```json
{
  "task_name": {
    "task": {
      "type": "task_identifier",
      "instructions": ["Clear actionable steps for the agent"],
      "context": {
        "data": "All information needed for decision making",
        "options": "Available actions and their commands"
      },
      "next_step": "Command to execute based on agent decision"
    }
  }
}
```

### Key Promptlets:
- `documentation_update` - Documentation analysis and update instructions
- `pr_description` - PR description generation from changelog
- `change_validation` - Branch change validation and conflict detection
- `conventional_commit_generation` - Commit message generation
- `branch_evaluation` - Branch naming and work context analysis

## 🔧 System Utilities

### Branch Validation (`utils/validate-branch-name.sh`)
Enforces feat/fix branch naming conventions with intelligent suggestions.

### Work Context Analysis (`utils/validate-work-context.sh`)
Analyzes actual changes to suggest appropriate branch names.

### Promptlet Compliance (`system/validate-*.sh`)
Ensures all agent tasks use the standardized promptlet system.

## 🔄 Workflow Integration

The agent system integrates with the main Makefile commands:

```bash
make pr-workflow    # Full PR creation pipeline
make commit         # Intelligent commit with agent-generated messages
make stage          # Intelligent file staging with agent decisions
make branch-new     # Branch creation with smart validation
```

## 📈 Workflow-Origin Tracking

All workflows support `--workflow-origin` parameter tracking to:
- ✅ Enable workflow debugging and tracing
- ✅ Provide context-aware decision making
- ✅ Support proper workflow chaining and continuation
- ✅ Improve error handling and user feedback

## 🎯 Design Principles

1. **Agent-Driven Intelligence**: Decisions are made by AI agents with structured context
2. **Ping-Pong Architecture**: Workflows generate promptlets → agents process → continue chain
3. **Graceful Degradation**: Workflows handle edge cases and continue gracefully
4. **Single Source of Truth**: All agent tasks defined in promptlet library
5. **Workflow Continuity**: Seamless chaining between different workflow steps

## 🔍 Debugging and Tracing

All workflows include comprehensive tracing:
- `🔍 TRACE [STEP]` - Shows workflow execution steps
- `workflow-origin` parameter tracking
- Clear success/failure messaging
- Promptlet generation logging

## 📝 Recent Improvements

- Fixed false conflict detection in PR validation
- Added workflow-origin parameter tracking throughout system