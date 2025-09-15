# Online Tables Lite - Development Commands

.PHONY: dev-frontend dev-backend dev install-frontend install-backend install-all setup setup-git-tools cleanup verify commit ship docs-commit pr-title-suggest pr-body pr-open branch-suggest branch-rename

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

# ---------- Commit workflow (conventional commits with git-cliff) ----------

# Generate conventional commit message using git-cliff configuration and agent assistance
commit:
	@echo "🔍 Checking for changes..."
	@STAGED=$$(git diff --staged --name-only | wc -l | tr -d ' '); \
	UNSTAGED=$$(git diff --name-only | wc -l | tr -d ' '); \
	UNTRACKED=$$(git ls-files --others --exclude-standard | wc -l | tr -d ' '); \
	TOTAL_CHANGES=$$((STAGED + UNSTAGED + UNTRACKED)); \
	if [ "$$TOTAL_CHANGES" -eq 0 ]; then \
		echo "ℹ️  No changes found. Working tree is clean - skipping commit."; \
		exit 0; \
	fi; \
	if [ "$$STAGED" -eq 0 ]; then \
		echo "📁 Staging $$((UNSTAGED + UNTRACKED)) file(s)..."; \
		git add -A; \
		echo "✅ Files staged. Generating commit message..."; \
	else \
		echo "📝 Found $$STAGED staged file(s). Generating commit message..."; \
	fi; \
	BASE=$$(git merge-base $(BASE_REF) HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1); \
	PREVIEW=$$(git-cliff --unreleased --bump 2>/dev/null | head -5 | tail -1 | sed 's/^## \[//' | sed 's/\].*//' || echo "preview unavailable"); \
	DIFF_SUMMARY=$$(git diff --staged --stat | head -10); \
	COMMIT_TYPES=$$(grep -E '^\s*\{\s*message\s*=\s*"\^[a-z]+' cliff.toml 2>/dev/null | sed -E 's/.*"\^([a-z]+).*/\1/' | tr '\n' '|' | sed 's/|$$//' || echo "feat|fix|docs|refactor|chore|test|ci|build|perf"); \
	CLIFF_CONFIG_STATUS=$$(if [ -f "cliff.toml" ]; then echo "✅ Using cliff.toml configuration"; else echo "⚠️ cliff.toml not found, using defaults"; fi); \
	SAMPLE_ANALYSIS=$$(git-cliff --unreleased --context 2>/dev/null | jq -r '.commits[0].message // "No recent commits"' 2>/dev/null || echo "No context available"); \
	echo "{"; \
	echo '  "task": {'; \
	echo '    "type": "conventional_commit_generation",'; \
	echo '    "instructions": ['; \
	echo '      "Analyze staged changes with: git diff --staged",'; \
	echo '      "Use git-cliff preview and configuration to determine appropriate commit type",'; \
	echo '      "Generate conventional commit message: type(scope): description (<72 chars)",'; \
	echo '      "Ensure format matches cliff.toml commit_parsers configuration",'; \
	echo '      "Validate with: echo \"message\" | git-cliff --unreleased --context",'; \
	echo '      "Execute: git commit -m \"generated-message\""'; \
	echo '    ],'; \
	echo '    "context": {'; \
	echo '      "staged_files": '$$STAGED','; \
	echo '      "suggested_version": "'"$$PREVIEW"'",'; \
	echo '      "diff_summary": "'"$$DIFF_SUMMARY"'",'; \
	echo '      "git_cliff_config": "'"$$CLIFF_CONFIG_STATUS"'",'; \
	echo '      "allowed_types": "'"$$COMMIT_TYPES"'",'; \
	echo '      "format_from_cliff": "type(scope): description - extracted from cliff.toml commit_parsers",'; \
	echo '      "sample_analysis": "'"$$SAMPLE_ANALYSIS"'",'; \
	echo '      "examples": ['; \
	echo '        "feat(ui): add user dashboard",'; \
	echo '        "fix(api): resolve authentication issue",'; \
	echo '        "docs: update README with setup instructions",'; \
	echo '        "perf(core): optimize database queries",'; \
	echo '        "refactor(auth): simplify token validation"'; \
	echo '      ],'; \
	echo '      "breaking_changes": "add ! after type for breaking changes (feat!: breaking change)",'; \
	echo '      "validation": "Use git-cliff --context to validate message format"'; \
	echo '    }'; \
	echo '  }'; \
	echo "}"


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

