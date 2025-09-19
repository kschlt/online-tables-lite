# Online Tables Lite - Development Commands

# Path constants for agent scripts
AGENT_BASE := ./scripts/agent
AGENT_WORKFLOWS := $(AGENT_BASE)/workflows
AGENT_PROMPTLETS := $(AGENT_BASE)/promptlets
AGENT_UTILS := $(AGENT_BASE)/utils
AGENT_SYSTEM := $(AGENT_BASE)/system

.PHONY: dev-frontend dev-backend dev install-frontend install-backend install-all setup setup-git-tools cleanup verify commit ship docs-commit pr-title-suggest pr-body pr-open branch-suggest branch-rename branch-new validate-promptlets

# Start frontend development server
dev-frontend:
	cd apps/web && npm run dev

# Start backend development server
dev-backend:
	cd apps/api && source venv/bin/activate && python3 main.py

# Start both frontend and backend (run in separate terminals)
dev:
	@echo "🚀 Starting Online Tables Lite..."
	@echo "📱 Frontend: http://localhost:3000"
	@echo "🔧 Backend: http://localhost:8000"
	@echo ""
	@echo "Run 'make dev-frontend' in one terminal and 'make dev-backend' in another"
	@echo "Or use 'make dev-all' to start both in background"

# Start both frontend and backend in background
dev-all:
	@echo "🚀 Starting Online Tables Lite in background..."
	cd apps/web && npm run dev &
	cd apps/api && source venv/bin/activate && python3 main.py &
	@echo "📱 Frontend: http://localhost:3000"
	@echo "🔧 Backend: http://localhost:8000"
	@echo "Use 'make stop' to stop all services"

# Install frontend dependencies
install-frontend:
	cd apps/web && npm install

# Install backend dependencies
install-backend:
	cd apps/api && source venv/bin/activate && pip install -r requirements.txt

# Install all dependencies
install-all: install-frontend install-backend
	@echo "✅ All dependencies installed!"

# Stop all background processes
stop:
	@echo "🛑 Stopping all services..."
	pkill -f "npm run dev" || true
	pkill -f "next dev" || true
	pkill -f "main.py" || true
	pkill -f "uvicorn" || true
	pkill -f "python.*main.py" || true
	@echo "✅ All services stopped"

# Quick setup for new developers
setup: install-all setup-git-tools
	@echo "🎉 Setup complete! Run 'make dev' to start development"

# Setup git-cliff and related tools for changelog automation
setup-git-tools:
	@echo "🔧 Setting up git-cliff and changelog tools..."
	@if ! command -v git-cliff >/dev/null 2>&1; then \
		echo "📦 Installing git-cliff via Homebrew..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew install git-cliff; \
		else \
			echo "❌ Homebrew not found. Please install git-cliff manually:"; \
			echo "   https://git-cliff.org/docs/installation"; \
			exit 1; \
		fi; \
	else \
		echo "✅ git-cliff already installed"; \
	fi
	@echo "🔍 Verifying git-cliff configuration..."
	@if [ -f "cliff.toml" ]; then \
		echo "✅ cliff.toml configuration found"; \
	else \
		echo "❌ cliff.toml not found - this should not happen"; \
		exit 1; \
	fi
	@echo "🔍 Verifying commitlint dependencies..."
	@if [ -f "apps/web/node_modules/.bin/commitlint" ]; then \
		echo "✅ commitlint installed in web app"; \
	else \
		echo "⚠️  commitlint not found - run 'cd apps/web && npm install' to install"; \
	fi
	@echo "✅ Git tools setup complete!"


# Clean up before merge/push (using organized scripts)
cleanup:
	./scripts/git/cleanup-before-merge.sh

# Verify clean commit (using organized scripts)
verify:
	./scripts/git/verify-clean-commit.sh

