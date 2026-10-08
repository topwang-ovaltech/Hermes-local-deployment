---
name: wechat-image-proactive
description: Send generated images to WeChat via Hermes native delivery. Use when sending generated images to WeChat, pushing files to WeChat, or 微信发图.
version: 1.0.0
author: custom
---

# 微信主动发图 Skill

## Overview

通过 Hermes 原生的 `hermes send` CLI 和 MEDIA 投递机制，主动将图片/文件推送到微信。不依赖 OpenClaw、wxclawbot 或任何第三方微信 CLI。

核心优势：
- 复用 Hermes gateway 已有的微信凭据和平台适配器，无需维护第二套配置
- 无需 context_token 预热，Hermes gateway 常驻进程自动管理会话
- 无需 npm install 第三方包，零额外依赖

## When to Use

- 图片生成完成后，需要自动通过微信发送给用户
- 定时任务的结果需要以图片/文件形式推送到微信
- 任何"生成内容 → 通过微信主动送达"的场景

Do NOT trigger when: 用户要求通过邮件、Telegram、Slack 发送，或仅需发送纯文本消息。

## Quick Reference

| 操作 | 命令 |
|------|------|
| 列出可用微信目标 | `hermes send --list weixin` |
| 发送图片 | `hermes send --to weixin:<chat_id> "MEDIA:/path/to/image.png"` |
| 发送文本 | `hermes send --to weixin:<chat_id> "消息内容"` |

> ⚠️ 图片发送陷阱：`--file` 参数是用来发**文本正文**（日志/报告/markdown）的，传图片路径会报错 `not a text file`。图片必须以 `MEDIA:/path` 的形式写在消息文本里才能作为原生附件发送。
| JSON 输出 | 加 `--json` |

## Procedure

### Step 1: 确认微信目标

运行 `hermes send --list weixin` 列出所有已配置的微信目标。

如果列表为空，说明微信 gateway 未正确配置。此时不要继续，告知用户先完成微信 gateway 配置。

目标格式为 `weixin:<chat_id>`，例如：
`weixin:o9cq80-rnZjGPyiEJ0nfZ1beSbB4@im.wechat`

如果用户没有提供目标，使用 `hermes send --to weixin`（发送到默认频道）。

### Step 2: 确保图片路径在允许列表内

这是最容易出错的环节。Hermes 的安全机制会静默丢弃不在允许列表中的 MEDIA 文件。

检查图片路径是否位于以下位置之一：
1. `~/.hermes/cache/` 或 `~/.hermes/media/` — Hermes 管理的缓存目录
2. `HERMES_MEDIA_ALLOW_DIRS` 环境变量中列出的目录

如果图片不在允许列表内，将图片复制到 Hermes 缓存目录：

```bash
mkdir -p ~/.hermes/cache/images
cp /original/path/image.png ~/.hermes/cache/images/image.png
