#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# NCTR Alliance MCP Server — Test Script
# ═══════════════════════════════════════════════════════════════
# Usage:
#   bash test-mcp-server.sh                                    # Test local server
#   bash test-mcp-server.sh https://xyz.supabase.co/functions/v1/mcp  # Test production
# ═══════════════════════════════════════════════════════════════

BASE_URL="${1:-https://yhwcaodofmbusjurawhp.supabase.co/functions/v1/mcp}"
MCP_URL="${BASE_URL}/rpc"
PASS=0
FAIL=0

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   NCTR Alliance MCP Server — Test Suite             ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║   Target: $BASE_URL"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

# ── Helper ──
run_test() {
  local test_name="$1"
  local method_name="$2"
  local params="$3"
  local expect_text="$4"

  echo "─── Test: $test_name ───"

  RESPONSE=$(curl -s -X POST "$MCP_URL" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json, text/event-stream" \
    -d "{
      \"jsonrpc\": \"2.0\",
      \"id\": 1,
      \"method\": \"tools/call\",
      \"params\": {
        \"name\": \"$method_name\",
        \"arguments\": $params
      }
    }")

  # Extract data line from SSE response
  DATA_LINE=$(echo "$RESPONSE" | grep "^data:" | head -1 | sed 's/^data: //')

  if [ -z "$DATA_LINE" ]; then
    # Try parsing as direct JSON (non-SSE response)
    DATA_LINE="$RESPONSE"
  fi

  if echo "$DATA_LINE" | grep -q "$expect_text"; then
    echo "  ✅ PASS — Found expected: $expect_text"
    PASS=$((PASS + 1))
  else
    echo "  ❌ FAIL — Expected to find: $expect_text"
    echo "  Response: $(echo "$DATA_LINE" | head -c 200)"
    FAIL=$((FAIL + 1))
  fi
  echo ""
}

# ── Test 0: Health Check ──
echo "─── Test: Health Check ───"
HEALTH=$(curl -s "$BASE_URL/health")
if echo "$HEALTH" | grep -q '"status":"ok"'; then
  echo "  ✅ PASS — Server is healthy"
  PASS=$((PASS + 1))
else
  echo "  ❌ FAIL — Health check failed"
  echo "  Response: $HEALTH"
  FAIL=$((FAIL + 1))
fi
echo ""

# ── Test 1: Root Info ──
echo "─── Test: Root Info Endpoint ───"
ROOT=$(curl -s "$BASE_URL/")
if echo "$ROOT" | grep -q "NCTR Alliance MCP Server"; then
  echo "  ✅ PASS — Root endpoint returns server info"
  PASS=$((PASS + 1))
else
  echo "  ❌ FAIL — Root endpoint missing server info"
  FAIL=$((FAIL + 1))
fi
echo ""

# ── Test 2: search_bounties — All Bounties ──
run_test "search_bounties — All Bounties" \
  "search_bounties" \
  "{}" \
  "total"

# ── Test 3: search_bounties — Filter by Category ──
run_test "search_bounties — Entry Category" \
  "search_bounties" \
  '{"category": "entry"}' \
  "Sign-Up Bounty"

# ── Test 4: search_bounties — Filter by Amount ──
run_test "search_bounties — Min 5000 NCTR" \
  "search_bounties" \
  '{"min_amount": 5000}' \
  "5,000 NCTR"

# ── Test 5: search_bounties — Keyword Search ──
run_test "search_bounties — Keyword: referral" \
  "search_bounties" \
  '{"keyword": "referral"}' \
  "Referral"

# ── Test 6: search_bounties — Repeatable Only ──
run_test "search_bounties — Repeatable Only" \
  "search_bounties" \
  '{"repeatable_only": true}' \
  "repeatable"

# ── Test 7: get_earning_rates — All Tiers ──
run_test "get_earning_rates — All Tiers" \
  "get_earning_rates" \
  "{}" \
  "Diamond"

# ── Test 8: get_earning_rates — Specific Tier ──
run_test "get_earning_rates — Gold Tier" \
  "get_earning_rates" \
  '{"tier": "Gold"}' \
  "1.5x"

# ── Test 9: get_earning_rates — With Bounty Calculation ──
run_test "get_earning_rates — Gold + First Purchase Bounty" \
  "get_earning_rates" \
  '{"tier": "Gold", "bounty_id": "bounty-first-purchase"}' \
  "adjusted_amount"

# ── Test 10: check_tier_requirements — Full Progression ──
run_test "check_tier_requirements — Full Progression" \
  "check_tier_requirements" \
  "{}" \
  "progression"

# ── Test 11: check_tier_requirements — With Balance ──
run_test "check_tier_requirements — Balance 3000 NCTR" \
  "check_tier_requirements" \
  '{"current_balance": 3000}' \
  "Silver"

# ── Test 12: check_tier_requirements — Target Tier ──
run_test "check_tier_requirements — Target Diamond" \
  "check_tier_requirements" \
  '{"target_tier": "Diamond", "current_balance": 500}' \
  "NOT YET"

# ── Test 13: get_active_promotions ──
run_test "get_active_promotions" \
  "get_active_promotions" \
  "{}" \
  "Early Adopter"

# ── Test 14: get_onboarding_link — No Referral ──
run_test "get_onboarding_link — No Referral" \
  "get_onboarding_link" \
  "{}" \
  "crescendo.nctr.live/join"

# ── Test 15: get_onboarding_link — With Referral ──
run_test "get_onboarding_link — With Referral Code" \
  "get_onboarding_link" \
  '{"referral_code": "ANDERSON123"}' \
  "ANDERSON123"

# ── Test 16: get_impact_engines — All Engines ──
run_test "get_impact_engines — All Engines" \
  "get_impact_engines" \
  "{}" \
  "THROTTLE"

# ── Test 17: get_impact_engines — Filter by Category ──
run_test "get_impact_engines — Lacrosse" \
  "get_impact_engines" \
  '{"category": "Lacrosse"}' \
  "GROUNDBALL"

# ── Results ──
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Results: $PASS passed, $FAIL failed               "
echo "╚══════════════════════════════════════════════════════╝"
echo ""

if [ $FAIL -gt 0 ]; then
  echo "⚠️  Some tests failed. Check the output above."
  exit 1
else
  echo "All tests passed."
  exit 0
fi
