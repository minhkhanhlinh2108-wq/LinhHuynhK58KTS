import os
import sys
import json
import re
from datetime import datetime, timezone
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "web"))
STUDENTS_FILE = os.path.join(BASE_DIR, "students.json")

def read_shared_registry():
    data = {"scholarships": {}, "students": {}}
    if os.path.exists(STUDENTS_FILE):
        try:
            with open(STUDENTS_FILE, "r", encoding="utf-8") as f:
                data = json.load(f)
        except Exception as e:
            print(f"[Server] Lỗi đọc students.json: {e}")
    if "scholarships" not in data or not isinstance(data["scholarships"], dict):
        data["scholarships"] = {}
    if "students" not in data or not isinstance(data["students"], dict):
        data["students"] = {}
    return data

def write_shared_registry(data):
    try:
        temp_file = f"{STUDENTS_FILE}.tmp.{int(datetime.now().timestamp() * 1000)}"
        with open(temp_file, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        os.replace(temp_file, STUDENTS_FILE)
        return True
    except Exception as e:
        print(f"[Server] Lỗi ghi nguyên tử students.json, thử ghi trực tiếp: {e}")
        try:
            with open(STUDENTS_FILE, "w", encoding="utf-8") as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            return True
        except Exception as fallback_err:
            print(f"[Server] Lỗi ghi trực tiếp students.json: {fallback_err}")
            return False

class TrustScholarHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Authorization")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def send_json_response(self, code, data):
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/health":
            payload = {
                "status": "ok",
                "service": "TrustScholar Python Registry",
                "port": self.server.server_port,
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
            self.send_json_response(200, payload)
            return

        if parsed.path == "/api/students":
            data = read_shared_registry()
            params = parse_qs(parsed.query)
            query_id = params.get("scholarshipId", [None])[0] or params.get("id", [None])[0]

            if query_id:
                sid = str(query_id).strip()
                item = data.get("scholarships", {}).get(sid)
                if item:
                    self.send_json_response(200, {"found": True, "scholarship": item})
                else:
                    self.send_json_response(404, {"found": False, "error": f"Chưa đăng ký tên cho suất #{sid}"})
                return

            self.send_json_response(200, data)
            return

        super().do_GET()

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/students":
            content_length = int(self.headers.get("Content-Length", 0))
            post_data = self.rfile.read(content_length)
            try:
                payload = json.loads(post_data.decode("utf-8"))
                scholarship_id = payload.get("scholarshipId")
                student_addr = (payload.get("studentAddress") or "").strip().lower()
                student_name = (payload.get("studentName") or "").strip()

                if not student_addr or not student_name:
                    self.send_json_response(400, {"error": "Thiếu địa chỉ ví hoặc tên sinh viên"})
                    return

                if not re.match(r"^0x[0-9a-fA-F]{40}$", student_addr):
                    self.send_json_response(400, {"error": "Địa chỉ ví sinh viên không đúng định dạng hex 20 byte"})
                    return

                data = read_shared_registry()

                sid = None
                if scholarship_id is not None and str(scholarship_id).strip() != "":
                    sid = str(scholarship_id).strip()
                    data["scholarships"][sid] = {
                        "scholarshipId": int(sid) if sid.isdigit() else sid,
                        "studentAddress": student_addr,
                        "studentName": student_name,
                        "updatedAt": datetime.now(timezone.utc).isoformat()
                    }
                data["students"][student_addr] = student_name

                if write_shared_registry(data):
                    resp_record = {
                        "scholarshipId": int(sid) if (sid and sid.isdigit()) else sid,
                        "studentAddress": student_addr,
                        "studentName": student_name
                    }
                    self.send_json_response(200, {
                        "success": True,
                        "message": "Đã lưu vào nguồn dùng chung thành công",
                        "record": resp_record
                    })
                    print(f"[Server] Đã lưu tên: Suất #{scholarship_id or '-'} | Ví {student_addr[:8]}... -> \"{student_name}\"")
                    return
                else:
                    self.send_json_response(500, {"error": "Lỗi ghi tệp trên máy chủ"})
                    return
            except Exception as e:
                self.send_json_response(400, {"error": f"Payload JSON không hợp lệ: {e}"})
                return
        self.send_response(404)
        self.end_headers()

def run():
    port = PORT
    server = None
    for p in range(port, port + 5):
        try:
            server = HTTPServer(("0.0.0.0", p), TrustScholarHandler)
            port = p
            break
        except OSError:
            print(f"[Server] Cổng {p} đang bận. Thử mở cổng tiếp theo...")
            continue
    if not server:
        print(f"Error: Could not bind to any port from {PORT} to {PORT+4}")
        sys.exit(1)
    print(f"================================================================")
    print(f"TrustScholar Web + Shared Registry Server running! (Python)")
    print(f"Local (máy này):          http://localhost:{port}")
    print(f"Local IP (127.0.0.1):     http://127.0.0.1:{port}")
    print(f"Serving Web UI:           {BASE_DIR}")
    print(f"Shared Registry File:     {STUDENTS_FILE}")
    print(f"API Endpoints:            GET  /api/health")
    print(f"                          GET  /api/students[?scholarshipId=...]")
    print(f"                          POST /api/students")
    print(f"================================================================")
    server.serve_forever()

if __name__ == "__main__":
    run()
