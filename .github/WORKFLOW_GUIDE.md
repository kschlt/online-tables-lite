# Enhanced Pipeline Workflow Guide

## Overview
This project uses a comprehensive pipeline with multiple guardrails to protect both the main branch and production environment. **NEVER work directly on main** - always use feature branches.

## Complete Workflow Steps

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

### 4. Production Branch Workflow
**This is the key part of your workflow:**

#### Step 4a: Local Production Branch Update
```bash
# Switch to production branch
git checkout production
git pull origin production

# Merge main into production locally
git merge main

# This is where the magic happens - pre-push hook runs!
git push origin production
```

#### Step 4b: Pre-Push Validation (`.husky/pre-push`)
**BEFORE** you can push to production, comprehensive checks run locally:
- ✅ Web app: TypeScript + linting + formatting + build
- ✅ API: linting + formatting + structure validation
- ❌ **If any check fails, the push is BLOCKED**
- 💡 **You get immediate feedback in your terminal**

#### Step 4c: GitHub Production Validation (`.github/workflows/production-push-checks.yml`)
After successful push, GitHub runs additional validation:
- Same comprehensive checks as pre-push
- Ensures consistency across environments
- Triggers production deployments if successful

### 5. Production Deployment
Production deployments now run automatically after validation:

#### Web Deployment (`.github/workflows/deploy-web.yml`)
- Runs only after production validation passes
- Deploys to Vercel automatically
- Environment selection available for manual deployments

#### API Deployment (`.github/workflows/deploy-api.yml`)
- Runs only after production validation passes
- Deploys to Fly.io automatically
- Environment selection available for manual deployments

## Key Guardrails

### 🛡️ Branch Protection
- **Main branch**: Protected, requires PRs with checks
- **Production branch**: Protected by pre-push hooks + GitHub validation
- **Feature branches**: Free development, but must pass all checks

### 🛡️ Code Quality
- TypeScript errors block PRs and production pushes
- Linting errors block PRs and production pushes
- Formatting issues block PRs and production pushes
- Build failures block PRs and production pushes

### 🛡️ Production Safety
- **Pre-push hooks prevent bad code from reaching GitHub**
- **Immediate feedback in your terminal when pushing**
- **GitHub validation as backup verification**
- **Automatic deployment only after all checks pass**

## Your Exact Workflow

1. **Feature Branch** → Develop and test locally
2. **PR to Main** → Automated checks + manual review
3. **Merge to Main** → Automated validation
4. **Local Production** → `git checkout production && git merge main`
5. **Push Production** → **Pre-push hooks run checks locally**
   - ✅ **If checks pass** → Push succeeds, GitHub validation runs, deployment triggers
   - ❌ **If checks fail** → Push blocked, fix in feature branch, repeat process
6. **Production Live** → Automatic deployment to Vercel + Fly.io

## What Happens When Checks Fail

### Pre-Push Hook Failure (Local)
```bash
$ git push origin production
�� PRODUCTION PUSH DETECTED - Running comprehensive checks...
❌ Web app checks failed!
💡 Fix the issues and try pushing again
💡 Or go back to your feature branch to fix issues
```

**Your response:**
1. Go back to your feature branch: `git checkout feature/your-feature-name`
2. Fix the issues
3. Test locally: `npm run check && npm run build`
4. Commit fixes: `git commit -m "fix: resolve linting issues"`
5. Repeat the workflow from step 2

### GitHub Validation Failure (Remote)
- GitHub Actions will show failed checks
- Production deployment will NOT trigger
- Fix issues in feature branch and repeat workflow

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
6. Follow normal production workflow

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
7. **Use pre-push feedback** - fix issues locally before pushing to production

## Troubleshooting

### Pre-Push Hook Not Working
- Ensure `.husky/pre-push` is executable: `chmod +x .husky/pre-push`
- Check if husky is installed: `npm list husky`
- Reinstall husky if needed: `npm install husky --save-dev`

### PR Checks Failing
- Check the specific error in GitHub Actions
- Run the same commands locally to reproduce
- Fix the issue and push to your feature branch
- Checks will re-run automatically

### Production Push Blocked
- Read the error message carefully
- Fix issues in your feature branch
- Test locally before trying to push again
- Don't try to bypass the pre-push hook

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

## Summary

This pipeline ensures that:
- ✅ **You get immediate feedback** when pushing to production
- ✅ **Bad code cannot reach production** (blocked by pre-push hooks)
- ✅ **All checks run before deployment** (local + GitHub validation)
- ✅ **Production is always in a deployable state**
- ✅ **You can fix issues in feature branches** before they reach production
