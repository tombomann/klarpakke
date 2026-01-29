#!/usr/bin/env bash
set -euo pipefail

echo "\n🧩 WEBFLOW DESIGNER EXTENSION (SETUP CHECKLIST)"
echo "════════════════════════════════════════════════════"

cat <<'EOF'

This project needs TWO automation lanes:

1) Data API v2 (server/CI):
   - CMS collections/items
   - publish
   - page listing + metadata (where supported)

2) Designer API (inside Designer via Webflow App/Extension):
   - create pages/folders
   - generate/attach structure/IDs

What you do next (manual once, then automated):

A) Create Webflow App
- In Webflow → Apps: create a new App (private/internal first).
- Enable Designer Extension.
- Request abilities/scopes that include page creation ("canCreatePage" in Designer API context).

B) Local dev loop (Mac M1)
- Node 18+ recommended.
- Run the Designer extension dev server.
- Connect the extension to your Webflow site.

C) CI/CD
- Build extension bundle.
- Publish a tagged release artifact.
- Keep tokens/IDs in GitHub Secrets.

EOF

echo "✅ Checklist printed. Next: implement /webflow-designer-extension package."