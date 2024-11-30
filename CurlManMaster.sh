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
    local content
    if [ -n "$proxy" ]; then
        content=$(curl -x "$proxy" -sSL "$url" 2>&1)
    else
        content=$(curl -sSL "$url" 2>&1)
    fi

    # 检查curl命令是否成功执行
    if echo "$content" | grep -q "Failed to connect to"; then
        log "失败：无法连接到 $url 的服务器,可能被拦截了或者域名地址不正确,请查证后再试。"
        output_results "$url" "" "$proxy" "isOFF" "1002"
    else
        log "成功：获取 $url 的内容成功。"
        local head_content=$(echo "$content" | grep -E '<[^>]*head[^>]*>' | sed 's/<head>/<head>\n/g' | sed 's/<\/head>/<\/head>\n/g' | sed -n '/<head>/,/<\/head>/p')
        output_results "$url" "$head_content" "$proxy" "isOKK" "1001"
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

    while IFS= read -r proxy || [ -n "$proxy" ];do
        if [ -z "$proxy" ]; then
            log "proxy忽略：跳过空行。"
            continue
        fi

        log "使用代理 $proxy 进行拨测..."
        while IFS= read -r url; do
            process_url "$url" "$proxy"
        done < "$URLS_FILE"
    done < "$PROXY_LIST"
else
    log "警告：代理列表文件不存在或为空，将使用本地设备进行访问."
    while IFS= read -r url || [ -n "$url" ]; do
        if [ -z "$url" ]; then
            log "url忽略：跳过空行。"
            continue
        fi

        process_url "$url" ""
    done < "$URLS_FILE"
fi