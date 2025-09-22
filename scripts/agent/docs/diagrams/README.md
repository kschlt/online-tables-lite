# Mermaid Diagram Guidelines

**Single source of truth for architectural diagram standards across all workflows.**

*Design system configuration: `../../system/diagram-config.json`*
*Validation: `../../system/validate-diagrams.sh`*
*Template generation: `../../system/generate-diagram-template.sh`*

## Quick Start

### Create New Diagram
```bash
# Generate template with current design system
./scripts/agent/system/generate-diagram-template.sh > my-workflow.mmd

# Or generate specific template types
./scripts/agent/system/generate-diagram-template.sh minimal > simple.mmd
./scripts/agent/system/generate-diagram-template.sh architecture > system.mmd
```

### Validate Existing Diagrams
```bash
# Validate all diagrams
./scripts/agent/system/validate-diagrams.sh

# Validate specific diagram
./scripts/agent/system/validate-diagrams.sh pr-workflow.mmd
```

### View Current Design System
```bash
./scripts/agent/system/generate-diagram-template.sh --config
```

## Color Legend & Semantic Meanings

Our diagram system uses consistent color coding to represent different types of system components and interactions:

### Core Color Classifications

| Color | Hex Code | Semantic Meaning | Usage |
|-------|----------|------------------|-------|
| 🟣 **Purple** | `#f3e5f5` | **Agent Layer** | Claude detects, executes, generates, AI reasoning and analysis tasks |
| 🔵 **Blue** | `#e1f5fe` | **User Layer** | User triggers, interactions, manual input points, user decisions |
| 🟡 **Yellow** | `#fff3e0` | **Automation Steps** | Makefile dispatching, script execution, validation checks, system operations |
| 🔴 **Red** | `#ffcdd2` | **Stop Nodes** | Error conditions, blocking states, user action required |
| 🟢 **Green** | `#a5d6a7` | **Success Nodes** | Workflow completion, successful outcomes |
| ⚫ **Gray** | `#f5f5f5` | **Black Box Steps** | Pre-commit hooks, external system interactions, simplified complex processes |
| 🟢 **Light Green** | `#e8f5e8` | **Entry Points** | Workflow initiation points, chain entry from other workflows |

## Node Shape Conventions

### Standard Shapes
- **Rectangle** `["text"]` - Standard process steps
- **Rhombus** `{"text"}` - Decision points/conditionals
- **Rounded Rectangle** `("text")` - Start/end points
- **Circle** `(("text"))` - Connection points
- **Asymmetric** `@{ shape: rect}` - Special user interaction nodes

### Subgraph Styling
```mermaid
subgraph WorkflowBox["🤖 WORKFLOW NAME<br>📄 <i>See: script-name.sh</i>"]
    direction TB
    Content["Workflow content"]
end
```

## Required classDef Definitions

Every workflow diagram MUST include these classDef definitions:

```mermaid
classDef userLayer fill:#e1f5fe
classDef agentLayer fill:#f3e5f5
classDef automationStep fill:#fff3e0
classDef stopNode fill:#ffcdd2
classDef successNode fill:#a5d6a7
classDef blackBoxStep fill:#f5f5f5
classDef entryPoint fill:#e8f5e8
classDef subgraphStyle fill:#f9f9f9,stroke:#666,stroke-width:2px,stroke-dasharray: 5 5
```

## Centralized Design System

All styling is now managed through `../../system/diagram-config.json`. This ensures:

- ✅ **Single source of truth** for all colors and styles
- ✅ **Automatic template generation** with current standards
- ✅ **Validation consistency** using same configuration
- ✅ **Easy updates** - change config once, affects all new diagrams

### Updating the Design System

1. **Modify colors/styles**: Edit `../../system/diagram-config.json`
2. **Generate new template**: Run `./scripts/agent/system/generate-diagram-template.sh`
3. **Validate existing diagrams**: Run `./scripts/agent/system/validate-diagrams.sh`
4. **Update non-compliant diagrams**: Use generated template as reference

## Validation Rules

The following rules are enforced by the validation script:

### Required Elements
- ✅ All classDef definitions must be present
- ✅ Every node must have appropriate styling applied
- ✅ Colors must match semantic meanings exactly
- ✅ User interactions must use `userLayer` class
- ✅ Agent actions must use `agentLayer` class
- ✅ Automation steps must use `automationStep` class

### Consistency Checks
- ✅ No custom colors outside the standard palette
- ✅ Proper node shape usage for different types
- ✅ Consistent emoji usage (🤖 for agents, 👤 for users, etc.)
- ✅ Subgraph styling follows standard pattern

### Content Standards
- ✅ Clear, descriptive node labels
- ✅ Consistent verb tenses (present for actions, imperative for stops)
- ✅ Proper workflow documentation references

## Quick Reference

**When creating diagrams, ask yourself:**
- 🟣 Is this Claude/AI doing something? → `agentLayer`
- 🔵 Is this user input/interaction? → `userLayer`
- 🟡 Is this automated system logic? → `automationStep`
- 🔴 Does this stop the workflow? → `stopNode`
- 🟢 Does this complete successfully? → `successNode`
- ⚫ Is this a black box/external system? → `blackBoxStep`

## Integration

This color system is designed to work across:
- Individual workflow diagrams (pr-workflow, commit-workflow, etc.)
- System architecture overviews
- Future architectural documentation
- Validation tooling and CI/CD checks

For usage examples, see existing workflow diagrams in this directory.