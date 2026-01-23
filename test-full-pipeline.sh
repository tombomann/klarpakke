#!/bin/bash
set -euo pipefail
export PPLX_API_KEY=sk-proj-din_key_her
make ai-test && make stripe-verify-usd && echo "ALL GREEN!"
