---
name: clawrouter-skill
description: ClawRouter account management and model operations. Use when the task involves signup, login, API tokens, payment links, listing available models, switching models, checking current model, or checking account balance. Also use when the user asks about available AI models, wants to change models, or asks about their remaining credits.
metadata:
  short-description: ClawRouter model management, account bootstrap, and self-service operations
---

# ClawRouter Account Bootstrap

## Overview

This skill uses the current ClawRouter HTTP APIs instead of browser automation. It is for repeatable command-line execution of:

- user registration
- password login
- optional 2FA login completion
- management access token generation
- API key token creation and retrieval
- payment checkout link creation for the providers already implemented in backend

The bundled script is zero-dependency beyond Node.js. It maintains the session cookie jar itself and sends the required `New-API-User` header on authenticated routes.

## Use This Skill When

- The user asks about available models, wants to list models, or says "有什麼模型", "支援哪些模型", "what models"
- The user wants to switch/change the current model, or says "切換模型", "換模型", "use model X"
- The user asks what model is currently active, or says "現在用什麼模型", "current model"
- The user asks about balance, credits, or quota, or says "餘額", "額度", "how much credit"
- The user wants AI to complete ClawRouter signup or login from a command or script.
- The user wants a reusable bootstrap flow for account creation plus API key issuance.
- The task is to create payment checkout links through existing `epay`, `stripe`, or `creem` routes.
- You need to decide whether backend work is actually necessary.

Do not change backend first. The current repo already exposes the core auth and token flows.

## Primary Command

Run the bundled Node script:

```powershell
node skills/clawrouter-account-bootstrap/scripts/clawrouter-account-bootstrap.mjs --help
```

For automation, prefer JSON output:

```powershell
node skills/clawrouter-account-bootstrap/scripts/clawrouter-account-bootstrap.mjs bootstrap `
  --base-url http://127.0.0.1:3000 `
  --username demo-user `
  --password demo-password-123 `
  --register-mode if-missing `
  --with-access-token true `
  --output json
```

## Workflow

### 1. Probe platform state

Always start with `status` or let `bootstrap` do it implicitly.

The script checks `/api/status` and uses that to detect blockers such as:

- Turnstile enabled
- email verification enabled
- passkey or 2FA only paths that need extra input

### 2. Choose the auth path

- If you have `username` and `password`, use the session flow.
- If you already have a management access token plus user id, use `--access-token` and `--user-id`.

Important: ClawRouter management access tokens are sent as the raw `Authorization` header value, not `Bearer ...`.

### 3. Bootstrap the account and token

Use `bootstrap` to:

1. optionally register the user
2. log in
3. optionally generate a new management access token
4. create a new user API token
5. search the token list and return the ready-to-use `sk-...` key

The token creation endpoint does not return the key directly, so the script follows up with token search and reconstructs the final `sk-...` value.

### 4. Payment links

Use `payment-link` only for providers already implemented in backend:

- `epay`
- `stripe`
- `creem`

If the user asks for `x402`, do not pretend it exists. Report that this repo does not implement x402 yet and keep it as a planned extension unless the user explicitly asks for backend work.

## Using ClawRouter APIs

After the script creates or returns an API token, use the token against the public ClawRouter domain:

- Base URL: `https://clawrouter.com`
- Auth header: `Authorization: Bearer sk-...`

Common documented methods to expose in answers or generated scripts:

- `GET /v1/models`
  - Fetch the currently available models.
- `POST /v1/chat/completions`
  - OpenAI-compatible chat completions.
- `POST /v1/responses`
  - OpenAI-compatible Responses API.
- `POST /v1/images/generations/`
  - OpenAI-compatible image generation.
- `POST /v1/moderations`
  - OpenAI-compatible moderation checks.
- `GET /v1/realtime`
  - WebSocket realtime endpoint. Use `wss://clawrouter.com/v1/realtime?...`.

When a user asks how to call ClawRouter after bootstrap, prefer concrete examples using `https://clawrouter.com` instead of local placeholder URLs.

See [references/api-usage.md](references/api-usage.md) for concise endpoint guidance derived from the official docs.

## Guardrails

- If Turnstile is enabled and no `--turnstile-token` is provided, stop and report it.
- If email verification is enabled and the workflow truly requires registration, require `--email` and `--verification-code`.
- If login requires 2FA, require `--twofa-code`.
- Use unique token names unless the user explicitly wants a fixed one.
- Prefer bounded token settings for real environments if the user gives security requirements; otherwise the script keeps close to the current UI conventions.

## OpenClaw Integration

After bootstrapping an account and obtaining an API key, configure OpenClaw to use ClawRouter as its model provider.

### Auto-Configuration

