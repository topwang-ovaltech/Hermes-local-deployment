---
name: xiaoai-voice
description: 让小米音箱朗读文字，通过本地 open-xiaoai-bridge 服务的 /api/play/text 接口。Use when 需要让音箱发声、朗读文字、语音播报、tts 播放，或 小米音箱/小爱 播报。
version: 1.0.0
author: custom
---

# 小米音箱朗读 Skill

## Overview

调用本地 `open-xiaoai-bridge` 服务，把一段文字通过小米音箱朗读出来。核心是 POST 请求
`http://<host>:<port>/api/play/text`，body 为 `{"text": "..."}`。

- 零额外依赖：只需 `curl`（有 `jq` 时自动用它做安全转义，否则手动转义）
- 默认服务地址 `192.168.33.188:9092`，可用 `XIAOAI_HOST` / `XIAOAI_PORT` 覆盖

## When to Use

- 需要让小米音箱发声 / 朗读一段文字
- 语音播报任务结果、提醒、状态等
- 任何「文字 → 音箱朗读」的场景

Do NOT trigger when: 仅需要文本回复（不必发声），或目标设备不是 open-xiaoai-bridge 服务的小米音箱。

## Quick Reference

| 操作 | 命令 |
|------|------|
| 朗读一句话 | `xiaoai-speak "测试成功，音箱可以发声了"` |
| 朗读文件内容 | `xiaoai-speak -f /path/to/file.txt` |
| 管道输入 | `echo "文字" \| xiaoai-speak` |

成功时服务返回 `{"success": true, "message": "Playing text in background"}`。

## 调用

脚本本体在 `scripts/xiaoai-speak.sh`。推荐软链到 PATH，保持单一来源：

```bash
ln -sf "$PWD/scripts/xiaoai-speak.sh" ~/.local/bin/xiaoai-speak
```

之后直接 `xiaoai-speak "文字"` 即可。

## 环境变量

| 变量 | 默认 | 说明 |
|------|------|------|
| `XIAOAI_HOST` | `192.168.33.188` | open-xiaoai-bridge 服务主机 |
| `XIAOAI_PORT` | `9092` | open-xiaoai-bridge 服务端口 |

## 前置条件

- 目标机器上 `open-xiaoai-bridge` 服务已启动，且 `curl` 可达该地址。
- 若服务地址变化，用 `XIAOAI_HOST` / `XIAOAI_PORT` 覆盖即可，无需改脚本。
