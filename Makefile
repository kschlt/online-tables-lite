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

# ---------- Staging workflow (intelligent file staging with agent decision) ----------

# Intelligent staging with agent decision-making for file selection
stage:
	@echo "🔍 Analyzing changes for staging..."
	@STAGED=$$(git diff --staged --name-only | wc -l | tr -d ' '); \
	UNSTAGED=$$(git diff --name-only | wc -l | tr -d ' '); \
	UNTRACKED=$$(git ls-files --others --exclude-standard | wc -l | tr -d ' '); \
	TOTAL_CHANGES=$$((STAGED + UNSTAGED + UNTRACKED)); \
	if [ "$$TOTAL_CHANGES" -eq 0 ]; then \
		echo "ℹ️  No changes found. Working tree is clean."; \
		exit 0; \
	fi; \
	echo "📊 Change Summary:"; \
	echo "  📝 Staged: $$STAGED files"; \
	echo "  ✏️  Modified: $$UNSTAGED files"; \
	echo "  🆕 Untracked: $$UNTRACKED files"; \
	echo; \
	if [ "$$UNSTAGED" -gt 0 ] || [ "$$UNTRACKED" -gt 0 ]; then \
		echo "📋 Modified files:"; \
		git diff --name-only | head -10 | sed 's/^/  - /' || true; \
		if [ "$$UNTRACKED" -gt 0 ]; then \
			echo "📋 Untracked files:"; \
			git ls-files --others --exclude-standard | head -10 | sed 's/^/  - /' || true; \
		fi; \
		echo; \
		RELEVANT_PATTERNS="\.md$$|\.json$$|\.js$$|\.ts$$|\.tsx$$|\.py$$|\.sh$$|Makefile$$|\.toml$$|\.yaml$$|\.yml$$|\.env"; \
		RELEVANT_FILES=$$(git diff --name-only && git ls-files --others --exclude-standard | grep -E "$$RELEVANT_PATTERNS" || true); \
		IGNORE_PATTERNS="node_modules|\.next|dist|build|venv|\.git|\.agent|package-lock\.json|\.log$$|\.tmp$$"; \
		FILTERED_FILES=$$(echo "$$RELEVANT_FILES" | grep -vE "$$IGNORE_PATTERNS" || true); \
		if [ -n "$$FILTERED_FILES" ]; then \
			echo "🎯 Relevant files detected for staging:"; \
			echo "$$FILTERED_FILES" | sed 's/^/  + /' | head -15; \
			if [ "$${AUTO_STAGE:-false}" = "true" ]; then \
				echo "⚡ AUTO_STAGE=true: Staging relevant files automatically..."; \
				echo "$$FILTERED_FILES" | xargs git add; \
				echo "✅ Relevant files staged automatically"; \
			else \
				$(AGENT_PROMPTLETS)/promptlet-reader.sh file_staging_decision \
					total_changes="$$TOTAL_CHANGES" \
					staged_count="$$STAGED" \
					modified_count="$$UNSTAGED" \
					untracked_count="$$UNTRACKED" \
					relevant_files="$$(echo "$$FILTERED_FILES" | tr '\n' '|' | sed 's/|$$//')" \
					auto_stage_command="make stage AUTO_STAGE=true" \
					manual_stage_help="git add <specific-files>"; \
			fi; \
		else \
			echo "⚠️  No obviously relevant files detected for automatic staging"; \
			echo "💡 Use: git add <specific-files> for manual staging"; \
			$(AGENT_PROMPTLETS)/promptlet-reader.sh manual_staging_required \
				total_changes="$$TOTAL_CHANGES" \
				modified_files="$$(git diff --name-only | tr '\n' '|' | sed 's/|$$//')" \
				untracked_files="$$(git ls-files --others --exclude-standard | tr '\n' '|' | sed 's/|$$//')" \
				staging_help="Use git add to stage specific files, then run make commit"; \
		fi; \
	else \
		echo "✅ All changes are already staged ($$STAGED files)"; \
		echo "💡 Ready for commit: make commit"; \
	fi

# ---------- Commit workflow (conventional commits with git-cliff) ----------

# Generate conventional commit message using git-cliff configuration and agent assistance
# Shows branch context to prevent accidental commits on wrong branch
commit:
	@echo "🌿 Current branch: $$(git rev-parse --abbrev-ref HEAD)"
	@echo "🔍 Checking for staged changes..."
	@STAGED=$$(git diff --staged --name-only | wc -l | tr -d ' '); \
	UNSTAGED=$$(git diff --name-only | wc -l | tr -d ' '); \
	UNTRACKED=$$(git ls-files --others --exclude-standard | wc -l | tr -d ' '); \
	if [ "$$STAGED" -eq 0 ]; then \
		if [ "$$((UNSTAGED + UNTRACKED))" -eq 0 ]; then \
			echo "ℹ️  No changes found. Working tree is clean - skipping commit."; \
			exit 0; \
		else \
			echo "❌ No files staged for commit."; \
			echo "💡 Use 'make stage' to intelligently stage files, or:"; \
			echo "   git add <specific-files>  # Stage specific files"; \
			echo "   make stage AUTO_STAGE=true  # Auto-stage relevant files"; \
			exit 1; \
		fi; \
	else \
		echo "📝 Found $$STAGED staged file(s). Generating commit message..."; \
	fi; \
	BASE=$$(git merge-base $(BASE_REF) HEAD 2>/dev/null || git rev-list --max-parents=0 HEAD | tail -n1); \
	PREVIEW=$$(git-cliff --unreleased --bump 2>/dev/null | head -5 | tail -1 | sed 's/^## \[//' | sed 's/\].*//' || echo "preview unavailable"); \
	DIFF_SUMMARY=$$(git diff --staged --stat | head -10); \
	COMMIT_TYPES=$$(grep -E '^\s*\{\s*message\s*=\s*"\^[a-z]+' cliff.toml 2>/dev/null | sed -E 's/.*"\^([a-z]+).*/\1/' | tr '\n' '|' | sed 's/|$$//' || echo "feat|fix|docs|refactor|chore|test|ci|build|perf"); \
	CLIFF_CONFIG_STATUS=$$(if [ -f "cliff.toml" ]; then echo "✅ Using cliff.toml configuration"; else echo "⚠️ cliff.toml not found, using defaults"; fi); \
	SAMPLE_ANALYSIS=$$(git-cliff --unreleased --context 2>/dev/null | jq -r '.commits[0].message // "No recent commits"' 2>/dev/null || echo "No context available"); \
	$(AGENT_PROMPTLETS)/promptlet-reader.sh conventional_commit_generation \
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

