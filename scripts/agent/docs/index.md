# Documentation Index

Quick navigation for agent system documentation.

## 📚 Main Documentation

| Document | Purpose |
|----------|---------|
| **[📖 README.md](./README.md)** | System architecture & design principles |
| **[🔄 Workflows Overview](./workflows-overview.md)** | Detailed workflow usage & parameters |

## 📊 Visual Diagrams

| Workflow | Diagram | Description |
|----------|---------|-------------|
| **System** | [🏗️ Architecture](./diagrams/system-architecture.mmd) | Complete system overview |
| **PR** | [🚀 PR Workflow](./diagrams/pr-workflow.mmd) | Pull request creation pipeline |
| **Commit** | [📝 Commit Workflow](./diagrams/commit-workflow.mmd) | Commit generation process |
| **Docs** | [📚 Docs Workflow](./diagrams/docs-workflow.mmd) | Documentation maintenance |
| **Branch** | [🌿 Branch Workflow](./diagrams/branch-workflow.mmd) | Branch creation & validation |

## ⚡ Quick Reference

### Trigger Phrases
| User Says | Command | Workflow |
|-----------|---------|----------|
| `"commit"`, `"save changes"` | `make commit` | [📝 Commit](./diagrams/commit-workflow.mmd) |
| `"push"`, `"create PR"` | `make pr-workflow` | [🚀 PR](./diagrams/pr-workflow.mmd) |
| `"create branch"` | `make branch-new` | [🌿 Branch](./diagrams/branch-workflow.mmd) |

### Key Files
- **Scripts**: `../workflows/*.sh` - Executable workflow scripts
- **Diagrams**: `./diagrams/*.mmd` - Mermaid visual flows
- **Config**: `../system/` - System configuration & validation
- **Utils**: `../utils/` - Shared utility functions

---

💡 **New to the system?** Start with [📖 README.md](./README.md) for architecture overview.
🔧 **Need usage details?** Check [🔄 Workflows Overview](./workflows-overview.md) for commands and parameters.