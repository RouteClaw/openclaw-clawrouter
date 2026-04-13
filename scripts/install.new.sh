#!/usr/bin/env bash
# install-v2.sh — OpenClaw + ClawRouter 一鍵安裝（新版）
set -euo pipefail

# ── Colors ──────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'

# ── Language selection ───────────────────────────────────────
LANG_MODE="zh"
echo ""
echo -e "  Select language / 選擇語言:"
echo -e "  ${CYAN}1)${NC} 繁體中文（預設）  ${CYAN}2)${NC} English"
echo -n "  👉 "
read -r _LANG_SEL
[[ "${_LANG_SEL:-1}" == "2" ]] && LANG_MODE="en"
unset _LANG_SEL

# ── Translations ─────────────────────────────────────────────
t() {
  local k="$1"
  if [ "$LANG_MODE" = "en" ]; then
    case "$k" in
      banner1)         echo "🦞  OpenClaw + ClawRouter  Setup Wizard" ;;
      banner2)         echo "Own your AI assistant in 5 minutes" ;;
      banner3)         echo "Chat with AI anytime via Telegram" ;;
      step1)           echo "Step 1/4 ── Installing OpenClaw (Auto, please wait)" ;;
      step2)           echo "Step 2/4 ── Connect Your Telegram Bot" ;;
      step3)           echo "Step 3/4 ── Create ClawRouter Account" ;;
      step4)           echo "Step 4/4 ── Configure & Launch" ;;
      installing)      echo "Installing OpenClaw, this may take 1-2 minutes..." ;;
      install_ok)      echo "OpenClaw installed" ;;
      install_fail)    echo "OpenClaw installation failed. Details:" ;;
      no_cmd)          echo "openclaw command not found. Please reopen your terminal and try again." ;;
      env_ready)       echo "Environment ready!" ;;
      tg_no_bot)       echo "📱 No Bot yet? Follow these steps:" ;;
      tg_step1)        echo "Open Telegram → Search for ${BOLD}@BotFather${NC}" ;;
      tg_step2)        echo "Send ${BOLD}/newbot${NC}" ;;
      tg_step3)        echo "Enter a Bot name (anything you like)" ;;
      tg_step4)        echo "Enter a Bot username (letters/numbers, ending with bot)" ;;
      tg_step5)        echo "Copy the Token from BotFather's reply" ;;
      tg_token_prompt) echo "Paste your Telegram Bot Token" ;;
      tg_token_hint)   echo "Format looks like 123456789:ABCdefGHI..." ;;
      tg_token_ok)     echo "Token format looks correct" ;;
      tg_token_bad)    echo "Wrong format, please paste again" ;;
      tg_id_header)    echo "📱 Get your Telegram ID:" ;;
      tg_id_step1)     echo "Search for ${BOLD}@userinfobot${NC} in Telegram" ;;
      tg_id_step2)     echo "Send any message → it will reply with your ID" ;;
      tg_id_prompt)    echo "Paste your Telegram ID" ;;
      tg_id_hint)      echo "Numbers only, e.g. 123456789" ;;
      tg_id_ok)        echo "ID format looks correct" ;;
      tg_id_bad)       echo "Should be numbers only" ;;
      cr_intro1)       echo "Your AI assistant uses ${BOLD}ClawRouter${NC} as its brain." ;;
      cr_intro2)       echo "One account gives you 40+ AI models (ChatGPT, Claude, Gemini...)" ;;
      cr_choice1)      echo "I'm a new user — create an account for me" ;;
      cr_choice2)      echo "I already have a ClawRouter account" ;;
      cr_choose)       echo "Which one?" ;;
      cr_choose_hint)  echo "1 or 2" ;;
      cr_choose_bad)   echo "Please enter 1 or 2" ;;
      cr_username_new) echo "Choose a username" ;;
      cr_username_hint) echo "Letters or numbers, e.g. alice123" ;;
      cr_username_existing) echo "Your ClawRouter username" ;;
      cr_password)     echo "Password" ;;
      cr_password_hint) echo "At least 8 characters (hidden while typing)" ;;
      cr_password_bad) echo "Password must be at least 8 characters" ;;
      cr_blank)        echo "Cannot be empty" ;;
      cr_connecting)   echo "Connecting to ClawRouter..." ;;
      cr_dl_fail)      echo "Could not download setup tool, please check your network" ;;
      cr_retry)        echo "Press Enter to retry, or Ctrl+C to quit" ;;
      cr_conn_fail)    echo "Connection failed" ;;
      cr_error)        echo "Error:" ;;
      cr_retry2)       echo "Press Enter to try again, or Ctrl+C to quit" ;;
      cr_apikey_fail)  echo "Could not retrieve API Key" ;;
      cr_result)       echo "Response:" ;;
      cr_ok)           echo "Account ready!" ;;
      writing_config)  echo "Writing config..." ;;
      config_ok)       echo "Config file written" ;;
      soul_ok)         echo "AI personality configured" ;;
      skill_updated)   echo "ClawRouter Skill updated" ;;
      skill_installed) echo "ClawRouter Skill installed" ;;
      skill_skip)      echo "Skill install skipped (won't affect usage)" ;;
      cron_ok)         echo "Skill auto-update scheduled (daily at 4am)" ;;
      gw_installing)   echo "Installing Gateway service..." ;;
      gw_starting)     echo "Starting Gateway..." ;;
      done_title)      echo "🎉  Congratulations! Your AI assistant is online!" ;;
      done_open)       echo "👉 Open Telegram, find your Bot, and say \"Hi\"" ;;
      done_pair1)      echo "First use will prompt for pairing, follow the instructions:" ;;
      done_pair2)      echo "  openclaw pairing approve telegram <CODE>" ;;
      done_cmds)       echo "Telegram commands:" ;;
      done_cmd1)       echo "  /status — usage   /model — switch model   /help — more" ;;
      done_mgmt)       echo "Management (on this server):" ;;
      done_mgmt1)      echo "  openclaw doctor           check config" ;;
      done_mgmt2)      echo "  openclaw logs --follow     live logs" ;;
      done_mgmt3)      echo "  openclaw gateway restart   restart" ;;
      done_mgmt4)      echo "  openclaw channels status   check connection" ;;
      *)               echo "$k" ;;
    esac
  else
    case "$k" in
      banner1)         echo "🦞  OpenClaw + ClawRouter  安裝精靈" ;;
      banner2)         echo "5 分鐘擁有你自己的 AI 助手" ;;
      banner3)         echo "透過 Telegram 隨時跟 AI 對話" ;;
      step1)           echo "Step 1/4 ── 安裝基礎環境（全自動，請稍候）" ;;
      step2)           echo "Step 2/4 ── 連接你的 Telegram Bot" ;;
      step3)           echo "Step 3/4 ── 建立 ClawRouter 帳號" ;;
      step4)           echo "Step 4/4 ── 設定 & 啟動" ;;
      installing)      echo "正在安裝 OpenClaw，這可能需要 1-2 分鐘..." ;;
      install_ok)      echo "OpenClaw 安裝完成" ;;
      install_fail)    echo "OpenClaw 安裝失敗，詳細訊息如下：" ;;
      no_cmd)          echo "找不到 openclaw 指令，請重新開啟 terminal 後再試" ;;
      env_ready)       echo "基礎環境就緒！" ;;
      tg_no_bot)       echo "📱 還沒有 Bot？照下面步驟做：" ;;
      tg_step1)        echo "打開 Telegram → 搜尋 ${BOLD}@BotFather${NC}" ;;
      tg_step2)        echo "傳送 ${BOLD}/newbot${NC}" ;;
      tg_step3)        echo "輸入 Bot 名稱（隨便取）" ;;
      tg_step4)        echo "輸入 Bot 帳號（英文，結尾加 bot）" ;;
      tg_step5)        echo "複製 BotFather 回覆的 Token" ;;
      tg_token_prompt) echo "貼上你的 Telegram Bot Token" ;;
      tg_token_hint)   echo "格式像 123456789:ABCdefGHI..." ;;
      tg_token_ok)     echo "Token 格式正確" ;;
      tg_token_bad)    echo "格式不對，請重新貼上" ;;
      tg_id_header)    echo "📱 取得你的 Telegram ID：" ;;
      tg_id_step1)     echo "在 Telegram 搜尋 ${BOLD}@userinfobot${NC}" ;;
      tg_id_step2)     echo "隨便傳一則訊息 → 它會回覆你的 ID" ;;
      tg_id_prompt)    echo "貼上你的 Telegram ID" ;;
      tg_id_hint)      echo "純數字，例如 123456789" ;;
      tg_id_ok)        echo "ID 格式正確" ;;
      tg_id_bad)       echo "應該是純數字" ;;
      cr_intro1)       echo "你的 AI 助手使用 ${BOLD}ClawRouter${NC} 作為大腦。" ;;
      cr_intro2)       echo "一個帳號就能用 40+ 種 AI 模型（ChatGPT、Claude、Gemini...）" ;;
      cr_choice1)      echo "我是新用戶，幫我建立帳號" ;;
      cr_choice2)      echo "我已經有 ClawRouter 帳號" ;;
      cr_choose)       echo "選哪個？" ;;
      cr_choose_hint)  echo "1 或 2" ;;
      cr_choose_bad)   echo "請輸入 1 或 2" ;;
      cr_username_new) echo "取一個帳號名稱" ;;
      cr_username_hint) echo "英文或數字，例如 alice123" ;;
      cr_username_existing) echo "你的 ClawRouter 帳號" ;;
      cr_password)     echo "密碼" ;;
      cr_password_hint) echo "至少 8 個字（輸入時不會顯示）" ;;
      cr_password_bad) echo "密碼至少 8 個字" ;;
      cr_blank)        echo "不能空白" ;;
      cr_connecting)   echo "正在連線 ClawRouter..." ;;
      cr_dl_fail)      echo "無法下載設定工具，請檢查網路" ;;
      cr_retry)        echo "按 Enter 重試，或 Ctrl+C 離開" ;;
      cr_conn_fail)    echo "連線失敗" ;;
      cr_error)        echo "錯誤：" ;;
      cr_retry2)       echo "按 Enter 重新輸入，或 Ctrl+C 離開" ;;
      cr_apikey_fail)  echo "無法取得 API Key" ;;
      cr_result)       echo "回傳：" ;;
      cr_ok)           echo "帳號就緒！" ;;
      writing_config)  echo "正在寫入設定..." ;;
      config_ok)       echo "設定檔寫入完成" ;;
      soul_ok)         echo "AI 人格設定完成" ;;
      skill_updated)   echo "ClawRouter Skill 已更新" ;;
      skill_installed) echo "ClawRouter Skill 已安裝" ;;
      skill_skip)      echo "Skill 安裝跳過（不影響使用）" ;;
      cron_ok)         echo "Skill 每日自動更新已設定（每天凌晨 4 點）" ;;
      gw_installing)   echo "正在安裝 Gateway 服務..." ;;
      gw_starting)     echo "正在啟動 Gateway..." ;;
      done_title)      echo "🎉  恭喜！你的 AI 助手已經上線了！" ;;
      done_open)       echo "👉 現在打開 Telegram，找到你的 Bot，說一聲「你好」" ;;
      done_pair1)      echo "首次使用 Bot 會要求配對，照它的指示跑：" ;;
      done_pair2)      echo "  openclaw pairing approve telegram <CODE>" ;;
      done_cmds)       echo "Telegram 指令：" ;;
      done_cmd1)       echo "  /status — 看用量   /model — 切換模型   /help — 更多指令" ;;
      done_mgmt)       echo "管理（在這台主機上）：" ;;
      done_mgmt1)      echo "  openclaw doctor           檢查設定" ;;
      done_mgmt2)      echo "  openclaw logs --follow     看即時 log" ;;
      done_mgmt3)      echo "  openclaw gateway restart   重啟" ;;
      done_mgmt4)      echo "  openclaw channels status   檢查連線" ;;
      *)               echo "$k" ;;
    esac
  fi
}

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
  [ -n "${2:-}" ] && echo -e "    ${DIM}$2${NC}"
  echo -n "    👉 "
}

