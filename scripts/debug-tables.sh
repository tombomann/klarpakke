#!/bin/bash
# Debug script: Why can't we see the tables?
set -euo pipefail

echo "🔍 Klarpakke Table Diagnostics"
echo "=============================="
echo ""

# Load .env
if [ -f ".env" ]; then
    source .env
else
    echo "❌ .env not found"
    exit 1
fi

echo "[1] Testing with ANON key..."
echo "URL: $SUPABASE_URL"
echo ""

for table in positions signals daily_risk_meter ai_calls; do
    echo "Testing table: $table"
    
    # Get response with HTTP code
    FULL_RESPONSE=$(curl -s -w "\n###HTTP_CODE###%{http_code}" \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
        "$SUPABASE_URL/rest/v1/$table?limit=1" 2>&1)
    
    # Extract HTTP code (after marker)
    HTTP_CODE=$(echo "$FULL_RESPONSE" | grep "###HTTP_CODE###" | sed 's/.*###HTTP_CODE###//')
    # Extract body (before marker)
    BODY=$(echo "$FULL_RESPONSE" | sed '/###HTTP_CODE###/d')
    
    echo "  HTTP Code: $HTTP_CODE"
    if [ -n "$BODY" ]; then
        echo "  Response: $BODY"
    fi
    echo ""
done

echo ""
echo "[2] Testing with SECRET key..."
echo ""

for table in positions signals daily_risk_meter ai_calls; do
    echo "Testing table: $table"
    
    FULL_RESPONSE=$(curl -s -w "\n###HTTP_CODE###%{http_code}" \
        -H "apikey: $SUPABASE_SECRET_KEY" \
        -H "Authorization: Bearer $SUPABASE_SECRET_KEY" \
        "$SUPABASE_URL/rest/v1/$table?limit=1" 2>&1)
    
    HTTP_CODE=$(echo "$FULL_RESPONSE" | grep "###HTTP_CODE###" | sed 's/.*###HTTP_CODE###//')
    BODY=$(echo "$FULL_RESPONSE" | sed '/###HTTP_CODE###/d')
    
    echo "  HTTP Code: $HTTP_CODE"
    if [ -n "$BODY" ]; then
        echo "  Response: $BODY"
    fi
    echo ""
done

echo ""
echo "[3] Testing REST API root..."
FULL_RESPONSE=$(curl -s -w "\n###HTTP_CODE###%{http_code}" \
    -H "apikey: $SUPABASE_ANON_KEY" \
    -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
    "$SUPABASE_URL/rest/v1/" 2>&1)

HTTP_CODE=$(echo "$FULL_RESPONSE" | grep "###HTTP_CODE###" | sed 's/.*###HTTP_CODE###//')
BODY=$(echo "$FULL_RESPONSE" | sed '/###HTTP_CODE###/d')

echo "HTTP Code: $HTTP_CODE"
if [ -n "$BODY" ]; then
    echo "Response: $BODY"
fi
echo ""

echo "[4] Environment check..."
echo "SUPABASE_URL: $SUPABASE_URL"
echo "ANON_KEY (first 20 chars): ${SUPABASE_ANON_KEY:0:20}..."
echo "SECRET_KEY (first 20 chars): ${SUPABASE_SECRET_KEY:0:20}..."
echo ""

echo "[5] Quick table check via SQL Editor:"
echo "  Run this SQL in Supabase SQL Editor:"
echo ""
echo "  SELECT schemaname, tablename "
echo "  FROM pg_tables "
echo "  WHERE tablename IN ('positions', 'signals', 'daily_risk_meter', 'ai_calls');"
echo ""
echo "  Open: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor"
echo ""
