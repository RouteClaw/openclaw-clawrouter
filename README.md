# 🦞 OpenClaw + ClawRouter

> 零基礎，5 分鐘，在雲端擁有你自己的 Telegram AI 助手。

## 這是什麼？

一鍵安裝工具，讓任何人（不需要程式背景）都能在 AWS EC2 上部署自己的 AI 助手：

- **Telegram 操作** — 在手機上隨時跟 AI 對話
- **ClawRouter 驅動** — 40+ 種 AI 模型，自動選最省的
- **完全屬於你** — 資料不經過第三方

## Quick Start

在你的 EC2 主機上，跑這一行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/RouteClaw/openclaw-clawrouter/main/scripts/install.sh)
```

安裝精靈會引導你完成所有設定。不需要打任何程式碼。

## 你需要準備

| 項目 | 去哪拿 |
|------|--------|
| AWS 帳號 | https://aws.amazon.com（免費註冊） |
| Telegram Bot Token | Telegram 裡找 @BotFather |
| Telegram User ID | Telegram 裡找 @userinfobot |

## 架構

```
📱 你的手機 Telegram
        ↕
☁️  你的 EC2 主機
    ├── OpenClaw Gateway（24hr 在線）
    ├── SOUL.md（AI 的人格設定）
    └── ClawRouter Skill（帳號管理）
        ↕
🌐 ClawRouter API（clawrouter.com）
    ├── Claude
    ├── ChatGPT
    ├── Gemini
    ├── DeepSeek
    └── 40+ 更多模型...
```

## EC2 最低需求

- **Instance type**: `t3.micro`（免費方案適用）
- **AMI**: Ubuntu 24.04 LTS
- **不需要開任何 port**（Telegram 用 long-polling）

## 安裝完成後能做什麼？

在 Telegram 裡：

| 傳什麼 | 會發生什麼 |
|--------|-----------|
| 任何問題 | AI 回答你 |
| `/status` | 看用了多少、花了多少錢 |
| `/model` | 看有哪些模型 |
| `/model deepseek-chat` | 切到最便宜的模型 |
| `/model claude-sonnet-4-20250514` | 切到 Anthropic Claude |

## 自訂你的 AI

編輯 `~/.openclaw/SOUL.md`，可以改 AI 的名字、性格、專長。改完後：

```bash
sudo systemctl restart openclaw
```

## 月費參考

| 項目 | 費用 |
|------|------|
| EC2 t3.micro | ~$7.50/月（或免費方案內免費） |
| ClawRouter（輕度使用） | ~$3-10/月 |
| **合計** | **~$10-18/月** |

## 不想用了？

在 AWS Console 把 EC2 Terminate 就好。所有東西都會一起刪除。

## 檔案結構

```
openclaw-clawrouter/
├── README.md                    ← 你在看的這份
├── scripts/
│   ├── install.sh               ← 一鍵安裝腳本
│   └── check.sh                 ← 安裝後健檢工具
├── clawrouter-skill/            ← OpenClaw Skill
│   ├── SKILL.md
│   ├── agents/openai.yaml
│   ├── references/
│   │   ├── api-usage.md
│   │   └── backend-contracts.md
│   └── scripts/
│       └── clawrouter-account-bootstrap.mjs
├── templates/
│   ├── openclaw.json            ← 設定檔模板
│   └── SOUL.md                  ← AI 人格模板
└── docs/
    └── workshop-guide.md        ← Workshop 教學指南
```

## Workshop

這個 repo 是為 workshop 設計的。詳細教學見 [docs/workshop-guide.md](docs/workshop-guide.md)。

## License

MIT

## Links

- [ClawRouter](https://clawrouter.com)
- [OpenClaw](https://openclaw.ai)
- [OpenClaw Docs](https://docs.openclaw.ai)
