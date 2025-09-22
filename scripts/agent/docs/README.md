# Agent System Architecture

## Overview

The agent system orchestrates development tasks through intelligent ping-pong interactions between Claude and specialized shell scripts. It provides a structured, automated workflow framework that scales from simple commits to complex multi-step operations.

**📊 [Complete System Architecture](./diagrams/system-architecture.mmd)**

## Core Design Principles

**🔄 Business Logic First**: Automate everything possible with pure business logic (faster, predictable). Only use LLM for generative tasks.

**🎯 Single-Purpose Functions**: Each function serves one specific purpose with clean boundaries. Orchestrator functions bundle multiple functions into automated flows.

**📁 File Organization**: One workflow file per domain (commit, PR, docs, branch). Related functions stay together. Move to `utils/` only when functions are shared across multiple workflows.

**📋 Standardized Promptlets**: Use prompt library pattern with validated JSON schemas. Promptlets follow consistent structure and are validated/linted for compliance.

**🔄 Ping-Pong Pattern**: Business logic handles automation → Generate promptlet for LLM tasks → Claude processes → Return to next logical workflow step

**🔗 Workflow Chaining**: Automatic transitions between related workflow steps using `--workflow-origin` parameter tracking

**🛡️ Graceful Degradation**: Workflows continue with warnings rather than failing completely

## Integration Pattern

```
User Trigger → CLAUDE.md Detection → Makefile Dispatch → Agent Workflows → GitHub
```

Claude detects trigger phrases in CLAUDE.md, executes corresponding `make` commands, which dispatch to specialized workflow scripts that handle automation and return control to Claude when human input is needed.

## System Structure

```
scripts/agent/
├── docs/          # Documentation and visual diagrams
├── workflows/     # Domain-specific workflow files (one per workflow type)
│   └── *.sh       # Contains single-purpose functions + orchestrators
├── promptlets/    # Standardized prompt library with validation
│   ├── *.json     # Prompt templates following consistent schema
│   └── reader.sh  # Prompt loading and validation logic
├── utils/         # Cross-workflow shared utilities only
│   └── *.sh       # Functions used by multiple workflows
└── system/        # System configuration and validation logic
```

**Key Principles**:
- **Domain Cohesion**: Keep related functions in same workflow file
- **Utility Promotion**: Move to `utils/` only when shared across workflows
- **Prompt Standardization**: All LLM interactions use validated promptlet library

## Adding New Workflows

Follow established patterns when extending the system:

1. **Create workflow script** in `workflows/` with:
   - Single-purpose functions for each step
   - Orchestrator function bundling automation flow
   - Business logic handling before LLM calls

2. **Define promptlets** in `promptlets/` for generative tasks:
   - Follow standard JSON schema pattern
   - Validate against existing promptlet structure
   - Use for creative/generative work only

3. **Organize functions properly**:
   - Keep domain-related functions in same workflow file
   - Extract to `utils/` only when used across multiple workflows
   - Maintain clear separation between automation and generation

4. **Add integration points**:
   - Trigger phrase in CLAUDE.md if user-initiated
   - Makefile entry for centralized dispatch
   - Workflow diagram to visualize the flow
   - Update workflows-overview.md with usage details

## Documentation

- **[Technical Usage Guide](./workflows-overview.md)** - Detailed workflow usage and parameters
- **[Visual Diagrams](./diagrams/)** - Mermaid workflow diagrams
- **Getting Started**: Review system architecture diagram, then explore individual workflow diagrams