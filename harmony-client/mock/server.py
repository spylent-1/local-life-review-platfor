"""Local HTTP mock for the HarmonyOS course client. All entries are fictional."""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import parse_qs, urlparse
import json

SHOPS = [
    {"id": 1, "name": "城市阅读空间", "area": "中心商圈", "address": "示例路 18 号", "openHours": "09:00-21:00", "score": 48},
    {"id": 2, "name": "星光运动中心", "area": "南区", "address": "示例大道 6 号", "openHours": "08:00-22:00", "score": 46},
    {"id": 3, "name": "周末生活馆", "area": "北区", "address": "体验街 25 号", "openHours": "10:00-20:00", "score": 45},
]
VOUCHERS = {
    1: [{"id": 101, "title": "阅读体验权益", "subTitle": "工作日可用", "rules": "示例权益，仅用于界面演示。"}],
    2: [{"id": 201, "title": "运动体验权益", "subTitle": "预约前请查看场次", "rules": "示例权益，仅用于界面演示。"}],
    3: [],
}


class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, value):
        body = json.dumps(value, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        url = urlparse(self.path)
        parts = url.path.strip("/").split("/")
        if url.path == "/shop/of/name":
            keyword = parse_qs(url.query).get("name", [""])[0].strip()
            data = [shop for shop in SHOPS if keyword.casefold() in shop["name"].casefold()]
            return self.send_json(200, {"success": True, "data": data})
        if len(parts) == 2 and parts[0] == "shop" and parts[1].isdigit():
            shop = next((s for s in SHOPS if s["id"] == int(parts[1])), None)
            return self.send_json(200, {"success": True, "data": shop} if shop else {"success": False, "errorMsg": "资源不存在"})
        if len(parts) == 3 and parts[:2] == ["voucher", "list"] and parts[2].isdigit():
            shop_id = int(parts[2])
            if shop_id not in VOUCHERS:
                return self.send_json(200, {"success": False, "errorMsg": "资源不存在"})
            return self.send_json(200, {"success": True, "data": VOUCHERS[shop_id]})
        self.send_json(404, {"success": False, "errorMsg": "接口不存在"})


if __name__ == "__main__":
    server = ThreadingHTTPServer(("127.0.0.1", 18081), Handler)
    print("FlashPass demo HTTP server: http://127.0.0.1:18081", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
