# Online Tables Lite - Development Commands

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
	./scripts/git/promptlet-reader.sh conventional_commit_generation \
		staged_files="$$STAGED" \
		suggested_version="$$PREVIEW" \
		diff_summary="$$DIFF_SUMMARY" \
		git_cliff_config="$$CLIFF_CONFIG_STATUS" \
		allowed_types="$$COMMIT_TYPES" \
		sample_analysis="$$SAMPLE_ANALYSIS"


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
	./scripts/git/promptlet-reader.sh documentation_update \
		diff_base="$$BASE" \
		branch="$$BRANCH" \
		changed_code_files="$$CH_CODE" \
		changed_docs_files="$$CH_DOCS" \
		changelog_entry="$$(echo "$$CHANGELOG_ENTRY" | tr '\n' ' ' | sed 's/"/\\"/g')"; \
	echo; \
	SUBJ=$$(git log --format='%s' $$BASE..HEAD | head -1); \
	[[ -n "$$SUBJ" ]] || SUBJ="Update: miscellaneous changes"; \
	TITLE=$$(printf "%s" "$$SUBJ" | sed 's/[[:space:]]\+/ /g'); \
	echo "$(TITLE_BEGIN)"; echo "$$TITLE"; echo "$(TITLE_END)"; echo; \
	echo "$(PRBODY_BEGIN)"; \
	PR_PROMPTLET=$$(./scripts/git/aggregate-pr-metadata.sh "$$BRANCH" promptlet 2>/dev/null || echo ""); \
	if [ -n "$$PR_PROMPTLET" ]; then \
		echo "$$PR_PROMPTLET"; \
		echo; \
		echo "---"; \
		echo; \
		echo "**Fallback Description** (if agent unavailable):"; \
		PR_FALLBACK=$$(./scripts/git/aggregate-pr-metadata.sh "$$BRANCH" description 2>/dev/null || echo "Basic PR from $$BRANCH"); \
		echo "$$PR_FALLBACK"; \
	else \
		echo "# Summary"; echo "$$TITLE"; echo; \
		echo "## Changes"; \
		if [[ -n "$$LOG" ]]; then echo "$$LOG"; else echo "_(commits not found)_"; fi; \
		echo; echo "## Affected files (added/removed lines)"; \
		if [[ -n "$$STATS" ]]; then echo "$$STATS"; else echo "_(no diff)_"; fi; \
		echo; echo "## Notes for reviewers"; \
		echo "- Verified with \`make check\`."; \
		echo "- Docs updated in this branch (see diff)."; \
		echo "- Part of Online Tables Lite development workflow."; \
	fi; \
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

# Generate PR body using agent promptlet with cached metadata
pr-body:
	@BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	CACHE_FILE=".git/commit-cache/last-commit-meta"; \
	if [ -f "$$CACHE_FILE" ] && [ -n "$$(grep COMMIT_CACHE_FILE $$CACHE_FILE 2>/dev/null)" ]; then \
		PR_PROMPTLET=$$(./scripts/git/aggregate-pr-metadata.sh "$$BRANCH" promptlet 2>/dev/null || echo ""); \
		if [ -n "$$PR_PROMPTLET" ]; then \
			echo "$$PR_PROMPTLET"; \
		else \
			echo "⚠️  Enhanced metadata unavailable, using fallback..."; \
			BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
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
			echo "$(PRBODY_END)"; \
		fi; \
	else \
		echo "ℹ️  No enhanced metadata cache, using traditional approach..."; \
		BASE=$$(git merge-base $(BASE_REF) HEAD || git rev-list --max-parents=0 HEAD | tail -n1); \
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
		echo "$(PRBODY_END)"; \
	fi

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
	./scripts/git/promptlet-reader.sh branch_evaluation \
		current_branch="$$BRANCH" \
		suggested_name="$$SUG" \
		changes_context="Recent commits and file changes"; \
	echo "$(BRANCH_END)"

# Validate promptlet system (multi-stage compliance)
validate-promptlets:
	@echo "🤖 Validating promptlet system compliance..."
	@./scripts/git/validate-promptlet-system.sh --force

# Rename branch (PR-safe)
branch-rename:
	@NEW=$${NAME:-}; \
	if [ -z "$$NEW" ]; then \
		echo "Usage: make branch-rename NAME=feat/good-name"; \
		echo "💡 Get naming suggestion: ./scripts/git/validate-branch-name.sh \$$(git rev-parse --abbrev-ref HEAD) suggest"; \
		exit 2; \
	fi; \
	CUR=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CUR" = "main" ] || [ "$$CUR" = "production" ]; then \
		echo "❌ Cannot rename protected branch: $$CUR"; \
		exit 1; \
	fi; \
	echo "🔍 Validating new branch name: $$NEW"; \
	if ! ./scripts/git/validate-branch-name.sh "$$NEW" validate >/dev/null 2>&1; then \
		echo "❌ New branch name '$$NEW' violates naming policy"; \
		./scripts/git/validate-branch-name.sh "$$NEW" promptlet; \
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

