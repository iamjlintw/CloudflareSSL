# Cloudflare DNS-01 自動化憑證申請工具

本專案提供一個 Python 工具，利用 Certbot 與 Cloudflare 的 DNS 外掛，透過 DNS-01 挑戰自動向 Let's Encrypt 申請 SSL 憑證。此工具特別適合初學者，只需透過設定 .env 檔案，即可完成憑證申請流程。

## 目錄
- [前置需求](#前置需求)
- [安裝流程](#安裝流程)
- [設定說明](#設定說明)
- [使用說明](#使用說明)
- [常見問題](#常見問題)
- [參考文件](#參考文件)
- [貢獻指南](#貢獻指南)
- [授權資訊](#授權資訊)

## 前置需求

### 系統需求
- **作業系統**：WSL / Debian / Ubuntu 系統（其他 Linux 發行版亦可）
- **Python 3.6+**

### 必要套件
- **Certbot 與 Cloudflare DNS 外掛**  
  安裝範例（Debian/Ubuntu）：
  ```bash
  sudo apt-get update
  sudo apt-get install certbot python3-certbot-dns-cloudflare
  ```

- **python-dotenv 模組**
  ```bash
  pip install python-dotenv
  ```

### Cloudflare API Token
請至 Cloudflare 儀表板 → My Profile → API Tokens  
建立自訂 Token，權限至少設定為 Zone → DNS:Edit（限定指定網域，如 ddd.com）

## 安裝流程

1. 下載並執行安裝腳本
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
   此腳本將自動：
   - 更新系統套件
   - 安裝 Certbot、Python3、pip 及必要套件
   - (可選) 建立虛擬環境

## 設定說明

在專案目錄下建立 `.env` 檔案，內容範例如下：

```bash
# Cloudflare API Token (請僅授予 DNS 編輯權限)
CLOUDFLARE_API_TOKEN=your_cloudflare_api_token_here

# 目標域名列表（逗號分隔，可包含多個域名）
DOMAINS=aaa.ddd.com

# DNS 記錄傳播等待時間 (單位：秒，根據需要調整)
PROPAGATION_SECONDS=30

# Cloudflare 憑證設定檔檔名（若不存在程式會自動建立）
CF_CREDENTIALS_FILE=cloudflare.ini

# 是否使用 Let's Encrypt 測試環境 (staging)，測試時請設為 true
STAGING=false
```

## 使用說明

1. 安裝完成後，依照上方建立 `.env` 檔案
2. 執行主程式：
   ```bash
   python get_cert.py
   ```

執行流程說明：
- 程式會讀取 `.env` 中的設定
- 自動建立 Cloudflare 憑證設定檔（若尚未存在）
- 呼叫 Certbot 進行 DNS-01 驗證
- 申請成功後，憑證存放於 `/etc/letsencrypt/live/<your_domain>/`

## 常見問題

### DNS 傳播延遲
若驗證失敗，可嘗試增加 `.env` 中的 `PROPAGATION_SECONDS` 參數值。

### 檔案權限
請確認 `cloudflare.ini` 權限設定為 `600`，確保 API Token 不被其他使用者讀取。

### 測試環境
初次測試建議將 `STAGING` 設為 `true`，避免憑證申請次數達到限制。

## 參考文件
- [Let's Encrypt - Getting Started](https://letsencrypt.org/getting-started/)
- [Certbot Documentation](https://certbot.eff.org/docs/)
- [Certbot DNS Cloudflare Plugin](https://certbot-dns-cloudflare.readthedocs.io/en/stable/)
- [Cloudflare API Tokens](https://developers.cloudflare.com/api/tokens/create/)

## 貢獻指南
歡迎提交 Pull Request 或 Issue 回報問題。請確保：
- 程式碼符合 PEP 8 規範
- 新增功能需包含對應測試
- 更新相關文件

## 授權資訊
本專案採用 [MIT License](LICENSE) 授權。
