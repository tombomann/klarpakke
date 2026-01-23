-- Migration: Add trading analysis fields to aisignal table
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new

-- Add trading price fields
ALTER TABLE aisignal 
ADD COLUMN IF NOT EXISTS entry_price NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS stop_loss NUMERIC(18,8),
ADD COLUMN IF NOT EXISTS take_profit NUMERIC(18,8);

-- Add approval/rejection tracking fields
ALTER TABLE aisignal 
ADD COLUMN IF NOT EXISTS approved_by TEXT,
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS rejected_by TEXT,
ADD COLUMN IF NOT EXISTS rejected_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS reasoning TEXT;

-- Add index for faster queries
CREATE INDEX IF NOT EXISTS idx_aisignal_status ON aisignal(status);
CREATE INDEX IF NOT EXISTS idx_aisignal_created_at ON aisignal(created_at DESC);

-- Verify columns exist
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_schema = 'public' 
  AND table_name = 'aisignal'
ORDER BY ordinal_position;
