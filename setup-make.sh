#!/bin/bash
set -euo pipefail

echo "🔧 Klarpakke Make.com Setup"
echo "=========================="
echo ""

# STEG 1: Åpne Supabase
echo "STEG 1: Hent Supabase API Keys"
echo "-------------------------------"
open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api"
echo ""
echo "Scroll ned til 'Project API keys' og kopier:"
echo "  - anon public"
echo "  - service_role (SECRET!)"
echo ""
read -p "Trykk Enter når du har kopiert keys..."

# STEG 2: Oppdater .env.migration
echo ""
echo "STEG 2: Legg til i .env.migration"
echo "---------------------------------"
echo "Åpner .env.migration..."
sleep 1
nano .env.migration

# STEG 3: Åpne Make.com
echo ""
echo "STEG 3: Lag Tool Scenario"
echo "-------------------------"
open "https://eu1.make.com/447181/scenarios"
echo ""
echo "I Make.com:"
echo "1. Click 'Create new scenario'"
echo "2. Name: Tool: Get Signal"
echo "3. Add Custom Webhook (trigger)"
echo "4. Add Supabase - Search Records"
echo "   Table: aisignal"
echo "   Filter: status = 'pending'"
echo "   Order: created_at DESC"
echo "   Limit: 1"
echo "5. Add Webhook Response"
echo "   Body: {{2.json}}"
echo "6. SAVE and copy webhook URL"
echo ""
echo "✅ Setup complete!"
