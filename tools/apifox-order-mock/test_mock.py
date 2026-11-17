"""独立验证登录、鉴权、CRUD、退登与状态持久化；最长每个 HTTP 请求 3 秒。"""
import json
from pathlib import Path
import tempfile
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import Request, urlopen
from server import create_server


class OrderMockTests(unittest.TestCase):
    def test_complete_flow(self):
        with tempfile.TemporaryDirectory(prefix="apifox-order-test-") as folder:
            service = create_server(port=0, database=Path(folder) / "test.sqlite3")
            thread = threading.Thread(target=service.serve_forever, daemon=True)
            thread.start()
            base = f"http://127.0.0.1:{service.server_port}/mock-order/v1"

            def request(method, path, expected, body=None, token=None):
                headers = {"Content-Type": "application/json"}
                if token:
                    headers["Authorization"] = "Bearer " + token
                data = None if body is None else json.dumps(body).encode()
                try:
                    response = urlopen(Request(base + path, data=data, method=method, headers=headers), timeout=3)
                except HTTPError as error:
                    response = error
                with response:
                    self.assertEqual(response.code, expected)
                    payload = json.loads(response.read())
                self.assertEqual(payload["status"], "1" if expected < 400 else "0")
                return payload["data"]

            try:
                request("GET", "/orders", 401)
                request("POST", "/auth/login", 401, {"username": "demo", "password": "bad"})
                token = request("POST", "/auth/login", 200, {"username": "demo", "password": "demo12345"})["token"]
                self.assertTrue(token)
                order = {"title": "测试订单", "amount": 19900, "quantity": 2, "status": "draft"}
                identifier = request("POST", "/orders", 201, order, token)["id"]
                path = f"/orders/{identifier}"
                self.assertEqual(request("GET", path, 200, token=token)["title"], order["title"])
                changed = {**order, "title": "编辑后订单", "amount": 29900}
                request("PUT", path, 200, changed, token)
                self.assertEqual(request("GET", path, 200, token=token)["amount"], 29900)
                self.assertEqual(request("GET", "/orders", 200, token=token)["total"], 1)
                request("POST", "/orders", 401, order)
                request("PUT", path, 401, changed, "forged-token")
                request("POST", "/orders", 422, {**order, "amount": -1}, token)
                self.assertTrue(request("DELETE", path, 200, token=token)["deleted"])
                request("GET", path, 404, token=token)
                self.assertTrue(request("POST", "/auth/logout", 200, {}, token)["loggedOut"])
                request("GET", "/orders", 401, token=token)
                request("DELETE", path, 401, token=token)
            finally:
                service.shutdown()
                service.server_close()
                thread.join(timeout=2)


if __name__ == "__main__":
    unittest.main()
