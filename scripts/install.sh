#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  OpenClaw + ClawRouter — One-click installer
#  bash <(curl -fsSL https://raw.githubusercontent.com/RouteClaw/openclaw-clawrouter/main/scripts/install.sh)
# ─────────────────────────────────────────────────────────────
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

clear
echo -e "${CYAN}"
echo "   ╔══════════════════════════════════════════════╗"
echo "   ║                                              ║"
echo "   ║   🦞  OpenClaw + ClawRouter  安裝精靈        ║"
echo "   ║                                              ║"
echo "   ║   5 分鐘擁有你自己的 AI 助手                 ║"
echo "   ║   透過 Telegram 隨時跟 AI 對話               ║"
echo "   ║                                              ║"
echo "   ╚══════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ── Helpers ─────────────────────────────────────────────────
step_header() {
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BOLD}  $1${NC}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
}

ok()   { echo -e "  ${GREEN}✅${NC} $1"; }
info() { echo -e "  ${CYAN}ℹ️${NC}  $1"; }
warn() { echo -e "  ${YELLOW}⚠️${NC}  $1"; }
fail() { echo -e "  ${RED}❌${NC} $1"; }

ask_with_hint() {
  echo -e "  ${CYAN}▶${NC} ${BOLD}$1${NC}"
  if [ -n "${2:-}" ]; then
    echo -e "    ${DIM}$2${NC}"
  fi
  echo -n "    👉 "
}

# ── Globals ─────────────────────────────────────────────────
CLAWROUTER_BASE_URL="${CLAWROUTER_BASE_URL:-https://clawrouter.com}"
CLAWROUTER_AFF_CODE="${CLAWROUTER_AFF_CODE:-p1jZ}"
OPENCLAW_HOME="${HOME}/.openclaw"
SKILL_REPO="https://github.com/RouteClaw/openclaw-clawrouter"
SKILL_ORIGIN_REPO="https://github.com/RouteClaw/clawrouter-skill"
BOOTSTRAP_RAW="https://raw.githubusercontent.com/RouteClaw/openclaw-clawrouter/main/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs"

# ── Fix IPv6 issues on EC2 ──────────────────────────────────
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true
export NODE_OPTIONS="--dns-result-order=ipv4first"

# ═════════════════════════════════════════════════════════════
#  STEP 1 — 安裝基礎環境（全自動）
# ═════════════════════════════════════════════════════════════
step_header "Step 1/4 ── 安裝基礎環境（全自動，請稍候）"

info "正在檢查系統環境..."

# Node.js
if command -v node &>/dev/null; then
  NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 22 ] 2>/dev/null; then
    ok "Node.js $(node -v) — 已安裝"
  fi
fi

if ! command -v node &>/dev/null || [ "$(node -v | sed 's/v//' | cut -d. -f1)" -lt 22 ] 2>/dev/null; then
  info "正在安裝 Node.js 22+（大約 30 秒）..."
  if command -v apt-get &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x 2>/dev/null | sudo -E bash - >/dev/null 2>&1
    sudo apt-get install -y nodejs >/dev/null 2>&1
  elif command -v dnf &>/dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_22.x 2>/dev/null | sudo -E bash - >/dev/null 2>&1
    sudo dnf install -y nodejs >/dev/null 2>&1
  elif command -v yum &>/dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_22.x 2>/dev/null | sudo -E bash - >/dev/null 2>&1
    sudo yum install -y nodejs >/dev/null 2>&1
  fi
  if command -v node &>/dev/null; then
    ok "Node.js $(node -v) — 安裝完成"
  else
    fail "Node.js 安裝失敗，請聯繫講師協助"
    exit 1
  fi
fi

# Git
if ! command -v git &>/dev/null; then
  sudo apt-get install -y git >/dev/null 2>&1 || sudo dnf install -y git >/dev/null 2>&1 || true
fi

