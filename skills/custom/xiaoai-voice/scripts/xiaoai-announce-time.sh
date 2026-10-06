#!/usr/bin/env bash
# xiaoai-announce-time — 小米音箱整点报时（供定时任务调用）
# 仅在 7:00–23:00 区间内朗读「现在是X点整」，其他时段静默退出。
set -euo pipefail

XIAOAI_SPEAK="${XIAOAI_SPEAK:-$HOME/.local/bin/xiaoai-speak}"
HOUR=$((10#$(date +%H)))
if (( HOUR < 7 || HOUR > 23 )); then
  exit 0
fi
"$XIAOAI_SPEAK" "现在是${HOUR}点整"
