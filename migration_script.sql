-- Migration script to add format field and fixed_rows support

-- Add fixed_rows column to tables
ALTER TABLE public.tables ADD COLUMN fixed_rows boolean DEFAULT false;

-- Add format column to columns table and drop today_hint
ALTER TABLE public.columns ADD COLUMN format text DEFAULT 'text';

-- Migrate existing today_hint data to format
UPDATE public.columns SET format = 'date' WHERE today_hint = true;

-- Drop the old today_hint column
ALTER TABLE public.columns DROP COLUMN today_hint;

-- Add check constraint for format values
ALTER TABLE public.columns ADD CONSTRAINT columns_format_check CHECK (format IN ('text', 'date'));
