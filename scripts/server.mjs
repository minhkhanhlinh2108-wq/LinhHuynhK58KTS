import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const WEB_DIR = path.resolve(__dirname, "../web");
const STUDENTS_FILE = path.join(WEB_DIR, "students.json");
const PORT = process.env.PORT ? parseInt(process.env.PORT, 10) : 3000;

const MIME_TYPES = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".txt": "text/plain; charset=utf-8"
};

function readSharedRegistry() {
  try {
    if (fs.existsSync(STUDENTS_FILE)) {
      const raw = fs.readFileSync(STUDENTS_FILE, "utf8");
      return JSON.parse(raw);
    }
  } catch (err) {
    console.error("[Server] Lỗi đọc students.json:", err);
  }
  return { scholarships: {}, students: {} };
}

function writeSharedRegistry(data) {
  try {
    fs.writeFileSync(STUDENTS_FILE, JSON.stringify(data, null, 2), "utf8");
    return true;
  } catch (err) {
    console.error("[Server] Lỗi ghi students.json:", err);
    return false;
  }
}

const server = http.createServer((req, res) => {
  // CORS Headers
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  const pathname = parsedUrl.pathname;

  // --- API ROUTE: GET /api/students ---
  if (req.method === "GET" && pathname === "/api/students") {
    const data = readSharedRegistry();
    res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
    res.end(JSON.stringify(data));
    return;
  }

  // --- API ROUTE: POST /api/students ---
  if (req.method === "POST" && pathname === "/api/students") {
    let body = "";
    req.on("data", chunk => {
      body += chunk;
      if (body.length > 1e6) req.destroy(); // 1MB limit
    });
    req.on("end", () => {
      try {
        const payload = JSON.parse(body);
        const { scholarshipId, studentAddress, studentName } = payload;

        if (!studentAddress || !studentName) {
          res.writeHead(400, { "Content-Type": "application/json; charset=utf-8" });
          res.end(JSON.stringify({ error: "Thiếu studentAddress hoặc studentName" }));
          return;
        }

        const data = readSharedRegistry();
        if (!data.scholarships) data.scholarships = {};
        if (!data.students) data.students = {};

        const cleanAddr = studentAddress.trim().toLowerCase();
        const cleanName = studentName.trim();

        if (scholarshipId !== undefined && scholarshipId !== null && scholarshipId !== "") {
          const idStr = String(scholarshipId);
          data.scholarships[idStr] = {
            scholarshipId: parseInt(idStr, 10) || idStr,
            studentAddress: cleanAddr,
            studentName: cleanName,
            updatedAt: new Date().toISOString()
          };
        }

        data.students[cleanAddr] = cleanName;

        const ok = writeSharedRegistry(data);
        if (ok) {
          console.log(`[Server] Đã lưu tên: Suất #${scholarshipId || "-"} | Ví ${cleanAddr.slice(0, 8)}... -> "${cleanName}"`);
          res.writeHead(200, { "Content-Type": "application/json; charset=utf-8" });
          res.end(JSON.stringify({ success: true, message: "Đã lưu vào nguồn dùng chung", data }));
        } else {
          res.writeHead(500, { "Content-Type": "application/json; charset=utf-8" });
          res.end(JSON.stringify({ error: "Lỗi ghi tệp trên máy chủ" }));
        }
      } catch (err) {
        res.writeHead(400, { "Content-Type": "application/json; charset=utf-8" });
        res.end(JSON.stringify({ error: "Payload JSON không hợp lệ" }));
      }
    });
    return;
  }

  // --- STATIC FILE SERVING ---
  let safePath = path.normalize(decodeURIComponent(pathname)).replace(/^(\.\.[/\\])+/, "");
  if (safePath === "/" || safePath === "\\") {
    safePath = "/index.html";
  }

  const filePath = path.join(WEB_DIR, safePath);

  // Security check: ensure path is inside WEB_DIR
  if (!filePath.startsWith(WEB_DIR)) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }

  fs.stat(filePath, (err, stats) => {
    if (err || !stats.isFile()) {
      res.writeHead(404, { "Content-Type": "text/plain; charset=utf-8" });
      res.end("404 Not Found");
      return;
    }

    const ext = path.extname(filePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || "application/octet-stream";

    res.writeHead(200, { "Content-Type": contentType });
    fs.createReadStream(filePath).pipe(res);
  });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`===================================================`);
  console.log(`TrustScholar Web + Shared Registry Server running!`);
  console.log(`Local:   http://localhost:${PORT}`);
  console.log(`Network: http://0.0.0.0:${PORT}`);
  console.log(`Serving: ${WEB_DIR}`);
  console.log(`Shared:  ${STUDENTS_FILE}`);
  console.log(`===================================================`);
});

server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    console.warn(`[Server] Cổng ${PORT} đang bận. Thử mở cổng ${PORT + 1}...`);
    server.listen(PORT + 1, "0.0.0.0");
  } else {
    console.error("[Server] Lỗi server:", err);
  }
});
