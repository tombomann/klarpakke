#!/usr/bin/env bash
set -euo pipefail

echo "🔍 Webflow Collection ID Finder"
echo "================================"
echo ""

# Load .env
if [[ -f .env ]]; then
  set -a && source .env && set +a
fi

# Check for API token
if [[ -z "${WEBFLOW_API_TOKEN:-}" ]]; then
  echo "⚠️  WEBFLOW_API_TOKEN not found in .env"
  echo ""
  echo "Get your token:"
  echo "  1. Open: https://webflow.com/dashboard/sites"
  echo "  2. Select site → Settings → Integrations"
  echo "  3. API Access → Generate API Token"
  echo "  4. Copy token"
  echo ""
  read -p "Paste Webflow API token: " TOKEN
  
  if [[ -z "$TOKEN" ]]; then
    echo "❌ No token provided"
    exit 1
  fi
  
  WEBFLOW_API_TOKEN="$TOKEN"
  echo "WEBFLOW_API_TOKEN=$TOKEN" >> .env
  echo "✅ Token saved to .env"
  echo ""
fi

# Get Site ID
echo "Step 1: Find your Site ID"
echo ""
echo "Method 1: From Webflow Designer URL"
echo "  URL format: https://webflow.com/design/YOUR_SITE_NAME"
echo "  Example: https://webflow.com/design/klarpakke"
echo "  Site ID = 'klarpakke'"
echo ""
echo "Method 2: List all sites"
echo ""

read -p "List all your Webflow sites? (y/n): " LIST_SITES

if [[ "$LIST_SITES" == "y" ]]; then
  echo ""
  echo "Fetching your Webflow sites..."
  
  SITES=$(curl -s "https://api.webflow.com/v2/sites" \
    -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
    -H "Accept: application/json")
  
  if echo "$SITES" | jq -e '.sites' > /dev/null 2>&1; then
    echo ""
    echo "Your sites:"
    echo "$SITES" | jq -r '.sites[] | "  - \(.displayName) (ID: \(.id))"'
    echo ""
  else
    echo "❌ Failed to fetch sites. Check your API token."
    echo "Response: $SITES"
    exit 1
  fi
fi

read -p "Enter Site ID: " SITE_ID

if [[ -z "$SITE_ID" ]]; then
  echo "❌ No Site ID provided"
  exit 1
fi

echo ""
echo "Step 2: Fetching collections for site '$SITE_ID'..."
echo ""

# Fetch collections
COLLECTIONS=$(curl -s "https://api.webflow.com/v2/sites/${SITE_ID}/collections" \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN" \
  -H "Accept: application/json")

if echo "$COLLECTIONS" | jq -e '.collections' > /dev/null 2>&1; then
  COUNT=$(echo "$COLLECTIONS" | jq '.collections | length')
  
  if [[ "$COUNT" -eq 0 ]]; then
    echo "⚠️  No collections found for site '$SITE_ID'"
    echo ""
    echo "Create a collection in Webflow CMS:"
    echo "  1. Open Webflow Designer"
    echo "  2. Click CMS panel (left sidebar)"
    echo "  3. Click '+ New Collection'"
    echo "  4. Name it 'Signals'"
    echo "  5. Add fields: symbol, direction, confidence, reasoning"
    echo "  6. Save collection"
    echo "  7. Re-run this script"
    exit 1
  fi
  
  echo "✅ Found $COUNT collection(s):"
  echo ""
  
  echo "$COLLECTIONS" | jq -r '.collections[] | "  - \(.displayName) (ID: \(.id))"'
  echo ""
  
  # Look for 'Signals' collection
  SIGNALS_ID=$(echo "$COLLECTIONS" | jq -r '.collections[] | select(.displayName == "Signals" or .displayName == "signals") | .id' | head -1)
  
  if [[ -n "$SIGNALS_ID" ]]; then
    echo "✨ Found 'Signals' collection!"
    echo "   Collection ID: $SIGNALS_ID"
    echo ""
    
    # Update .env
    if grep -q "WEBFLOW_COLLECTION_ID" .env; then
      sed -i.bak "s|WEBFLOW_COLLECTION_ID=.*|WEBFLOW_COLLECTION_ID=$SIGNALS_ID|" .env
      rm -f .env.bak
      echo "✅ Updated WEBFLOW_COLLECTION_ID in .env"
    else
      echo "WEBFLOW_COLLECTION_ID=$SIGNALS_ID" >> .env
      echo "✅ Added WEBFLOW_COLLECTION_ID to .env"
    fi
    
    echo ""
    echo "Your .env now contains:"
    grep "WEBFLOW_" .env || true
  else
    echo "⚠️  No 'Signals' collection found."
    echo ""
    read -p "Enter Collection ID manually: " MANUAL_ID
    
    if [[ -n "$MANUAL_ID" ]]; then
      if grep -q "WEBFLOW_COLLECTION_ID" .env; then
        sed -i.bak "s|WEBFLOW_COLLECTION_ID=.*|WEBFLOW_COLLECTION_ID=$MANUAL_ID|" .env
        rm -f .env.bak
      else
        echo "WEBFLOW_COLLECTION_ID=$MANUAL_ID" >> .env
      fi
      echo "✅ Saved to .env"
    fi
  fi
else
  echo "❌ Failed to fetch collections"
  echo "Response: $COLLECTIONS"
  exit 1
fi

echo ""
echo "✨ Done! Next steps:"
echo "  1. Test sync: bash scripts/webflow-sync.sh"
echo "  2. Continue deployment: bash scripts/webflow-one-click.sh"
