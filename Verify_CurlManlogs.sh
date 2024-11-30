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

function log() {
    message="[Aspnmy Log]: $1"
    case "$1" in
        *"失败"*|*"错误"*|*"请使用 root 或 sudo 权限运行此脚本"*)
            echo -e "${RED}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}/CurlMan.log"
            ;;
        *"成功"*)
            echo -e "${GREEN}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}/CurlMan.log"
            ;;
        *"忽略"*|*"跳过"*)
            echo -e "${YELLOW}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}/CurlMan.log"
            ;;
        *)
            echo -e "${BLUE}${message}${NC}" 2>&1 | tee -a "${CURRENT_DIR}/CurlMan.log"
            ;;
    esac
}

# 设置日志文件和关键词文件路径
LOG_FILE="content.log"
KEYWORD_FILE="Verification-Code.txt"

# 检查日志文件是否存在
if [ ! -f "$LOG_FILE" ]; then
    log "错误：日志文件 $LOG_FILE 不存在。"
    exit 1
fi

# 检查关键词文件是否存在
if [ ! -f "$KEYWORD_FILE" ]; then
    log "错误：关键词文件 $KEYWORD_FILE 不存在。"
    exit 1
fi

# 读取关键词文件中的每个关键词
while IFS= read -r keyword; do
    if [ -z "$keyword" ]; then
        log "忽略：跳过空行。"
        continue
    fi

    # 构建要搜索的<meta>标签
    META_TAG="<meta name=\"Aspnmy-CurlManMaster-Verification\" content=\"$keyword\" />"

    # 搜索<meta>标签是否在日志文件中
    if grep -q "$META_TAG" "$LOG_FILE"; then
        log "成功：在 $LOG_FILE 中找到了<meta>标签，关键词为 $keyword。"
    else
        log "失败：在 $LOG_FILE 中没有找到<meta>标签，关键词为 $keyword。"
    fi
    echo "-----"
done < "$KEYWORD_FILE"