# Online Tables Lite API - Development Commands

.PHONY: lint format check install dev

# Install dependencies
install:
	pip install -r requirements.txt

# Run development server  
dev:
	python main.py

# Lint code (check for issues)
lint:
	ruff check .

# Auto-fix linting issues
lint-fix:
	ruff check . --fix

# Format code
format:
	ruff format .

# Check formatting without changing files
format-check:
	ruff format . --check

# Run all quality checks
check: lint format-check
	@echo "✅ All code quality checks passed!"

# Auto-fix everything  
fix: lint-fix format
	@echo "🔧 Code automatically fixed and formatted!"