# ── Globals ─────────────────────────────────────────────────
CLAWROUTER_BASE_URL="${CLAWROUTER_BASE_URL:-https://clawrouter.com}"
CLAWROUTER_AFF_CODE="${CLAWROUTER_AFF_CODE:-p1jZ}"
OPENCLAW_HOME="${HOME}/.openclaw"
SKILL_REPO="https://github.com/RouteClaw/openclaw-clawrouter"
SKILL_ORIGIN_REPO="https://github.com/RouteClaw/clawrouter-skill"
BOOTSTRAP_RAW="https://raw.githubusercontent.com/RouteClaw/openclaw-clawrouter/main/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs"

export NODE_OPTIONS="--dns-result-order=ipv4first"

sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1 || true
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1 >/dev/null 2>&1 || true

clear
echo -e "${CYAN}"
echo "   ╔══════════════════════════════════════════════╗"
echo "   ║                                              ║"
printf "   ║   %-44s║\n" "$(t banner1)"
echo "   ║                                              ║"
printf "   ║   %-44s║\n" "$(t banner2)"
printf "   ║   %-44s║\n" "$(t banner3)"
echo "   ║                                              ║"
echo "   ╚══════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ═════════════════════════════════════════════════════════════
#  STEP 1 — 安裝 OpenClaw（官方安裝腳本）
# ═════════════════════════════════════════════════════════════
step_header "$(t step1)"

