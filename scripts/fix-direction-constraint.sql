-- Fix aisignal direction constraint to be case-insensitive
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new

-- 1. Check existing constraint
SELECT 
  conname, 
  pg_get_constraintdef(oid) as definition
FROM pg_constraint 
WHERE conrelid = 'aisignal'::regclass 
  AND conname = 'aisignal_direction_check';

-- 2. Drop old constraint
ALTER TABLE aisignal 
DROP CONSTRAINT IF EXISTS aisignal_direction_check;

-- 3. Add new case-insensitive constraint (UPPER function)
ALTER TABLE aisignal 
ADD CONSTRAINT aisignal_direction_check 
CHECK (UPPER(direction) IN ('LONG', 'SHORT'));

-- 4. Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';

-- 5. Test insert
INSERT INTO aisignal (
  symbol, 
  direction, 
  entry_price, 
  stop_loss, 
  take_profit, 
  confidence, 
  status
) VALUES (
  'BTCUSDT', 
  'LONG', 
  50000, 
  48000, 
  52000, 
  0.85, 
  'pending'
)
ON CONFLICT DO NOTHING
RETURNING id, symbol, direction, status, confidence, created_at;

-- 6. Verify all signals
SELECT 
  id, 
  symbol, 
  direction, 
  entry_price, 
  confidence, 
  status, 
  created_at
FROM aisignal 
ORDER BY created_at DESC 
LIMIT 10;

-- 7. Test that both LONG and long work
INSERT INTO aisignal (symbol, direction, entry_price, stop_loss, take_profit, confidence, status)
VALUES ('ETHUSDT', 'long', 3000, 2900, 3100, 0.80, 'pending')
ON CONFLICT DO NOTHING
RETURNING id, symbol, direction;

-- Both should work now!
