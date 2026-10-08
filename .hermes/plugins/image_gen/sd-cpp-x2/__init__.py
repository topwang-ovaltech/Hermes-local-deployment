import base64
import os
import requests
from typing import Any, Dict, List, Optional

from agent.image_gen_provider import ImageGenProvider, success_response, error_response


class SdCppX2Provider(ImageGenProvider):
    @property
    def name(self) -> str:
        return "sd-cpp-x2"

    @property
    def display_name(self) -> str:
        return "Stable Diffusion.cpp (X2)"

    def is_available(self) -> bool:
        try:
            r = requests.get("http://localhost:8090/", timeout=2)
            return r.status_code < 500
        except Exception:
            return False

    def list_models(self) -> List[Dict[str, Any]]:
        return [{
            "id": "qwen-image-2512",
            "name": "Qwen Image 2512 (GGUF Q4_K_M)",
            "description": "本地 Qwen Image 模型，通过 sd-server 常驻",
            "speed": "取决于硬件",
            "cost": "free (local)",
        }]

    def default_model(self) -> Optional[str]:
        return "qwen-image-2512"

    def generate(self, prompt: str, **kwargs) -> Dict[str, Any]:
        try:
            payload = {
                "prompt": prompt,
                "width": kwargs.get("width", 1024),
                "height": kwargs.get("height", 768),
                "steps": kwargs.get("steps", 20),
                "cfg_scale": kwargs.get("cfg_scale", 2.5),
            }
            resp = requests.post(
                "http://localhost:8090/sdapi/v1/txt2img",
                json=payload,
                timeout=1200,
            )
            resp.raise_for_status()
            data = resp.json()
            image_b64 = data["images"][0]
            image_bytes = base64.b64decode(image_b64)
            
            # 使用 save_b64_image 保存并返回路径（Hermes 期望的格式）
            from agent.image_gen_provider import save_b64_image
            image_path = save_b64_image(image_b64, prefix="sd-cpp", extension="png")
            
            return success_response(
                image=str(image_path),   # 返回本地路径
                model="qwen-image-2512",
                prompt=prompt,
                aspect_ratio=kwargs.get("aspect_ratio", "square"),
                provider=self.name,
            )
        except Exception as e:
            return error_response(
                error=str(e),
                error_type=type(e).__name__,
                provider=self.name,
                prompt=prompt,
                aspect_ratio=kwargs.get("aspect_ratio", "square"),
            )

def register(ctx):
    ctx.register_image_gen_provider(SdCppX2Provider())