# Main ship command - generates docs promptlet and PR materials
ship:
	@echo "🚀 Preparing ship workflow - quality guaranteed by pre-commit hook"
	@CACHE_FILE=".git/commit-cache/last-commit-meta"; \
	if [ -f "$$CACHE_FILE" ]; then \
		echo "⚡ Using cached commit metadata from pre-commit hook"; \
		. "$$CACHE_FILE"; \
		CH_CODE=$$(echo "$$CH_CODE" | tr ' ' '\n' | grep -v '^$$'); \
		CH_DOCS=$$(echo "$$CH_DOCS" | tr ' ' '\n' | grep -v '^$$'); \
		LOG=$$(echo "$$LOG" | tr '|' '\n'); \
		STATS=$$(echo "$$STATS" | tr '|' '\n'); \
		CHANGELOG_ENTRY=$$(echo "$$CHANGELOG_ENTRY" | tr '|' '\n'); \
	else \
		echo "🔍 No commit cache found - calculating git diff..."; \
		BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
		BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
		CH_CODE=$$(git diff --name-only $$BASE...HEAD -- $(CODE_HINTS) \
			$(foreach p,$(EXCLUDE_GLOBS),:!$(p)) \
			$(foreach p,$(DOC_PATHS),:!$(p)) || true); \
		CH_DOCS=$$(git diff --name-only $$BASE...HEAD -- $(DOC_PATHS) \
			$(foreach p,$(EXCLUDE_GLOBS),:!$(p)) || true); \
		LOG=$$(git log --pretty=format:'* %s (%h)' $$BASE..HEAD); \
		STATS=$$(git diff --numstat $$BASE..HEAD | awk '{printf "- %s (+%s/-%s)\n", $$3, $$1, $$2}'); \
		CHANGELOG_ENTRY=$$(git-cliff --unreleased --strip header 2>/dev/null || echo "No unreleased changes detected"); \
	fi; \
	echo "{"; \
	echo '  "task": {'; \
	echo '    "type": "documentation_update",'; \
	echo '    "instructions": ['; \
	echo '      "Identify impacted docs and update them to match current implementation",'; \
	echo '      "Update CLI usage, API changes, configuration changes in README.md",'; \
	echo '      "Update design system docs if UI components changed",'; \
	echo '      "If nothing needs updating, reply exactly: NO-OP"'; \
	echo '    ],'; \
	printf '    "context": {\n      "diff_base": "%s",\n      "branch": "%s",\n' "$$BASE" "$$BRANCH"; \
	printf '      "changed_code_files": "%s",\n      "changed_docs_files": "%s",\n' "$$CH_CODE" "$$CH_DOCS"; \
	printf '      "changelog_entry": "%s",\n' "$$(echo "$$CHANGELOG_ENTRY" | tr '\n' ' ' | sed 's/"/\\"/g')"; \
	echo '      "changelog_update_needed": "Review and update CHANGELOG.md if code changes require it",'; \
	echo '      "allowed_paths": "$(DOC_PATHS)",'; \
	echo '      "forbidden": "any edits outside allowed paths"'; \
	echo '    },'; \
	echo '    "next_steps": ["make docs-commit"]'; \
	echo '  }'; \
	echo "}"; echo; \
	SUBJ=$$(git log --format='%s' $$BASE..HEAD | head -1); \
	[[ -n "$$SUBJ" ]] || SUBJ="Update: miscellaneous changes"; \
	TITLE=$$(printf "%s" "$$SUBJ" | sed 's/[[:space:]]\+/ /g'); \
	echo "$(TITLE_BEGIN)"; echo "$$TITLE"; echo "$(TITLE_END)"; echo; \
	echo "$(PRBODY_BEGIN)"; \
	echo "# Summary"; echo "$$TITLE"; echo; \
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
	echo "🤖 Agent: Execute JSON task above, then run: make docs-commit pr-open"

# Commit doc edits (only if there are any)
docs-commit:
	@git add $(DOC_PATHS) >/dev/null 2>&1 || true; \
	if git diff --cached --quiet -- $(DOC_PATHS) 2>/dev/null; then \
		echo "✅ No doc changes to commit."; \
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
	echo; \
	echo "🤖 Rename when:"; \
	echo "  ✅ Current name is generic (feature/update, feature/fix)"; \
	echo "  ✅ Suggested name is significantly more descriptive"; \
	echo "  ✅ Suggested name better reflects actual changes"; \
	echo; \
	echo "🤖 Keep current when:"; \
	echo "  ❌ Current name is already clear and specific"; \
	echo "  ❌ Only minor wording differences"; \
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
	@echo "  make setup-git-tools - Install git-cliff and changelog tools"
	@echo ""
	@echo "📝 Conventional Commits (Agent Workflow):"
	@echo "  make commit          - Generate conventional commit message (agent task)"
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
	@echo ""
	@echo "🔄 Git Hooks (Automatic):"
	@echo "  pre-commit          - Auto-runs: cleanup → fix → verify"
	@echo "  pre-push            - Lightweight verification (agent handles analysis)"
	@echo ""
	@echo "ℹ️  Help:"
	@echo "  make help            - Show this help message"
