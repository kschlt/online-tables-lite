# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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