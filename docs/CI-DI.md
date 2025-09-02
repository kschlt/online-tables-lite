# CI/CD

## Web (Vercel)
**Option A (recommended):** native Vercel Git integration → set root dir to `apps/web`.  
**Option B:** GitHub Action below triggers Vercel deploys.

## API (Fly.io)
GitHub Action deploys `apps/api` when files change there.

## Nightly jobs
Optional: GitHub Action that calls cron endpoints (if/when enabled).

### .github/workflows/deploy-web.yml
```yaml
name: Deploy Web (Vercel)
on:
  push:
    branches: [ main ]
    paths:
      - 'apps/web/**'
      - '.github/workflows/deploy-web.yml'
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Vercel Deploy
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          working-directory: apps/web
          vercel-args: '--prod'