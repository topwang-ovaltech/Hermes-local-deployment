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