# OpenClaw
if command -v openclaw &>/dev/null; then
  ok "OpenClaw — 已安裝"
else
  info "正在安裝 OpenClaw（大約 60 秒）..."
  npm install -g openclaw >/dev/null 2>&1 || sudo npm install -g openclaw >/dev/null 2>&1
  if command -v openclaw &>/dev/null; then
    ok "OpenClaw — 安裝完成"
  else
    fail "OpenClaw 安裝失敗，請聯繫講師協助"
    exit 1
  fi
fi

ok "基礎環境就緒！"

# ═════════════════════════════════════════════════════════════
#  STEP 2 — Telegram 資訊
# ═════════════════════════════════════════════════════════════
step_header "Step 2/4 ── 連接你的 Telegram Bot"

echo -e "  ${BOLD}📱 還沒有 Bot？照下面步驟做：${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} 打開 Telegram → 搜尋 ${BOLD}@BotFather${NC}"
echo -e "  ${CYAN}2.${NC} 傳送 ${BOLD}/newbot${NC}"
echo -e "  ${CYAN}3.${NC} 輸入 Bot 名稱（隨便取）"
echo -e "  ${CYAN}4.${NC} 輸入 Bot 帳號（英文，結尾加 bot）"
echo -e "  ${CYAN}5.${NC} 複製 BotFather 回覆的 Token"
echo ""

while true; do
  ask_with_hint "貼上你的 Telegram Bot Token" "格式像 123456789:ABCdefGHI..."
  read -r TG_BOT_TOKEN
  TG_BOT_TOKEN=$(echo "$TG_BOT_TOKEN" | xargs)
  if [[ "$TG_BOT_TOKEN" =~ ^[0-9]+:.+$ ]]; then
    ok "Token 格式正確"
    break
  fi
  warn "格式不對，請重新貼上"
  echo ""
done

echo ""
echo -e "  ${BOLD}📱 取得你的 Telegram ID：${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} 在 Telegram 搜尋 ${BOLD}@userinfobot${NC}"
echo -e "  ${CYAN}2.${NC} 隨便傳一則訊息 → 它會回覆你的 ID"
echo ""

while true; do
  ask_with_hint "貼上你的 Telegram ID" "純數字，例如 123456789"
  read -r TG_OWNER_ID
  TG_OWNER_ID=$(echo "$TG_OWNER_ID" | xargs)
  if [[ "$TG_OWNER_ID" =~ ^[0-9]+$ ]]; then
    ok "ID 格式正確"
    break
  fi
  warn "應該是純數字"
  echo ""
done

# ═════════════════════════════════════════════════════════════
#  STEP 3 — ClawRouter 帳號
# ═════════════════════════════════════════════════════════════
step_header "Step 3/4 ── 建立 ClawRouter 帳號"

echo -e "  你的 AI 助手使用 ${BOLD}ClawRouter${NC} 作為大腦。"
echo -e "  一個帳號就能用 40+ 種 AI 模型（ChatGPT、Claude、Gemini...）"
echo ""

CR_REGISTER_MODE="if-missing"

echo -e "  ${CYAN}1.${NC} 我是新用戶，幫我建立帳號"
echo -e "  ${CYAN}2.${NC} 我已經有 ClawRouter 帳號"
echo ""
while true; do
  ask_with_hint "選哪個？" "1 或 2"
  read -r CR_CHOICE
  case "$CR_CHOICE" in
    1) CR_REGISTER_MODE="if-missing"; break ;;
    2) CR_REGISTER_MODE="never"; break ;;
    *) warn "請輸入 1 或 2" ;;
  esac
done
echo ""

