# Development Commands

.PHONY: dev-frontend dev-backend dev install-frontend install-backend install-all setup setup-git-tools cleanup verify commit pr-workflow branch-new

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

# ------------------------ AGENT WORKFLOWS ------------------------

# Path constants for agent scripts
AGENT_BASE := ./scripts/agent
AGENT_WORKFLOWS := $(AGENT_BASE)/workflows
AGENT_PROMPTLETS := $(AGENT_BASE)/promptlets
AGENT_UTILS := $(AGENT_BASE)/utils

# Commit workflow (Agent Workflow)
commit:
	@echo "🤖 Starting integrated commit workflow..."
	@$(AGENT_WORKFLOWS)/commit-workflow.sh integrated_commit_workflow false commit

# PR Workflow (Agent Workflow)
pr-workflow:
	@echo "🚀 Starting PR creation workflow..."; \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	echo "🌿 Current branch: $$BRANCH"; \
	$(AGENT_WORKFLOWS)/pr-workflow.sh pr_workflow_orchestrator --branch $$BRANCH --workflow-origin pr-workflow

# Branch Workflow (Agent Workflow)
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
	@echo "📝 Commit Workflow (Agent Workflow):"
	@echo "  make commit          - Auto-stage relevant files + generate conventional commit message"
	@echo ""
	@echo "🔧 Quality Control (Manual + Hooks):"
	@echo "  make cleanup         - Clean up before merge/push"
	@echo "  make verify          - Verify clean commit"
	@echo "  make fix             - Auto-fix linting and formatting"
	@echo "  make check           - Run all quality checks"
	@echo ""
	@echo "🌿 Branch Management Workflow (Agent Workflow):"
	@echo "  make branch-new      - Create new feature branch with checks (NAME=optional)"
	@echo ""
	@echo "🚢 PR Workflow (Agent Workflow):"
	@echo "  make pr-workflow     - Complete PR creation pipeline (validation + docs + push + PR)"
	@echo ""
	@echo "ℹ️  Help:"
	@echo "  make help            - Show this help message"
