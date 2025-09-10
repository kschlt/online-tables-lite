# GitHub Configuration

## Branch Protection
- **Main**: PR required, 0 approvals, Quality Checks, squash/rebase only
- **Production**: PR required, 0 approvals, Quality Checks, rebase only

## Workflows
- **CI**: Quality checks (TypeScript, linting, build)
- **Deploy**: Manual deployment to Vercel + Fly.io

## Workflow
1. Create feature branch
2. Push to GitHub
3. Create PR to main → wait for Quality Checks
4. Create PR main → production → wait for Quality Checks
5. Deploy via GitHub Actions

## AI Protection
- AI can work in feature branches freely
- AI cannot push to main/production directly
- All merges require Quality Checks to pass
