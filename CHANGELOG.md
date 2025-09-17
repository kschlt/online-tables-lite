# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation
- Implement perfect ping-pong chain architecture
- Implement comprehensive branch/PR validation to prevent confusion
- Add intelligent staging with agent decision-making

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks
- Use branch-specific git-cliff range for accurate PR descriptions
- Remove trailing semicolon in Makefile ship target
- Update agent instructions for workflow trigger messages

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Clean up CLAUDE.md commit workflow formatting
- Improve CLAUDE.md workflow instruction formatting

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing
- Consolidate agent architecture with ping-pong workflows
- Implement path constants for maintainable script references
- Consolidate push pipeline and fix branch detection
- Improve file staging decision instructions

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation
- Implement perfect ping-pong chain architecture
- Implement comprehensive branch/PR validation to prevent confusion

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks
- Use branch-specific git-cliff range for accurate PR descriptions
- Remove trailing semicolon in Makefile ship target

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing
- Consolidate agent architecture with ping-pong workflows
- Implement path constants for maintainable script references

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation
- Implement perfect ping-pong chain architecture
- Implement comprehensive branch/PR validation to prevent confusion

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks
- Use branch-specific git-cliff range for accurate PR descriptions
- Remove trailing semicolon in Makefile ship target

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing
- Consolidate agent architecture with ping-pong workflows
- Implement path constants for maintainable script references

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation
- Implement perfect ping-pong chain architecture
- Implement comprehensive branch/PR validation to prevent confusion

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks
- Use branch-specific git-cliff range for accurate PR descriptions
- Remove trailing semicolon in Makefile ship target

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing
- Consolidate agent architecture with ping-pong workflows
- Implement path constants for maintainable script references

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation
- Implement perfect ping-pong chain architecture
- Implement comprehensive branch/PR validation to prevent confusion

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks
- Use branch-specific git-cliff range for accurate PR descriptions
- Remove trailing semicolon in Makefile ship target

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing
- Consolidate agent architecture with ping-pong workflows
- Implement path constants for maintainable script references

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation
- Implement perfect ping-pong chain architecture
- Implement comprehensive branch/PR validation to prevent confusion

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks
- Use branch-specific git-cliff range for accurate PR descriptions

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing
- Consolidate agent architecture with ping-pong workflows
- Implement path constants for maintainable script references

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation
- Implement perfect ping-pong chain architecture

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing
- Consolidate agent architecture with ping-pong workflows
- Implement path constants for maintainable script references

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system
- Implement self-executing promptlet chain for PR generation

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system
- Simplify pr-body to return promptlet for agent processing

### Testing

- Workflow validation
- Verify Husky integration works properly
- Validate unified git-cliff workflow

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script
- Remove redundant individual commit cache system

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats
- Complete sophisticated cache → promptlet → AI PR generation system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system
- Restore detailed PR descriptions with commit list and file stats

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management
- Generate markdown PR descriptions instead of JSON tasks

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes
- Update CHANGELOG.md with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command
- Resolve pre-push conflicts and improve PR management

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook
- Resolve sed regex error in pr-open command

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture
- Resolve git-cliff CHANGELOG generation in pre-push hook

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added

