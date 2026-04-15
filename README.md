# Signet + MCP Example

Two ways to add cryptographic signing to MCP tool calls:

## Option A: MCP Proxy (Zero Code Changes)

```bash
pip install signet-auth
signet identity generate --name my-agent --unencrypted
signet proxy --target "npx @modelcontextprotocol/server-github" --key my-agent
```

Every `tools/call` is signed. Server responses are co-signed (bilateral receipts). No changes to agent or server code.

Use in `claude_desktop_config.json`:
```json
{
  "mcpServers": {
    "github": {
      "command": "signet",
      "args": ["proxy", "--target", "npx @modelcontextprotocol/server-github", "--key", "my-agent"]
    }
  }
}
```

## Option B: SigningTransport (TypeScript)

```typescript
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { generateKeypair } from "@signet-auth/core";
import { SigningTransport } from "@signet-auth/mcp";

const { secretKey } = generateKeypair();
const inner = new StdioClientTransport({ command: "my-mcp-server" });
const transport = new SigningTransport(inner, secretKey, "my-agent");

const client = new Client({ name: "my-agent", version: "1.0" }, {});
await client.connect(transport);
// Every tools/call now carries a signed receipt in params._meta._signet
```

## Option C: Server-Side Verification

```typescript
import { verifyRequest, NonceCache } from "@signet-auth/mcp-server";

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const result = verifyRequest(request, {
    trustedKeys: ["ed25519:..."],
    expectedTarget: "mcp://my-server",
    maxAge: 300,
    nonceCache: new NonceCache(),
  });
  if (!result.ok) return { content: [{ type: "text", text: result.error }], isError: true };
  // Verified — proceed
});
```

## Verify Audit Trail

```bash
signet audit --since 1h
signet verify --chain
signet dashboard
```

## Links

- [Signet](https://github.com/Prismer-AI/signet) — Cryptographic action receipts for AI agents
- [npm: @signet-auth/core](https://www.npmjs.com/package/@signet-auth/core)
- [npm: @signet-auth/mcp](https://www.npmjs.com/package/@signet-auth/mcp)
- [MCP](https://modelcontextprotocol.io/)
