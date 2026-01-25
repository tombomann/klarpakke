#!/bin/bash
echo "🧪 Testing trading pipeline..."
bash scripts/generate-trading-signals.sh
cat latest-signal.json | jq .
echo "✅ Pipeline test complete"
