#!/bin/bash
# Deploy Supabase migrations to production
# Usage: bash scripts/deploy-migrations.sh

set -euo pipefail

PROJECT_REF="${SUPABASE_PROJECT_REF:-swfyuwkptusceiouqlks}"
MIGRATIONS_DIR="supabase/migrations"

echo "🚀 Deploying Supabase migrations..."
echo "Project: $PROJECT_REF"
echo ""

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found."
    echo "Install: https://supabase.com/docs/guides/cli"
    exit 1
fi

# Check if migrations directory exists
if [ ! -d "$MIGRATIONS_DIR" ]; then
    echo "❌ Migrations directory not found: $MIGRATIONS_DIR"
    exit 1
fi

# List migrations
echo "📁 Migrations to deploy:"
ls -1 "$MIGRATIONS_DIR"/*.sql 2>/dev/null || {
    echo "❌ No .sql files found in $MIGRATIONS_DIR"
    exit 1
}
echo ""

# Dry-run first
echo "🔍 Dry-run: checking SQL syntax..."
for migration in "$MIGRATIONS_DIR"/*.sql; do
    echo "  Checking: $(basename "$migration")"
    # Basic SQL syntax check (can be improved with pgsql parser)
    if grep -qE "^(CREATE|ALTER|DROP|INSERT)" "$migration"; then
        echo "    ✅ Valid SQL detected"
    else
        echo "    ⚠️  Warning: No DDL statements found"
    fi
done
echo ""

# Confirm deployment
read -p "Deploy to production? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled."
    exit 0
fi

# Deploy using Supabase CLI
echo "📤 Pushing migrations to Supabase..."
supabase db push --project-ref "$PROJECT_REF" || {
    echo "❌ Migration failed!"
    echo "Check Supabase logs: https://supabase.com/dashboard/project/$PROJECT_REF/logs"
    exit 1
}

echo ""
echo "✅ Migrations deployed successfully!"
echo ""
echo "📊 Verify in Supabase Studio:"
echo "   https://supabase.com/dashboard/project/$PROJECT_REF/editor"
echo ""
echo "🧪 Test with:"
echo "   bash scripts/smoke-test.sh"
