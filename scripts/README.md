# 📜 Scripts Directory

This directory contains all executable scripts organized by purpose. This follows modern project organization best practices for maintainability and clarity.

## 📁 Directory Structure

```
scripts/
├── README.md              # This file
├── dev/                   # Development environment scripts
│   ├── setup-dev.sh       # Development environment setup
│   └── start-dev.sh       # Development server startup
├── git/                   # Git workflow scripts
│   ├── cleanup-before-merge.sh    # Pre-merge cleanup
│   └── verify-clean-commit.sh     # Commit verification
├── deploy/                # Deployment scripts
│   └── (future deployment scripts)
└── utils/                 # Utility scripts
    └── (general utility scripts)
```

## 🚀 Usage

### Development Scripts
```bash
# Setup development environment
./scripts/dev/setup-dev.sh

# Start development servers
./scripts/dev/start-dev.sh
```

### Git Workflow Scripts
```bash
# Clean up before merging
./scripts/git/cleanup-before-merge.sh

# Verify clean commit
./scripts/git/verify-clean-commit.sh
```

## 🎯 Benefits

1. **Clear Organization**: Scripts are grouped by purpose
2. **Easy Discovery**: Developers know where to find specific scripts
3. **Maintainability**: Easier to update and manage scripts
4. **Scalability**: Easy to add new scripts without cluttering root
5. **Professional Structure**: Follows industry best practices

## 📋 Best Practices

- **Naming**: Use descriptive names with `.sh` extension
- **Permissions**: Ensure scripts are executable (`chmod +x`)
- **Documentation**: Document what each script does
- **Testing**: Test scripts before committing
- **Version Control**: All scripts should be version controlled

## 🔧 Adding New Scripts

1. Choose the appropriate subdirectory based on purpose
2. Create the script with descriptive name
3. Make it executable: `chmod +x script-name.sh`
4. Update this README if needed
5. Test the script thoroughly

## 🚫 What NOT to Put Here

- **Configuration files** (use `config/` directory)
- **Source code** (use `src/` or `apps/` directories)
- **Documentation** (use `docs/` directory)
- **Temporary files** (use `.agent/` directory)
