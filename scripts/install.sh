#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  OpenClaw + ClawRouter — One-click installer
#  Designed for beginners. Zero programming knowledge required.
#
#  Usage:  bash <(curl -fsSL https://raw.githubusercontent.com/RouteClaw/openclaw-clawrouter/main/scripts/install.sh)
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
  local prompt="$1"
  local hint="$2"
  echo -e "  ${CYAN}▶${NC} ${BOLD}$prompt${NC}"
  if [ -n "$hint" ]; then
    echo -e "    ${DIM}$hint${NC}"
  fi
  echo -n "    👉 "
}

press_enter() {
  echo ""
  echo -e "  ${DIM}準備好了就按 Enter 繼續 ⏎${NC}"
  read -r
}

# ── Globals ─────────────────────────────────────────────────
CLAWROUTER_BASE_URL="${CLAWROUTER_BASE_URL:-https://clawrouter.com}"
CLAWROUTER_AFF_CODE="${CLAWROUTER_AFF_CODE:-p1jZ}"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
SKILL_REPO="https://github.com/RouteClaw/openclaw-clawrouter"
SKILL_ORIGIN_REPO="https://github.com/RouteClaw/clawrouter-skill"
BOOTSTRAP_RAW="https://raw.githubusercontent.com/RouteClaw/openclaw-clawrouter/main/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs"

# ═════════════════════════════════════════════════════════════
#  STEP 1 — 自動安裝基礎環境
# ═════════════════════════════════════════════════════════════
step_header "Step 1/3 ── 安裝基礎環境（全自動，請稍候）"

info "正在檢查系統環境..."

# Node.js
install_node() {
  info "正在安裝 Node.js（大約 30 秒）..."
  if command -v apt-get &>/dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_22.x 2>/dev/null | sudo -E bash - >/dev/null 2>&1
    sudo apt-get install -y nodejs >/dev/null 2>&1
  elif command -v dnf &>/dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_22.x 2>/dev/null | sudo -E bash - >/dev/null 2>&1
    sudo dnf install -y nodejs >/dev/null 2>&1
  elif command -v yum &>/dev/null; then
    curl -fsSL https://rpm.nodesource.com/setup_22.x 2>/dev/null | sudo -E bash - >/dev/null 2>&1
    sudo yum install -y nodejs >/dev/null 2>&1
  else
    fail "無法自動安裝 Node.js，請聯繫講師協助"
    exit 1
  fi
}

