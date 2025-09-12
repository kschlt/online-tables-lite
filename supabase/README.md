# Database Setup

This folder contains the database schema and setup scripts for Online Table Lite.

## Files

- **`setup.sql`** - **🎯 SINGLE SOURCE OF TRUTH** - Smart script for all database operations
- **`database-schema.sql`** - Reference schema file (for documentation)

## How to Use

### 🚀 One Script to Rule Them All

**Always use `setup.sql`** - it's smart enough to handle both scenarios:

**Fresh Database:**
- ✅ Creates all tables, indexes, policies, triggers
- ✅ Inserts default values ("Online Tables Lite", "Collaborative table editing application")
- ✅ Shows "Fresh database detected" message

**Existing Database (Production):**
- ✅ Updates schema (new tables, indexes, constraints)
- ✅ **Preserves ALL your existing data** (titles, descriptions, user content)
- ✅ Shows "Existing database detected - preserving your current values"
- ✅ Only removes deprecated config keys (moved to JSON)

### 🔒 Production Safety

```sql
-- This script is SAFE to run multiple times on production
-- It automatically detects if app_config has data and preserves it
-- No more worrying about overwriting your custom titles/descriptions!
```

## What's in the Database

### Core Tables
- `tables` - Table metadata (title, slug, tokens, etc.)
- `columns` - Column definitions for each table
- `cells` - Cell data (row, column, value)
- `comments` - Comments/notes on tables
- `snapshots` - Table backups/history

### Configuration
- `app_config` - **Only translatable content** (app title, description)
- Table defaults (rows, columns, default language) are stored in JSON config files, not the database

## Architecture Decision

**Database**: Only stores translatable content that needs multi-language support
**JSON Files**: Stores configuration settings that don't need translation

This keeps the database focused and makes configuration management simpler.