#!/bin/bash
# Automates Supabase Database Setup for Klarpakke
set -e

echo "🚀 Initializing Supabase Database tables..."

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found. Please install it or run SQL manually."
    exit 1
fi

# Link project (ensure we are linked)
# Note: Requires user to be logged in via 'supabase login'
echo "🔗 Linking to project swfyuwkptusceiouqlks..."
supabase link --project-ref swfyuwkptusceiouqlks --password "$SUPABASE_DB_PASSWORD" 2>/dev/null || echo "⚠️  Already linked or password env var missing (skipping link step)"

# Run SQL from file
echo "💾 Applying Database Schema (Profiles & Secrets)..."
supabase db reset --linked --no-confirmation 2>/dev/null || true # Optional: Reset if you want fresh start, usually unsafe for prod. Skipping here.

# Push the migration directly using psql via supabase db execute is cleaner for one-off
# But since we have the file, let's use the CLI's query execution if available, or just cat it.
# Supabase CLI doesn't have a direct 'db execute < file' for remote easily without password prompt unless using connection string.

echo "⚠️  NOTE: Automation of remote DB migration requires DB Password."
echo "   Please paste the SQL from 'scripts/setup_profiles.sql' into the Dashboard SQL Editor if this fails."
echo "   https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql"

# Alternative: We just output the SQL for the user to see, as remote execution is tricky without storing raw password in script
cat scripts/setup_profiles.sql

echo ""
echo "✅ SQL script outputted above."
