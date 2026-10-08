# Hermes-local-deployment
local deployed Hermes workflow settings

Hermes:
1..hermes/SOUL.md:
personalized identity definition for the agent (女仆「小花」人设)
2..hermes/config.yaml:
Hermes config; defines model_routes for the open-xiaomi-bridge voice route → 5080 GPU's Swift-Qwen3.8-27B-Q3 (192.168.33.205:8080)


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
2.sys-config/etc/systemd/system/sd-server.service (v2):
system service; runs the new stable-diffusion.cpp sd-server (ROCm build at sd-official, commit a1ded76, supports Qwen-Image-2.1) with QwenImage-2.1 models, ROCm/HSA env vars, listening on 0.0.0.0:8090; supersedes the old Vulkan/QwenImage-1225 v1 config
3.sys-config/home/oval/.config/systemd/user/hermes-gateway.service:
user service; runs `hermes gateway run` with proper PATH/HERMES_HOME env, SIGTERM stop with stop-mark + cgroup cleanup
4.sys-config/home/oval/.config/systemd/user/hermes-dashboard.service:
user service; runs the Hermes dashboard on 127.0.0.1:9119, depends on hermes-gateway