# Fix issues then run quality checks (recommended workflow)
check: verify
	@echo "🔧 Auto-fixing and checking..."
	@echo "🔧 Frontend: Auto-fixing..."
	cd apps/web && npm run fix
	@echo "🔧 Backend: Auto-fixing..."
	cd apps/api && source venv/bin/activate && ruff check --fix . && ruff format .
	@echo "🔍 Frontend: Validating..."
	cd apps/web && npm run check
	@echo "🔍 Backend: Linting..."
	cd apps/api && source venv/bin/activate && ruff check . && ruff format --check .
	@echo "🔍 Building..."
	cd apps/web && npm run build
	@echo "🔍 Validating conventional commits..."
	@if command -v git-cliff >/dev/null 2>&1; then \
		if git-cliff --unreleased >/dev/null 2>&1; then \
			echo "✅ Git-cliff validation passed"; \
		else \
			echo "⚠️  Some commits may not follow conventional format"; \
		fi; \
	else \
		echo "ℹ️  git-cliff not available, skipping commit validation"; \
	fi
	@echo "🔍 Validating CHANGELOG.md format..."
	@if [ -f "CHANGELOG.md" ]; then \
		echo "✅ CHANGELOG.md exists and will be validated by git-cliff during ship"; \
	else \
		echo "ℹ️  CHANGELOG.md not found"; \
	fi
	@echo "✅ All fixes applied and checks passed!"

# Fix issues only (no validation)
fix:
	@echo "🔧 Auto-fixing all issues..."
	cd apps/web && npm run fix
	cd apps/api && source venv/bin/activate && ruff check --fix . && ruff format .
	@echo "✅ All fixes applied!"

# ---------- Integrated Commit workflow (staging + conventional commits with git-cliff) ----------

# Integrated commit workflow - handles staging + conventional commit generation
# Automatically stages relevant files if no files are staged, then generates commit message
commit:
	@echo "🤖 Starting integrated commit workflow..."
	@$(AGENT_WORKFLOWS)/commit-workflow.sh integrated_commit_workflow false commit_command


# ---------- Ship workflow (agent-friendly PR creation) ----------
SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c

