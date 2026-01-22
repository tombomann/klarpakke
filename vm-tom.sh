#!/usr/bin/env bash
set -euo pipefail

VM_HOST="opc@VM"              # <- bytt til riktig host/IP
BUBBLE_APP="tom-58107"        # <- ditt app-slug
REPO_URL="https://github.com/tombomann/klarpakke.git"

# Ikke hardkod nøkkel i fil om du kan unngå det:
: "${BUBBLE_API_KEY:?Sett BUBBLE_API_KEY i miljøet før du kjører.}"

ssh -o StrictHostKeyChecking=accept-new "$VM_HOST" 'bash -s' <<REMOTE
set -euo pipefail

rm -rf ~/klarpakke
git clone "$REPO_URL" ~/klarpakke
cd ~/klarpakke

# Bytt app-slug i app.js (Linux sed)
sed -i "s/klarpakke-trading/$BUBBLE_APP/g" app.js

npm ci || npm i

# Start PM2 fra riktig mappe + riktig script
pm2 delete bubble-cron || true
BUBBLE_API_KEY="$BUBBLE_API_KEY" pm2 start ./app.js --name bubble-cron --cwd "\$HOME/klarpakke"
pm2 save
pm2 status
REMOTE
