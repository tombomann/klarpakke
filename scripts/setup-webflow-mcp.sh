#!/bin/bash
set -euo pipefail

echo "🤖 Setting up Webflow MCP Server..."

# Install MCP CLI (hvis ikke allerede installert)
if ! command -v mcp &> /dev/null; then
  echo "Installing MCP CLI..."
  npm install -g @modelcontextprotocol/cli
fi

# Configure Webflow MCP Server
cat > ~/.mcp/config.json <<'MCP_CONFIG'
{
  "mcpServers": {
    "webflow": {
      "command": "npx",
      "args": ["-y", "@webflow/mcp-server"],
      "env": {
        "WEBFLOW_API_TOKEN": "${WEBFLOW_API_TOKEN}"
      }
    }
  }
}
MCP_CONFIG

echo "✅ MCP configured!"
echo ""
echo "📋 Next steps:"
echo "1. Gå til Webflow Designer"
echo "2. Åpne Apps panel"
echo "3. Installer 'Webflow MCP Companion App'"
echo "4. Authorize din site"
echo "5. Start designing med AI prompts!"
