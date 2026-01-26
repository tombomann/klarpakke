#!/bin/bash
set -euo pipefail
supabase db reset  # Caution: dev only!
supabase db push
make edge-deploy   # Redeploy functions
make edge-test-live
