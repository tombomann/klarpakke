#!/bin/bash
# Direct SQL deployment using psql (bypass Supabase CLI)
# Usage: bash scripts/direct-sql-deploy.sh

set -euo pipefail

echo "🔧 Direct SQL Deployment (bypass CLI)"
echo "====================================="
echo ""

# Load env
if [ -f ".env" ]; then
    source .env
else
    echo "❌ .env not found. Run: bash scripts/auto-setup-env.sh"
    exit 1
fi

# Check for required vars
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_SECRET_KEY:-}" ]; then
    echo "❌ Missing SUPABASE_URL or SUPABASE_SECRET_KEY in .env"
    exit 1
fi

PROJECT_REF="${SUPABASE_PROJECT_REF:-swfyuwkptusceiouqlks}"
MIGRATIONS_DIR="supabase/migrations"

echo "📋 Deploying to: $SUPABASE_URL"
echo ""

# Check for migrations
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo "❌ Migrations directory not found: $MIGRATIONS_DIR"
    exit 1
fi

MIGRATIONS=("$MIGRATIONS_DIR"/*.sql)
if [ ! -f "${MIGRATIONS[0]}" ]; then
    echo "❌ No .sql files found in $MIGRATIONS_DIR"
    exit 1
fi

echo "📁 Found migrations:"
for migration in "${MIGRATIONS[@]}"; do
    echo "  - $(basename "$migration")"
done
echo ""

read -p "Deploy these migrations? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 0
fi

echo ""
echo "📤 Deploying migrations..."
echo ""

# Method 1: Try psql if available
if command -v psql &> /dev/null; then
    echo "Using psql..."
    
    # Extract connection details
    # Format: postgres://[user]:[password]@[host]:[port]/[database]
    
    read -p "Enter database password (from Supabase Settings > Database): " -s DB_PASSWORD
    echo ""
    
    DB_HOST="db.${PROJECT_REF}.supabase.co"
    DB_USER="postgres"
    DB_NAME="postgres"
    DB_PORT="5432"
    
    export PGPASSWORD="$DB_PASSWORD"
    
    for migration in "${MIGRATIONS[@]}"; do
        echo "Executing: $(basename "$migration")"
        
        if psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -p "$DB_PORT" -f "$migration"; then
            echo "  ✅ Success"
        else
            echo "  ❌ Failed"
            exit 1
        fi
    done
    
    unset PGPASSWORD
    
else
    # Method 2: Manual SQL editor
    echo "⚠️  psql not found. Manual deployment required."
    echo ""
    echo "Follow these steps:"
    echo ""
    echo "1. Open Supabase SQL Editor:"
    echo "   https://supabase.com/dashboard/project/$PROJECT_REF/editor"
    echo ""
    echo "2. Copy and run each migration:"
    echo ""
    
    for migration in "${MIGRATIONS[@]}"; do
        echo "=" File: $(basename "$migration") "="
        echo ""
        cat "$migration"
        echo ""
        echo "========================================"
        echo ""
    done
    
    echo "3. Verify tables exist:"
    echo "   SELECT tablename FROM pg_tables WHERE schemaname = 'public';"
    echo ""
fi

echo "✅ Deployment instructions complete"
echo ""
echo "Verify in Supabase Studio:"
echo "  https://supabase.com/dashboard/project/$PROJECT_REF/editor"
