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
JSON_OUTPATH="${WebLogsPATH}/content.json"

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

function output_results() {
    local url=$1
    local head_content=$2
    local proxy=$3
    local status=$4
    local err_code=$5

    local log_message="$url|$status|$head_content"
    local json_output="{\"url\":\"$url\",\"head\":\"$head_content\",\"proxy\":\"$proxy\",\"title\":\"$status\",\"err_code\":\"$err_code\"}"

    echo "$log_message" | tee -a "${LogsPATH}/content.log"
    echo "$json_output" | tee -a "$JSON_OUTPATH"
}

function fetch_url() {
    local url=$1
    local proxy=$2
    if [ -n "$proxy" ]; then
        curl -x "$proxy" -sSL "$url"
    else
        curl -sSL "$url"
    fi
}

function process_url() {
    local url=$1
    local proxy=$2
    local content=$(fetch_url "$url" "$proxy")
    if [ $? -eq 0 ]; then
        log "成功：获取 $url 的内容成功."
        local head_content=$(echo "$content" | grep -E '<[^>]*head[^>]*>' | sed 's/<head>/<head>\n/g' | sed 's/<\/head>/<\/head>\n/g' | sed -n '/<head>/,/<\/head>/p')
        output_results "$url" "$head_content" "$proxy" "isOKK" "1001"
    else
        local head_content=""
        output_results "$url" "$head_content" "$proxy" "isOFF" "1002"
        log "失败：获取 $url 的内容失败.状态码:1002"
    fi
    echo "-----"
}

# 检查urls.txt文件是否存在
URLS_FILE="$ConfigPATH/urls.txt"
if [ ! -f "$URLS_FILE" ]; then
    log "错误：urls.txt文件不存在."
    exit 1
fi

PROXY_LIST="$ConfigPATH/proxies.txt"
if [ -s "$PROXY_LIST" ]; then
    log "代理列表文件存在，将使用代理进行拨测."
    while IFS= read -r proxy; do
        if [ -z "$proxy" ]; then
            continue
        fi
        log "使用代理 $proxy 进行拨测..."
        while IFS= read -r url; do
            process_url "$url" "$proxy"
        done < "$URLS_FILE"
    done < "$PROXY_LIST"
else
    log "警告：代理列表文件不存在或为空，将使用本地设备进行访问."
    while IFS= read -r url; do
        process_url "$url" ""
    done < "$URLS_FILE"
fi