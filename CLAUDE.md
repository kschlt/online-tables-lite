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

## Development Guidelines & Dependency Management

### **Frontend Stack (Locked-In)**
- **UI Framework**: Next.js 15 App Router - no other React frameworks
- **Styling**: Tailwind CSS only - no CSS-in-JS, styled-components, or other CSS libraries  
- **State Management**: React hooks (useState, useEffect) - no Redux, Zustand unless absolutely required
- **HTTP Client**: Native `fetch()` only - no axios, SWR, or React Query
- **Real-time**: `socket.io-client` for WebSocket communication
- **TypeScript**: Strict mode enabled - all components must be typed

### **Backend Stack (Locked-In)**
- **Framework**: FastAPI with Pydantic v2 - no Django, Flask, or other frameworks
- **Database**: Supabase client only - no direct SQL, SQLAlchemy ORM usage
- **Async**: Native async/await - no Celery, asyncio beyond basic usage
- **WebSockets**: `python-socketio` for real-time features
- **Validation**: Pydantic models for all request/response - no manual validation

### **Dependency Rules**
1. **NO new dependencies** without explicit justification
2. **Before adding any library**: Check if existing tools can solve the problem
3. **UI Components**: Use native HTML + Tailwind - no component libraries (MUI, Ant Design, etc.)
4. **Icons**: Use Unicode/emoji or SVG - no icon libraries unless critical
5. **Utilities**: Prefer native JavaScript/Python over utility libraries

### **Code Style Enforcement**
- **ESLint**: Next.js config extended with strict rules (see below)
- **TypeScript**: `--strict` mode, no `any` types allowed
- **Prettier**: Consistent formatting (see below)
- **File Organization**: Feature-based structure in `src/` directories

### **Architecture Constraints**
- **No server components mixing**: Keep client components in `'use client'` files only
- **API route pattern**: All FastAPI routes follow `/api/{resource}` pattern
- **Component structure**: One component per file, named exports only
- **Error handling**: Consistent error boundaries and HTTP error responses

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

### **CRITICAL: Always Activate Backend Virtual Environment First**

**Backend (`apps/api`)** - **ALWAYS run these commands in order:**
```bash
cd apps/api
source venv/bin/activate         # MUST activate venv first!
pip install -r requirements.txt  # Install dependencies (if needed)
python main.py                   # Start dev server (localhost:8000, auto-reload)
```

**Important Notes:**
- **NEVER** run `python` or `python3` commands without activating the virtual environment first
- The system may not have `python` command - use `python3` if `python` fails
- Always `cd apps/api && source venv/bin/activate` before any Python commands
- Virtual environment contains all required dependencies (FastAPI, Supabase, etc.)

### Frontend (`apps/web`)  
```bash
cd apps/web
npm install                      # Install dependencies (if needed)
npm run dev                      # Start dev server (localhost:3000)
npm run build                    # Production build
npm run typecheck                # TypeScript validation
npm run lint                     # ESLint validation
npm run lint:fix                 # Auto-fix ESLint issues
npm run format                   # Format code with Prettier
npm run format:check             # Check Prettier formatting
```

### **Quality Assurance Commands**
```bash
# Before committing - run all checks:
npm run typecheck && npm run lint && npm run format:check
# Auto-fix issues:  
npm run lint:fix && npm run format
```

### **Development Startup Checklist:**
1. **Backend:** `cd apps/api && source venv/bin/activate && python main.py`
2. **Frontend:** `cd apps/web && npm run dev`  
3. **Test:** Health check `curl http://localhost:8000/healthz`

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