# Create new feature branch with automated checks
branch-new:
	@echo "🌿 Initializing new branch workflow..."
	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT_BRANCH" != "main" ]; then \
		echo "⚠️  Currently on: $$CURRENT_BRANCH"; \
		if ! git diff --quiet || ! git diff --cached --quiet; then \
			echo "⚠️  You have uncommitted changes"; \
			ACTION_INSTRUCTION=$$(if ! git diff --cached --quiet; then echo "Changes are staged - ready for commit. Execute: make commit, then retry make branch-new"; else echo "Changes are unstaged - stash before proceeding. Execute: git stash && make branch-new && git stash pop"; fi); \
			./scripts/git/promptlet-reader.sh uncommitted_changes_handling \
				current_branch="$$CURRENT_BRANCH" \
				has_staged_changes="$$(if ! git diff --cached --quiet; then echo "true"; else echo "false"; fi)" \
				has_unstaged_changes="$$(if ! git diff --quiet; then echo "true"; else echo "false"; fi)" \
				decision="$$(if ! git diff --cached --quiet; then echo "commit_first"; else echo "stash_first"; fi)" \
				action_instruction="$$ACTION_INSTRUCTION"; \
			exit 1; \
		fi; \
		echo "🔄 Switching to main..."; \
		git checkout main; \
	fi; \
	echo "📡 Checking main branch status..."; \
	git fetch origin main >/dev/null 2>&1; \
	LOCAL_MAIN=$$(git rev-parse main); \
	REMOTE_MAIN=$$(git rev-parse origin/main); \
	if [ "$$LOCAL_MAIN" != "$$REMOTE_MAIN" ]; then \
		echo "🔄 Updating main branch..."; \
		git pull origin main; \
		echo "✅ Main branch updated"; \
	else \
		echo "✅ Main branch is up to date"; \
	fi; \
	echo "🔍 Checking for open PRs..."; \
	if command -v gh >/dev/null 2>&1; then \
		OPEN_PRS=$$(gh pr list --state open --json number,title,headRefName 2>/dev/null || echo "[]"); \
		PR_COUNT=$$(echo "$$OPEN_PRS" | jq length 2>/dev/null || echo "0"); \
		if [ "$$PR_COUNT" -gt 0 ]; then \
			echo "⚠️  Found $$PR_COUNT open PR(s):"; \
			echo "$$OPEN_PRS" | jq -r '.[] | "  #\(.number): \(.title) (\(.headRefName))"' 2>/dev/null || echo "  Could not parse PR details"; \
			echo; \
			./scripts/git/promptlet-reader.sh branch_creation_with_open_prs \
				open_prs="$$OPEN_PRS" \
				pr_count="$$PR_COUNT"; \
		else \
			echo "✅ No open PRs found"; \
		fi; \
	else \
		echo "ℹ️  GitHub CLI not found - skipping PR check"; \
		echo "   Install with: brew install gh"; \
	fi; \
	if [ "$$PR_COUNT" -eq 0 ] || [ -z "$$PR_COUNT" ]; then \
		BRANCH_NAME=$${NAME:-}; \
		if [ -z "$$BRANCH_NAME" ]; then \
			echo; \
			./scripts/git/promptlet-reader.sh branch_name_generation \
				open_prs="$$PR_COUNT"; \
		else \
			echo "🔍 Validating branch name: $$BRANCH_NAME"; \
			if ./scripts/git/validate-branch-name.sh "$$BRANCH_NAME" validate >/dev/null 2>&1; then \
				echo "✅ Branch name is compliant"; \
				echo "🌿 Creating branch: $$BRANCH_NAME"; \
				git checkout -b "$$BRANCH_NAME"; \
				echo "✅ Branch created and switched to: $$BRANCH_NAME"; \
				echo; \
				echo "🚀 Ready to start development!"; \
				echo "📝 Next steps:"; \
				echo "  - Start coding your feature"; \
				echo "  - When ready to commit: User says 'commit' → you run 'make commit'"; \
				echo "  - When ready to push: User says 'push' → you run 'make ship'"; \
			else \
				echo "❌ Branch name '$$BRANCH_NAME' violates naming policy"; \
				echo "💡 Getting compliance guidance..."; \
				echo; \
				./scripts/git/validate-branch-name.sh "$$BRANCH_NAME" promptlet; \
				exit 1; \
			fi; \
		fi; \
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
	@echo "📝 Conventional Commits (Agent Workflow):"
	@echo "  make commit          - Generate conventional commit message (agent task)"
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
	@echo "  make pr-body         - Show generated PR body"
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