info "$(t installing)"

_install_log=$(mktemp)

if curl -fsSL https://openclaw.ai/install.sh 2>>"$_install_log" \
   | bash -s -- --no-onboard >>"$_install_log" 2>&1; then
  ok "$(t install_ok)"
  rm -f "$_install_log"
else
  fail "$(t install_fail)"
  echo ""
  cat "$_install_log"
  rm -f "$_install_log"
  exit 1
fi

export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

if ! command -v openclaw &>/dev/null; then
  fail "$(t no_cmd)"
  exit 1
fi

ok "$(t env_ready)"

# ═════════════════════════════════════════════════════════════
#  STEP 2 — Telegram 資訊
# ═════════════════════════════════════════════════════════════
step_header "$(t step2)"

echo -e "  ${BOLD}$(t tg_no_bot)${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} $(t tg_step1)"
echo -e "  ${CYAN}2.${NC} $(t tg_step2)"
echo -e "  ${CYAN}3.${NC} $(t tg_step3)"
echo -e "  ${CYAN}4.${NC} $(t tg_step4)"
echo -e "  ${CYAN}5.${NC} $(t tg_step5)"
echo ""

while true; do
  ask_with_hint "$(t tg_token_prompt)" "$(t tg_token_hint)"
  read -r TG_BOT_TOKEN
  TG_BOT_TOKEN=$(echo "$TG_BOT_TOKEN" | xargs)
  if [[ "$TG_BOT_TOKEN" =~ ^[0-9]+:.+$ ]]; then
    ok "$(t tg_token_ok)"
    break
  fi
  warn "$(t tg_token_bad)"
  echo ""
