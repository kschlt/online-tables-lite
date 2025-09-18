# Agent System Architecture

This document provides a comprehensive overview of the agent-driven workflow system, including entry points, workflow chains, and decision trees.

## Overview

The agent system is designed around a **ping-pong architecture** where:
1. **Claude (User Interface)** triggers workflows via CLAUDE.md trigger phrases
2. **Makefile** serves as the central dispatcher to agent scripts
3. **Agent Scripts** execute workflow steps and generate **promptlets** (JSON task instructions)
4. **Claude** processes promptlets and continues the chain

## System Architecture Diagram

**📊 [View System Architecture Diagram](./system-architecture.mmd)**

## Entry Points and Triggers

The system has three main entry points triggered by specific phrases in user conversations:

### 1. Commit Workflow Trigger
**User says:** `"commit"`, `"commit changes"`, `"save changes"`
**Claude executes:** `make commit`

### 2. Push & PR Workflow Trigger
**User says:** `"push"`, `"create PR"`, `"open PR"`, `"make PR"`
**Claude executes:** `make pr-workflow`

### 3. Branch Creation Trigger
**User says:** `"create branch"`, `"new branch"`
**Claude executes:** `make branch-new`

## Workflow Chains

Each workflow follows a **ping-pong pattern** where agent scripts generate promptlets that Claude processes:

### Commit Chain
```
make commit → generate promptlet → Claude processes → execute_commit → completion
```

### PR Chain
```
make pr-workflow → validate_changes → docs-workflow → push_branch → create_pr → finalize_pr
```

### Branch Chain
```
make branch-new → validate context → generate promptlet → Claude creates branch
```

## Key Components

### 1. **Makefile (Central Dispatcher)**
- **Location:** `./Makefile`
- **Role:** Central command dispatcher, parameter validation, workflow routing
- **Key Commands:** `commit`, `pr-workflow`, `branch-new`, `stage`

### 2. **Agent Workflows**
- **Location:** `./scripts/agent/workflows/`
- **Components:**
  - `pr-workflow.sh` - Complete PR creation chain
  - `commit-workflow.sh` - Commit execution with validation
  - `docs-workflow.sh` - Documentation update chain

### 3. **Utilities**
- **Location:** `./scripts/agent/utils/`
- **Components:**
  - `validate-branch-name.sh` - Branch naming compliance
  - `validate-work-context.sh` - Work vs branch name validation
  - `workflow-cache.sh` - Performance optimization via caching

### 4. **Promptlet System**
- **Location:** `./scripts/agent/promptlets/`
- **Components:**
  - `promptlet-reader.sh` - JSON task generator
  - `promptlets.json` - Standardized task library

## Workflow Diagrams

### Complete Workflow Flows
- **🚀 [PR Workflow](./workflows/pr-workflow.mmd)** - Complete pull request creation pipeline
- **📝 [Commit Workflow](./workflows/commit-workflow.mmd)** - Conventional commit generation and execution
- **🌿 [Branch Workflow](./workflows/branch-workflow.mmd)** - Intelligent branch creation with validation

## Performance Optimizations

### Caching System
The workflow system uses a centralized caching mechanism (`workflow-cache.sh`) to:
- **Cache git-cliff data** across workflow steps
- **Store branch status** to avoid repeated git operations
- **Share metadata** between workflow functions

### Parallel Operations
- **Git operations** are batched where possible
- **Validation checks** run in combined operations
- **Multiple tool calls** are executed in parallel by Claude

## Error Handling

### Graceful Degradation
- **Missing dependencies:** Workflows continue with warnings
- **Network issues:** Local operations proceed, remote operations deferred
- **Validation failures:** Clear promptlets guide resolution

### Recovery Mechanisms
- **Uncommitted changes:** Automatic stash/commit guidance
- **Merge conflicts:** Step-by-step resolution instructions
- **PR conflicts:** Automatic detection and update logic

## Security & Compliance

### Branch Protection
- **Protected branches:** main, production cannot be directly modified
- **Naming validation:** Enforced conventional branch naming
- **Work context validation:** Branch names must match actual work

### Commit Standards
- **Conventional commits:** Enforced via git-cliff integration
- **Changelog generation:** Automatic updates based on commit messages
- **Quality gates:** Pre-commit and pre-push hooks ensure code quality

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

---

## Quick Reference

### Trigger Phrases
| User Says | Claude Executes | Workflow |
|-----------|----------------|----------|
| "commit", "save changes" | `make commit` | [Commit Workflow](./workflows/commit-workflow.mmd) |
| "push", "create PR" | `make pr-workflow` | [PR Workflow](./workflows/pr-workflow.mmd) |
| "create branch", "new branch" | `make branch-new` | [Branch Workflow](./workflows/branch-workflow.mmd) |

### Key Features
- ✅ **Ping-Pong Architecture** - Agent scripts generate promptlets → Claude processes → continues chain
- ✅ **Smart Validation** - Branch naming, work context, merge conflict detection
- ✅ **Graceful Error Handling** - Clear recovery paths for all failure scenarios
- ✅ **Performance Optimization** - Centralized caching and batched operations
- ✅ **GitHub Integration** - Automated PR creation/updates via gh CLI