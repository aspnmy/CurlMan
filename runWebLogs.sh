#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CURRENT_DIR=$(
    cd "$(dirname "$0")" || exit
    pwd
)

WebLogsPATH="${CURRENT_DIR}/web_logs"
ConfigPATH="${CURRENT_DIR}/config"
LogsPATH="${CURRENT_DIR}/logs"

function log() {
    message="[Aspnmy Log]: $1"
    case "$1" in
        *"失败"*|*"错误"*|*"请使用 root 或 sudo 权限运行此脚本"*)
            echo -e "${RED}${message}${NC}" 2>&1 | tee -a "${LogsPATH}/CurlMan.log"
            ;;
        *"成功"*)
            echo -e "${GREEN}${message}${NC}" 2>&1 | tee -a "${LogsPATH}/CurlMan.log"
            ;;
        *"忽略"*|*"跳过"*)
            echo -e "${YELLOW}${message}${NC}" 2>&1 | tee -a "${LogsPATH}/CurlMan.log"
            ;;
        *)
            echo -e "${BLUE}${message}${NC}" 2>&1 | tee -a "${LogsPATH}/CurlMan.log"
            ;;
    esac
}

# 确保WebLogsPATH存在
if [ ! -d "$WebLogsPATH" ]; then
    mkdir -p "$WebLogsPATH"
fi

# 检测系统版本并安装Python
function install_python() {
    if [ -f /etc/debian_version ]; then
        # Debian/Ubuntu
        sudo apt update && sudo apt install -y python3 python3-pip
    elif [ -f /etc/redhat-release ]; then
        # CentOS/RHEL
        sudo yum install -y python3 python3-pip
    elif [ -f /etc/fedora-release ]; then
        # Fedora
        sudo dnf install -y python3 python3-pip
    else
        log "错误：不支持的操作系统。"
        exit 1
    fi
    log "成功：Python环境已安装。"
}

# 安装Python环境
install_python

# 启动Python HTTP服务器来托管content.json文件
log "启动Web服务器..."
nohup python3 "${WebLogsPATH}/web_serve.py" > "${LogsPATH}/server.log" 2>&1 &

# 记录服务器启动信息
log "Web服务器已启动，正在端口7988上托管content.json文件。"
log "访问 http://localhost:7988/content.json 查看文件。"