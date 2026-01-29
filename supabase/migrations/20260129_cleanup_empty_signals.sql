-- Migration: Cleanup empty signals and add validation
-- Date: 2026-01-29
-- Description: Remove signals with empty symbols and add constraint

-- 1. Remove signals with empty or null symbols
DELETE FROM signals 
WHERE symbol IS NULL OR symbol = '' OR TRIM(symbol) = '';

-- 2. Add constraint to prevent future empty symbols
ALTER TABLE signals 
ADD CONSTRAINT signals_symbol_not_empty 
CHECK (symbol IS NOT NULL AND symbol <> '' AND TRIM(symbol) <> '');

-- 3. Add index for better performance
CREATE INDEX IF NOT EXISTS idx_signals_symbol ON signals(symbol);
CREATE INDEX IF NOT EXISTS idx_signals_status ON signals(status);
CREATE INDEX IF NOT EXISTS idx_signals_created_at ON signals(created_at DESC);

-- 4. Log cleanup
DO $$
DECLARE
  deleted_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO deleted_count FROM signals WHERE symbol IS NULL OR symbol = '';
  RAISE NOTICE 'Cleanup complete. Would have deleted % signals with empty symbols.', deleted_count;
END $$;
