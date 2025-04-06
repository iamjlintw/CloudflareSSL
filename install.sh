set -e

# 取得作業系統名稱
OS_TYPE=$(uname)

echo "=== 檢查作業系統 ==="
if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "偵測到 macOS 系統"
    # macOS 使用 Homebrew 安裝相關工具
    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew 尚未安裝，正在安裝 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "使用 Homebrew 安裝 Certbot 與 Cloudflare DNS 外掛..."
    brew install certbot certbot-dns-cloudflare

    # macOS 通常已內建 Python3，如果需要可更新 pip
    if ! command -v python3 >/dev/null 2>&1; then
        echo "請先安裝 Python3"
        exit 1
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "偵測到 Linux 系統 (WSL / Debian/Ubuntu)"
    echo "更新套件列表..."
    sudo apt-get update

    echo "安裝 Certbot、Cloudflare DNS 外掛、Python3、pip 與 python3-venv..."
    sudo apt-get install -y certbot python3-certbot-dns-cloudflare python3 python3-pip python3-venv
else
    echo "不支援的作業系統: $OS_TYPE"
    exit 1
fi

# 定義虛擬環境目錄名稱為 cfvenv
VENV_DIR="cfvenv"

echo "=== 建立虛擬環境 ($VENV_DIR) ==="
# 如果目錄存在但缺少 activate 檔案，則刪除並重新建立
if [ -d "$VENV_DIR" ]; then
    if [ ! -f "$VENV_DIR/bin/activate" ]; then
        echo "發現虛擬環境目錄 '$VENV_DIR' 但缺少 activate 檔案，將重新建立。"
        rm -rf "$VENV_DIR"
        python3 -m venv "$VENV_DIR"
        echo "虛擬環境已建立在 '$VENV_DIR/' 目錄中。"
    else
        echo "虛擬環境 '$VENV_DIR/' 已存在。"
    fi
else
    python3 -m venv "$VENV_DIR"
    echo "虛擬環境已建立在 '$VENV_DIR/' 目錄中。"
fi

echo "=== 啟用虛擬環境並安裝 Python 套件 ==="
if [ -f "$VENV_DIR/bin/activate" ]; then
    # 啟動虛擬環境
    source "$VENV_DIR/bin/activate"
else
    echo "錯誤：找不到虛擬環境啟動檔案 ($VENV_DIR/bin/activate)"
    exit 1
fi

# 升級 pip 並安裝 python-dotenv
pip install --upgrade pip
pip install python-dotenv

echo "=== 安裝完成 ==="
echo "虛擬環境已啟動，現在您可以直接執行："
echo "  python get_cert.py"

# 啟動一個新的 shell，並自動執行 activate 命令
exec "$SHELL"