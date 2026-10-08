#!/usr/bin/env bash
# xiaoai-speak — 让小米音箱朗读一段文字
# 依赖: 本地 open-xiaoai-bridge 服务（默认 http://192.168.33.188:9092）
#
# 用法:
#   xiaoai-speak "要朗读的文字"
#   xiaoai-speak -f 文件路径      # 从文件读取文字
#   echo "文字" | xiaoai-speak    # 从标准输入读取
#
# 环境变量:
#   XIAOAI_HOST   默认 192.168.33.188
#   XIAOAI_PORT   默认 9092

set -euo pipefail

HOST="${XIAOAI_HOST:-192.168.33.188}"
PORT="${XIAOAI_PORT:-9092}"
URL="http://${HOST}:${PORT}/api/play/text"

text=""
if [[ "${1:-}" == "-f" ]]; then
  [[ -f "${2:-}" ]] || { echo "xiaoai-speak: 文件不存在: ${2:-}" >&2; exit 1; }
  text="$(<"$2")"
elif [[ -n "${1:-}" ]]; then
  text="$1"
elif [[ ! -t 0 ]]; then
  text="$(cat)"
else
  echo "用法: xiaoai-speak \"文字\" | xiaoai-speak -f 文件 | echo 文字 | xiaoai-speak" >&2
  exit 2
fi

if [[ -z "${text//[[:space:]]/}" ]]; then
  echo "xiaoai-speak: 文字为空" >&2
  exit 1
fi

# 用 jq 安全构造 JSON（若可用），否则手动转义
if command -v jq >/dev/null 2>&1; then
  payload="$(jq -n --arg t "$text" '{text: $t}')"
else
  esc="${text//\\/\\\\}"
  esc="${esc//\"/\\\"}"
  payload="{\"text\": \"${esc}\"}"
fi

curl -sS -X POST "$URL" -H "Content-Type: application/json" -d "$payload"
echo
