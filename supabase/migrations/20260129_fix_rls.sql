-- Allow public read of approved signals
DROP POLICY IF EXISTS "Allow public read access to approved signals" ON signals;

CREATE POLICY "Allow public read access to approved signals"
  ON signals
  FOR SELECT
  USING (status = 'approved');