# Project-specific configuration
BASE_REF        ?= origin/main
PR_BASE         ?= main
REMOTE          ?= origin
DOC_PATHS       := README.md apps/web/DESIGN_SYSTEM.md scripts/README.md **/*.md
CODE_HINTS      := apps/** supabase/** scripts/**
EXCLUDE_GLOBS   := node_modules/** venv/** .next/** dist/** build/** .git/** .agent/**

# Delimiters for human-readable sections (PR/branch output only)
PRBODY_BEGIN := ### BEGIN PR BODY
PRBODY_END   := ### END PR BODY
TITLE_BEGIN  := ### BEGIN PR TITLE
TITLE_END    := ### END PR TITLE
BRANCH_BEGIN := ### BEGIN BRANCH SUGGESTION
BRANCH_END   := ### END BRANCH SUGGESTION

# Generate documentation update promptlet (for agent processing)
# Always shows current branch context to prevent confusion
ship:
	@echo "🔍 Validating current branch before ship workflow..."; \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$BRANCH" = "main" ] || [ "$$BRANCH" = "production" ]; then \
		echo "❌ Cannot ship from protected branch: $$BRANCH"; \
		echo "💡 Create a feature branch first: make branch-new NAME=feat/your-feature"; \
		exit 1; \
	fi; \
	echo "✅ Branch validation passed: $$BRANCH"
	@$(AGENT_WORKFLOWS)/docs-workflow.sh generate_docs

# Commit doc edits (only if there are any)
docs-commit:
	@echo "🔍 Checking for documentation updates (excluding CHANGELOG.md)..."; \
	DOC_PATHS_NO_CHANGELOG=$$(echo "$(DOC_PATHS)" | tr ' ' '\n' | grep -v CHANGELOG.md | tr '\n' ' '); \
	git add $$DOC_PATHS_NO_CHANGELOG >/dev/null 2>&1 || true; \
	if git diff --cached --quiet -- $$DOC_PATHS_NO_CHANGELOG 2>/dev/null; then \
		echo "✅ No doc changes to commit (CHANGELOG.md handled by pre-push hook)."; \
	else \
		git commit -m "docs: sync documentation with latest changes"; \
		echo "✅ Documentation changes committed."; \
	fi


# Print PR title suggestion
pr-title-suggest:
	@BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
	TITLE=$$(git log --format='%s' $$BASE..HEAD | head -1 | sed 's/[[:space:]]\+/ /g'); \
	[[ -n "$$TITLE" ]] || TITLE="Update: miscellaneous changes"; \
	echo "$(TITLE_BEGIN)"; echo "$$TITLE"; echo "$(TITLE_END)"

# Validate changes before PR creation
pr-validate:
	@$(AGENT_WORKFLOWS)/pr-workflow.sh validate_changes

# Generate PR description promptlet (for agent processing)
pr-body:
	@$(AGENT_WORKFLOWS)/pr-workflow.sh pr_body


# Start PR creation workflow (entry point)
pr-workflow:
	@echo "🚀 Starting PR creation workflow..."; \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	echo "🌿 Current branch: $$BRANCH"; \
	$(AGENT_WORKFLOWS)/pr-workflow.sh validate_changes --branch $$BRANCH --workflow-origin pr-workflow

# Create GitHub PR with provided title and body (ping-pong final step)
# Usage: make pr-open TITLE="PR Title" BODY="PR markdown description"
pr-open:
	@echo "🔍 Validating branch before PR creation..."; \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	echo "🌿 Current branch: $$BRANCH"; \
	if [ "$$BRANCH" = "main" ] || [ "$$BRANCH" = "production" ]; then \
		echo "❌ Cannot create PR from protected branch: $$BRANCH"; \
		echo "💡 Create a feature branch first: make branch-new NAME=feat/your-feature"; \
		exit 1; \
	fi; \
	echo "✅ Branch validation completed: $$BRANCH"; \
	TITLE=$${TITLE:-$$(git log -1 --pretty='%s' | sed 's/[[:space:]]\+/ /g')}; \
	if [ -z "$$BODY" ]; then \
		echo "❌ Error: BODY parameter required"; \
		echo "Usage: make pr-open TITLE=\"PR Title\" BODY=\"markdown description\""; \
		echo "💡 Workflow:"; \
		echo "  1. make pr-push    → push branch"; \
		echo "  2. make pr-body    → get promptlet"; \
		echo "  3. [agent processes promptlet into markdown]"; \
		echo "  4. make pr-open TITLE=\"...\" BODY=\"...\" → create PR"; \
		exit 1; \
	fi; \
	if command -v gh >/dev/null 2>&1; then \
		echo "📝 Creating PR → $(PR_BASE)"; \
		if [[ "$${DRAFT:-false}" == "true" ]]; then DFLAG="--draft"; else DFLAG=""; fi; \
		if gh pr view "$$BRANCH" --json number >/dev/null 2>&1; then \
			echo "📝 Updating existing PR for branch: $$BRANCH"; \
			gh pr edit "$$BRANCH" --title "$$TITLE" --body "$$BODY"; \
			PR_URL=$$(gh pr view "$$BRANCH" --json url -q .url); \
			echo "✅ PR updated: $$PR_URL"; \
		else \
			echo "📝 Creating new PR for branch: $$BRANCH"; \
			gh pr create --base $(PR_BASE) --head "$$BRANCH" --title "$$TITLE" --body "$$BODY" $$DFLAG; \
		fi; \
	else \
		echo "ℹ️  GitHub CLI (gh) not found. Install with: brew install gh"; \
		echo "📝 Proposed PR Title: $$TITLE"; \
		echo "📝 Proposed PR Body:"; \
		echo "$$BODY"; \
	fi

# Suggest better branch name
branch-suggest:
	@BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
	TITLE=$$(git log --format='%s' $$BASE..HEAD | head -1 | tr '[:upper:]' '[:lower:]'); \
	[[ -n "$$TITLE" ]] || TITLE="update miscellaneous"; \
	SAFE=$$(printf "%s" "$$TITLE" | sed 's/[^a-z0-9]+/-/g; s/ /-/g; s/--\+/-/g; s/^-//; s/-$$//'); \
	SUG=$$(printf "feature/%s" "$$SAFE" | cut -c1-70); \
	echo "$(BRANCH_BEGIN)"; \
	echo "Current: $$BRANCH"; echo "Suggested: $$SUG"; \
	echo "To rename: make branch-rename NAME=$$SUG"; \
	echo; \
	$(AGENT_PROMPTLETS)/promptlet-reader.sh branch_evaluation \
		current_branch="$$BRANCH" \
		suggested_name="$$SUG" \
		changes_context="Recent commits and file changes"; \
	echo "$(BRANCH_END)"

# Validate promptlet system (multi-stage compliance)
validate-promptlets:
	@echo "🤖 Validating promptlet system compliance..."
	@$(AGENT_SYSTEM)/validate-promptlet-system.sh --force

# Rename branch (PR-safe)
branch-rename:
	@NEW=$${NAME:-}; \
	if [ -z "$$NEW" ]; then \
		echo "Usage: make branch-rename NAME=feat/good-name"; \
		echo "💡 Get naming suggestion: $(AGENT_UTILS)/validate-branch-name.sh \$$(git rev-parse --abbrev-ref HEAD) suggest"; \
		exit 2; \
	fi; \
	CUR=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CUR" = "main" ] || [ "$$CUR" = "production" ]; then \
		echo "❌ Cannot rename protected branch: $$CUR"; \
		exit 1; \
	fi; \
	echo "🔍 Validating new branch name: $$NEW"; \
	if ! $(AGENT_UTILS)/validate-branch-name.sh "$$NEW" validate >/dev/null 2>&1; then \
		echo "❌ New branch name '$$NEW' violates naming policy"; \
		$(AGENT_UTILS)/validate-branch-name.sh "$$NEW" promptlet; \
		exit 1; \
	fi; \
	echo "✅ New branch name is compliant"; \
	echo "🔍 Checking for existing PR..."; \
	if command -v gh >/dev/null 2>&1; then \
		PR_INFO=$$(gh pr list --head "$$CUR" --json number,title 2>/dev/null || echo "[]"); \
		PR_NUMBER=$$(echo "$$PR_INFO" | jq -r '.[0].number // empty' 2>/dev/null || echo ""); \
		if [ -n "$$PR_NUMBER" ]; then \
			echo "🔄 Found existing PR #$$PR_NUMBER - will update automatically"; \
			echo "📝 Renaming local branch..."; \
			git branch -m "$$NEW"; \
			echo "📤 Pushing new branch name to remote..."; \
			git push origin -u "$$NEW"; \
			echo "🗑️  Deleting old remote branch..."; \
			git push origin --delete "$$CUR" 2>/dev/null || echo "⚠️  Could not delete old remote branch (may not exist)"; \
			echo "✅ PR #$$PR_NUMBER automatically updated to track new branch name"; \
			echo "🔗 PR will now show changes from: $$NEW"; \
		else \
			echo "ℹ️  No existing PR found - performing simple rename"; \
			git branch -m "$$NEW"; \
			if git rev-parse --verify "origin/$$CUR" >/dev/null 2>&1; then \
				echo "📤 Updating remote branch..."; \
				git push origin -u "$$NEW"; \
				git push origin --delete "$$CUR"; \
			fi; \
		fi; \
	else \
		echo "ℹ️  GitHub CLI not available - performing local rename only"; \
		git branch -m "$$NEW"; \
		echo "⚠️  Manual steps required if branch was pushed:"; \
		echo "   1. git push origin -u $$NEW"; \
		echo "   2. git push origin --delete $$CUR"; \
		echo "   3. Update any existing PR to track new branch"; \
	fi; \
	echo "🔁 Branch renamed: $$CUR → $$NEW"

# Create new feature branch with automated checks (2B streamlined version)
branch-new:
	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT_BRANCH" != "main" ]; then \
		if ! git diff --quiet || ! git diff --cached --quiet; then \
			if ! git diff --cached --quiet; then \
				echo "❌ STOP: Staged changes detected"; \
				echo "Terminal: Commit changes first"; \
				echo "USER ACTION REQUIRED: make commit"; \
			else \
				echo "❌ STOP: Unstaged changes detected"; \
				echo "Terminal: Stash changes first"; \
				echo "USER ACTION REQUIRED: git stash"; \
			fi; \
			exit 1; \
		fi; \
		git checkout main; \
	fi; \
	git fetch origin main >/dev/null 2>&1; \
	if [ "$$(git rev-parse main)" != "$$(git rev-parse origin/main)" ]; then \
		git pull origin main; \
	fi; \
	if command -v gh >/dev/null 2>&1; then \
		OPEN_PRS=$$(gh pr list --state open --json number,title,headRefName 2>/dev/null || echo "[]"); \
		PR_COUNT=$$(echo "$$OPEN_PRS" | jq length 2>/dev/null || echo "0"); \
		if [ "$$PR_COUNT" -gt 0 ]; then \
			echo "⚠️ STOP: Open PRs detected"; \
			echo "Terminal: $$PR_COUNT open PRs found"; \
			echo "$$OPEN_PRS" | jq -r '.[] | "  #\(.number): \(.title) (\(.headRefName))"' 2>/dev/null || echo "  Could not parse PR details"; \
			echo "USER CHOICE: Continue anyway? (Y/N)"; \
		fi; \
	fi; \
	BRANCH_NAME=$${NAME:-}; \
	if [ -z "$$BRANCH_NAME" ]; then \
		$(AGENT_PROMPTLETS)/promptlet-reader.sh branch_name_generation \
			open_prs="$${PR_COUNT:-0}"; \
	else \
		if ! $(AGENT_UTILS)/validate-branch-name.sh "$$BRANCH_NAME" validate >/dev/null 2>&1; then \
			AUTO_FIXED=$$($(AGENT_UTILS)/validate-branch-name.sh "$$BRANCH_NAME" auto-fix 2>/dev/null || echo ""); \
			if [ -n "$$AUTO_FIXED" ] && $(AGENT_UTILS)/validate-branch-name.sh "$$AUTO_FIXED" validate >/dev/null 2>&1; then \
				BRANCH_NAME="$$AUTO_FIXED"; \
				echo "✅ Auto-fixed name: $$BRANCH_NAME"; \
			else \
				$(AGENT_UTILS)/validate-branch-name.sh "$$BRANCH_NAME" promptlet; \
				exit 1; \
			fi; \
		fi; \
		git checkout -b "$$BRANCH_NAME"; \
		echo "✅ Branch created: $$BRANCH_NAME"; \
	fi


# Help command
help:
	@echo "📋 Available commands:"
	@echo ""
	@echo "🚀 Development (Manual):"
	@echo "  make dev-frontend    - Start frontend development server"
	@echo "  make dev-backend     - Start backend development server"
	@echo "  make dev             - Show development instructions"
	@echo "  make dev-all         - Start both servers in background"
	@echo "  make stop            - Stop all background services"
	@echo ""
	@echo "📦 Setup (Manual):"
	@echo "  make install-all     - Install all dependencies"
	@echo "  make setup           - Quick setup for new developers"
	@echo "  make setup-git-tools - Install git-cliff and changelog tools"
	@echo ""
	@echo "📝 Integrated Commit Workflow (Agent Workflow):"
	@echo "  make commit          - Auto-stage relevant files + generate conventional commit message"
	@echo ""
	@echo "🔧 Quality Control (Manual + Hooks):"
	@echo "  make cleanup         - Clean up before merge/push"
	@echo "  make verify          - Verify clean commit"
	@echo "  make fix             - Auto-fix linting and formatting"
	@echo "  make check           - Run all quality checks"
	@echo ""
	@echo "🌿 Branch Management:"
	@echo "  make branch-new      - Create new feature branch with checks (NAME=optional)"
	@echo "  make branch-suggest  - Suggest better branch name"
	@echo "  make branch-rename   - Rename branch (NAME=new-name)"
	@echo ""
	@echo "🚢 Ship Workflow - Manual Testing:"
	@echo "  make ship            - Generate docs promptlet + PR materials"
	@echo "  make pr-title-suggest - Show suggested PR title"
	@echo "  make pr-body         - Generate PR description promptlet (for agent)"
	@echo ""
	@echo "🤖 Ship Workflow - Agent Commands:"
	@echo "  make docs-commit     - Commit documentation updates"
	@echo "  make pr-open BODY=\"description\" - Push branch + create GitHub PR"
	@echo ""
	@echo "🔄 Git Hooks (Automatic):"
	@echo "  pre-commit          - Auto-runs: cleanup → fix → verify"
	@echo "  pre-push            - Lightweight verification (agent handles analysis)"
	@echo ""
	@echo "ℹ️  Help:"
	@echo "  make help            - Show this help message"
