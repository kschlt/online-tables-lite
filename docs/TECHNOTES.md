# TECHNOTES

## Architecture
- Frontend: Next.js (App Router) + Tailwind + TS
- Backend: FastAPI + Uvicorn + python-socketio (ASGI)
- DB: Supabase Postgres (server-only access via Service Role key)
- Realtime: Socket.IO room per table `table:<id>`

## Database schema (run in Supabase SQL)
```sql
create extension if not exists pgcrypto;
create table public.tables (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  title text,
  description text,
  cols int not null default 4,
  rows int not null default 10,
  edit_token_hash text not null,
  admin_token_hash text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_activity_at timestamptz not null default now(),
  deleted_at timestamptz
);
create index on public.tables (slug);
create index on public.tables (last_activity_at);
create index on public.tables (deleted_at);

create table public.columns (
  id bigserial primary key,
  table_id uuid references public.tables(id) on delete cascade,
  idx int not null,
  header text,
  width int,
  today_hint boolean default false
);
create index on public.columns (table_id, idx);

create table public.cells (
  id bigserial primary key,
  table_id uuid references public.tables(id) on delete cascade,
  r int not null,
  c int not null,
  value text,
  updated_at timestamptz not null default now(),
  updated_by text
);
create unique index on public.cells (table_id, r, c);

create table public.comments (
  id bigserial primary key,
  table_id uuid references public.tables(id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  ip_hash text
);
create index on public.comments (table_id, created_at);

create table public.snapshots (
  id uuid primary key default gen_random_uuid(),
  table_id uuid references public.tables(id) on delete cascade,
  created_at timestamptz not null default now(),
  note text,
  data jsonb not null
);
create index on public.snapshots (table_id, created_at);

create or replace function touch_tables_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end $$ language plpgsql;

create trigger trg_tables_touch
before update on public.tables
for each row execute function touch_tables_updated_at();
```

## Local Development

### Prerequisites
- Node.js 18+ and npm
- Python 3.11+
- PostgreSQL database (or Supabase account)

### Backend Setup (apps/api)
```bash
cd apps/api
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your database URL and CORS origin
python main.py
```

### Frontend Setup (apps/web)
```bash
cd apps/web
npm install
cp .env.example .env.local
# Edit .env.local with API URL if needed
npm run dev
```

### Environment Variables

**Backend (apps/api/.env)**:
- `DATABASE_URL` - PostgreSQL connection string
- `CORS_ORIGIN` - Frontend URL for CORS (default: http://localhost:3000)
- `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` - For production

**Frontend (apps/web/.env.local)**:
- `NEXT_PUBLIC_API_URL` - Backend URL (default: http://localhost:8000)

### Testing the Implementation

1. Start backend: `cd apps/api && python main.py`
2. Start frontend: `cd apps/web && npm run dev`
3. Create a table: `POST http://localhost:8000/api/table`
4. Visit table: `http://localhost:3000/table/{slug}?t={token}`
