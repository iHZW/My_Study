"""供 Apifox 联调的本地有状态 Mock，所有账号和订单均为测试数据。"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit, parse_qs
import argparse
import hashlib
import json
import secrets
import sqlite3
import time

PREFIX = "/mock-order/v1"


class MockHandler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        # 请求头和 token 不写日志。
        print(f"{self.command} {urlsplit(self.path).path}", flush=True)

    def respond(self, http_status, data=None, message="", code=0):
        payload = json.dumps({"status": "1" if http_status < 400 else "0", "code": code or (http_status if http_status >= 400 else 0),
                              "errmsg": message, "data": data, "timestamp": int(time.time() * 1000)}, ensure_ascii=False).encode()
        self.send_response(http_status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(payload)

    def read_body(self):
        size = int(self.headers.get("Content-Length", "0"))
        if size < 0 or size > 65536:
            raise ValueError("请求体过大")
        if not size:
            return {}
        data = json.loads(self.rfile.read(size))
        if not isinstance(data, dict):
            raise ValueError("请求体必须为 JSON 对象")
        return data

    def handle_request(self):
        path = urlsplit(self.path).path
        if self.command == "GET" and path == "/health":
            return self.respond(200, {"service": "apifox-order-mock"})
        if not path.startswith(PREFIX + "/"):
            return self.respond(404, message="接口不存在")
        body = self.read_body() if self.command in ("POST", "PUT") else {}
        with sqlite3.connect(self.server.database, timeout=5) as db:
            db.row_factory = sqlite3.Row
            if path == PREFIX + "/auth/login" and self.command == "POST":
                if body.get("username") != "demo" or body.get("password") != "demo12345":
                    return self.respond(401, message="账号或密码错误")
                token = secrets.token_urlsafe(32)
                db.execute("INSERT INTO sessions VALUES (?, ?)", (hashlib.sha256(token.encode()).hexdigest(), time.time() + 3600))
                db.commit()
                return self.respond(200, {"token": token, "tokenType": "Bearer", "expiresIn": 3600, "user": {"id": 1, "name": "演示用户"}})
            authorization = self.headers.get("Authorization", "")
            token = authorization[7:] if authorization.startswith("Bearer ") else ""
            token_hash = hashlib.sha256(token.encode()).hexdigest()
            session = db.execute("SELECT expires_at FROM sessions WHERE token_hash = ?", (token_hash,)).fetchone()
            if not token or not session or session["expires_at"] <= time.time():
                return self.respond(401, message="请先登录，token 缺失、失效或已退登")
            if path == PREFIX + "/auth/logout" and self.command == "POST":
                db.execute("DELETE FROM sessions WHERE token_hash = ?", (token_hash,))
                db.commit()
                return self.respond(200, {"loggedOut": True})
            order_root = PREFIX + "/orders"
            if path == order_root and self.command == "GET":
                query = parse_qs(urlsplit(self.path).query)
                page = int(query.get("page", ["1"])[0])
                size = int(query.get("size", ["20"])[0])
                if page < 1 or size < 1 or size > 100:
                    return self.respond(422, message="分页参数无效")
                rows = db.execute("SELECT * FROM orders ORDER BY id DESC LIMIT ? OFFSET ?", (size, (page - 1) * size)).fetchall()
                total = db.execute("SELECT COUNT(*) FROM orders").fetchone()[0]
                return self.respond(200, {"list": [dict(row) for row in rows], "total": total, "page": page, "size": size})
            if path == order_root and self.command == "POST":
                values = self.validate_order(body)
                if values is None:
                    return
                now = int(time.time() * 1000)
                cursor = db.execute("INSERT INTO orders (title, amount, quantity, status, remark, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, ?)", (*values, now, now))
                db.commit()
                row = db.execute("SELECT * FROM orders WHERE id = ?", (cursor.lastrowid,)).fetchone()
                return self.respond(201, dict(row))
            if path.startswith(order_root + "/"):
                identifier = path[len(order_root) + 1:]
                if not identifier.isdigit():
                    return self.respond(404, message="订单不存在")
                if len(identifier) > 18:
                    return self.respond(404, message="订单不存在")
                order_id = int(identifier)
                row = db.execute("SELECT * FROM orders WHERE id = ?", (order_id,)).fetchone()
                if not row:
                    return self.respond(404, message="订单不存在")
                if self.command == "GET":
                    return self.respond(200, dict(row))
                if self.command == "PUT":
                    values = self.validate_order(body)
                    if values is None:
                        return
                    db.execute("UPDATE orders SET title=?, amount=?, quantity=?, status=?, remark=?, updatedAt=? WHERE id=?", (*values, int(time.time() * 1000), order_id))
                    db.commit()
                    return self.respond(200, dict(db.execute("SELECT * FROM orders WHERE id=?", (order_id,)).fetchone()))
                if self.command == "DELETE":
                    db.execute("DELETE FROM orders WHERE id=?", (order_id,))
                    db.commit()
                    return self.respond(200, {"id": order_id, "deleted": True})
            return self.respond(404, message="接口不存在或请求方法不匹配")

    def validate_order(self, body):
        title, amount, quantity = body.get("title"), body.get("amount"), body.get("quantity")
        status, remark = body.get("status", "draft"), body.get("remark", "")
        if (not isinstance(title, str) or not title.strip() or len(title) > 100
                or type(amount) is not int or amount < 1 or amount > 100000000
                or type(quantity) is not int or quantity < 1 or quantity > 10000
                or status not in ("draft", "confirmed", "cancelled") or not isinstance(remark, str) or len(remark) > 1000):
            self.respond(422, message="订单参数无效：标题必填，金额为正整数分，数量为正整数")
            return None
        return title.strip(), amount, quantity, status, remark

    def dispatch(self):
        try:
            self.handle_request()
        except (ValueError, TypeError, json.JSONDecodeError):
            self.respond(400, message="请求参数或 JSON 格式无效")
        except (BrokenPipeError, ConnectionResetError):
            pass
        except sqlite3.Error:
            self.respond(500, message="Mock 数据库操作失败")

    do_GET = do_POST = do_PUT = do_DELETE = dispatch


def create_server(host="127.0.0.1", port=18080, database=None):
    database = Path(database or Path(__file__).parent / ".runtime/mock.sqlite3")
    database.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(database) as db:
        db.execute("CREATE TABLE IF NOT EXISTS sessions (token_hash TEXT PRIMARY KEY, expires_at REAL NOT NULL)")
        db.execute("CREATE TABLE IF NOT EXISTS orders (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, amount INTEGER NOT NULL, quantity INTEGER NOT NULL, status TEXT NOT NULL, remark TEXT NOT NULL, createdAt INTEGER NOT NULL, updatedAt INTEGER NOT NULL)")
        db.commit()
    server = ThreadingHTTPServer((host, port), MockHandler)
    server.database = str(database)
    return server


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--port", type=int, default=18080)
    arguments = parser.parse_args()
    server = create_server(port=arguments.port)
    print(f"Mock 已启动：http://127.0.0.1:{server.server_port}{PREFIX}", flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()
