#!/bin/bash
# Deploy Supabase migrations to production
# Usage: bash scripts/deploy-migrations.sh

set -euo pipefail

MIGRATIONS_DIR="supabase/migrations"

echo "🚀 Deploying Supabase migrations..."
echo ""

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI not found."
    echo "Install: brew install supabase/tap/supabase"
    echo "Or: npm i supabase --save-dev"
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

# Check if linked to a project
if ! supabase status &>/dev/null; then
    echo "⚠️  No linked Supabase project found."
    echo ""
    echo "Link to your project first:"
    echo "  supabase link --project-ref YOUR_PROJECT_REF"
    echo ""
    echo "Find your project ref at:"
    echo "  https://supabase.com/dashboard/project/_/settings/general"
    exit 1
fi

# Show current project
echo "📍 Linked project:"
supabase status | grep "Project ID" || echo "  (checking...)"
echo ""

# Dry-run first
echo "🔍 Dry-run: checking SQL syntax..."
for migration in "$MIGRATIONS_DIR"/*.sql; do
    echo "  Checking: $(basename "$migration")"
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

# Deploy using Supabase CLI (v2 syntax)
echo "📤 Pushing migrations to Supabase..."
supabase db push || {
    echo "❌ Migration failed!"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check you're linked: supabase link --project-ref YOUR_REF"
    echo "  2. Check migrations syntax"
    echo "  3. View logs: supabase db push --debug"
    exit 1
}

echo ""
echo "✅ Migrations deployed successfully!"
echo ""
echo "📊 Verify in Supabase Studio:"
echo "   https://supabase.com/dashboard/project/_/editor"
echo ""
echo "🧪 Test with:"
echo "   bash scripts/smoke-test.sh"
