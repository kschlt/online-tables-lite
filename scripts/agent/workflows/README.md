# Workflow Scripts Documentation

This directory contains the core workflow orchestration scripts that power the agent-driven automation system.

## 🔄 Workflow Scripts

### PR Workflow (`pr-workflow.sh`)

Complete pull request creation pipeline with intelligent validation and automation.

#### Usage:
```bash
# Full automated PR workflow
make pr-workflow

# Individual functions
./scripts/agent/workflows/pr-workflow.sh validate_changes [--branch BRANCH] [--base BASE] [--workflow-origin ORIGIN]
./scripts/agent/workflows/pr-workflow.sh push_branch [--branch BRANCH] [--workflow-origin ORIGIN]
./scripts/agent/workflows/pr-workflow.sh pr_body [--branch BRANCH] [--workflow-origin ORIGIN]
./scripts/agent/workflows/pr-workflow.sh create_pr [--branch BRANCH] [--title TITLE] [--body BODY] [--workflow-origin ORIGIN]
./scripts/agent/workflows/pr-workflow.sh finalize_pr [--branch BRANCH] [--pr-url URL] [--workflow-origin ORIGIN]
```

#### Pipeline Flow:
1. **Validation** → Checks branch changes, detects conflicts, validates naming
2. **Documentation** → Auto-chains to docs workflow for analysis
3. **Push** → Pushes branch with pre-push hook integration
4. **PR Creation** → Creates new PR or updates existing one intelligently
5. **Finalization** → Post-creation tasks and deployment preparation

#### Key Features:
- ✅ **Smart Conflict Detection**: Detects fast-forward merges to avoid false positives
- ✅ **Existing PR Handling**: Updates existing PRs instead of failing
- ✅ **Workflow Tracking**: Complete workflow-origin parameter propagation
- ✅ **Auto-chaining**: Seamless transitions between workflow steps

#### Recent Fixes:
- Fixed false conflict detection for fast-forward merges
- Added existing PR detection and update logic
- Implemented universal workflow-origin parameter support
- Enhanced error handling with actionable guidance

---

### Documentation Workflow (`docs-workflow.sh`)

Automated documentation maintenance based on changelog analysis and workflow changes.

#### Usage:
```bash
# Individual functions
./scripts/agent/workflows/docs-workflow.sh generate_docs [BRANCH] [BASE_REF] [--workflow-origin ORIGIN]
./scripts/agent/workflows/docs-workflow.sh no_docs_changes [--workflow-origin ORIGIN]
./scripts/agent/workflows/docs-workflow.sh apply_docs [--files FILES] [--workflow-origin ORIGIN]
./scripts/agent/workflows/docs-workflow.sh commit_docs [--message MESSAGE] [--workflow-origin ORIGIN]
```

#### Pipeline Flow:
1. **Analysis** → Agent analyzes git-cliff changelog for documentation impacts
2. **Decision** → Agent chooses between:
   - `apply_docs` (if documentation changes made)
   - `no_docs_changes` (if no updates needed)
3. **Validation** → Checks for modified documentation files
4. **Commit** → Auto-commits documentation changes if found

#### Documentation Targets:
- 📝 **README.md** - CLI usage, API changes, configuration updates
- 📝 **Agent Documentation** - Workflow improvements in `scripts/agent/`
- 📝 **Design System** - UI component changes
- 📝 **Architecture Docs** - System design changes

#### Recent Improvements:
- Fixed workflow flow to handle NO-OP cases properly
- Added explicit agent documentation update instructions
- Separated no-change handling from validation logic
- Enhanced workflow-origin parameter support

---

### Commit Workflow (`commit-workflow.sh`)

Conventional commit message generation with git-cliff integration.

#### Usage:
```bash
# Used internally by make commit
./scripts/agent/workflows/commit-workflow.sh execute_commit --message "GENERATED_MESSAGE"
```

#### Features:
- ✅ **git-cliff Integration**: Uses project's changelog configuration
- ✅ **Conventional Commits**: Enforces proper commit message format
- ✅ **Pre-commit Hooks**: Integrates with quality checks and cleanup
- ✅ **Metadata Caching**: Caches commit data for efficient PR workflows

---

## 🎯 Common Parameters

All workflows support these standardized parameters:

### `--workflow-origin`
Tracks the originating workflow for proper chaining and context:
- `pr-workflow` - Originated from PR creation pipeline
- `commit-workflow` - Originated from commit process
- `docs-workflow` - Originated from documentation workflow
- `manual` - Manually executed

### `--branch`
Specifies the target branch (auto-detected if not provided)

### Error Handling
All workflows include:
- 🔍 **Comprehensive Tracing**: Step-by-step execution logging
- ✅ **Graceful Degradation**: Continue workflow even with non-critical failures
- 📝 **Actionable Messages**: Clear guidance for manual intervention when needed
- 🔄 **Auto-chaining**: Seamless transitions between workflow components

## 🚀 Integration with Make Commands

These workflows integrate with the main project commands:

```bash
make pr-workflow    # → pr-workflow.sh (full pipeline)
make commit         # → commit-workflow.sh (message generation)
make stage          # → Intelligent staging with agent decisions
```

## 📈 Workflow Architecture

### Ping-Pong Pattern
```
Workflow Script → Promptlet → Agent Analysis → Continue Workflow
```

### Auto-chaining
```
validate_changes → docs-workflow → push_branch → create_pr → finalize_pr
```

### Error Recovery
```
Error Detection → Actionable Message → Manual Intervention or Auto-retry
```

This architecture ensures robust, intelligent automation while maintaining transparency and debuggability.