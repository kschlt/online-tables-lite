# Online Tables Lite

A collaborative table editing application with real-time synchronization and internationalization support. Create and share editable tables with secure token-based access control.

## �� Features

- **Real-time Collaboration**: Multiple users can edit tables simultaneously with live updates
- **Internationalization**: Full English/German language support with dynamic language switching
- **Admin Controls**: Configure table settings, add/remove rows and columns
- **Token-based Security**: Secure access control with admin and editor tokens
- **Responsive Design**: Modern UI with Tailwind CSS and Radix UI components
- **Date Formatting**: Special date column formatting with today's date insertion
- **Column Management**: Configurable column widths and data types

## 🚀 Roadmap

- **CSV Import/Export**: Import data from CSV files and export tables to CSV
- **Snapshots and Backup**: Save table states and restore previous versions
- **Comments System**: Add comments to cells for collaboration
- **Advanced Sharing**: Public links and user management
- **Data Validation**: Cell-level validation rules
- **Charts and Analytics**: Visualize table data with charts

## 🏗️ Tech Stack

- **Frontend**: Next.js 15 + TypeScript + Tailwind CSS + Radix UI
- **Backend**: FastAPI + Socket.IO + Pydantic v2  
- **Database**: Supabase Postgres
- **Internationalization**: next-intl
- **Deployment**: Vercel (frontend) + Fly.io (backend) via GitHub Actions

## 🚀 Quick Start

### Prerequisites
- Node.js 22+ and npm
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

### 5. Development Commands
```bash
# Start both frontend and backend
make dev-all

# Start only frontend
make dev-frontend

# Start only backend  
make dev-backend

# Stop all services
make stop

# Install all dependencies
make install-all
```

### 6. Test the Application
1. Visit: `http://localhost:3000/en` (English) or `http://localhost:3000/de` (German)
2. Create a table with title, description, columns, and rows
3. Use the returned admin token to configure table settings
4. Use the editor token to edit table content in real-time
5. Switch languages using the language switcher in the top-right

## 🌍 Internationalization

The application supports English and German with:
- **Dynamic Language Switching**: Toggle between languages without page reload
- **Complete Translation Coverage**: All UI elements translated
- **URL-based Locales**: `/en` for English, `/de` for German

## 🔧 Environment Variables

### Backend (`apps/api/.env`)
| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `SUPABASE_URL` | ✅ | Supabase project URL | - |
| `SUPABASE_SERVICE_ROLE_KEY` | ✅ | Supabase service role key | - |
| `CORS_ORIGIN` | ✅ | Frontend URL for CORS | `http://localhost:3000` |
| `TABLE_ROW_LIMIT` | | Maximum rows per table | `500` |
| `TABLE_COL_LIMIT` | | Maximum columns per table | `64` |

### Frontend (`apps/web/.env.local`)
| Variable | Required | Description | Default |
|----------|----------|-------------|---------|
| `NEXT_PUBLIC_API_URL` | | Backend API URL | `http://localhost:8000` |

## 🌍 Deployment

### Git Workflow
- **`main`** - Development branch
- **`production`** - Deployment branch (triggers auto-deploy)
- **`feature/*`** - Feature branches (merge to main, then delete)

### GitHub Actions CI/CD
The application uses GitHub Actions for automated deployment:

1. **Frontend (Vercel)**: 
   - Deploys via GitHub Actions workflow using Vercel CLI
   - Uses Vercel project secrets stored in GitHub repository settings
   - Triggers on `production` branch updates

2. **Backend (Fly.io)**:
   - Deploys via GitHub Actions workflow using Fly.io CLI
   - Uses Fly.io secrets stored in GitHub repository settings
   - Triggers on `production` branch updates

### Required GitHub Secrets
Configure these secrets in your GitHub repository settings:

**For Vercel (Frontend)**:
- `VERCEL_TOKEN` - Vercel API token
- `VERCEL_PROJECT_ID` - Vercel project ID
- `VERCEL_TEAM_ID` - Vercel team ID

**For Fly.io (Backend)**:
- `FLY_API_TOKEN` - Fly.io API token
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key
- `CORS_ORIGIN` - Frontend URL for CORS

## 🔄 Development Workflow

1. Create feature branch: `git checkout -b feature/feature-name`
2. Develop and test locally
3. Merge to `main`, delete feature branch
4. When stable: merge `main` → `production` (triggers deployment)

## 📚 Documentation

- **[docs/](./docs/)** - Technical implementation details and phases
- **[CLAUDE.md](./CLAUDE.md)** - AI assistant guidance and architecture
- **[apps/web/DESIGN_SYSTEM.md](./apps/web/DESIGN_SYSTEM.md)** - UI component design system

## Key Security Notes

- Token-based authentication (no cookies)
- SHA-256 hashed tokens in database (never log raw tokens)
- All database access through FastAPI (no direct client access)
- Role-based permissions: Admin/Editor only
- CORS protection for API endpoints

## Tech Details

### Frontend Architecture
- **Next.js 15** with App Router
- **TypeScript** for type safety
- **Tailwind CSS** for styling
- **Radix UI** for accessible components
- **next-intl** for internationalization
- **Socket.IO Client** for real-time updates

### Backend Architecture  
- **FastAPI** for REST API
- **Socket.IO** for real-time communication
- **SQLAlchemy** for database ORM
- **Pydantic v2** for data validation
- **Supabase** for PostgreSQL database