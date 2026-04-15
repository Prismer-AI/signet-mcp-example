#!/usr/bin/env bash
set -euo pipefail
echo "=== Signet MCP Proxy Demo ==="

# Generate identity
signet identity generate --name mcp-demo --unencrypted 2>/dev/null || true

# Sign a few tool calls manually (simulating what the proxy does)
signet sign --key mcp-demo --tool "github_create_issue" --params '{"title":"fix bug"}' --target "mcp://github.local" > /dev/null
signet sign --key mcp-demo --tool "file_read" --params '{"path":"/etc/hosts"}' --target "mcp://filesystem" > /dev/null
signet sign --key mcp-demo --tool "bash" --params '{"command":"ls -la"}' --target "mcp://local" > /dev/null

echo "3 tool calls signed."
echo ""
signet audit --since 1h
echo ""
signet verify --chain
echo ""
echo "To use the proxy with a real MCP server:"
echo "  signet proxy --target 'npx @modelcontextprotocol/server-github' --key mcp-demo"
