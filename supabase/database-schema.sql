-- Online Table Lite - Complete Database Schema
-- This file represents the complete database schema for both development and production
-- Run this in Supabase SQL Editor to create the full schema
-- For setup/updates, use setup.sql instead (it handles both creation and updates)

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tables table - stores table metadata
CREATE TABLE IF NOT EXISTS tables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT NOT NULL UNIQUE,
    title TEXT,
    description TEXT,
    cols INT4 NOT NULL DEFAULT 4,
    rows INT4 NOT NULL DEFAULT 10,
    edit_token_hash TEXT NOT NULL,
    admin_token_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    fixed_rows BOOLEAN NOT NULL DEFAULT false
);

-- Create index on slug for fast lookups
CREATE INDEX IF NOT EXISTS idx_tables_slug ON tables(slug);
CREATE INDEX IF NOT EXISTS idx_tables_created_at ON tables(created_at);

-- Columns table - stores column configuration
CREATE TABLE IF NOT EXISTS columns (
    id INT8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    idx INT4 NOT NULL,
    header TEXT,
    width INT4,
    format TEXT NOT NULL DEFAULT 'text'
);

-- Add constraint for column format
ALTER TABLE columns 
DROP CONSTRAINT IF EXISTS columns_format_check;

ALTER TABLE columns 
ADD CONSTRAINT columns_format_check 
CHECK (format IN ('text', 'date', 'timerange'));

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_columns_table_id ON columns(table_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_columns_table_id_idx ON columns(table_id, idx);

-- Cells table - stores cell data
CREATE TABLE IF NOT EXISTS cells (
    id INT8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    r INT4 NOT NULL,
    c INT4 NOT NULL,
    value TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by TEXT
);

-- Create indexes for cells
CREATE INDEX IF NOT EXISTS idx_cells_table_id ON cells(table_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_cells_table_id_r_c ON cells(table_id, r, c);
CREATE INDEX IF NOT EXISTS idx_cells_updated_at ON cells(updated_at);

-- Comments table - stores comments/notes
CREATE TABLE IF NOT EXISTS comments (
    id INT8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_hash TEXT
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_comments_table_id ON comments(table_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at);

-- Snapshots table - stores table snapshots/backups
CREATE TABLE IF NOT EXISTS snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    note TEXT,
    data JSONB NOT NULL
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_snapshots_table_id ON snapshots(table_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_created_at ON snapshots(created_at);

-- App configuration table - stores translatable application content only
-- NOTE: Non-translatable configuration (like table defaults) is handled by JSON files
CREATE TABLE IF NOT EXISTS app_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(255) NOT NULL UNIQUE,
    value_en TEXT,
    value_de TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_app_config_key ON app_config(key);

-- Row Level Security (RLS) Policies
-- Enable RLS on all tables
ALTER TABLE tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE columns ENABLE ROW LEVEL SECURITY;
ALTER TABLE cells ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Tables policies
CREATE POLICY IF NOT EXISTS "Tables are viewable by everyone" ON tables
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Tables are insertable by everyone" ON tables
    FOR INSERT WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "Tables are updatable by everyone" ON tables
    FOR UPDATE USING (true);

-- Columns policies
CREATE POLICY IF NOT EXISTS "Columns are viewable by everyone" ON columns
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Columns are insertable by everyone" ON columns
    FOR INSERT WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "Columns are updatable by everyone" ON columns
    FOR UPDATE USING (true);

CREATE POLICY IF NOT EXISTS "Columns are deletable by everyone" ON columns
    FOR DELETE USING (true);

-- Cells policies
CREATE POLICY IF NOT EXISTS "Cells are viewable by everyone" ON cells
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Cells are insertable by everyone" ON cells
    FOR INSERT WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "Cells are updatable by everyone" ON cells
    FOR UPDATE USING (true);

CREATE POLICY IF NOT EXISTS "Cells are deletable by everyone" ON cells
    FOR DELETE USING (true);

-- Comments policies
CREATE POLICY IF NOT EXISTS "Comments are viewable by everyone" ON comments
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Comments are insertable by everyone" ON comments
    FOR INSERT WITH CHECK (true);

-- Snapshots policies
CREATE POLICY IF NOT EXISTS "Snapshots are viewable by everyone" ON snapshots
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Snapshots are insertable by everyone" ON snapshots
    FOR INSERT WITH CHECK (true);

-- App config policies
CREATE POLICY IF NOT EXISTS "App config is viewable by everyone" ON app_config
    FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "App config is insertable by everyone" ON app_config
    FOR INSERT WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "App config is updatable by everyone" ON app_config
    FOR UPDATE USING (true);

-- Functions and Triggers
-- Update updated_at timestamp automatically
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
DROP TRIGGER IF EXISTS update_tables_updated_at ON tables;
CREATE TRIGGER update_tables_updated_at
    BEFORE UPDATE ON tables
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_cells_updated_at ON cells;
CREATE TRIGGER update_cells_updated_at
    BEFORE UPDATE ON cells
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_app_config_updated_at ON app_config;
CREATE TRIGGER update_app_config_updated_at
    BEFORE UPDATE ON app_config
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Update last_activity_at when tables are accessed
CREATE OR REPLACE FUNCTION update_table_activity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE tables SET last_activity_at = NOW() WHERE id = NEW.table_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to update activity when cells are modified
DROP TRIGGER IF EXISTS update_table_activity_on_cell_change ON cells;
CREATE TRIGGER update_table_activity_on_cell_change
    AFTER INSERT OR UPDATE ON cells
    FOR EACH ROW EXECUTE FUNCTION update_table_activity();

-- Initial seed data for translatable app configuration only
-- NOTE: Table defaults and other non-translatable config is in JSON files
INSERT INTO app_config (key, value_en, value_de) VALUES
    ('app.title', 'Online Tables Lite', 'Online Tabellen Lite'),
    ('app.description', 'Collaborative table editing application', 'App um gemeinsam Tabellen zu erstellen und zu bearbeiten')
ON CONFLICT (key) DO NOTHING;