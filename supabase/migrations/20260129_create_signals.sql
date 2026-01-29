CREATE TABLE IF NOT EXISTS signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol TEXT NOT NULL,
  direction TEXT NOT NULL CHECK (direction IN ('LONG', 'SHORT')),
  confidence DECIMAL(3,2) CHECK (confidence >= 0 AND confidence <= 1),
  reason TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE signals ENABLE ROW LEVEL SECURITY;

-- Allow public read access to approved signals
CREATE POLICY "Allow public read access to approved signals"
  ON signals
  FOR SELECT
  USING (status = 'approved');

-- Allow authenticated users to insert/update
CREATE POLICY "Allow authenticated insert"
  ON signals
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Allow authenticated update"
  ON signals
  FOR UPDATE
  TO authenticated
  USING (true);