if command -v node &>/dev/null; then
  NODE_VER=$(node -v 2>/dev/null | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
  if [ "$NODE_MAJOR" -ge 22 ] 2>/dev/null; then
    ok "Node.js v$NODE_VER — 已安裝"
  else
    install_node
  fi
else
  install_node
fi

# Verify
if ! command -v node &>/dev/null; then
  fail "Node.js 安裝失敗，請聯繫講師協助"
  exit 1
fi
ok "Node.js $(node -v) — 就緒"

# Git
if ! command -v git &>/dev/null; then
  info "正在安裝 Git..."
  sudo apt-get install -y git >/dev/null 2>&1 || sudo dnf install -y git >/dev/null 2>&1 || true
fi

# OpenClaw
if command -v openclaw &>/dev/null; then
  ok "OpenClaw — 已安裝"
else
  info "正在安裝 OpenClaw（大約 60 秒）..."
  npm install -g openclaw >/dev/null 2>&1 || sudo npm install -g openclaw >/dev/null 2>&1
  if command -v openclaw &>/dev/null; then
    ok "OpenClaw — 安裝成功"
  else
    fail "OpenClaw 安裝失敗，請聯繫講師協助"
    exit 1
  fi
fi

echo ""
ok "基礎環境全部就緒！"

# ═════════════════════════════════════════════════════════════
#  STEP 2 — 建立 Telegram Bot
# ═════════════════════════════════════════════════════════════
step_header "Step 2/3 ── 連接你的 Telegram Bot"

echo -e "  現在需要你在 Telegram 上建立一個 Bot。"
echo -e "  如果你已經有了，直接貼上 Token。"
echo ""
echo -e "  ${BOLD}📱 還沒有 Bot？照下面步驟做：${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} 打開 Telegram"
echo -e "  ${CYAN}2.${NC} 搜尋 ${BOLD}@BotFather${NC} 並點進去"
echo -e "  ${CYAN}3.${NC} 傳送 ${BOLD}/newbot${NC}"
echo -e "  ${CYAN}4.${NC} 輸入你的 Bot 名稱（隨便取，例如「我的AI助手」）"
echo -e "  ${CYAN}5.${NC} 輸入 Bot 帳號（要英文，結尾要加 bot，例如 myai_bot）"
echo -e "  ${CYAN}6.${NC} BotFather 會回覆一串 Token，${BOLD}複製它${NC}"
echo ""
echo -e "  ${DIM}Token 長這樣：123456789:ABCdefGHIjklMNO-pqrstuvwxyz${NC}"
echo ""

while true; do
  ask_with_hint "貼上你的 Telegram Bot Token" ""
  read -r TG_BOT_TOKEN
  TG_BOT_TOKEN=$(echo "$TG_BOT_TOKEN" | xargs)  # trim whitespace

  if [[ "$TG_BOT_TOKEN" =~ ^[0-9]+:.+$ ]]; then
    ok "Token 格式正確"
    break
  else
    warn "這不像是有效的 Token（應該像 123456:ABC...）"
    echo -e "    ${DIM}請再試一次，或檢查是否複製完整${NC}"
    echo ""
  fi
done

echo ""
echo -e "  ${BOLD}📱 接下來取得你的 Telegram ID：${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} 在 Telegram 搜尋 ${BOLD}@userinfobot${NC}"
echo -e "  ${CYAN}2.${NC} 隨便傳一則訊息給它"
echo -e "  ${CYAN}3.${NC} 它會回覆你的 ID（一串數字）"
echo ""

while true; do
  ask_with_hint "貼上你的 Telegram ID" "純數字，例如 123456789"
  read -r TG_OWNER_ID
  TG_OWNER_ID=$(echo "$TG_OWNER_ID" | xargs)

  if [[ "$TG_OWNER_ID" =~ ^[0-9]+$ ]]; then
    ok "ID 格式正確"
    break
  else
    warn "應該是純數字（例如 123456789）"
    echo ""
  fi
done

# ═════════════════════════════════════════════════════════════
#  STEP 3 — ClawRouter 帳號 + 啟動
# ═════════════════════════════════════════════════════════════
step_header "Step 3/3 ── 建立 ClawRouter 帳號 & 啟動"

echo -e "  你的 AI 助手使用 ${BOLD}ClawRouter${NC} 作為大腦。"
echo -e "  一個帳號就能用 40+ 種 AI 模型（ChatGPT、Claude、Gemini...）"
echo ""
echo -e "  ${DIM}如果你已經有帳號，輸入現有的就好。沒有的話幫你建一個。${NC}"
echo ""

while true; do
  # ── Ask credentials ──
  while true; do
    ask_with_hint "取一個帳號名稱" "英文或數字，例如 alice123"
    read -r CR_USERNAME
    CR_USERNAME=$(echo "$CR_USERNAME" | xargs)
    if [ -n "$CR_USERNAME" ]; then
      break
    fi
    warn "不能空白"
  done

  while true; do
    ask_with_hint "設定密碼" "至少 8 個字，例如 mypassword123"
    read -r CR_PASSWORD
    if [ ${#CR_PASSWORD} -ge 8 ]; then
      break
    fi
    warn "密碼至少 8 個字"
  done

  echo ""
  info "正在建立帳號並取得 API Key..."

  # Download bootstrap script
  TMPDIR=$(mktemp -d)
  BOOTSTRAP_OK=false

  if command -v git &>/dev/null; then
    git clone --depth 1 "$SKILL_REPO" "$TMPDIR/repo" >/dev/null 2>&1 && \
      BOOTSTRAP_OK=true || true
  fi

  if [ "$BOOTSTRAP_OK" = true ] && \
     [ -f "$TMPDIR/repo/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs" ]; then
    BS_SCRIPT="$TMPDIR/repo/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs"
  else
    BS_SCRIPT="$TMPDIR/bootstrap.mjs"
    curl -fsSL "$BOOTSTRAP_RAW" \
      -o "$BS_SCRIPT" 2>/dev/null || {
        fail "無法下載設定工具，請檢查網路連線"
        rm -rf "$TMPDIR"
        echo ""
        warn "按 Enter 重試，或 Ctrl+C 離開"
        read -r
        continue
      }
  fi

  BS_RESULT=$(node "$BS_SCRIPT" bootstrap \
    --base-url "$CLAWROUTER_BASE_URL" \
    --username "$CR_USERNAME" \
    --password "$CR_PASSWORD" \
    --register-mode if-missing \
    --aff-code "$CLAWROUTER_AFF_CODE" \
    --with-access-token false \
    --token-name "openclaw-$(date +%s)" \
    --output json 2>&1)

  if [ $? -ne 0 ]; then
    fail "帳號建立失敗"
    echo ""
    echo -e "  ${DIM}可能的原因：${NC}"
    echo -e "  ${DIM}• 帳號名稱已被使用 → 換一個名字${NC}"
    echo -e "  ${DIM}• ClawRouter 暫時無法連線 → 稍後重試${NC}"
    echo ""
    echo -e "  ${DIM}錯誤訊息：${NC}"
    echo "$BS_RESULT" | head -5
    rm -rf "$TMPDIR"
    echo ""
    warn "按 Enter 重新輸入帳號密碼，或 Ctrl+C 離開"
    read -r
    echo ""
    continue
  fi

  MODEL_API_KEY=$(echo "$BS_RESULT" | node -e "
    let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
      try{const r=JSON.parse(d);process.stdout.write(r.api_token?.key||'')}
      catch{process.exit(1)}
    })
  " 2>/dev/null)

  if [ -z "$MODEL_API_KEY" ]; then
    fail "無法取得 API Key"
    echo ""
    echo -e "  ${DIM}帳號可能已建立但 token 取得失敗${NC}"
    rm -rf "$TMPDIR"
    echo ""
    warn "按 Enter 用同一組帳密重試，或 Ctrl+C 離開"
    read -r
    echo ""
    continue
  fi

  rm -rf "$TMPDIR"
  ok "帳號建立成功！"
  ok "API Key: ${MODEL_API_KEY:0:12}..."
  break
done

# ── Write config ──
info "正在寫入設定..."

mkdir -p "$OPENCLAW_HOME"
mkdir -p "$OPENCLAW_HOME/skills"

cat > "$OPENCLAW_HOME/openclaw.json" <<CFGEOF
{
  "models": {
    "default": "claude-sonnet-4-20250514",
    "providers": {
      "clawrouter": {
        "type": "openai-compatible",
        "baseURL": "${CLAWROUTER_BASE_URL}/v1",
        "apiKey": "$MODEL_API_KEY",
        "models": ["*"]
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "$TG_BOT_TOKEN",
      "allowFrom": ["$TG_OWNER_ID"],
      "groups": {
        "*": { "requireMention": true }
      }
    }
  }
}
CFGEOF

ok "設定檔寫入完成"

# ── SOUL.md ──
cat > "$OPENCLAW_HOME/SOUL.md" <<'SOULEOF'
# Identity

You are a helpful AI assistant.
You communicate via Telegram and can help with any topic.

## Style

- Be concise and friendly
- Auto-detect and match the user's language
- When speaking Chinese, use Traditional Chinese (繁體中文)
- Give direct answers first, then explain if needed
- Use markdown formatting for code
SOULEOF

ok "AI 人格設定完成"

# ── Install ClawRouter skill（from canonical repo）──
if command -v git &>/dev/null; then
  TMPSKILL=$(mktemp -d)
  git clone --depth 1 "$SKILL_ORIGIN_REPO" "$TMPSKILL" >/dev/null 2>&1 && \
    cp -r "$TMPSKILL/clawrouter-skill" "$OPENCLAW_HOME/skills/" >/dev/null 2>&1 && \
    ok "ClawRouter Skill 已安裝" || \
    info "Skill 安裝跳過（不影響使用，待 clawrouter-skill repo 公開後可手動安裝）"
  rm -rf "$TMPSKILL"
fi

# ── systemd service ──
if [ -d "/etc/systemd/system" ] && command -v systemctl &>/dev/null; then
  CURRENT_USER=$(whoami)
  OPENCLAW_BIN=$(which openclaw 2>/dev/null || echo "/usr/bin/openclaw")

  sudo tee /etc/systemd/system/openclaw.service > /dev/null <<SVCEOF
[Unit]
Description=OpenClaw AI Agent
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
Environment=HOME=$HOME
ExecStart=$OPENCLAW_BIN gateway start
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
SVCEOF

  sudo systemctl daemon-reload >/dev/null 2>&1
  sudo systemctl enable openclaw >/dev/null 2>&1
  ok "開機自動啟動 — 已設定"
fi

# ── Start the gateway ──
info "正在啟動..."

if [ -f /etc/systemd/system/openclaw.service ]; then
  sudo systemctl start openclaw >/dev/null 2>&1 && \
    ok "AI 助手已啟動！" || {
      warn "自動啟動失敗，嘗試手動啟動..."
      openclaw gateway start &
      sleep 2
      ok "AI 助手已啟動！"
    }
else
  openclaw gateway start &
  sleep 2
  ok "AI 助手已啟動！"
fi

# ═════════════════════════════════════════════════════════════
#  DONE
# ═════════════════════════════════════════════════════════════
echo ""
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}"
echo "   🎉  恭喜！你的 AI 助手已經上線了！"
echo -e "${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}👉 現在打開 Telegram，找到你的 Bot，說一聲「你好」${NC}"
echo ""
echo ""
echo -e "  ${DIM}你可以試試這些：${NC}"
echo -e "  ${DIM}• 問它任何問題${NC}"
echo -e "  ${DIM}• 傳 /status 看目前用了多少${NC}"
echo -e "  ${DIM}• 傳 /model 看有哪些模型可以切換${NC}"
echo ""
echo -e "  ${DIM}ClawRouter 後台：${CLAWROUTER_BASE_URL}${NC}"
echo -e "  ${DIM}帳號：${CR_USERNAME}${NC}"
echo ""
echo -e "  ${DIM}設定檔位置：~/.openclaw/openclaw.json${NC}"
echo -e "  ${DIM}AI 人格設定：~/.openclaw/SOUL.md${NC}"
echo ""
echo -e "  ${DIM}💡 如果你有自己的 OpenAI / Anthropic API Key，${NC}"
echo -e "  ${DIM}   可以編輯 ~/.openclaw/openclaw.json 替換 provider 設定${NC}"
echo ""
