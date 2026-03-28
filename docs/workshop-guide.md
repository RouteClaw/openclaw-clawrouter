# 🦞 Workshop：打造你自己的 AI 助手

> 零基礎，60 分鐘，從零開始擁有一個專屬於你的 Telegram AI 助手。

---

## 你會得到什麼？

完成後你會有一個 24 小時在線的 AI 助手，可以：
- 在 Telegram 隨時問它問題
- 幫你寫文案、翻譯、寫程式
- 切換不同的 AI 模型（ChatGPT、Claude、Gemini...）
- 完全屬於你，資料不經過第三方

---

## 事前準備

你需要：
- ✅ 一台電腦（有瀏覽器就行）
- ✅ 一個 AWS 帳號（免費註冊：https://aws.amazon.com）
- ✅ 手機上有 Telegram app

---

## Step 1：在 Telegram 建立你的 Bot（3 分鐘）

### 1-1. 建立 Bot

1. 打開手機上的 **Telegram**
2. 在上方搜尋欄輸入 **@BotFather**，點進去
3. 按下方的 **Start** 或傳送 `/start`
4. 傳送 `/newbot`
5. 它會問你 Bot 的名字 → 隨便取，例如輸入 `我的AI助手`
6. 它會問你 Bot 的帳號 → 必須英文，結尾要加 `bot`，例如 `workshop_demo_bot`
7. 成功！BotFather 會回覆一段包含 **Token** 的訊息

> 💡 Token 長這樣：`7123456789:AAF1xxxxxxxxxxxxxxxxxxxxxxxxxxx`
> 
> **先別關 Telegram，等等要用到這串 Token**

### 1-2. 取得你的 ID

1. 在 Telegram 搜尋 **@userinfobot**，點進去
2. 隨便傳一則訊息（例如傳 `hi`）
3. 它會回覆你的資訊，其中 **Id** 那行是一串數字

> 💡 ID 就是那串數字，例如 `514234444`
>
> **把這串數字也記下來**

---

## Step 2：開一台雲端主機（5 分鐘）

### 2-1. 進入 AWS

1. 打開瀏覽器，前往 https://console.aws.amazon.com
2. 登入你的 AWS 帳號
3. 左上角確認地區（建議選 **Asia Pacific (Tokyo)** 或你最近的地區）

### 2-2. 開一台主機

1. 在上方搜尋欄搜尋 **EC2**，點進去
2. 點橘色按鈕 **Launch instance**
3. 填寫設定：

| 項目 | 填什麼 |
|------|--------|
| **Name** | `my-ai-bot`（隨便取） |
| **AMI** | 選 **Ubuntu**（預設的 24.04 LTS 就好） |
| **Instance type** | `t3.micro`（免費方案適用） |
| **Key pair** | 選 **Proceed without a key pair**（我們用瀏覽器連線，不需要） |

4. **Network settings** 點 **Edit**：
   - ✅ Allow SSH traffic → **Anywhere**（讓瀏覽器可以連進去）

5. 其他都不用改，直接按右下角 **Launch instance**

6. 等 1-2 分鐘，看到 **Instance state** 變成 ✅ **Running**

### 2-3. 用瀏覽器連進主機

1. 在 EC2 instance 列表中，**勾選你的主機**
2. 點上方的 **Connect** 按鈕
3. 選 **EC2 Instance Connect** 分頁
4. Username 保持 `ubuntu`
5. 點 **Connect**

> 🎉 一個黑色的終端機視窗會在瀏覽器裡打開。這就是你的主機了！

---

## Step 3：安裝 AI 助手（5 分鐘）

在剛才打開的黑色視窗中，**複製貼上下面這行指令**，然後按 Enter：

```
curl -fsSL https://install.clawrouter.com | bash
```

> 💡 複製方法：用滑鼠選取上面的指令 → Ctrl+C（複製）→ 在黑色視窗裡 Ctrl+Shift+V（貼上）→ Enter

安裝精靈會一步一步問你問題，照著回答就好：

### 問答流程

**「選哪個？1 或 2」**
→ 輸入 `1` 按 Enter（選 ClawRouter，最簡單）

**「取一個帳號名稱」**
→ 輸入你想要的帳號（英文或數字，例如 `alice123`）按 Enter

**「設定密碼」**
→ 輸入密碼（至少 8 個字，打字時不會顯示，這是正常的）按 Enter

**「貼上你的 Telegram Bot Token」**
→ 回到 Telegram，複製 BotFather 給你的那串 Token，貼上，按 Enter

**「貼上你的 Telegram ID」**
→ 貼上剛才 @userinfobot 給你的那串數字，按 Enter

等它跑完，看到：

```
🎉  恭喜！你的 AI 助手已經上線了！
```

就完成了！

---

## Step 4：開始使用（馬上！）

1. 打開 Telegram
2. 搜尋你剛才建的 Bot 名字
3. 傳送 **你好**

你的 AI 助手會回覆你！🎉

### 試試這些

| 傳什麼 | 會發生什麼 |
|--------|-----------|
| `你好` | AI 跟你打招呼 |
| `幫我用 Python 寫 Hello World` | AI 幫你寫程式 |
| `翻譯成英文：今天天氣很好` | AI 幫你翻譯 |
| `/status` | 看目前用了多少 |
| `/model` | 看有哪些模型可以切換 |
| `/model deepseek-chat` | 切換到最便宜的模型 |

---

## 常見問題

### 黑色視窗打不開

- 確認主機狀態是 ✅ Running
- 確認 Security Group 有開放 SSH
- 試試重新整理頁面再按 Connect

### 安裝指令跑到一半失敗

- 如果是「帳號已被使用」→ 重跑一次，用不同的帳號名稱
- 如果是網路問題 → 確認主機的 Security Group outbound 有全部放行

### Bot 不回應

- 確認你傳訊息給的是正確的 Bot
- 在黑色視窗輸入 `openclaw gateway logs` 看有沒有錯誤
- 試試重啟：`sudo systemctl restart openclaw`

### 如何關掉？

不想用了，在 AWS Console 把 EC2 **Terminate** 就好。所有東西都會一起刪除。

---

## 講師備註

### 建議流程（60 分鐘）

| 時間 | 內容 | 備註 |
|------|------|------|
| 0:00 | 開場 + Demo | 用你自己的 bot 即時展示 |
| 0:10 | 參與者做 Step 1（Telegram Bot） | 走到 Token 就好 |
| 0:15 | 參與者做 Step 2（開 EC2） | 最容易卡的步驟，準備巡場 |
| 0:25 | 參與者做 Step 3（跑安裝） | 基本只需複製貼上一行 |
| 0:35 | 大家一起測試 | 一起傳訊息看結果 |
| 0:45 | 進階玩法 | /model、改 SOUL.md |
| 0:55 | Q&A + 結束 | 留充值連結 |

### 容易卡關的地方

1. **EC2 Instance Connect 打不開** — Security Group 要開 SSH inbound
2. **複製貼上到終端機** — 教他們 Ctrl+Shift+V（不是 Ctrl+V）
3. **密碼打字看不到** — 提前講這是正常的
4. **帳號名稱重複** — 建議加日期或暱稱，例如 `alice-0329`
