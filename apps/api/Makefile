# Online Tables Lite API - Development Commands

.PHONY: lint format check install dev

# Install dependencies
install:
	source venv/bin/activate && pip install -r requirements.txt

# Run development server  
dev:
	source venv/bin/activate && python3 main.py

# Lint code (check for issues)
lint:
	source venv/bin/activate && ruff check .

# Auto-fix linting issues
lint-fix:
	source venv/bin/activate && ruff check . --fix

# Format code
format:
	source venv/bin/activate && ruff format .

# Check formatting without changing files
format-check:
	source venv/bin/activate && ruff format . --check

# Run all quality checks
check: lint format-check
	@echo "✅ All code quality checks passed!"

# Auto-fix everything  
fix: lint-fix format
	@echo "🔧 Code automatically fixed and formatted!"
