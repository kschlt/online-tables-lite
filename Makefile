# Online Tables Lite - Development Commands

.PHONY: dev-frontend dev-backend dev install-frontend install-backend install-all setup cleanup verify ship docs-commit docs-update pr-title-suggest pr-body pr-open branch-suggest branch-rename

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
setup: install-all
	@echo "🎉 Setup complete! Run 'make dev' to start development"

# Development environment setup (using organized scripts)
setup-dev:
	./scripts/dev/setup-dev.sh

# Start development servers (using organized scripts)
start-dev:
	./scripts/dev/start-dev.sh

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
	@echo "✅ All fixes applied and checks passed!"

# Fix issues only (no validation)
fix:
	@echo "🔧 Auto-fixing all issues..."
	cd apps/web && npm run fix
	cd apps/api && source venv/bin/activate && ruff check --fix . && ruff format .
	@echo "✅ All fixes applied!"

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

PROMPT_BEGIN := ### BEGIN DOCS PROMPT
PROMPT_END   := ### END DOCS PROMPT
PRBODY_BEGIN := ### BEGIN PR BODY
PRBODY_END   := ### END PR BODY
TITLE_BEGIN  := ### BEGIN PR TITLE
TITLE_END    := ### END PR TITLE
BRANCH_BEGIN := ### BEGIN BRANCH SUGGESTION
BRANCH_END   := ### END BRANCH SUGGESTION

