#!/bin/bash
set -euo pipefail

WALLET_DIR="./wallet"
DB_HOST="${DB_HOST:-your_actual_db_name.high.eu-stockholm-1.oraclecloud.com}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-klarpakke}"
DB_USER="${DB_USER:-admin}"

: "${DB_HOST:?DB_HOST required from OCI Console}"
: "${DB_USER:?DB_USER required}"

if [[ ! -d "$WALLET_DIR" ]]; then
  echo "❌ Download wallet: OCI > Database > Connection > Download (unzip to $WALLET_DIR)"
  exit 1
fi

psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER \
  sslmode=verify-full \
  sslrootcert=$WALLET_DIR/Dbcert.pem \
  sslcert=$WALLET_DIR/cwallet.sso \
  sslkey=$WALLET_DIR/cwallet.sso" \
  -c "SELECT 1 as connected, version();" || echo "❌ Connect failed - check host/user/wallet"