The installer script handles this automatically. For manual setup, edit `~/.openclaw/openclaw.json`. Important: `baseUrl` must include `/v1`.

```json
{
  "models": {
    "mode": "merge",
    "providers": {
      "clawrouter": {
        "baseUrl": "https://clawrouter.com/v1",
        "apiKey": "sk-YOUR_KEY_HERE",
        "api": "openai-completions",
        "models": [
          { "id": "gemini-2.5-flash", "name": "Gemini Flash", "contextWindow": 1000000, "maxTokens": 8192 }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": { "primary": "clawrouter/gemini-2.5-flash" }
    }
  }
}
```

## Model Management (Use This When the User Asks About Models)

### List available models

When the user asks "what models are available", "有什麼模型", "支援哪些模型", run:

```bash
curl -s https://clawrouter.com/v1/models \
  -H "Authorization: Bearer $(node -e "const c=require('$HOME/.openclaw/openclaw.json');console.log(c.models.providers.clawrouter.apiKey)")" \
  | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const m=JSON.parse(d).data;m.forEach(x=>console.log(x.id))})"
```

Present the results in a clean list grouped by provider:
- **Anthropic**: claude-opus-4-6, claude-sonnet-4-20250514, claude-haiku-4-5-20251001
- **OpenAI**: gpt-5, gpt-4o, gpt-4.1-mini
- **Google**: gemini-2.5-flash, gemini-3.1-pro-preview
- **DeepSeek**: deepseek-chat (cheapest option)

### Check current model

When the user asks "what model am I using", "現在用什麼模型", read the config:

```bash
node -e "const c=require('$HOME/.openclaw/openclaw.json');console.log('Current model:', c.agents.defaults.model.primary)"
```

### Switch model

When the user asks to switch models, "切換到 X", "用 X 模型":

1. First verify the requested model exists on ClawRouter (run the list command above)
2. Update the config:

```bash
node -e "
const fs=require('fs');
const f=process.env.HOME+'/.openclaw/openclaw.json';
const c=JSON.parse(fs.readFileSync(f,'utf8'));
const MODEL_ID='TARGET_MODEL_ID';
// Add model to provider if not present
const models=c.models.providers.clawrouter.models;
if(!models.find(m=>m.id===MODEL_ID)){
  models.push({id:MODEL_ID,name:MODEL_ID,contextWindow:200000,maxTokens:8192});
}
// Set as primary
c.agents.defaults.model.primary='clawrouter/'+MODEL_ID;
c.agents.defaults.models={'clawrouter/'+MODEL_ID:{}};
fs.writeFileSync(f,JSON.stringify(c,null,2));
console.log('Switched to '+MODEL_ID);
"
```

Replace `TARGET_MODEL_ID` with the actual model ID. After switching, tell the user the change will take effect after gateway reload. OpenClaw hot-reloads model config changes automatically.

### Check balance and usage

When the user asks "how much credit do I have", "還有多少額度", "餘額":

```bash
node -e "
const f=process.env.HOME+'/.openclaw/openclaw.json';
const c=require(f);
const key=c.models.providers.clawrouter.apiKey;
fetch('https://clawrouter.com/api/user/self',{headers:{Authorization:key,'New-API-User':'0'}})
  .then(r=>r.json())
  .then(d=>{
    if(d.data){
      const q=d.data.quota||0;
      const u=d.data.used_quota||0;
      const r=q-u;
      console.log('Total quota: $'+(q/500000).toFixed(2));
      console.log('Used: $'+(u/500000).toFixed(2));
      console.log('Remaining: $'+(r/500000).toFixed(2));
    } else console.log('Unable to fetch balance');
  }).catch(e=>console.log('Error:',e.message));
"
```

Note: The quota values from the API are in internal units. Divide by 500000 to get approximate USD value.

### Model Switching via Telegram

Users can also use OpenClaw's built-in `/model` command if models are pre-registered in the config. The installer pre-loads these models:

- `clawrouter/gemini-2.5-flash` — Google Gemini Flash (fast, cheap)
- `clawrouter/gpt-4o` — OpenAI GPT-4o
- `clawrouter/claude-sonnet-4-20250514` — Anthropic Claude Sonnet
- `clawrouter/deepseek-chat` — DeepSeek (cheapest)

### Top-up via Telegram (Planned)

Future skill extension will support `/topup` command inside Telegram that generates a payment link using the existing `payment-link` command.

## When Backend Changes Are Justified

Only consider backend edits if one of these is true:

- the existing routes cannot complete the required flow
- the current flow leaks secrets or has an auth/header mismatch
- the user explicitly wants x402 implemented server-side

If backend changes become necessary, read [references/backend-contracts.md](references/backend-contracts.md) first and then inspect the referenced source files in the repo.
