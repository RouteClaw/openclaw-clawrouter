#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  OpenClaw + ClawRouter — Health Check
#  Run after installation to verify everything works
# ─────────────────────────────────────────────────────────────
set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
PASS=0
FAIL=0
WARN=0

check() {
  if eval "$2" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $1"
    PASS=$((PASS+1))
  else
    echo -e "  ${RED}✗${NC} $1"
    FAIL=$((FAIL+1))
  fi
}

warn_check() {
  if eval "$2" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $1"
    PASS=$((PASS+1))
  else
    echo -e "  ${YELLOW}!${NC} $1 ${YELLOW}(optional)${NC}"
    WARN=$((WARN+1))
  fi
}

echo -e "${BOLD}━━━ Health Check ━━━${NC}"
echo ""

echo -e "${BOLD}Runtime${NC}"
check "Node.js 22+" "node -v | grep -qE 'v(2[2-9]|[3-9])'"
check "OpenClaw installed" "command -v openclaw"
echo ""

echo -e "${BOLD}Configuration${NC}"
check "openclaw.json exists" "[ -f '$OPENCLAW_HOME/openclaw.json' ]"
check "SOUL.md exists" "[ -f '$OPENCLAW_HOME/SOUL.md' ]"

# Check if config has required fields
if [ -f "$OPENCLAW_HOME/openclaw.json" ]; then
  check "Telegram token set" "grep -q 'token' '$OPENCLAW_HOME/openclaw.json' && ! grep -q 'REPLACE' '$OPENCLAW_HOME/openclaw.json'"
  check "API key set" "grep -q 'apiKey' '$OPENCLAW_HOME/openclaw.json' && ! grep -q 'REPLACE_ME' '$OPENCLAW_HOME/openclaw.json'"
fi
echo ""

echo -e "${BOLD}ClawRouter Skill${NC}"
warn_check "Skill directory exists" "[ -d '$OPENCLAW_HOME/skills/clawrouter-skill' ]"
warn_check "Bootstrap script present" "[ -f '$OPENCLAW_HOME/skills/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs' ]"
echo ""

echo -e "${BOLD}Network${NC}"
check "ClawRouter API reachable" "curl -sf --max-time 5 https://clawrouter.com/api/status -o /dev/null"
check "Telegram API reachable" "curl -sf --max-time 5 https://api.telegram.org -o /dev/null"
echo ""

echo -e "${BOLD}Service${NC}"
warn_check "systemd service exists" "[ -f /etc/systemd/system/openclaw.service ]"
if [ -f /etc/systemd/system/openclaw.service ]; then
  warn_check "systemd service enabled" "systemctl is-enabled openclaw"
  warn_check "systemd service running" "systemctl is-active openclaw"
fi
echo ""

# Test ClawRouter API key if we can extract it
if [ -f "$OPENCLAW_HOME/openclaw.json" ]; then
  API_KEY=$(node -e "
    try {
      const c = require('$OPENCLAW_HOME/openclaw.json');
      const p = c.models?.providers || {};
      const cr = p.clawrouter || p.openai || Object.values(p)[0];
      if (cr?.apiKey && !cr.apiKey.includes('REPLACE')) process.stdout.write(cr.apiKey);
    } catch {}
  " 2>/dev/null || true)

  if [ -n "$API_KEY" ]; then
    echo -e "${BOLD}API Test${NC}"
    MODELS_RESP=$(curl -sf --max-time 10 \
      -H "Authorization: Bearer $API_KEY" \
      "https://clawrouter.com/v1/models" 2>/dev/null || true)

    if echo "$MODELS_RESP" | grep -q '"id"'; then
      MODEL_COUNT=$(echo "$MODELS_RESP" | node -e "
        let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
          try{process.stdout.write(String(JSON.parse(d).data?.length||0))}catch{process.stdout.write('?')}
        })
      " 2>/dev/null || echo "?")
      echo -e "  ${GREEN}✓${NC} ClawRouter API key valid — $MODEL_COUNT models available"
      PASS=$((PASS+1))
    else
      echo -e "  ${RED}✗${NC} ClawRouter API key invalid or expired"
      FAIL=$((FAIL+1))
    fi
    echo ""
  fi
fi

# Summary
echo -e "${BOLD}━━━ Result ━━━${NC}"
TOTAL=$((PASS+FAIL+WARN))
if [ $FAIL -eq 0 ]; then
  echo -e "  ${GREEN}${BOLD}All checks passed!${NC} ($PASS/$TOTAL pass, $WARN optional skipped)"
  echo ""
  echo -e "  Run: ${BOLD}openclaw gateway start${NC}"
  echo -e "  Then open Telegram and send your bot a message."
else
  echo -e "  ${RED}${BOLD}$FAIL check(s) failed${NC} ($PASS pass, $FAIL fail, $WARN optional)"
  echo ""
  echo -e "  Fix the failed items above, then run this check again:"
  echo -e "  ${BOLD}bash scripts/check.sh${NC}"
fi
