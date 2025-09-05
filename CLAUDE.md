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

## Development Guidelines & Human-in-the-Loop Decision Making

### **Core Stack (Established - Low Change Frequency)**
- **Frontend**: Next.js 15 + Tailwind CSS + TypeScript 
- **Backend**: FastAPI + Pydantic v2 + Supabase
- **Real-time**: socket.io-client/python-socketio
- **HTTP**: Native fetch() (existing choice)

### **Pragmatic Guidelines (Flexible - Warnings, Not Blockers)**
- **Dependencies**: Prefer existing tools first, justify new additions
- **UI**: Use Tailwind + native HTML as default, discuss component libraries if needed
- **State**: React hooks as default, discuss complex state management when required  
- **Code Style**: Prettier formatting, basic ESLint rules, TypeScript strict mode

### **Tiered Decision-Making System (Senior Developer Model)**

I will act like a senior developer with autonomous decision-making authority for routine issues, escalating only major architectural decisions.

#### **🟢 AUTO-HANDLE (No Human Loop Required)**
*Senior developer decisions - I implement immediately and document:*

- **Code Quality**: Fix ESLint warnings, formatting issues, type errors
- **Minor Dependencies**: Add tiny utilities (lodash functions, date formatters) if clearly beneficial
- **Code Refactoring**: Extract components, improve naming, reduce duplication
- **Bug Fixes**: Resolve issues within existing patterns and architecture
- **Testing**: Add unit tests, fix broken tests, improve test coverage
- **Performance**: Optimize existing code without architectural changes

#### **🟢 AUTONOMOUS ESLint RULE ADJUSTMENTS**
*I can modify linting configurations when they block legitimate development:*

**Allowed Autonomous Changes:**
- **Disable specific rules** for individual files (`// eslint-disable-next-line rule-name`)
- **Adjust rule severity** (error → warn, warn → off) for development productivity
- **Add file/directory exceptions** to existing rules (e.g., allow console.log in scripts/)
- **Modify rule parameters** (line length, complexity limits) within reasonable bounds
- **Add new minor rules** that enforce established patterns

**Process:**
1. **Encounter ESLint blocker** during legitimate development
2. **Assess if rule conflict** is due to valid new requirements
3. **Make minimal rule adjustment** to unblock development
4. **Document change** in commit with reasoning
5. **Update guidelines** if it establishes new pattern

#### **🟡 INTERNAL EVALUATION (AI Self-Assessment)**
*When encountering decisions, I will internally assess:*

1. **Impact Scope**: Does this affect multiple files/components/systems?
2. **Reversibility**: Can this be easily undone if it doesn't work?
3. **Precedent Setting**: Does this establish a new pattern others should follow?
4. **Complexity Cost**: Does this add significant mental overhead?
5. **Risk Level**: Could this break existing functionality or future scalability?

#### **🔴 ESCALATE TO HUMAN (Team Lead Consultation)**
*I will PAUSE & ASK when decisions meet these criteria:*

**Code & Architecture:**
- **Major Dependencies**: New frameworks, large libraries, or tools with lock-in
- **Architecture Patterns**: Database schema changes, API design shifts, state management approaches  
- **Cross-System Impact**: Changes affecting multiple apps (web + api), deployment, or external integrations
- **Security/Performance Trade-offs**: Decisions with significant implications for either
- **Technology Shifts**: Moving away from established stack choices
- **Complex Business Logic**: Domain-specific rules that need product input

**ESLint Configuration Changes Requiring Discussion:**
- **Disable entire rule categories** (e.g., all TypeScript rules, all React hooks rules)
- **Allow unrestricted imports** (removing import restrictions entirely)
- **Major philosophy shifts** (switching from warnings to errors, or vice versa project-wide)
- **Security-related rule changes** (disabling rules that prevent security issues)
- **Add strict new rules** that would require major refactoring of existing code

#### **📋 Escalation Format**
*When I escalate, I'll present like in a technical meeting:*