# Validate changes before PR creation
pr-validate:
	@$(AGENT_WORKFLOWS)/pr-workflow.sh validate_changes

# Generate PR description promptlet (for agent processing)
pr-body:
	@$(AGENT_WORKFLOWS)/pr-workflow.sh pr_body


# Complete automation pipeline and prepare PR (agent decision point)
pr-prepare:
	@echo "🚀 Starting complete automation pipeline..."; \
	echo "📋 Step 1/5: Documentation generation"; \
	$(MAKE) ship; \
	echo "📋 Step 2/5: Documentation commit"; \
	$(MAKE) docs-commit; \
	echo "📋 Step 3/5: Branch validation and push"; \
	BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	echo "🌿 Current branch: $$BRANCH"; \
	if [ "$$BRANCH" = "main" ] || [ "$$BRANCH" = "production" ]; then \
		echo "❌ Cannot push from protected branch: $$BRANCH"; \
		echo "💡 Create a feature branch first: make branch-new NAME=feat/your-feature"; \
		exit 1; \
	fi; \
	if ! $(AGENT_UTILS)/validate-branch-name.sh "$$BRANCH" validate >/dev/null 2>&1; then \
		echo "⚠️  Branch name '$$BRANCH' violates naming policy"; \
		echo "💡 Get compliant name: $(AGENT_UTILS)/validate-branch-name.sh $$BRANCH suggest"; \
		echo "💡 Rename branch: make branch-rename NAME=\$$($(AGENT_UTILS)/validate-branch-name.sh $$BRANCH suggest)"; \
		echo "⚠️  Proceeding anyway, but consider fixing branch name..."; \
	fi; \
	echo "✅ Branch validation completed: $$BRANCH"; \
	echo "📤 Pushing $$BRANCH to $(REMOTE)..."; \
	git push -u $(REMOTE) $$BRANCH; \
	echo "📋 Step 4/5: PR description generation"; \
	$(MAKE) pr-body; \
	echo "📋 Step 5/5: All automation complete"; \
	echo "✅ Automation pipeline completed successfully"; \
	echo "🤖 Next: Agent processes the PR description promptlet and calls:"; \
	echo "    make pr-open TITLE=\"processed-title\" BODY=\"processed-markdown\""

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
		if gh pr view $$BRANCH >/dev/null 2>&1; then \
			echo "📝 Updating existing PR..."; \
			gh pr edit $$BRANCH --title "$$TITLE" --body "$$BODY"; \
			echo "✅ PR updated: $$(gh pr view $$BRANCH --json url -q .url)"; \
		else \
			echo "📝 Creating new PR..."; \
			gh pr create --base $(PR_BASE) --head $$BRANCH --title "$$TITLE" --body "$$BODY" $$DFLAG; \
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

# Create new feature branch with automated checks
branch-new:
	@echo "🌿 Initializing new branch workflow..."
	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$CURRENT_BRANCH" != "main" ]; then \
		echo "⚠️  Currently on: $$CURRENT_BRANCH"; \
		if ! git diff --quiet || ! git diff --cached --quiet; then \
			echo "⚠️  You have uncommitted changes"; \
			ACTION_INSTRUCTION=$$(if ! git diff --cached --quiet; then echo "Changes are staged - ready for commit. Execute: make commit, then retry make branch-new"; else echo "Changes are unstaged - stash before proceeding. Execute: git stash && make branch-new && git stash pop"; fi); \
			$(AGENT_PROMPTLETS)/promptlet-reader.sh uncommitted_changes_handling \
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
			$(AGENT_PROMPTLETS)/promptlet-reader.sh branch_creation_with_open_prs \
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
			$(AGENT_PROMPTLETS)/promptlet-reader.sh branch_name_generation \
				open_prs="$$PR_COUNT"; \
		else \
			echo "🔍 Validating branch name: $$BRANCH_NAME"; \
			if $(AGENT_UTILS)/validate-branch-name.sh "$$BRANCH_NAME" validate >/dev/null 2>&1; then \
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
				$(AGENT_UTILS)/validate-branch-name.sh "$$BRANCH_NAME" promptlet; \
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
