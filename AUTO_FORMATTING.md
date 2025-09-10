# 🎨 Auto-Formatting & Code Quality Pipeline

This project has a comprehensive auto-formatting and code quality pipeline that automatically fixes and formats code on save and commit.

## 🚀 Quick Setup

Run the setup script to configure your development environment:

```bash
./setup-dev.sh
```

## ⚙️ What's Configured

### On File Save (VS Code)
- **Prettier formatting** - Automatically formats code
- **ESLint auto-fix** - Fixes fixable linting issues
- **Import organization** - Sorts and organizes imports
- **Trailing whitespace removal** - Cleans up whitespace
- **Final newline insertion** - Ensures files end with newline

### On Commit (Pre-commit Hooks)
- **ESLint auto-fix** - Fixes all fixable issues
- **Prettier formatting** - Formats all staged files
- **Automatic staging** - Adds fixed files to commit

## 🎯 How It Works

### 1. File Save Pipeline
When you save a file in VS Code:
1. Prettier formats the code
2. ESLint fixes auto-fixable issues
3. Imports are organized
4. Trailing whitespace is removed

### 2. Commit Pipeline
When you commit changes:
1. Husky triggers pre-commit hooks
2. lint-staged runs on staged files
3. ESLint fixes issues in TypeScript/JavaScript files
4. Prettier formats all supported files
5. Fixed files are automatically staged

## 🔧 Manual Commands

```bash
# Fix ESLint issues
npm run lint:fix

# Format with Prettier
npm run format

# Run both lint:fix and format
npm run fix

# Check formatting without fixing
npm run format:check

# Run all checks (typecheck + lint + format)
npm run check
```

## 📁 File Types Supported

### Auto-Formatting (Prettier)
- TypeScript (`.ts`, `.tsx`)
- JavaScript (`.js`, `.jsx`)
- JSON (`.json`)
- CSS (`.css`)
- Markdown (`.md`)
- YAML (`.yml`, `.yaml`)

### Auto-Fixing (ESLint)
- TypeScript (`.ts`, `.tsx`)
- JavaScript (`.js`, `.jsx`)

## 🎨 VS Code Settings

The `.vscode/settings.json` file configures:
- Default formatter: Prettier
- Auto-format on save
- ESLint auto-fix on save
- Import organization on save
- Rulers at 80 and 120 characters
- Word wrap at 120 characters
- Trailing whitespace removal
- Final newline insertion

## 🔍 ESLint Configuration

The project uses ESLint with:
- Next.js recommended rules
- TypeScript support
- Custom rules for code quality
- Auto-fixable rules enabled

## 📦 Dependencies

- **Prettier** - Code formatting
- **ESLint** - Code linting and fixing
- **Husky** - Git hooks
- **lint-staged** - Pre-commit file processing

## 🚨 Troubleshooting

### VS Code Not Auto-Formatting
1. Ensure Prettier extension is installed
2. Ensure ESLint extension is installed
3. Check that `.vscode/settings.json` exists
4. Reload VS Code window

### Pre-commit Hooks Not Working
1. Run `npx husky install` in the project root
2. Ensure `.husky/pre-commit` file exists
3. Check file permissions: `chmod +x .husky/pre-commit`

### Manual Fix All Issues
```bash
cd apps/web
npm run fix
```

## 🎯 Benefits

- **Consistent code style** across the project
- **Automatic issue fixing** reduces manual work
- **Pre-commit validation** prevents bad code from being committed
- **Developer productivity** - focus on logic, not formatting
- **Team consistency** - everyone uses the same formatting rules

## 📝 Notes

- The pipeline reduces ESLint warnings automatically
- Some warnings (like console statements) require manual review
- Unused variables starting with `_` are ignored
- The build process includes linting and type checking
