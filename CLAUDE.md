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

## Deployment

- **Web**: Vercel with Git integration (root: `apps/web`)
- **API**: Fly.io via GitHub Actions
- **Database**: Supabase with Service Role key access only

## Key Implementation Notes

- Debounced optimistic updates on frontend
- Socket.IO patch emissions for real-time sync
- CSV round-trip must be deterministic
- Snapshots must be idempotent
- "Saving/Saved/Error" status UX required
- Mobile-responsive design priority