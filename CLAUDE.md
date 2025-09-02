# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Online Tables Lite is a collaborative table editing application with real-time synchronization. The project is planned as a monorepo with:

- `apps/web` - Next.js frontend (App Router + Tailwind + TypeScript)
- `apps/api` - FastAPI backend with Socket.IO for real-time updates
- Database: Supabase Postgres with server-only access

## Architecture

### Security Model
- **Roles**: Admin and Editor only (no Viewer role)
- **Tokens**: Raw tokens in URLs, SHA-256 hashes stored in database
- **Authentication**: Token-based, no cookies
- **Data Flow**: No direct client-to-database writes, all through FastAPI

### Core Components
- **Tables**: Identified by slug, with admin/editor tokens
- **Real-time**: Socket.IO rooms per table (`table:<id>`)
- **Permissions**: CSV export/import controlled by environment flags
- **Mobile-first**: Bottom toolbar for admin functions

## Database Schema

Key tables:
- `tables` - Table metadata with token hashes
- `columns` - Column headers and configuration
- `cells` - Individual cell data with coordinates (r,c)
- `comments` - Rate-limited comments system
- `snapshots` - Full table state backups (admin only)

## Development Phases

The project follows a 6-phase implementation plan (see docs/CLAUDE_TASKS.md):

1. **Bootstrap** - Monorepo setup with strict TypeScript and Pydantic v2
2. **Create & Read** - Basic table creation and viewing
3. **Edit + Realtime** - Live collaborative editing with Socket.IO
4. **Admin Config** - Table configuration and limits enforcement
5. **CSV Import/Export** - Data exchange with permission controls
6. **Snapshots** - Full table state backup/restore
7. **Polish** - Comments, sharing, dark mode, accessibility

## Security Guardrails

- Never log raw tokens
- Use SHA-256 for token storage
- Enforce role-based permissions
- Restrict CORS appropriately
- Rate-limit comment submissions
- Validate all input with Pydantic models

## Git Workflow

### Branch Strategy
- **`main`** - Development branch (working branch, can break during development)
- **`production`** - Stable deployment branch (only working, tested code)
- **`feature/*`** - Short-lived feature branches (merged to main, then deleted)

### Workflow Process
1. Create feature branch from `main`: `git checkout -b feature/feature-name`
2. Develop & test locally in feature branch
3. When feature is complete and tested: 
   - Merge feature → `main`
   - Delete feature branch
4. Test `main` branch locally and on development servers
5. When `main` is stable and ready: merge `main` → `production`
6. `production` branch triggers deployments to Vercel & Fly.io

### Key Principles
- Keep features small and focused
- Test thoroughly before merging to `main`
- Only merge stable code to `production`
- Delete feature branches after merging
- `main` is for development, `production` is for deployment only

## Deployment

- **Web**: Vercel with Git integration from `production` branch (root: `apps/web`)
- **API**: Fly.io via GitHub Actions from `production` branch
- **Database**: Supabase with Service Role key access only

## Development Commands

### Backend (`apps/api`)
```bash
python main.py                    # Start dev server (localhost:8000, auto-reload)
pip install -r requirements.txt  # Install dependencies
source venv/bin/activate         # Activate virtual environment
```

### Frontend (`apps/web`)  
```bash
npm run dev        # Start dev server (localhost:3000)
npm run build      # Production build
npm run typecheck  # TypeScript validation
npm run lint       # ESLint validation
```

## Architecture Patterns

### Authentication Flow
- Raw tokens in URLs (`?t=token`), SHA-256 hashes in database
- `verify_token(slug, token)` returns `(table_data, role)` tuple
- Roles: "admin" or "editor" only (no viewer role)
- All API calls require token in header or URL parameter

### API Structure
- **Hybrid ASGI**: `socket_app = socketio.ASGIApp(sio, app)` combines FastAPI + Socket.IO
- **Database**: Supabase client with service role key (no direct client access)
- **CORS**: Dynamic origin handling with/without trailing slash
- **Pydantic v2**: Strict request/response validation

### Frontend Integration
- **Next.js 15 App Router**: `/table/[slug]/page.tsx` for table viewing
- **Socket.IO ready**: Client imported but real-time features in Phase 2
- **API calls**: Custom fetch with token headers to FastAPI backend

### Database Connection
```python
# Supabase pattern
result = supabase.table("tables").select("*").eq("slug", slug).execute()
table = result.data[0]
```

## Key Implementation Notes

- Debounced optimistic updates on frontend
- Socket.IO patch emissions for real-time sync  
- CSV round-trip must be deterministic
- Snapshots must be idempotent
- "Saving/Saved/Error" status UX required
- Mobile-responsive design priority