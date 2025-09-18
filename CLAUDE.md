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
- Work only in feature branches (one active branch at a time)
- No direct commits to main
1. Print "🤖 Development workflow triggert. Starting execution..."
2. Use `make branch-new` - automated workflow with smart checks

### When to Commit
**User triggers**: "commit", "commit changes", "save changes"
1. Print "🤖 Commit workflow has been triggered. Starting execution..."
2. `make stage` - Intelligent file staging (follow JSON task for decisions)
3. `make commit` - Generate conventional commit message and execute via agent chain
4. If pre-commit hook fails: fix problems and retry

### When to Push
**User triggers**: "push", "create PR", "open PR", "make PR"
1. Print "🤖 Push & PR to Main workflow triggered. Starting execution..."
2. `make pr-workflow` - Automated pipeline with agent chain

## Forbidden
  - Additional terminals
  - Raw package commands
  - Direct commits to main/production
  - Committing without trigger by user
