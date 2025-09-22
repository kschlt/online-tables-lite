# Workflow Scripts & Usage

Detailed descriptions and usage patterns for all agent workflows.

## 🚀 PR Workflow (`pr-workflow.sh`)

**📊 [View PR Workflow Diagram](./diagrams/pr-workflow.mmd)** | **🎨 [Diagram Guidelines](./diagrams/README.md)**

Complete pull request creation pipeline with intelligent validation and automation.

### Usage
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

### Pipeline Flow
1. **Validation** → Checks branch changes, detects conflicts, validates naming
2. **Documentation** → Auto-chains to docs workflow for analysis
3. **Push** → Pushes branch with pre-push hook integration
4. **PR Creation** → Creates new PR or updates existing one intelligently
5. **Finalization** → Post-creation tasks and deployment preparation

### Key Features
- ✅ Smart conflict detection (avoids false positives on fast-forward merges)
- ✅ Existing PR handling (updates instead of failing)
- ✅ Auto-chaining with docs workflow
- ✅ Workflow tracking with `--workflow-origin`

---

## 📝 Commit Workflow (`commit-workflow.sh`)

**📊 [View Commit Workflow Diagram](./diagrams/commit-workflow.mmd)**

Conventional commit message generation with git-cliff integration.

### Usage
```bash
# Used internally by make commit
./scripts/agent/workflows/commit-workflow.sh execute_commit --message "GENERATED_MESSAGE"
```

### Features
- ✅ git-cliff integration for conventional commits
- ✅ Automatic staging of relevant files
- ✅ Pre-commit hook compatibility
- ✅ Metadata caching for efficient PR workflows

---

## 📚 Documentation Workflow (`docs-workflow.sh`)

**📊 [View Documentation Workflow Diagram](./diagrams/docs-workflow.mmd)**

Automated documentation maintenance based on changelog analysis and workflow changes.

### Usage
```bash
# Individual functions
./scripts/agent/workflows/docs-workflow.sh generate_docs [BRANCH] [BASE_REF] [--workflow-origin ORIGIN]
./scripts/agent/workflows/docs-workflow.sh no_docs_changes [--workflow-origin ORIGIN]
./scripts/agent/workflows/docs-workflow.sh apply_docs [--files FILES] [--workflow-origin ORIGIN]
./scripts/agent/workflows/docs-workflow.sh commit_docs [--message MESSAGE] [--workflow-origin ORIGIN]
```

### Pipeline Flow
1. **Analysis** → Agent analyzes git-cliff changelog for documentation impacts
2. **Decision** → Agent chooses between:
   - `apply_docs` (if documentation changes made)
   - `no_docs_changes` (if no updates needed)
3. **Validation** → Checks for modified documentation files
4. **Commit** → Auto-commits documentation changes if found

### Documentation Targets
- 📝 **README.md** - CLI usage, API changes, configuration updates
- 📝 **Agent Documentation** - Workflow improvements in `scripts/agent/`
- 📝 **Design System** - UI component changes
- 📝 **Architecture Docs** - System design changes

---

## 🌿 Branch Workflow (Makefile: `branch-new`)

**📊 [View Branch Workflow Diagram](./diagrams/branch-workflow.mmd)**

Intelligent branch creation with validation, naming compliance, and context analysis.

### Key Features
- Uncommitted changes detection and handling
- Branch naming convention enforcement
- Open PR coordination
- Main branch synchronization

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