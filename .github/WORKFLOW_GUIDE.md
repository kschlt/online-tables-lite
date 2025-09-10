# Enhanced Pipeline Workflow Guide

## Overview
This project now uses a comprehensive pipeline with multiple guardrails to protect both the main branch and production environment. **NEVER work directly on main** - always use feature branches.

## Workflow Steps

### 1. Feature Development
```bash
# Always start from main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Make your changes
# ... your development work ...

# Test locally
cd apps/web && npm run check && npm run build
cd apps/api && ruff check . && ruff format --check .
```

### 2. Pull Request Process
When you create a PR to main, the following checks run automatically:

#### PR Checks Workflow (`.github/workflows/pr-checks.yml`)
- **Web App Checks:**
  - TypeScript type checking (`npm run typecheck`)
  - ESLint linting (`npm run lint`)
  - Prettier format checking (`npm run format:check`)
  - Build validation (`npm run build`)
  - Build artifacts verification

- **API Checks:**
  - Ruff linting (`ruff check .`)
  - Ruff formatting (`ruff format --check .`)
  - API structure validation
  - Import testing

- **Build Validation:**
  - Full build process validation
  - Cross-platform compatibility checks

### 3. Main Branch Protection
Once PR is merged to main, additional validation runs:

#### Main Branch Checks (`.github/workflows/main-checks.yml`)
- Comprehensive validation of main branch
- Integration testing
- Production readiness verification

### 4. Production Deployment
Production deployments now require **manual approval**:

#### Web Deployment (`.github/workflows/deploy-web.yml`)
- Pre-deployment validation (all checks + build)
- Manual approval required
- Environment selection (production/preview)
- Deployment to Vercel with verification

#### API Deployment (`.github/workflows/deploy-api.yml`)
- Pre-deployment validation (linting + structure)
- Manual approval required
- Environment selection (production/staging)
- Deployment to Fly.io with verification

## Key Guardrails

### 🛡️ Branch Protection
- **Main branch**: Protected, requires PRs
- **Production branch**: Protected, requires manual approval
- **Feature branches**: Free development, but must pass all checks

### 🛡️ Code Quality
- TypeScript errors block PRs
- Linting errors block PRs
- Formatting issues block PRs
- Build failures block PRs

### 🛡️ Production Safety
- Manual approval required for all production deployments
- Pre-deployment validation runs before any deployment
- Environment selection for controlled deployments
- Rollback capability through environment management

## Manual Deployment Process

### For Web App:
1. Go to GitHub Actions → "Deploy Web (Vercel)"
2. Click "Run workflow"
3. Select environment (production/preview)
4. Review pre-deployment checks
5. Approve deployment

### For API:
1. Go to GitHub Actions → "Deploy API (Fly.io)"
2. Click "Run workflow"
3. Select environment (production/staging)
4. Review pre-deployment checks
5. Approve deployment

## Emergency Procedures

### Quick Fixes
If you need to make urgent fixes:
1. Create hotfix branch: `git checkout -b hotfix/urgent-fix`
2. Make minimal changes
3. Test thoroughly locally
4. Create PR with clear explanation
5. Fast-track review and merge
6. Deploy with manual approval

### Rollback
- Use Vercel dashboard for web rollbacks
- Use Fly.io dashboard for API rollbacks
- Or redeploy previous working version through GitHub Actions

## Best Practices

1. **Always use feature branches** - never commit directly to main
2. **Test locally first** - run `npm run check` and `ruff check .`
3. **Write descriptive PR titles** - helps with review process
4. **Review your own PR** - check the automated checks before requesting review
5. **Deploy during business hours** - easier to monitor and rollback if needed
6. **Keep PRs small** - easier to review and less risk of issues

## Troubleshooting

### PR Checks Failing
- Check the specific error in GitHub Actions
- Run the same commands locally to reproduce
- Fix the issue and push to your feature branch
- Checks will re-run automatically

### Deployment Failing
- Check pre-deployment validation logs
- Verify all secrets are properly configured
- Check environment-specific configurations
- Contact team lead if issues persist

## Environment Variables Required

### Vercel (Web)
- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

### Fly.io (API)
- `FLY_API_TOKEN`

Make sure these are configured in GitHub repository secrets.
