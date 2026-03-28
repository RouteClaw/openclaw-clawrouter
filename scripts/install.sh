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
SKILL_REPO="https://github.com/RouteClaw/openclaw-clawrouter"
SKILL_ORIGIN_REPO="https://github.com/RouteClaw/clawrouter-skill"
BOOTSTRAP_RAW="https://raw.githubusercontent.com/RouteClaw/openclaw-clawrouter/main/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs"

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
    # Fallback: try git clone
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
#  STEP 4 — 交給 OpenClaw 設定 + 啟動
# ═════════════════════════════════════════════════════════════
step_header "Step 4/4 ── 設定 & 啟動"

info "正在交給 OpenClaw 處理設定..."

# 用 openclaw 自己的 CLI 寫入設定
openclaw config set channels.telegram.botToken "$TG_BOT_TOKEN" 2>/dev/null || true
openclaw config set channels.telegram.dmPolicy "allowlist" 2>/dev/null || true
openclaw config set channels.telegram.allowFrom "$TG_OWNER_ID" 2>/dev/null || true

openclaw config set models.providers.clawrouter.baseUrl "${CLAWROUTER_BASE_URL}/v1" 2>/dev/null || true
openclaw config set models.providers.clawrouter.apiKey "$MODEL_API_KEY" 2>/dev/null || true
openclaw config set models.providers.clawrouter.api "openai-completions" 2>/dev/null || true

ok "Telegram + ClawRouter 設定完成"

# 讓 OpenClaw 自己驗證
echo ""
info "OpenClaw 正在驗證設定..."
openclaw doctor 2>&1 | grep -E "✓|✗|warn|error|ok|fail" | head -10 || true

# 安裝 ClawRouter skill
if command -v git &>/dev/null; then
  OPENCLAW_HOME="${HOME}/.openclaw"
  mkdir -p "$OPENCLAW_HOME/skills"
  TMPSKILL=$(mktemp -d)
  git clone --depth 1 "$SKILL_ORIGIN_REPO" "$TMPSKILL" >/dev/null 2>&1 && \
    cp -r "$TMPSKILL/clawrouter-skill" "$OPENCLAW_HOME/skills/" >/dev/null 2>&1 && \
    ok "ClawRouter Skill 已安裝" || true
  rm -rf "$TMPSKILL"
fi

# 啟動
echo ""
info "正在啟動 Gateway..."
openclaw gateway start 2>&1 &
sleep 3

# 檢查 Telegram 連線
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
echo -e "  ${DIM}Telegram 指令：${NC}"
echo -e "  ${DIM}  /status — 看用量   /model — 切換模型   /help — 更多指令${NC}"
echo ""
echo -e "  ${DIM}管理（在這台主機上）：${NC}"
echo -e "  ${DIM}  openclaw doctor           檢查設定${NC}"
echo -e "  ${DIM}  openclaw gateway logs     看 log${NC}"
echo -e "  ${DIM}  openclaw gateway restart  重啟${NC}"
echo -e "  ${DIM}  openclaw channels status  檢查連線${NC}"
echo -e "  ${DIM}  openclaw config show      看設定${NC}"
echo ""
echo -e "  ${DIM}ClawRouter 後台：${CLAWROUTER_BASE_URL}（帳號：${CR_USERNAME}）${NC}"
echo -e "  ${DIM}設定檔：~/.openclaw/openclaw.json${NC}"
echo ""
