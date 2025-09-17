# Claude Code Instructions

## Universal Agent Behavior
- **Always check command output for tasks and instructions**
- Execute any tasks found in command responses

## Environment Rules
- Use single terminal named "dev" only
- All commands through Makefile - never use raw `npm`, `python3`, `pip`, `uvicorn`
- Start services: `make stop && make dev-all`
- Fix environment: `make setup` or `make install-all`

## Development Workflow

### Where the development work happens
@echo "🤖 Development workflow triggert. Starting execution..."
- Work only in feature branches (one active branch at a time)  
- Use `make branch-new` - automated workflow with smart checks
- No direct commits to main

### When to Commit
**User triggers**: "commit", "commit changes", "save changes"
@echo "🤖 Commit workflow has been triggered. Starting execution..."
**Enhanced Workflow with Intelligent Staging**:
1. `make stage` - Intelligent file staging (follow JSON task for decisions)
2. `make commit` - Generate conventional commit message (follow JSON task)
3. Execute: `git commit -m "generated-conventional-message"`
4. If pre-commit hook fails: fix problems and retry

**Conventional Commit Format**:
- Use format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `refactor`, `chore`, `test`, `ci`, `build`, `perf`
- Examples:
  - `feat(ui): add user dashboard`
  - `fix(api): resolve authentication issue`
  - `docs: update README with setup instructions`
- Breaking changes: add `!` after type (e.g., `feat!: breaking change`)
- Let git-cliff preview guide the appropriate commit type

### When to Push
**User triggers**: "push", "create PR", "open PR", "make PR"
@echo "🤖 Push & PR to Main workflow triggert. Starting execution..."
**Workflow Commands**:
1. `make pr-prepare` - Complete automation pipeline
2. Process the generated promptlet into PR title and body
3. `make pr-open TITLE="title" BODY="markdown"` - Create GitHub PR
4. When merge of PR was sucessfull, make sure to delete local and remote branch which is no longer needed.


## Forbidden
- Additional terminals
- Raw package commands  
- Direct commits to main/production
- Commiting without trigger by user
