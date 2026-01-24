#!/usr/bin/env bash
# Quick constraint fix - Opens SQL editor with pre-filled query
# Usage: ./scripts/quick-constraint-fix.sh

set -euo pipefail

cd "$(dirname "$0")/.."

echo "════════════════════════════════════════════════════════════════"
echo "🚀 QUICK CONSTRAINT FIX"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "Choose fix method:"
echo "  1) SQL Editor (opens in browser) - RECOMMENDED"
echo "  2) Python script (requires psycopg2)"
echo "  3) Show SQL only (copy-paste)"
echo ""
read -p "Select [1-3]: " choice

case $choice in
  1)
    echo ""
    echo "🌐 Opening Supabase SQL Editor..."
    echo ""
    
    # Show SQL to copy
    echo "📋 Copy this SQL and paste in the editor:"
    echo ""
    echo "-- ========================================"
    cat scripts/fix-direction-constraint.sql | grep -v "^--" | grep -v "^$"
    echo "-- ========================================"
    echo ""
    
    # Open SQL editor
    open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new"
    
    echo "✅ SQL Editor opened in browser"
    echo ""
    echo "📝 Instructions:"
    echo "   1. Paste the SQL above"
    echo "   2. Click 'Run' or press Cmd+Enter"
    echo "   3. Verify output shows constraint created"
    echo ""
    ;;
    
  2)
    echo ""
    echo "🐍 Running Python script..."
    echo ""
    
    # Check if psycopg2 is installed
    if ! python3 -c "import psycopg2" 2>/dev/null; then
      echo "⚠️  psycopg2 not installed"
      echo ""
      read -p "Install now? [y/N]: " install
      if [[ "$install" == "y" || "$install" == "Y" ]]; then
        echo "📦 Installing psycopg2-binary..."
        pip3 install psycopg2-binary
      else
        echo "❌ Aborted"
        exit 1
      fi
    fi
    
    # Load .env.local
    if [[ -f .env.local ]]; then
      source .env.local
      echo "✅ Loaded .env.local"
      echo ""
    else
      echo "❌ .env.local not found"
      exit 1
    fi
    
    # Run Python script
    chmod +x scripts/fix-constraint-python.py
    python3 scripts/fix-constraint-python.py
    ;;
    
  3)
    echo ""
    echo "📋 SQL to fix constraint:"
    echo ""
    cat scripts/fix-direction-constraint.sql
    echo ""
    echo "🔗 Run in SQL Editor:"
    echo "   https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/sql/new"
    echo ""
    ;;
    
  *)
    echo "❌ Invalid choice"
    exit 1
    ;;
esac

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "🔗 After fixing constraint, test with:"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "source .env.local"
echo "curl -X POST -H \"apikey: \$SUPABASE_SERVICE_ROLE_KEY\" \\"
echo "  -H \"Content-Type: application/json\" \\"
echo "  -d '{\"symbol\":\"BTCUSDT\",\"direction\":\"LONG\",\"entry_price\":50000,\"stop_loss\":48000,\"take_profit\":52000,\"confidence\":0.85,\"status\":\"pending\"}' \\"
echo "  https://swfyuwkptusceiouqlks.supabase.co/rest/v1/aisignal"
echo ""
echo "Or run full auto-fix:"
echo "  ./scripts/auto-fix-cli.sh"
echo ""
