-- Online Table Lite Database Setup
-- Date: 2025-09-12

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

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

CREATE TABLE IF NOT EXISTS columns (
    id INT8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    idx INT4 NOT NULL,
    header TEXT,
    width INT4,
    format TEXT NOT NULL DEFAULT 'text'
);

CREATE TABLE IF NOT EXISTS cells (
    id INT8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    r INT4 NOT NULL,
    c INT4 NOT NULL,
    value TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_by TEXT
);

CREATE TABLE IF NOT EXISTS comments (
    id INT8 PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ip_hash TEXT
);

CREATE TABLE IF NOT EXISTS snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_id UUID NOT NULL REFERENCES tables(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    note TEXT,
    data JSONB NOT NULL
);

CREATE TABLE IF NOT EXISTS app_config (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(255) NOT NULL UNIQUE,
    value_en TEXT,
    value_de TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Constraints and indexes
DO $$ BEGIN
    ALTER TABLE columns DROP CONSTRAINT IF EXISTS columns_format_check;
    ALTER TABLE columns ADD CONSTRAINT columns_format_check 
        CHECK (format IN ('text', 'date', 'timerange'));
EXCEPTION
    WHEN others THEN NULL;
END $$;

CREATE INDEX IF NOT EXISTS idx_tables_slug ON tables(slug);
CREATE INDEX IF NOT EXISTS idx_tables_created_at ON tables(created_at);

CREATE INDEX IF NOT EXISTS idx_columns_table_id ON columns(table_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_columns_table_id_idx ON columns(table_id, idx);

CREATE INDEX IF NOT EXISTS idx_cells_table_id ON cells(table_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_cells_table_id_r_c ON cells(table_id, r, c);
CREATE INDEX IF NOT EXISTS idx_cells_updated_at ON cells(updated_at);

CREATE INDEX IF NOT EXISTS idx_comments_table_id ON comments(table_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at);

CREATE INDEX IF NOT EXISTS idx_snapshots_table_id ON snapshots(table_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_created_at ON snapshots(created_at);

CREATE INDEX IF NOT EXISTS idx_app_config_key ON app_config(key);

-- Row Level Security
ALTER TABLE tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE columns ENABLE ROW LEVEL SECURITY;
ALTER TABLE cells ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Tables are viewable by everyone" ON tables;
DROP POLICY IF EXISTS "Tables are insertable by everyone" ON tables;
DROP POLICY IF EXISTS "Tables are updatable by everyone" ON tables;

CREATE POLICY "Tables are viewable by everyone" ON tables FOR SELECT USING (true);
CREATE POLICY "Tables are insertable by everyone" ON tables FOR INSERT WITH CHECK (true);
CREATE POLICY "Tables are updatable by everyone" ON tables FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Columns are viewable by everyone" ON columns;
DROP POLICY IF EXISTS "Columns are insertable by everyone" ON columns;
DROP POLICY IF EXISTS "Columns are updatable by everyone" ON columns;
DROP POLICY IF EXISTS "Columns are deletable by everyone" ON columns;

CREATE POLICY "Columns are viewable by everyone" ON columns FOR SELECT USING (true);
CREATE POLICY "Columns are insertable by everyone" ON columns FOR INSERT WITH CHECK (true);
CREATE POLICY "Columns are updatable by everyone" ON columns FOR UPDATE USING (true);
CREATE POLICY "Columns are deletable by everyone" ON columns FOR DELETE USING (true);

DROP POLICY IF EXISTS "Cells are viewable by everyone" ON cells;
DROP POLICY IF EXISTS "Cells are insertable by everyone" ON cells;
DROP POLICY IF EXISTS "Cells are updatable by everyone" ON cells;
DROP POLICY IF EXISTS "Cells are deletable by everyone" ON cells;

CREATE POLICY "Cells are viewable by everyone" ON cells FOR SELECT USING (true);
CREATE POLICY "Cells are insertable by everyone" ON cells FOR INSERT WITH CHECK (true);
CREATE POLICY "Cells are updatable by everyone" ON cells FOR UPDATE USING (true);
CREATE POLICY "Cells are deletable by everyone" ON cells FOR DELETE USING (true);

DROP POLICY IF EXISTS "Comments are viewable by everyone" ON comments;
DROP POLICY IF EXISTS "Comments are insertable by everyone" ON comments;

CREATE POLICY "Comments are viewable by everyone" ON comments FOR SELECT USING (true);
CREATE POLICY "Comments are insertable by everyone" ON comments FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Snapshots are viewable by everyone" ON snapshots;
DROP POLICY IF EXISTS "Snapshots are insertable by everyone" ON snapshots;

CREATE POLICY "Snapshots are viewable by everyone" ON snapshots FOR SELECT USING (true);
CREATE POLICY "Snapshots are insertable by everyone" ON snapshots FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "App config is viewable by everyone" ON app_config;
DROP POLICY IF EXISTS "App config is insertable by everyone" ON app_config;
DROP POLICY IF EXISTS "App config is updatable by everyone" ON app_config;

CREATE POLICY "App config is viewable by everyone" ON app_config FOR SELECT USING (true);
CREATE POLICY "App config is insertable by everyone" ON app_config FOR INSERT WITH CHECK (true);
CREATE POLICY "App config is updatable by everyone" ON app_config FOR UPDATE USING (true);

-- Functions and triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

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

CREATE OR REPLACE FUNCTION update_table_activity()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE tables SET last_activity_at = NOW() WHERE id = NEW.table_id;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_table_activity_on_cell_change ON cells;
CREATE TRIGGER update_table_activity_on_cell_change
    AFTER INSERT OR UPDATE ON cells
    FOR EACH ROW EXECUTE FUNCTION update_table_activity();

-- Data cleanup and seeding
-- SAFE: Remove only deprecated keys that were moved to JSON config files
-- This will NOT delete app.title or app.description (your custom values)
DELETE FROM app_config WHERE key IN (
    'table.default_columns',
    'table.default_rows', 
    'table.default_cols',
    'app.default_language'
);

-- Only insert defaults if app_config is empty (fresh database)
DO $$ 
DECLARE
    config_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO config_count FROM app_config;
    
    IF config_count = 0 THEN
        INSERT INTO app_config (key, value_en, value_de) VALUES
            ('app.title', 'Online Tables Lite', 'Online Tabellen Lite'),
            ('app.description', 'Collaborative table editing application', 'App um gemeinsam Tabellen zu erstellen und zu bearbeiten');
        
        RAISE NOTICE 'Fresh database: inserted default values';
    ELSE
        RAISE NOTICE 'Existing database: preserving values (count: %)', config_count;
    END IF;
END $$;

-- Verification
SELECT 'Setup complete. App config:' as status;
SELECT key, value_en, value_de, updated_at FROM app_config ORDER BY key;