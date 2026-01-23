#!/bin/bash
set -euo pipefail

DB_NAME="klarpakke"  # Endre til din DB name
REGION="eu-stockholm-1"  # Fra query
WALLET_DIR="./wallet"

echo "📥 1. Download wallet fra Oracle Console:"
echo "   OCI Console > Database > din DB > DB Connection > Download Wallet"
echo "   Unzip til $WALLET_DIR"
echo ""
read -p "Trykk ENTER etter unzip wallet til $WALLET_DIR"

# Test wallet files
ls -la $WALLET_DIR/*.pem || { echo "❌ Wallet mangler"; exit 1; }

echo "🔗 2. Psql connect (bruk wallet user/pass):"
echo "   psql \"sslmode=verify-full sslrootcert=$WALLET_DIR/Dbcert.pem host=yourhost.$REGION.oraclecloud.com port=5432 dbname=$DB_NAME sslcert=$WALLET_DIR/cwallet.sso sslkey=$WALLET_DIR/cwallet.sso user=your_db_user\""
echo ""
echo "💡 Alternativ: Bruk DBeaver/psql GUI med wallet path."
echo "💡 Eksakt host/port/user: Kopier fra OCI Console > Connection String (PostgreSQL tab)"
echo "   Eks: postgres://admin:pass@abc123.high.eu-stockholm-1.oraclecloud.com:5432/free?sslmode=require"
