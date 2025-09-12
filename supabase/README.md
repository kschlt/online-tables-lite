# Database Setup

This folder contains the database schema and setup scripts for Online Table Lite.

## Files

- **`database-schema.sql`** - **🎯 SINGLE SOURCE OF TRUTH** - Complete schema definition
- **`setup.sql`** - Smart script to create/update database to match the schema

## How to Use

### 🚀 Always Use setup.sql

**Run `setup.sql` in Supabase SQL Editor** - it ensures your database matches the schema:

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

The `setup.sql` script is safe to run multiple times - it automatically detects existing data and preserves it while updating the schema to match `database-schema.sql`.

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

## Architecture

**`database-schema.sql`**: The definitive schema - what the database should look like  
**`setup.sql`**: Implementation script - makes the database match the schema safely  

**Data Storage**:
- **Database**: Only translatable content (app title, description)
- **JSON Files**: Configuration settings (table defaults, language settings)

This separation keeps the database focused and configuration management simple.