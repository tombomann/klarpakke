#!/bin/bash
set -euo pipefail

echo "🤖 Setting up Webflow MCP Server (Remote)..."
echo ""

# 1. Opprett config for Claude Desktop / Cursor
mkdir -p ~/.cursor

cat > ~/.cursor/mcp.json <<'MCP'
{
  "mcpServers": {
    "webflow": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.webflow.com/sse"]
    }
  }
}
MCP

echo "✅ MCP configured for Cursor!"
echo ""

# 2. Opprett config for Claude Desktop (hvis du bruker det)
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ -d "$(dirname "$CLAUDE_CONFIG")" ]; then
  cat > "$CLAUDE_CONFIG" <<'CLAUDE'
{
  "mcpServers": {
    "webflow": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.webflow.com/sse"]
    }
  }
}
CLAUDE
  echo "✅ MCP configured for Claude Desktop!"
else
  echo "⚠️  Claude Desktop ikke installert (optional)"
fi

echo ""
echo "════════════════════════════════════════════════════"
echo "✅ SETUP COMPLETE!"
echo "════════════════════════════════════════════════════"
echo ""
echo "📋 NESTE STEG:"
echo ""
echo "1️⃣  AUTORISÉR WEBFLOW:"
echo "   - Restart Cursor/Claude Desktop"
echo "   - I chatten, skriv: 'List my Webflow sites'"
echo "   - Følg OAuth-lenken som kommer"
echo "   - Godkjenn tilgang til Webflow-sitene dine"
echo ""
echo "2️⃣  INSTALLER BRIDGE APP I WEBFLOW:"
echo "   - Gå til: https://webflow.com/apps/detail/mcp-bridge-app"
echo "   - Klikk 'Add App to Workspace'"
echo "   - Godkjenn installasjonen"
echo ""
echo "3️⃣  ÅPNE BRIDGE APP I DESIGNER:"
echo "   - Åpne Webflow Designer for klarpakke"
echo "   - Trykk 'E' for Apps panel"
echo "   - Åpne 'Webflow MCP Bridge App'"
echo "   - Vent på grønt 'Connected' lys"
echo ""
echo "4️⃣  TEST:"
echo "   - I Cursor/Claude: 'Create a new section on my homepage with heading and button'"
echo "   - Se magien skje i Designer! ✨"
echo ""
