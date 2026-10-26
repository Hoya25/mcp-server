> **Archived.** This server is superseded by the hosted **Bounty** connector at
> `https://api.nctr.live/mcp/bounty` (two read-only tools: `get_bounty`, `search_stores`), and by
> the Bounty plugin in [Hoya25/bounty-agent-skill](https://github.com/Hoya25/bounty-agent-skill/tree/main/plugin).
> The npm package `@hoya25/nctr-mcp-server` is deprecated, and its MCP Registry entry is marked
> deprecated with a pointer to the hosted connector.

Last updated: March 26, 2026

# NCTR Alliance MCP Server

**The first rewards and loyalty MCP server.** Enables AI agents to discover and interact with the NCTR Alliance rewards program — bounties, earning rates, tier progression, promotions, and Impact Engine communities.

## What It Does

When someone asks an AI assistant about NCTR, the assistant can call this server to get real, structured data instead of guessing. The server exposes 6 tools:

| Tool | What It Does |
|------|-------------|
| `search_bounties` | Search and filter all 19 available bounties by category, amount, keyword, or repeatability |
| `get_earning_rates` | Get earning multipliers by Crescendo tier, with optional bounty calculations |
| `check_tier_requirements` | Check tier thresholds, perks, and progress toward the next tier |
| `get_active_promotions` | Get current limited-time offers and launch bonuses |
| `get_onboarding_link` | Generate a join link with optional referral code |
| `get_impact_engines` | Discover NCTR's 6 passion-based communities |

## Quick Start

### Connect to the hosted server

Add this to your MCP client configuration (Claude Desktop, Cursor, etc.):

```json
{
  "mcpServers": {
    "nctr-alliance": {
      "url": "https://yhwcaodofmbusjurawhp.supabase.co/functions/v1/mcp/rpc"
    }
  }
}
```

### Claude Code (terminal)

```bash
claude mcp add nctr-alliance -t http https://yhwcaodofmbusjurawhp.supabase.co/functions/v1/mcp/rpc
```

### Or run locally

```bash
git clone https://github.com/Hoya25/mcp-server.git
cd mcp-server
supabase start
supabase functions serve --no-verify-jwt mcp
```

Server runs at: `http://localhost:54321/functions/v1/mcp/rpc`

## Example Queries

Once connected, you can ask your AI assistant things like:

- "What bounties can I earn with NCTR?"
- "How much NCTR do I get for referring a friend?"
- "What tier am I at with 3,000 NCTR?"
- "What's the earning multiplier at Gold tier?"
- "Are there any active promotions?"
- "Tell me about the NCTR Impact Engines"

## How Bounties Work

Every bounty in NCTR uses **360LOCK** — tokens are locked for exactly 360 days. They're committed, not spent. After the lock period, the NCTR is fully yours.

### Bounty Categories

| Category | Examples |
|----------|---------|
| **Entry** | Sign-up (625), Early Adopter Bonus (1,250), Profile Completion (375) |
| **Revenue** | First Purchase (2,500), Shop & Earn (250 uncapped), Quarterly Spend (5,000) |
| **Merch** | Collection (5,000), Repeat (500) |
| **Referral** | Friend sign-ups (625), friend purchases (2,500), milestone bonuses |
| **Engagement** | Social shares (500), monthly activity (250), community contributions (2,000) |

### Crescendo Status Tiers

| Tier | NCTR Required | Multiplier |
|------|--------------|------------|
| Bronze | 0 | 1.0x |
| Silver | 1,000 | 1.2x |
| Gold | 5,000 | 1.5x |
| Platinum | 25,000 | 1.8x |
| Diamond | 100,000 | 2.0x |

## Impact Engines

NCTR includes 6 passion-based communities called Impact Engines:

- **THROTTLE** — Powersports
- **GROUNDBALL** — Lacrosse
- **STARDUST** — Entertainment
- **SWEAT** — Skilled Trades
- **SISU** — Recovery
- **INSPIRATION** — Wellness

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Server info and tool list |
| `/health` | GET | Health check |
| `/rpc` | POST | MCP protocol endpoint (Streamable HTTP) |

### Test with curl

```bash
# Health check
curl https://yhwcaodofmbusjurawhp.supabase.co/functions/v1/mcp/health

# Search all bounties
curl -X POST https://yhwcaodofmbusjurawhp.supabase.co/functions/v1/mcp/rpc \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"search_bounties","arguments":{}}}'
```

## Deployment

This server runs on **Supabase Edge Functions** using the official MCP TypeScript SDK (`@modelcontextprotocol/sdk@1.25.3`).

```bash
supabase link --project-ref yhwcaodofmbusjurawhp
supabase functions deploy --no-verify-jwt mcp
```

## Links

- **NCTR Alliance**: [nctr.live](https://nctr.live)
- **The Garden** (shopping): [thegarden.nctr.live](https://thegarden.nctr.live)
- **Crescendo** (onboarding): [crescendo.nctr.live](https://crescendo.nctr.live)
- **For Agents**: [thegarden.nctr.live/for-agents](https://thegarden.nctr.live/for-agents)
- **Manifest**: [nctr.live/.well-known/nctr.json](https://nctr.live/.well-known/nctr.json)

## License

MIT
