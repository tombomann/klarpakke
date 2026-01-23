#!/bin/bash
echo "🔍 Testing Supabase connection..."

# Hvis du har .env.migration med riktig passord
if [[ -f .env.migration ]]; then
  source .env.migration
  echo "Loaded .env.migration"
else
  echo "❌ .env.migration not found"
  echo "Create it with: nano .env.migration"
  exit 1
fi

# Test connection
if psql "$SUPABASE_DB_URL" -c "SELECT version();" 2>&1 | grep -q "PostgreSQL"; then
  echo "✅ Connection OK!"
else
  echo "❌ Connection failed!"
  echo "Fix password in .env.migration"
fi