```
🚨 ARCHITECTURAL DECISION NEEDED

**Context**: [What I'm implementing and why this decision came up]
**Problem**: [Current limitation/blocker I encountered]  
**Impact Scope**: [What parts of system this affects]

**Option A**: [My recommended approach]
  ✅ Pros: [Benefits and why I favor this]  
  ❌ Cons: [Downsides and risks]

**Option B**: [Alternative approach]
  ✅ Pros: [Benefits]
  ❌ Cons: [Downsides]

**My Recommendation**: [Option A/B and brief reasoning]
**Urgency**: [Blocking/Can work around temporarily/Future iteration]
```

#### **⚡ After Decisions (Both Auto & Escalated)**
- Document new patterns in "Current Auto-Apply Patterns" section
- Apply consistently in future similar situations
- Reference decision in commit messages for future context

#### **🎯 Practical Examples**

**✅ AUTONOMOUS ESLint Adjustments I'll Make:**
```javascript
// Scenario: Need console.log for debugging Socket.IO in development
// Auto-adjustment: Add exception for specific file
{
  "rules": {
    "no-console": ["warn", { "allow": ["warn", "error"] }]
  },
  "overrides": [{
    "files": ["src/utils/socket-debug.ts"],
    "rules": { "no-console": "off" }
  }]
}
```

**❌ ESCALATION Required - Major Rule Change:**
```javascript
// Scenario: Want to disable all TypeScript strict rules project-wide
// This would require discussion:
{
  "rules": {
    "@typescript-eslint/no-explicit-any": "off", // Major policy change
    "@typescript-eslint/strict-boolean-expressions": "off" // Affects code quality
  }
}
```

**🤝 How I'll Present Escalations:**
> 🚨 **ESLINT CONFIGURATION DECISION NEEDED**
> 
> **Context**: Implementing Socket.IO real-time features requires dynamic event handling
> **Problem**: Current ESLint rules prevent `any` types, but Socket.IO events are inherently dynamic
> **Impact Scope**: All real-time features, 3-4 files
> 
> **Option A**: Disable `@typescript-eslint/no-explicit-any` for socket files only
>   ✅ Pros: Unblocks Socket.IO development, contained to specific use case  
>   ❌ Cons: Less type safety in socket handling code
> 
> **Option B**: Create strict Socket.IO type definitions
>   ✅ Pros: Maintains type safety, better long-term code quality
>   ❌ Cons: Significant upfront time investment, may be over-engineering
> 
> **My Recommendation**: Option A - focused exception for this specific use case
> **Urgency**: Blocking Phase 2 implementation

## **Naming Conventions & File Organization Best Practices**

### **Backend (FastAPI) Structure**
```
apps/api/
├── main.py                 # Entry point, app setup
├── app/
│   ├── __init__.py
│   ├── core/              # Core configuration
│   │   ├── config.py      # Settings, environment vars
│   │   ├── database.py    # Supabase client setup
│   │   └── security.py    # Auth, token hashing
│   ├── models/            # Pydantic models
│   │   ├── __init__.py
│   │   ├── table.py       # Table-related models
│   │   └── base.py        # Base model classes
│   ├── api/               # API routes
│   │   ├── __init__.py
│   │   ├── v1/            # API versioning
│   │   │   ├── __init__.py
│   │   │   ├── tables.py  # Table endpoints
│   │   │   └── cells.py   # Cell endpoints
│   │   └── dependencies.py # Shared dependencies
│   ├── services/          # Business logic
│   │   ├── __init__.py
│   │   ├── table_service.py
│   │   └── auth_service.py
│   └── utils/             # Shared utilities
│       ├── __init__.py
│       └── helpers.py
├── tests/                 # Test files
└── alembic/              # DB migrations (if needed)
```