done

echo ""
echo -e "  ${BOLD}$(t tg_id_header)${NC}"
echo ""
echo -e "  ${CYAN}1.${NC} $(t tg_id_step1)"
echo -e "  ${CYAN}2.${NC} $(t tg_id_step2)"
echo ""

while true; do
  ask_with_hint "$(t tg_id_prompt)" "$(t tg_id_hint)"
  read -r TG_OWNER_ID
  TG_OWNER_ID=$(echo "$TG_OWNER_ID" | xargs)
  if [[ "$TG_OWNER_ID" =~ ^[0-9]+$ ]]; then
    ok "$(t tg_id_ok)"
    break
  fi
  warn "$(t tg_id_bad)"
  echo ""
done

# ═════════════════════════════════════════════════════════════
#  STEP 3 — ClawRouter 帳號
# ═════════════════════════════════════════════════════════════
step_header "$(t step3)"

echo -e "  $(t cr_intro1)"
echo -e "  $(t cr_intro2)"
echo ""

CR_REGISTER_MODE="if-missing"

echo -e "  ${CYAN}1.${NC} $(t cr_choice1)"
echo -e "  ${CYAN}2.${NC} $(t cr_choice2)"
echo ""
while true; do
  ask_with_hint "$(t cr_choose)" "$(t cr_choose_hint)"
  read -r CR_CHOICE
  case "$CR_CHOICE" in
    1) CR_REGISTER_MODE="if-missing"; break ;;
    2) CR_REGISTER_MODE="never"; break ;;
    *) warn "$(t cr_choose_bad)" ;;
  esac
