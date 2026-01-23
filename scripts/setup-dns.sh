#!/bin/bash
set -euo pipefail

sudo mkdir -p /etc/resolver
echo "nameserver 8.8.8.8" | sudo tee /etc/resolver/oraclecloud.com
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolver/oraclecloud.com

# Flush DNS cache (macOS)
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder || true
echo "✅ DNS resolver setup for *.oraclecloud.com"

# Test
nslookup oraclecloud.com 8.8.8.8 || echo "⚠️ nslookup failed, men resolver OK"