### **Frontend (Next.js 15) Structure** 
```
apps/web/src/
├── app/                   # App Router (Next.js 15)
│   ├── globals.css
│   ├── layout.tsx         # Root layout
│   ├── page.tsx          # Home page
│   ├── table/            # Table feature
│   │   └── [slug]/
│   │       └── page.tsx
│   └── api/              # API routes (if needed)
├── components/           # Reusable components
│   ├── ui/              # Base UI components
│   │   ├── Button.tsx
│   │   └── Input.tsx
│   ├── table/           # Table-specific components
│   │   ├── TableGrid.tsx
│   │   ├── TableCell.tsx
│   │   └── TableHeader.tsx
│   └── layout/          # Layout components
│       ├── Header.tsx
│       └── Footer.tsx
├── lib/                 # Shared utilities
│   ├── api.ts           # API client functions
│   ├── socket.ts        # Socket.IO client
│   ├── types.ts         # TypeScript types
│   └── utils.ts         # Helper functions
├── hooks/               # Custom React hooks
│   ├── useTable.ts
│   └── useSocket.ts
└── styles/             # Additional styles (if needed)
```

### **Naming Conventions**

**Files & Directories:**
- **snake_case**: Python files (`table_service.py`, `auth_service.py`)
- **kebab-case**: Directories and config files (`api/v1/`, `.eslintrc.json`)
- **PascalCase**: React components (`TableGrid.tsx`, `Button.tsx`)
- **camelCase**: TypeScript files (`api.ts`, `utils.ts`)

**Code Naming:**
- **snake_case**: Python functions, variables (`create_table`, `user_id`)
- **PascalCase**: Python classes, React components (`TableService`, `TableGrid`)
- **camelCase**: JavaScript/TypeScript functions, variables (`createTable`, `userId`)
- **SCREAMING_SNAKE_CASE**: Constants (`API_BASE_URL`, `DEFAULT_ROWS`)

**API Patterns:**
- **REST**: `/api/v1/tables`, `/api/v1/tables/{id}/cells`
- **Resources**: Plural nouns for collections (`/tables`, `/cells`)
- **Actions**: HTTP verbs (GET, POST, PUT, DELETE)

### **Database Access Patterns**
- **ONLY Supabase client**: `supabase.table("tables").select("*")`
- **NO direct SQL**: No raw SQL strings or SQLAlchemy ORM
- **NO database imports**: Avoid `psycopg2`, `asyncpg` direct usage

### **Current Auto-Apply Patterns** 
*(Updated as we make decisions)*

- **File Organization**: Feature-based structure with domain separation
- **API Routes**: `/api/v1/{resource}` pattern with versioning
- **Components**: PascalCase, one per file, named exports
- **Database**: Supabase client only, no direct SQL/ORM
- **Error Handling**: Consistent boundaries and HTTP responses

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

### **Backend (`apps/api`)**
```bash
cd apps/api && source venv/bin/activate   # Always activate venv first
make lint                                  # Check Python code quality
make format                               # Auto-format Python code
make check                                # Run all quality checks
make fix                                  # Auto-fix all issues
```

### **Quality Assurance Commands**
```bash
# Frontend checks:
npm run typecheck && npm run lint && npm run format:check
npm run fix  # Auto-fix all frontend issues

# Backend checks:
make check   # Run all Python quality checks  
make fix     # Auto-fix all Python issues
```

### **Implemented Linting Configuration**

**✅ Frontend Linting (`apps/web`):**
- **ESLint v9** with flat config format (`eslint.config.mjs`)
- **TypeScript strict mode** with type checking (`tsc --noEmit`)
- **Prettier** for consistent formatting
- **Ignores**: `.next/`, `node_modules/`, build artifacts, config files
- **Lints only**: `src/**/*.{ts,tsx}` - actual TypeScript source code
- **Rules**: Warnings (not blockers) for code quality guidance

**✅ Backend Linting (`apps/api`):**
- **Ruff** (modern Python linter & formatter) via `pyproject.toml`
- **Checks**: Code style, imports, complexity, security patterns
- **Auto-fixes**: Import sorting, formatting, common issues
- **Lints only**: `*.py` files in project root (ignores `venv/`, `__pycache__`)
- **Make commands** for easy usage: `make lint`, `make format`, `make fix`

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