# Main ship command - generates docs promptlet and PR materials
ship: cleanup verify check
	@BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	CH_CODE=$$(git diff --name-only $$BASE...HEAD -- $(CODE_HINTS) \
		$(foreach p,$(EXCLUDE_GLOBS),:!$(p)) \
		$(foreach p,$(DOC_PATHS),:!$(p)) || true); \
	CH_DOCS=$$(git diff --name-only $$BASE...HEAD -- $(DOC_PATHS) \
		$(foreach p,$(EXCLUDE_GLOBS),:!$(p)) || true); \
	LOG=$$(git log --pretty=format:'* %s (%h)' $$BASE..HEAD); \
	STATS=$$(git diff --numstat $$BASE..HEAD | awk '{printf "- %s (+%s/-%s)\n", $$3, $$1, $$2}'); \
	echo "$(PROMPT_BEGIN)"; echo; \
	echo "You are a documentation editor for Online Tables Lite."; \
	echo "Update ONLY documentation files to reflect the current code changes."; \
	echo; \
	echo "Rules:"; \
	echo " - Allowed paths: $(DOC_PATHS)"; \
	echo " - Forbidden: any edits outside allowed paths"; \
	echo " - Keep headings/anchors/examples consistent; minimal accurate changes"; \
	echo " - If nothing needs updating, reply exactly: NO-OP"; \
	echo; \
	echo "Context (diff base: $$BASE) — changed CODE files:"; \
	if [[ -n "$$CH_CODE" ]]; then printf '\n```\n%s\n```\n\n' "$$CH_CODE"; else echo "_(none)_\n"; fi; \
	echo "Docs already changed in this branch:"; \
	if [[ -n "$$CH_DOCS" ]]; then printf '\n```\n%s\n```\n\n' "$$CH_DOCS"; else echo "_(none)_\n"; fi; \
	echo "Tasks:"; \
	echo " 1) Identify impacted docs and update them to match current implementation"; \
	echo " 2) Update CLI usage, API changes, configuration changes in README.md"; \
	echo " 3) Update design system docs if UI components changed"; \
	printf '\nFinish by running:\n```bash\nmake docs-commit\n```\n'; \
	echo; echo "$(PROMPT_END)"; echo; \
	SUBJ=$$(git log --format='%s' $$BASE..HEAD | head -1); \
	[[ -n "$$SUBJ" ]] || SUBJ="Update: miscellaneous changes"; \
	TITLE=$$(printf "%s" "$$SUBJ" | sed 's/[[:space:]]\+/ /g'); \
	echo "$(TITLE_BEGIN)"; echo "$$TITLE"; echo "$(TITLE_END)"; echo; \
	echo "$(PRBODY_BEGIN)"; \
	echo "# Summary"; \
	echo "$$TITLE"; echo; \
	echo "## Changes"; \
	if [[ -n "$$LOG" ]]; then echo "$$LOG"; else echo "_(commits not found)_"; fi; \
	echo; echo "## Affected files (added/removed lines)"; \
	if [[ -n "$$STATS" ]]; then echo "$$STATS"; else echo "_(no diff)_"; fi; \
	echo; echo "## Notes for reviewers"; \
	echo "- Verified with \`make check\`."; \
	echo "- Docs updated in this branch (see diff)."; \
	echo "- Part of Online Tables Lite development workflow."; \
	echo; echo "$(PRBODY_END)"; echo; \
	SAFE=$$(printf "%s" "$$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]+/-/g; s/ /-/g; s/--\+/-/g; s/^-//; s/-$$//'); \
	SUG=$$(printf "feature/%s" "$$SAFE" | cut -c1-70); \
	if [[ "$$BRANCH" != "$$SUG" ]]; then \
		echo "$(BRANCH_BEGIN)"; \
		echo "Current branch: $$BRANCH"; \
		echo "Suggested name: $$SUG"; \
		echo "To rename: make branch-rename NAME=$$SUG"; \
		echo "$(BRANCH_END)"; echo; \
	fi; \
	echo "➡️  Next: Execute the DOCS PROMPT above, then run: make docs-commit pr-open"

# Commit doc edits (only if there are any)
docs-commit:
	@git add $(DOC_PATHS) >/dev/null 2>&1 || true; \
	if git diff --cached --quiet -- $(DOC_PATHS) 2>/dev/null; then \
		echo "✅ No doc changes to commit."; \
	else \
		git commit -m "docs: sync documentation with latest changes"; \
		echo "✅ Documentation changes committed."; \
	fi

# Alternative target name for docs promptlet generation
docs-update: ship

# Print PR title suggestion
pr-title-suggest:
	@BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
	TITLE=$$(git log --format='%s' $$BASE..HEAD | head -1 | sed 's/[[:space:]]\+/ /g'); \
	[[ -n "$$TITLE" ]] || TITLE="Update: miscellaneous changes"; \
	echo "$(TITLE_BEGIN)"; echo "$$TITLE"; echo "$(TITLE_END)"

# Print PR body
pr-body:
	@BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
	LOG=$$(git log --pretty=format:'* %s (%h)' $$BASE..HEAD); \
	STATS=$$(git diff --numstat $$BASE..HEAD | awk '{printf "- %s (+%s/-%s)\n", $$3, $$1, $$2}'); \
	TITLE=$$(git log --format='%s' $$BASE..HEAD | head -1 | sed 's/[[:space:]]\+/ /g'); \
	[[ -n "$$TITLE" ]] || TITLE="Update: miscellaneous changes"; \
	echo "$(PRBODY_BEGIN)"; \
	echo "# Summary"; echo "$$TITLE"; echo; \
	echo "## Changes"; if [[ -n "$$LOG" ]]; then echo "$$LOG"; else echo "_(commits not found)_"; fi; \
	echo; echo "## Affected files (added/removed lines)"; \
	if [[ -n "$$STATS" ]]; then echo "$$STATS"; else echo "_(no diff)_"; fi; \
	echo; echo "## Notes for reviewers"; \
	echo "- Verified with \`make check\`."; \
	echo "- Docs updated in this branch (see diff)."; \
	echo "- Part of Online Tables Lite development workflow."; \
	echo; echo "$(PRBODY_END)"

# Open PR (push + create GitHub PR)
pr-open:
	@BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	TITLE=$${TITLE:-$$(git log -1 --pretty='%s' | sed 's/[[:space:]]\+/ /g')}; \
	BODY=$$(make -s pr-body | sed -n '/$(PRBODY_BEGIN)/, /$(PRBODY_END)/p' | sed '1d; $$d'); \
	echo "🚀 Pushing $$BRANCH to $(REMOTE)..."; \
	git push -u $(REMOTE) $$BRANCH >/dev/null 2>&1 || git push -u $(REMOTE) $$BRANCH; \
	if command -v gh >/dev/null 2>&1; then \
		echo "📝 Creating PR → $(PR_BASE)"; \
		if [[ "$${DRAFT:-false}" == "true" ]]; then DFLAG="--draft"; else DFLAG=""; fi; \
		gh pr create --base $(PR_BASE) --head $$BRANCH --title "$$TITLE" --body "$$BODY" $$DFLAG; \
	else \
		echo "ℹ️  GitHub CLI (gh) not found. Open a PR manually with this title:"; \
		echo "$$TITLE"; \
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
	echo "$(BRANCH_END)"

# Rename branch
branch-rename:
	@NEW=$${NAME:-}; [[ -n "$$NEW" ]] || { echo "Usage: make branch-rename NAME=feature/good-name"; exit 2; }; \
	CUR=$$(git rev-parse --abbrev-ref HEAD); \
	git branch -m "$$NEW"; \
	echo "🔁 Renamed branch: $$CUR → $$NEW"

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
	@echo "  make setup-dev       - Full development environment setup"
	@echo "  make start-dev       - Start development servers"
	@echo ""
	@echo "🔧 Quality Control (Manual + Hooks):"
	@echo "  make cleanup         - Clean up before merge/push"
	@echo "  make verify          - Verify clean commit"
	@echo "  make fix             - Auto-fix linting and formatting"
	@echo "  make check           - Run all quality checks"
	@echo ""
	@echo "🚢 Ship Workflow - Manual Testing:"
	@echo "  make ship            - Generate docs promptlet + PR materials"
	@echo "  make pr-title-suggest - Show suggested PR title"
	@echo "  make pr-body         - Show generated PR body"
	@echo "  make branch-suggest  - Suggest better branch name"
	@echo "  make branch-rename   - Rename branch (NAME=new-name)"
	@echo ""
	@echo "🤖 Ship Workflow - Agent Commands:"
	@echo "  make docs-commit     - Commit documentation updates"
	@echo "  make pr-open         - Push branch + create GitHub PR"
	@echo "  make docs-update     - Alias for 'make ship'"
	@echo ""
	@echo "🔄 Git Hooks (Automatic):"
	@echo "  pre-commit          - Auto-runs: cleanup → fix → verify"
	@echo "  pre-push            - Auto-runs: check → ship → docs-commit → PR"
	@echo ""
	@echo "ℹ️  Help:"
	@echo "  make help            - Show this help message"
