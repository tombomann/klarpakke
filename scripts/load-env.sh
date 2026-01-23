#!/bin/bash
set -euo pipefail
if [ -f .env ]; then
  set -a  # auto-export
  source .env
  set +a
fi