while true; do
  while true; do
    if [ "$CR_REGISTER_MODE" = "never" ]; then
      ask_with_hint "你的 ClawRouter 帳號" ""
    else
      ask_with_hint "取一個帳號名稱" "英文或數字，例如 alice123"
    fi
    read -r CR_USERNAME
    CR_USERNAME=$(echo "$CR_USERNAME" | xargs)
    [ -n "$CR_USERNAME" ] && break
    warn "不能空白"
  done

  while true; do
    ask_with_hint "密碼" "至少 8 個字（輸入時不會顯示）"
    read -rs CR_PASSWORD
    echo ""
    [ ${#CR_PASSWORD} -ge 8 ] && break
    warn "密碼至少 8 個字"
  done

  echo ""
  info "正在連線 ClawRouter..."

  # Download bootstrap script
  TMPDIR=$(mktemp -d)
  BS_SCRIPT="$TMPDIR/bootstrap.mjs"

  curl -fsSL "$BOOTSTRAP_RAW" -o "$BS_SCRIPT" 2>/dev/null || {
    git clone --depth 1 "$SKILL_REPO" "$TMPDIR/repo" >/dev/null 2>&1 && \
      cp "$TMPDIR/repo/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs" "$BS_SCRIPT" || {
        fail "無法下載設定工具，請檢查網路"
        rm -rf "$TMPDIR"
        warn "按 Enter 重試，或 Ctrl+C 離開"
        read -r; continue
      }
  }

  BS_RESULT=$(node "$BS_SCRIPT" bootstrap \
    --base-url "$CLAWROUTER_BASE_URL" \
    --username "$CR_USERNAME" \
    --password "$CR_PASSWORD" \
    --register-mode "$CR_REGISTER_MODE" \
    --aff-code "$CLAWROUTER_AFF_CODE" \
    --with-access-token false \
    --token-name "openclaw-$(date +%s)" \
    --output json 2>&1)

  if [ $? -ne 0 ]; then
    fail "連線失敗"
    echo -e "  ${DIM}錯誤：${NC}"
    echo "$BS_RESULT" | head -5
    rm -rf "$TMPDIR"
    echo ""
    warn "按 Enter 重新輸入，或 Ctrl+C 離開"
    read -r; echo ""; continue
  fi

  MODEL_API_KEY=$(echo "$BS_RESULT" | node -e "
    let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
      try{const r=JSON.parse(d);process.stdout.write(r.api_token?.api_key||r.api_token?.key||'')}
      catch{process.exit(1)}
    })
  " 2>/dev/null)

  if [ -z "$MODEL_API_KEY" ]; then
    fail "無法取得 API Key"
    echo -e "  ${DIM}回傳：${NC}"
    echo "$BS_RESULT" | head -10
    rm -rf "$TMPDIR"
    echo ""
    warn "按 Enter 重試，或 Ctrl+C 離開"
    read -r; echo ""; continue
  fi

  rm -rf "$TMPDIR"
  ok "帳號就緒！"
  ok "API Key: ${MODEL_API_KEY:0:12}..."
  break
done

# ═════════════════════════════════════════════════════════════
#  STEP 4 — 寫設定 + 啟動
# ═════════════════════════════════════════════════════════════
step_header "Step 4/4 ── 設定 & 啟動"

info "正在寫入設定..."

# 先跑 openclaw onboard 的最小初始化（建目錄結構）
mkdir -p "$OPENCLAW_HOME/workspace"
mkdir -p "$OPENCLAW_HOME/agents/main/sessions"
mkdir -p "$OPENCLAW_HOME/skills"
mkdir -p "$OPENCLAW_HOME/logs"

# 寫 openclaw.json — 嚴格按照 OpenClaw 的 schema
# 重點：baseUrl 必須帶 /v1
cat > "$OPENCLAW_HOME/openclaw.json" << CFGEOF
{
  "models": {
    "mode": "merge",
    "providers": {
      "clawrouter": {
        "baseUrl": "${CLAWROUTER_BASE_URL}/v1",
        "apiKey": "$MODEL_API_KEY",
        "api": "openai-completions",
        "models": [
          {
            "id": "gemini-2.5-flash",
            "name": "Gemini Flash",
            "contextWindow": 1000000,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "clawrouter/gemini-2.5-flash"
      },
      "models": {
        "clawrouter/gemini-2.5-flash": {}
      },
      "workspace": "$OPENCLAW_HOME/workspace"
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw"
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$TG_BOT_TOKEN",
      "dmPolicy": "pairing",
      "groupPolicy": "allowlist",
      "streaming": "partial",
      "groups": {
        "*": { "requireMention": true }
      }
    }
  },
  "gateway": {
    "mode": "local",
    "port": 18789,
    "bind": "loopback"
  },
  "meta": {
    "lastTouchedVersion": "installer",
    "lastTouchedAt": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)"
  }
}
CFGEOF

ok "設定檔寫入完成"

# 寫 SOUL.md
cat > "$OPENCLAW_HOME/SOUL.md" << 'SOULEOF'
# Identity

You are a helpful AI assistant powered by ClawRouter.

## Style

- Be concise and friendly
- Auto-detect and match the user's language
- When speaking Chinese, use Traditional Chinese (繁體中文)
- Give direct answers first, then explain if needed
- Use markdown formatting for code
SOULEOF

ok "AI 人格設定完成"

# 安裝 ClawRouter skill
if command -v git &>/dev/null; then
  TMPSKILL=$(mktemp -d)
  git clone --depth 1 "$SKILL_ORIGIN_REPO" "$TMPSKILL" >/dev/null 2>&1 && \
    cp -r "$TMPSKILL/clawrouter-skill" "$OPENCLAW_HOME/skills/" >/dev/null 2>&1 && \
    ok "ClawRouter Skill 已安裝" || true
  rm -rf "$TMPSKILL"
fi

# 讓 OpenClaw 驗證設定
info "正在驗證設定..."
openclaw doctor --fix 2>&1 | grep -E "✓|✗|warn|error|ok|fail|Approved|token|Gateway" | head -10 || true

# 設定 gateway mode 和 auth（如果 doctor 沒處理）
openclaw config set gateway.mode local 2>/dev/null || true

# 安裝 gateway service
info "正在安裝 Gateway 服務..."
openclaw gateway install 2>/dev/null || true

# 啟動
info "正在啟動 Gateway..."
openclaw gateway start 2>/dev/null &
sleep 5

# 檢查
openclaw channels status 2>/dev/null | head -5 || true

# ═════════════════════════════════════════════════════════════
#  DONE
# ═════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}"
echo "   🎉  恭喜！你的 AI 助手已經上線了！"
echo -e "${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}👉 現在打開 Telegram，找到你的 Bot，說一聲「你好」${NC}"
echo ""
echo -e "  ${DIM}首次使用 Bot 會要求配對，照它的指示跑：${NC}"
echo -e "  ${DIM}  openclaw pairing approve telegram <CODE>${NC}"
echo ""
echo -e "  ${DIM}Telegram 指令：${NC}"
echo -e "  ${DIM}  /status — 看用量   /model — 切換模型   /help — 更多指令${NC}"
echo ""
echo -e "  ${DIM}管理（在這台主機上）：${NC}"
echo -e "  ${DIM}  openclaw doctor           檢查設定${NC}"
echo -e "  ${DIM}  openclaw logs --follow     看即時 log${NC}"
echo -e "  ${DIM}  openclaw gateway restart   重啟${NC}"
echo -e "  ${DIM}  openclaw channels status   檢查連線${NC}"
echo -e "  ${DIM}  openclaw config show       看設定${NC}"
echo -e "  ${DIM}  openclaw configure         重新設定${NC}"
echo ""
echo -e "  ${DIM}ClawRouter 後台：${CLAWROUTER_BASE_URL}（帳號：${CR_USERNAME}）${NC}"
echo -e "  ${DIM}設定檔：~/.openclaw/openclaw.json${NC}"
echo ""
