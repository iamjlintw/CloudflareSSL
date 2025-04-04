#!/usr/bin/env python3
import os
import subprocess
from dotenv import load_dotenv


def main():
    # 載入 .env 檔案中的設定
    load_dotenv()

    # 從環境變數讀取必要參數
    api_token = os.getenv("CLOUDFLARE_API_TOKEN")
    domains = os.getenv("DOMAINS")  # 以逗號分隔的域名，例如：aaa.ddd.com,www.ddd.com
    propagation_seconds = os.getenv("PROPAGATION_SECONDS", "30")
    credentials_file = os.getenv("CF_CREDENTIALS_FILE", "cloudflare.ini")
    staging = os.getenv("STAGING", "false").lower() == "true"

    if not api_token or not domains:
        print("錯誤：請確保 .env 中已設定 CLOUDFLARE_API_TOKEN 與 DOMAINS 變數。")
        return

    # 若指定的 credentials_file 不存在，則自動建立並寫入 API Token，並設定權限為 600
    if not os.path.exists(credentials_file):
        with open(credentials_file, "w") as f:
            f.write(f"dns_cloudflare_api_token = {api_token}\n")
        os.chmod(credentials_file, 0o600)
        print(f"已建立 Cloudflare 憑證設定檔: {credentials_file}")
    else:
        print(f"使用現有的憑證設定檔: {credentials_file}")

    # 組合 Certbot 指令
    cmd = [
        "sudo", "certbot", "certonly",
        "--dns-cloudflare",
        "--dns-cloudflare-credentials", credentials_file,
        "--dns-cloudflare-propagation-seconds", propagation_seconds,
    ]

    if staging:
        cmd.append("--staging")

    # 將 .env 中指定的每個域名以 -d 參數加入
    for domain in domains.split(","):
        domain = domain.strip()
        if domain:
            cmd.extend(["-d", domain])

    print("執行指令：", " ".join(cmd))
    subprocess.run(cmd)


if __name__ == "__main__":
    main()
