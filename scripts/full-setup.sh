#!/bin/bash
set -euo pipefail

echo "🚀 Klarpakke Full Setup - Step by Step"

# 1. Make token
read -p "Enter MAKE_TOKEN (xmake_abc...): " MAKE_TOKEN
export MAKE_TOKEN
bash scripts/debug-make-api.sh

# 2. OCI DB details
read -p "DB_HOST (from OCI Console postgres string, eks adb123.high.eu-stockholm-1.oraclecloud.com): " DB_HOST
read -p "DB_USER (admin?): " DB_USER
read -s -p "DB_PASS: " DB_PASS
export DB_HOST DB_USER DB_PASS
echo

# 3. Wallet
if [[ ! -d wallet ]]; then
  echo "📥 Go to OCI Console > Database > Connection > Download Wallet"
  echo "Unzip to ./wallet then rerun."
  exit 1
fi

# 4. Test connect
bash scripts/psql-oracle-connect.sh

# 5. Schema + data
bash scripts/postgres-schema.sh
bash scripts/insert-test-signals.sh

echo "✅ Setup complete! make all"
