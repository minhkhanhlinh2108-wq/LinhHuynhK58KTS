import os
import sys
import json
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 3000
BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "web"))
STUDENTS_FILE = os.path.join(BASE_DIR, "students.json")

class TrustScholarHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/students":
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.end_headers()
            if os.path.exists(STUDENTS_FILE):
                with open(STUDENTS_FILE, "rb") as f:
                    self.wfile.write(f.read())
            else:
                self.wfile.write(b'{"scholarships":{},"students":{}}')
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
                    self.send_response(400)
                    self.send_header("Content-Type", "application/json; charset=utf-8")
                    self.end_headers()
                    self.wfile.write(b'{"error":"Missing address or name"}')
                    return

                data = {"scholarships": {}, "students": {}}
                if os.path.exists(STUDENTS_FILE):
                    try:
                        with open(STUDENTS_FILE, "r", encoding="utf-8") as f:
                            data = json.load(f)
                    except Exception:
                        pass

                if "scholarships" not in data:
                    data["scholarships"] = {}
                if "students" not in data:
                    data["students"] = {}

                if scholarship_id is not None and str(scholarship_id).strip() != "":
                    sid = str(scholarship_id)
                    data["scholarships"][sid] = {
                        "scholarshipId": int(sid) if sid.isdigit() else sid,
                        "studentAddress": student_addr,
                        "studentName": student_name,
                        "updatedAt": ""
                    }
                data["students"][student_addr] = student_name

                with open(STUDENTS_FILE, "w", encoding="utf-8") as f:
                    json.dump(data, f, indent=2, ensure_ascii=False)

                self.send_response(200)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.end_headers()
                self.wfile.write(json.dumps({"success": True, "data": data}, ensure_ascii=False).encode("utf-8"))
                print(f"[Server] Da luu: Suat #{scholarship_id} | Vi {student_addr[:8]}... -> {student_name}")
                return
            except Exception as e:
                self.send_response(500)
                self.send_header("Content-Type", "application/json; charset=utf-8")
                self.end_headers()
                self.wfile.write(json.dumps({"error": str(e)}).encode("utf-8"))
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
            continue
    if not server:
        print(f"Error: Could not bind to any port from {PORT} to {PORT+4}")
        sys.exit(1)
    print(f"TrustScholar Server running at http://localhost:{port} (serving {BASE_DIR})")
    server.serve_forever()

if __name__ == "__main__":
    run()
