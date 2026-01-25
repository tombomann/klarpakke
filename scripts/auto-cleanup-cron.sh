#!/bin/bash
# Cron-friendly wrapper (logger til fil)

LOGFILE="$HOME/klarpakke-cleanup.log"
echo "=== $(date) ===" >> "$LOGFILE"
bash /Users/taj/klarpakke/scripts/auto-cleanup.sh >> "$LOGFILE" 2>&1
