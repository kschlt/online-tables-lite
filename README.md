# Online Tables Lite

A collaborative table editing application with real-time synchronization. Create and share editable tables with secure token-based access control.

## ✨ Features

- **Real-time Collaboration**: Live editing with Socket.IO synchronization
- **Secure Access**: Token-based authentication with admin/editor roles  
- **Mobile-First Design**: Responsive interface optimized for all devices
- **Phase-based Development**: Currently in Phase 1 (Create & Read)

## 🏗️ Architecture

**Monorepo Structure:**
- `apps/web` - Next.js frontend (App Router + Tailwind + TypeScript)
- `apps/api` - FastAPI backend with Socket.IO for real-time updates
- `docs/` - Technical documentation and implementation phases

**Technology Stack:**
- **Frontend**: Next.js 15, TypeScript, Tailwind CSS, Socket.IO Client
- **Backend**: FastAPI, Python 3.12, Socket.IO, Pydantic v2
- **Database**: Supabase Postgres (server-only access)
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
1. Create a table: `POST http://localhost:8000/api/table`
2. Use the returned tokens to view: `http://localhost:3000/table/{slug}?t={token}`

## 🌍 Deployment

### Production Deployment

The project uses a 3-branch strategy:
- **`main`** - Development branch (working branch, can break)
- **`production`** - Stable deployment branch (triggers deploys)
- **`feature/*`** - Short-lived feature branches

### Frontend (Vercel)
1. Connect your Vercel account to the GitHub repository
2. Set root directory to `apps/web`
3. Configure auto-deploy from `production` branch
4. Environment variables: (none required for basic setup)

### Backend (Fly.io)
1. Install [Fly CLI](https://fly.io/docs/hands-on/install-flyctl/)
2. Login: `flyctl auth login`
3. Set secrets:
```bash
cd apps/api
flyctl secrets set SUPABASE_URL="https://your-project.supabase.co"
flyctl secrets set SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
flyctl secrets set CORS_ORIGIN="https://your-vercel-app.vercel.app"
```
4. Deploy: `flyctl deploy`

**GitHub Actions**: Automated deployment from `production` branch is configured.

## 📋 Current Status

**✅ Phase 0 & 1 Complete:**
- Monorepo setup with FastAPI + Next.js
- Token-based authentication with SHA-256 hashing
- Basic table creation and viewing
- Read-only table interface with headers

**🚧 Coming Next (Phase 2):**
- Live collaborative editing
- Real-time cell updates with Socket.IO
- Optimistic UI updates

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

### Working with Features
1. **Create feature branch**: `git checkout -b feature/your-feature-name`
2. **Develop and test** locally in the feature branch
3. **When complete**: 
   - Test thoroughly
   - Merge to `main`: `git checkout main && git merge feature/your-feature-name`
   - Delete feature branch: `git branch -d feature/your-feature-name`
4. **Test `main`** branch locally and on development servers
5. **Deploy to production**: `git checkout production && git merge main && git push origin production`

### Key Principles
- Keep features small and focused
- Test thoroughly before merging to `main`
- Only merge stable, working code to `production`
- Delete feature branches after merging

## 📚 Documentation

- **[CLAUDE.md](./CLAUDE.md)** - AI assistant guidance and project overview
- **[docs/CLAUDE_TASKS.md](./docs/CLAUDE_TASKS.md)** - Phased implementation plan
- **[docs/TECHNOTES.md](./docs/TECHNOTES.md)** - Technical implementation details
- **[docs/CI-DI.md](./docs/CI-DI.md)** - Deployment configuration

## 🔒 Security

- Raw tokens in URLs, SHA-256 hashes stored in database
- No direct client-to-database access (all through FastAPI)
- CORS properly configured
- No raw token logging
- Role-based permissions (Admin/Editor only)

## 🛠️ Development Commands

### Backend
```bash
cd apps/api
python main.py              # Start development server
pip install -r requirements.txt  # Install dependencies
```

### Frontend  
```bash
cd apps/web
npm run dev                 # Start development server
npm run build              # Build for production
npm run lint               # Run ESLint
npm run typecheck          # Run TypeScript checks
```

## 📦 Project Structure

```
online-tables-lite/
├── apps/
│   ├── api/              # FastAPI backend
│   │   ├── main.py       # Main application file
│   │   ├── requirements.txt
│   │   ├── Dockerfile    # Fly.io deployment
│   │   └── fly.toml      # Fly.io configuration
│   └── web/              # Next.js frontend  
│       ├── src/app/      # App Router pages
│       ├── package.json
│       └── tailwind.config.ts
├── docs/                 # Technical documentation
├── .github/workflows/    # CI/CD automation
├── CLAUDE.md            # AI assistant guidance
└── README.md            # This file
```

## 🎯 Roadmap

The project follows a 6-phase implementation plan:

1. **✅ Bootstrap & Create/Read** - Basic setup and viewing
2. **🚧 Edit + Realtime** - Live collaborative editing  
3. **📋 Admin Config** - Table configuration and limits
4. **📊 CSV Import/Export** - Data exchange features
5. **💾 Snapshots** - Table state backup/restore
6. **✨ Polish** - Comments, sharing, accessibility

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test locally
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to your branch: `git push origin feature/amazing-feature`
6. Open a Pull Request to `main`

## 📄 License

This project is private and proprietary.