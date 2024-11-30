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

# 检查urls.txt文件是否存在
URLS_FILE="${ConfigPATH}/urls.txt"
if [ ! -f "$URLS_FILE" ]; then
    log "错误：urls.txt文件不存在。"
    exit 1
fi

JSON_OUTPUT="${WebLogsPATH}/content.json"

# 读取urls.txt文件中的每个URL并执行curl命令
while IFS= read -r url; do
    if [ -z "$url" ]; then
        log "忽略：跳过空行。"
        continue
    fi
    log "开始：获取 $url 的内容..."
    content=$(curl -sSL "$url")
    if [ $? -eq 0 ]; then
        log "成功：获取 $url 的内容成功。"
        # 提取<head>标签的内容
        head_content=$(echo "$content" | grep -E '<[^>]*head[^>]*>' | sed 's/<head>/<head>\n/g' | sed 's/<\/head>/<\/head>\n/g' | sed -n '/<head>/,/<\/head>/p')
        # 构造JSON对象并追加到content.json
        if [ -z "$head_content" ]; then
            head_content="No head content found"
        fi
        echo "{\"url\":\"$url\",\"head\":\"$head_content\"}" | tee -a "$JSON_OUTPUT"
    else
        log "失败：获取 $url 的内容失败。"
    fi
    echo "-----"
done < "$URLS_FILE"