done
echo ""

while true; do
  while true; do
    if [ "$CR_REGISTER_MODE" = "never" ]; then
      ask_with_hint "$(t cr_username_existing)" ""
    else
      ask_with_hint "$(t cr_username_new)" "$(t cr_username_hint)"
    fi
    read -r CR_USERNAME
    CR_USERNAME=$(echo "$CR_USERNAME" | xargs)
    [ -n "$CR_USERNAME" ] && break
    warn "$(t cr_blank)"
  done

  while true; do
    ask_with_hint "$(t cr_password)" "$(t cr_password_hint)"
    read -rs CR_PASSWORD
    echo ""
    [ ${#CR_PASSWORD} -ge 8 ] && break
    warn "$(t cr_password_bad)"
  done

  echo ""
  info "$(t cr_connecting)"

  TMPDIR=$(mktemp -d)
  BS_SCRIPT="$TMPDIR/bootstrap.mjs"

  curl -fsSL "$BOOTSTRAP_RAW" -o "$BS_SCRIPT" 2>/dev/null || {
    git clone --depth 1 "$SKILL_REPO" "$TMPDIR/repo" >/dev/null 2>&1 && \
      cp "$TMPDIR/repo/clawrouter-skill/scripts/clawrouter-account-bootstrap.mjs" "$BS_SCRIPT" || {
        fail "$(t cr_dl_fail)"
        rm -rf "$TMPDIR"
        warn "$(t cr_retry)"
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
    fail "$(t cr_conn_fail)"
    echo -e "  ${DIM}$(t cr_error)${NC}"
    echo "$BS_RESULT" | head -5
    rm -rf "$TMPDIR"
    echo ""
    warn "$(t cr_retry2)"
    read -r; echo ""; continue
  fi

  MODEL_API_KEY=$(echo "$BS_RESULT" | node -e "
    let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{
      try{const r=JSON.parse(d);process.stdout.write(r.api_token?.api_key||r.api_token?.key||'')}
      catch{process.exit(1)}
    })
  " 2>/dev/null)

  if [ -z "$MODEL_API_KEY" ]; then
    fail "$(t cr_apikey_fail)"
    echo -e "  ${DIM}$(t cr_result)${NC}"
    echo "$BS_RESULT" | head -10
    rm -rf "$TMPDIR"
    echo ""
    warn "$(t cr_retry)"
    read -r; echo ""; continue
  fi

  rm -rf "$TMPDIR"
  ok "$(t cr_ok)"
  ok "API Key: ${MODEL_API_KEY:0:12}..."
  break
done

# ═════════════════════════════════════════════════════════════
#  STEP 4 — 寫設定 + 啟動
# ═════════════════════════════════════════════════════════════
step_header "$(t step4)"

info "$(t writing_config)"

mkdir -p "$OPENCLAW_HOME/workspace"
mkdir -p "$OPENCLAW_HOME/agents/main/sessions"
mkdir -p "$OPENCLAW_HOME/skills"
mkdir -p "$OPENCLAW_HOME/logs"

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
          { "id": "gemini-2.5-flash", "name": "Gemini Flash", "contextWindow": 1000000, "maxTokens": 8192 },
          { "id": "gpt-4o", "name": "GPT-4o", "contextWindow": 128000, "maxTokens": 16384 },
          { "id": "claude-sonnet-4-20250514", "name": "Claude Sonnet", "contextWindow": 200000, "maxTokens": 8192 },
          { "id": "deepseek-chat", "name": "DeepSeek Chat", "contextWindow": 128000, "maxTokens": 8192 },
          { "id": "gpt-4.1-mini", "name": "GPT-4.1 Mini", "contextWindow": 128000, "maxTokens": 16384 }
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
        "clawrouter/gemini-2.5-flash": {},
        "clawrouter/gpt-4o": {},
        "clawrouter/claude-sonnet-4-20250514": {},
        "clawrouter/deepseek-chat": {},
        "clawrouter/gpt-4.1-mini": {}
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

ok "$(t config_ok)"

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

ok "$(t soul_ok)"

SKILL_REPO_DIR="$OPENCLAW_HOME/skills/_clawrouter-skill-repo"
SKILL_LINK="$OPENCLAW_HOME/skills/clawrouter-skill"

if command -v git &>/dev/null; then
  if [ -d "$SKILL_REPO_DIR/.git" ]; then
    (cd "$SKILL_REPO_DIR" && git pull --ff-only >/dev/null 2>&1) || true
    ok "$(t skill_updated)"
  else
    rm -rf "$SKILL_REPO_DIR" "$SKILL_LINK"
    git clone --depth 1 "$SKILL_ORIGIN_REPO" "$SKILL_REPO_DIR" >/dev/null 2>&1 && \
      ln -sf "$SKILL_REPO_DIR/clawrouter-skill" "$SKILL_LINK" && \
      ok "$(t skill_installed)" || \
      warn "$(t skill_skip)"
  fi

  CRON_CMD="cd $SKILL_REPO_DIR && git pull --ff-only >/dev/null 2>&1"
  EXISTING_CRON=$(crontab -l 2>/dev/null || echo "")
  FILTERED_CRON=$(echo "$EXISTING_CRON" | grep -v "clawrouter-skill-repo" || true)
  echo "${FILTERED_CRON}
0 4 * * * $CRON_CMD" | crontab - 2>/dev/null && \
    ok "$(t cron_ok)" || true
fi

openclaw config set gateway.mode local 2>/dev/null || true

info "$(t gw_installing)"
yes | openclaw gateway install 2>/dev/null || true

info "$(t gw_starting)"
openclaw gateway start 2>/dev/null || openclaw gateway 2>/dev/null &
sleep 5

openclaw channels status 2>/dev/null | head -5 || true

# ═════════════════════════════════════════════════════════════
#  DONE
# ═════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}"
echo "   $(t done_title)"
echo -e "${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}$(t done_open)${NC}"
echo ""
echo -e "  ${DIM}$(t done_pair1)${NC}"
echo -e "  ${DIM}$(t done_pair2)${NC}"
echo ""
echo -e "  ${DIM}$(t done_cmds)${NC}"
echo -e "  ${DIM}$(t done_cmd1)${NC}"
echo ""
echo -e "  ${DIM}$(t done_mgmt)${NC}"
echo -e "  ${DIM}$(t done_mgmt1)${NC}"
echo -e "  ${DIM}$(t done_mgmt2)${NC}"
echo -e "  ${DIM}$(t done_mgmt3)${NC}"
echo -e "  ${DIM}$(t done_mgmt4)${NC}"
echo ""
echo -e "  ${DIM}ClawRouter: ${CLAWROUTER_BASE_URL}  ($([ "$LANG_MODE" = "en" ] && echo "user" || echo "帳號")：${CR_USERNAME})${NC}"
echo -e "  ${DIM}$([ "$LANG_MODE" = "en" ] && echo "Config" || echo "設定檔")：~/.openclaw/openclaw.json${NC}"
echo ""
