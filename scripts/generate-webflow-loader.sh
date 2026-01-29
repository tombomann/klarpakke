#!/bin/bash
set -euo pipefail

cd ~/klarpakke
source .env

# Valider variabler
if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ]; then
  echo "❌ Mangler SUPABASE_URL eller SUPABASE_ANON_KEY i .env"
  exit 1
fi

# Generer loader
cat > /tmp/webflow-loader-final.html <<ENDMARKER
<!-- Klarpakke Custom Code -->
<!-- Generated: $(date '+%Y-%m-%d %H:%M:%S') -->

<script>
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: "${SUPABASE_URL}",
    supabaseAnonKey: "${SUPABASE_ANON_KEY}",
    debug: false
  };
</script>
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/klarpakke-site.js"></script>
ENDMARKER

# Vis output
echo ""
echo "════════════════════════════════════════════════════"
cat /tmp/webflow-loader-final.html
echo "════════════════════════════════════════════════════"
echo ""

# Kopier til clipboard
pbcopy < /tmp/webflow-loader-final.html
echo "✅ Kopiert til clipboard!"
echo ""
echo "📋 NESTE STEG:"
echo "1. Gå til: https://webflow.com/dashboard/sites/klarpakke/designer"
echo "2. Klikk ⚙️ (Site settings)"
echo "3. Velg 'Custom Code'"
echo "4. Scroll til 'Footer Code (Before </body>)'"
echo "5. Lim inn (Cmd+V)"
echo "6. Klikk 'Save' → 'Publish'"
