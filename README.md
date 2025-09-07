# Online Tables Lite

A collaborative table editing application with real-time synchronization. Create and share editable tables with secure token-based access control.

**Current Status**: Phase 2 & 3 complete - collaborative editing with real-time sync and admin controls functional.

## 🏗️ Tech Stack

- **Frontend**: Next.js 15 + TypeScript + Tailwind CSS
- **Backend**: FastAPI + Socket.IO + Pydantic v2  
- **Database**: Supabase Postgres
- **Deployment**: Vercel (frontend) + Fly.io (backend)

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ and npm
- Python 3.11+  
- Supabase account (for database)

### 1. Clone and Setup
```bash
git clone https://github.com/kschlt/online-tables-lite.git
cd online-tables-lite
```

### 2. Database Setup
1. Create a Supabase project at [supabase.com](https://supabase.com)
2. Run the SQL schema from `docs/TECHNOTES.md` in the Supabase SQL editor
3. Get your Supabase URL and Service Role key from Project Settings → API

### 3. Backend Setup
```bash
cd apps/api
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env
```

Edit `apps/api/.env`:
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
CORS_ORIGIN=http://localhost:3000
TABLE_ROW_LIMIT=500
TABLE_COL_LIMIT=64
```

Start the backend:
```bash
python main.py
# Runs on http://localhost:8000
```

### 4. Frontend Setup
```bash
cd apps/web
npm install
cp .env.example .env.local
```

Edit `apps/web/.env.local` (optional):
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

Start the frontend:
```bash
npm run dev
# Runs on http://localhost:3000
```

### 5. Test the Application
1. Create a table: `POST http://localhost:8000/api/v1/tables`
2. Use the returned tokens to view: `http://localhost:3000/table/{slug}?t={token}`
3. Edit cells in real-time with collaborative features
4. Use admin token to access table configuration (add/remove rows/columns)

## 🌍 Deployment

### Git Workflow
- **`main`** - Development branch
- **`production`** - Deployment branch (triggers auto-deploy)
- **`feature/*`** - Feature branches (merge to main, then delete)

### Frontend (Vercel)
1. Connect GitHub repo to Vercel
2. Set root directory to `apps/web`
3. Auto-deploy from `production` branch

### Backend (Fly.io)
1. Install [Fly CLI](https://fly.io/docs/hands-on/install-flyctl/)
2. Set secrets: `flyctl secrets set SUPABASE_URL="..." SUPABASE_SERVICE_ROLE_KEY="..." CORS_ORIGIN="https://your-app.vercel.app"`
3. Deploy: `flyctl deploy`

## 🚧 Development Roadmap

**✅ Phase 1**: Table creation and viewing  
**✅ Phase 2**: Live collaborative editing with Socket.IO  
**✅ Phase 3**: Admin controls, row/column management, header width config, and today date highlighting  
**📊 Phase 4**: CSV import/export  
**💾 Phase 5**: Snapshots and backup/restore  
**✨ Phase 6**: Comments, sharing, polish

## 🔧 Environment Variables

### Backend (`apps/api/.env`)
| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `SUPABASE_URL` | ✅ | Supabase project URL | - |
| `SUPABASE_SERVICE_ROLE_KEY` | ✅ | Supabase service role key | - |
| `CORS_ORIGIN` | ✅ | Frontend URL for CORS | `http://localhost:3000` |
| `TABLE_ROW_LIMIT` | | Maximum rows per table | `500` |
| `TABLE_COL_LIMIT` | | Maximum columns per table | `64` |
| `CSV_DELIMITER` | | CSV export delimiter | `;` |
| `CSV_MAX_MB` | | CSV import size limit | `5` |
| `ALLOW_EDITOR_EXPORT` | | Allow editors to export | `false` |
| `ALLOW_EDITOR_IMPORT` | | Allow editors to import | `false` |

### Frontend (`apps/web/.env.local`)
| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `NEXT_PUBLIC_API_URL` | | Backend API URL | `http://localhost:8000` |

## 🔄 Development Workflow

1. Create feature branch: `git checkout -b feature/feature-name`
2. Develop and test locally
3. Merge to `main`, delete feature branch
4. When stable: merge `main` → `production` (triggers deployment)

## 📚 Documentation

- **[docs/](./docs/)** - Technical implementation details and phases
- **[CLAUDE.md](./CLAUDE.md)** - AI assistant guidance and architecture

## 🔒 Key Security Notes

- Token-based authentication (no cookies)
- SHA-256 hashed tokens in database (never log raw tokens)
- All database access through FastAPI (no direct client access)
- Role-based permissions: Admin/Editor only