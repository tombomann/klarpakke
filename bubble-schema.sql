-- Copy to Bubble Data → AICallLog type fields
-- Or psql when URL ready
CREATE TABLE IF NOT EXISTS AICallLog (
  id SERIAL PRIMARY KEY,
  pair TEXT NOT NULL,
  signal TEXT,
  confidence INTEGER DEFAULT 85,
  created_at TIMESTAMP DEFAULT NOW()
);
