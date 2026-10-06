

## scripts/send_to_wechat.sh

```bash
#!/usr/bin/env bash
# 微信主动发图辅助脚本
# 用法: ./send_to_wechat.sh <image_path> [target] [subject]
#
# 自动处理:
# 1. 检查图片路径是否在 MEDIA 允许列表内
# 2. 如果不在，自动复制到 ~/.hermes/cache/images/
# 3. 调用 hermes send 发送

set -euo pipefail

IMAGE_PATH="${1:-}"
TARGET="${2:-weixin}"
SUBJECT="${3:-图片生成完成}"

if [ -z "$IMAGE_PATH" ]; then
    echo '{"ok":false,"error":"usage: send_to_wechat.sh <image_path> [target] [subject]"}'
    exit 2
fi

if [ ! -f "$IMAGE_PATH" ]; then
    echo "{\"ok\":false,\"error\":\"file not found: $IMAGE_PATH\"}"
    exit 2
fi

# Hermes 管理的安全目录
HERMES_CACHE="${HOME}/.hermes/cache/images"
mkdir -p "$HERMES_CACHE"

# 检查路径是否在允许列表内
ALLOW_DIRS="${HERMES_MEDIA_ALLOW_DIRS:-}"
IS_ALLOWED=false

# 检查是否在 Hermes 缓存目录下
case "$(realpath "$IMAGE_PATH")" in
    "${HOME}/.hermes/cache/"*|"${HOME}/.hermes/media/"*)
        IS_ALLOWED=true
        ;;
esac

# 检查是否在 HERMES_MEDIA_ALLOW_DIRS 中
if [ "$IS_ALLOWED" = false ] && [ -n "$ALLOW_DIRS" ]; then
    IFS=':' read -ra DIRS <<< "$ALLOW_DIRS"
    for dir in "${DIRS[@]}"; do
        case "$(realpath "$IMAGE_PATH")" in
            "$(realpath "$dir")"/*)
                IS_ALLOWED=true
                break
                ;;
        esac
    done
fi

# 如果不在允许列表内，复制到 Hermes 缓存目录
if [ "$IS_ALLOWED" = false ]; then
    BASENAME=$(basename "$IMAGE_PATH")
    DEST="${HERMES_CACHE}/${BASENAME}"
    cp "$IMAGE_PATH" "$DEST"
    IMAGE_PATH="$DEST"
    echo "{\"info\":\"copied to Hermes cache: $DEST\"}" >&2
fi

# 调用 hermes send
hermes send \
    --to "$TARGET" \
    --file "$IMAGE_PATH" \
    --subject "$SUBJECT" \
    --json

EXIT_CODE=$?
exit $EXIT_CODE