- Implement Phase 0 & 1 - monorepo setup with FastAPI backend and Next.js frontend
- Establish comprehensive development guidelines and tooling
- Complete Phase 2 & 3 - Cell editing + Real-time + Admin config
- Add dedicated row/column management endpoints
- Phase 3 - Header width configuration
- Phase 3 - Today date highlighting functionality
- Add table creation form to homepage with dual token display
- Add comprehensive table creation interface to homepage
- Implement new table configuration UI
- Improve CORS configuration for development with multiple ports
- Complete Phase 3 - add +Row/+Column buttons and fix admin drawer API integration
- Redesign admin row/column buttons with elegant modern style
- Add inline 'Add new row' button at bottom of table
- Implement instant row/column addition without page reload
- Replace admin settings button with modern SVG icon
- Implement i18n support with English/German translations
- Implement industry standard next-intl i18n
- Major backend and frontend improvements
- Update .gitignore and remove IDE/agent config files
- Remove CLAUDE.md from tracking
- Comprehensive datetime picker improvements
- Enhance table functionality and UI components
- Add logging improvements and translation updates
- Implement comprehensive code quality improvements
- Enhance auto-formatting pipeline with comprehensive VS Code integration
- Implement comprehensive cleanup system for agent files and backups
- AI-era pipeline protection with simplified CI/CD ([#2](/issues/2))
- Enhanced mobile date picker UX with centered modal and Clear buttons ([#4](/issues/4))
- Clean header refactor implementation ([#5](/issues/5))
- Comprehensive codebase cleanup and lint configuration fixes ([#6](/issues/6))
- Comprehensive CI/CD improvements with health checks and rollback ([#9](/issues/9))
- Make deployment more robust and fix Fly.io port binding
- Comprehensive deployment optimization and dependency updates
- Complete Husky removal and dependency updates
- Upgrade Node.js version requirements to eliminate EBADENGINE warnings
- Upgrade to Node.js 22 LTS and complete ESLint configuration
- Completely remove Husky and is-ci dependencies
- Update CI environment to properly handle modern Node.js types
- Comprehensive CI workflow improvements with bulletproof devDependencies
- Add i18n support to navigation menu
- Implement strict linting workflow with auto-fixing
- Implement configurable default table settings with smart database setup
- Complete configuration system implementation
- Enhance Git workflow for both human and agent use
- Implement self-evident JSON agent feedback system
- Implement universal agent task recognition system
- Add git-cliff conventional commits and automated changelog
- Enhance make commit with full git-cliff configuration integration
- Improve commit command UX with better error handling and convenience
- Add comprehensive change detection and workflow optimization
- Add automated branch creation with smart checks
- Enforce feat/fix branch naming with guardrails
- Implement incremental PR metadata system
- Implement comprehensive promptlet compliance system

### Fixed

- Remove deprecated Next.js config and update ESLint to v9
- Improve CORS handling and token header parsing
- Disable GitHub Action for Vercel, use auto-deploy
- Re-enable GitHub Actions for Vercel deployment
- Use direct Vercel CLI instead of action for more reliable deployment
- Update vercel.json for monorepo and fix workflow paths
- Admin drawer add/remove column functions to call actual API
- Admin drawer add/remove column to work with local state only
- Resolve table creation 400 errors with improved validation
- Update trusted hosts for Fly.io production deployment
- Implement proper horizontal lines and unified table borders
- Resolve TypeScript build errors and clean up unnecessary files
- Remove git add from lint-staged config
- Adjust ESLint warning threshold for successful builds
- Update branch protection settings to reflect 0 approvals ([#3](/issues/3))
- Use commit SHA instead of branch ref for GitHub deployments
- Resolve Vercel deployment warnings and improve CI/CD robustness
- Resolve API linting issues
- Improve deployment workflow health checks
- Resolve ESLint configuration and formatting issues
- Eliminate all Next.js ESLint warnings and build issues
- Update remaining Node.js version reference in deployment workflow
- Resolve Husky CI failure with is-ci detection
- Update TypeScript configuration to support modern JavaScript features
- Comprehensive TypeScript configuration update
- Remove explicit Node.js types reference to fix CI
- Restore Node.js types with skipLibCheck for CI compatibility
- Align @types/node version with Node.js 22
- Remove explicit Node.js types reference for CI compatibility
- Comprehensive TypeScript configuration and Node.js types resolution
- Revert to working main branch TypeScript approach
- Revert @types/node to working version from main
- Disable npm cache in CI to debug type resolution issues
- Ensure devDependencies are installed in CI
- Improve npm installation verification in CI workflow
- Optimize CI cache strategy for better performance
- Streamline CI workflow to resolve @types/node installation issues
- Improve @types/node verification in CI
- Force install @types/node and verify TypeScript resolution in CI
- Regenerate package-lock.json for Node.js 22 compatibility
- Ensure devDependencies installation and TypeScript hardening
- Format tsconfig.json with Prettier
- Resolve production deployment conflicts with branch protection rules
- Improve header layout alignment and structure
- Improve table settings dialog layout alignment
- Improve time picker scrolling behavior and hide scrollbars
- Implement reusable NumericInput component and resolve admin dialog input bug
- Resolve infinite re-render loop and improve configuration integration
- Resolve post-push hook issue with proper push-and-pr workflow
- Align cliff.toml with commitlint conventional config
- Improve cache format for proper bash variable handling
- Resolve JSON parsing and commit counting bugs in metadata system
- Standardize promptlet injection pattern across all commands
- Complete promptlet system migration and fix validation
- Achieve 100% consistent promptlet architecture

### Documentation

- Add git workflow documentation and update deployments
- Add comprehensive README and .env.example
- Streamline README to essential information only
- Add development commands and architecture patterns to CLAUDE.md
- Update README to reflect Phase 2 & 3 completion
- Update README to reflect header width configuration completion
- Update README to reflect Phase 3 completion
- Update README with comprehensive feature overview and deployment info
- Clean up README formatting and remove redundant sections
- Clean up obsolete documentation files
- Update README files to clarify database architecture
- Sync documentation with latest changes
- Add explicit agent trigger words and fix workflow descriptions
- Update documentation for modern Husky integration
- Update scripts/README.md for Husky integration
- Add test file for metadata system validation
- Sync documentation with latest changes

### Performance

- Optimize commit and ship commands for efficiency

### Refactored

- Implement single-source i18n management
- Organize scripts into modern project structure
- Simplify echo messages in cleanup and verification scripts
- Implement single source of truth promptlet system

### Testing

- Workflow validation
- Verify Husky integration works properly

### Miscellaneous Tasks

- Remove build artifacts and update gitignore files
- Update package-lock.json for is-ci dependency

### Cleanup

- Remove unnecessary dev.sh wrapper script

### Debug

- Add comprehensive logging to CI for @types/node investigation

### Deploy

- Trigger both API and Web deployments with secrets

### Optimize

- Eliminate inefficiencies and fix workflow inconsistencies

### Simplify

- Remove unnecessary push-and-pr wrapper command

### Trigger

- Re-deploy after adding secrets

## [Unreleased]

### Added
- Universal agent task recognition system
- Self-evident JSON agent feedback system  
- Enhanced Git workflow for both human and agent use
- Workflow validation testing

### Changed
- Eliminated workflow inefficiencies and inconsistencies
- Simplified push-and-pr workflow by removing unnecessary wrapper command
- Improved configuration integration

### Fixed
- Post-push hook issues with proper push-and-pr workflow
- Infinite re-render loop in configuration system

### Documentation
- Added explicit agent trigger words and workflow descriptions
- Synced documentation with latest changes

## [0.1.0] - 2025-01-15

### Added
- Initial Online Tables Lite implementation
- FastAPI backend with async SQLAlchemy and Socket.IO
- Next.js frontend with TypeScript and Tailwind CSS
- Token-based authentication with SHA-256 hashing
- Core endpoints: `/healthz`, `POST /api/table`, `GET /api/table/{slug}`
- Read-only table viewing page at `/table/[slug]?t={token}`
- GitHub Actions workflows for Vercel and Fly.io deployment
- Complete local development setup
- Comprehensive CI/CD pipeline with quality checks
- Monorepo structure with organized scripts directory

### Security
- Secure token-based authentication
- No raw token logging in production
- CORS properly configured for production origins

[unreleased]: https://github.com/yourusername/online-table-lite/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/online-table-lite/releases/tag/v0.1.0