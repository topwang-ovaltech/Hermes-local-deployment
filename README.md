# Hermes-local-deployment
local deployed Hermes workflow settings


Plugin:
1.sd-cpp-x2:
invoke local sd-cli service to generate image(http://localhost:8090/sdapi/v1/txt2img)


Skill:
1.wechat-image-proactive:
send image to weixin
2.xiaoai-voice:
make a Xiaomi speaker read text aloud via local open-xiaoai-bridge service (http://192.168.33.188:9092/api/play/text); invoke `xiaoai-speak "text"`

Sys-config:
systemd service units, laid out mirroring the real filesystem paths under `sys-config/`:
1.sys-config/etc/systemd/system/llama-qwen3.service:
system service; runs llama-server with the ROCmFPX Qwen3.8-27B GGUF model (draft-MTP speculative decoding, ROCm env vars), failed runs auto-restart
2.sys-config/etc/systemd/system/sd-server.service:
system service; runs stable-diffusion.cpp sd-server (Vulkan backend, QwenImage models) listening on 0.0.0.0:8090
3.sys-config/home/oval/.config/systemd/user/hermes-gateway.service:
user service; runs `hermes gateway run` with proper PATH/HERMES_HOME env, SIGTERM stop with stop-mark + cgroup cleanup
4.sys-config/home/oval/.config/systemd/user/hermes-dashboard.service:
user service; runs the Hermes dashboard on 127.0.0.1:9119, depends on hermes-gateway

