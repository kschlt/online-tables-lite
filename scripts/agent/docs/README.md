# Agent System Architecture

## Overview

The agent system orchestrates development tasks through intelligent ping-pong interactions between Claude and specialized shell scripts. It operates on an **orchestrator-based architecture** where workflows are broken down into focused, single-responsibility functions that chain together seamlessly.

## Core Design Principles

1. **Ping-Pong Pattern**: Agent scripts generate promptlets (JSON task instructions) → Claude processes them → Returns to the next logical workflow step
2. **Separation of Concerns**: Each function handles a single responsibility with clean boundaries
3. **Workflow Chaining**: Automatic transitions between related workflow steps using `--workflow-origin` parameter tracking
4. **Graceful Degradation**: Workflows continue with warnings rather than failing completely

## System Architecture

**📊 [View Complete System Diagram](./diagrams/system-architecture.mmd)**

```
scripts/agent/
├── docs/                         # 📚 Documentation hub
├── workflows/                    # 🔄 Workflow orchestration scripts
├── promptlets/                   # 📋 Agent task definitions
├── processors/                   # 🔧 Data processing utilities
├── system/                       # ⚙️ System configuration & validation
└── utils/                        # 🛠 Utility functions
```

## Entry Points & Triggers

The system activates through CLAUDE.md trigger phrases:

| User Trigger | Claude Executes | Workflow |
|-------------|----------------|----------|
| `"commit"`, `"save changes"` | `make commit` | [📝 Commit](./diagrams/commit-workflow.mmd) |
| `"push"`, `"create PR"` | `make pr-workflow` | [🚀 PR](./diagrams/pr-workflow.mmd) |
| `"create branch"` | `make branch-new` | [🌿 Branch](./diagrams/branch-workflow.mmd) |

## Documentation Structure

- **[📋 Workflows Overview](./workflows-overview.md)** - Detailed workflow descriptions and usage
- **[🔍 Quick Navigation](./index.md)** - Documentation index and references
- **[📊 Visual Diagrams](./diagrams/)** - Mermaid workflow diagrams

## Integration

### Makefile Commands
```bash
make pr-workflow    # Complete PR creation pipeline
make commit         # Conventional commit generation
make branch-new     # Branch creation with validation
```

### Performance Features
- **Caching**: Git-cliff data and branch status caching (`workflow-cache.sh`)
- **Parallel Operations**: Batched git operations and validation checks
- **Error Recovery**: Graceful degradation with clear resolution guidance

## Getting Started

1. **Architecture**: Review [System Architecture Diagram](./diagrams/system-architecture.mmd)
2. **Workflows**: Check [Workflows Overview](./workflows-overview.md) for detailed usage
3. **Visual Learning**: Explore individual diagrams in `./diagrams/`
4. **Quick Reference**: Use [Navigation Index](./index.md) for specific topics