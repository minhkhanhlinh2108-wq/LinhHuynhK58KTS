import http from "node:http";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
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
    const tempFile = `${STUDENTS_FILE}.tmp.${Date.now()}`;
    fs.writeFileSync(tempFile, JSON.stringify(data, null, 2), "utf8");
    fs.renameSync(tempFile, STUDENTS_FILE);
    return true;
  } catch (err) {
    console.error("[Server] Lỗi ghi nguyên tử students.json, thử ghi trực tiếp:", err);
    try {
      fs.writeFileSync(STUDENTS_FILE, JSON.stringify(data, null, 2), "utf8");
      return true;
    } catch (fallbackErr) {
      console.error("[Server] Lỗi ghi trực tiếp students.json:", fallbackErr);
      return false;
    }
  }
}

function getLocalIpAddresses() {
  const ips = [];
  const ifaces = os.networkInterfaces();
  for (const name of Object.keys(ifaces)) {
    for (const iface of ifaces[name] || []) {
      if (iface.family === "IPv4" && !iface.internal) {
        ips.push(iface.address);
      }
    }
  }
  return ips;
}

const server = http.createServer((req, res) => {
  // CORS Headers - Cho phép mọi nguồn (cross-origin / LAN / localhost) truy cập
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");

  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }

  const parsedUrl = new URL(req.url, `http://${req.headers.host || "localhost"}`);
  const pathname = parsedUrl.pathname;

  // --- API ROUTE: GET /api/health ---
  if (req.method === "GET" && pathname === "/api/health") {
    res.writeHead(200, {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-cache, no-store, must-revalidate"
    });
    res.end(JSON.stringify({
      status: "ok",
      service: "TrustScholar Shared Student Registry",
      port: PORT,
      timestamp: new Date().toISOString()
    }));
    return;
  }

  // --- API ROUTE: GET /api/students ---
  if (req.method === "GET" && pathname === "/api/students") {
    const data = readSharedRegistry();

    // Hỗ trợ tra cứu theo ID cụ thể nếu client truyền query param (?id=... hoặc ?scholarshipId=...)
    const queryId = parsedUrl.searchParams.get("scholarshipId") || parsedUrl.searchParams.get("id");
    if (queryId) {
      const idStr = String(queryId).trim();
      const item = data.scholarships && data.scholarships[idStr];
      if (item) {
        res.writeHead(200, {
          "Content-Type": "application/json; charset=utf-8",
          "Cache-Control": "no-cache, no-store, must-revalidate"
        });
        res.end(JSON.stringify({ found: true, scholarship: item }));
      } else {
        res.writeHead(404, {
          "Content-Type": "application/json; charset=utf-8",
          "Cache-Control": "no-cache, no-store, must-revalidate"
        });
        res.end(JSON.stringify({ found: false, error: `Chưa đăng ký tên cho suất #${idStr}` }));
      }
      return;
    }

    res.writeHead(200, {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "no-cache, no-store, must-revalidate"
    });
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

        const cleanAddr = String(studentAddress).trim().toLowerCase();
        const cleanName = String(studentName).trim();

        if (!/^0x[0-9a-f]{40}$/.test(cleanAddr)) {
          res.writeHead(400, { "Content-Type": "application/json; charset=utf-8" });
          res.end(JSON.stringify({ error: "Địa chỉ ví sinh viên không đúng định dạng hex 20 byte" }));
          return;
        }

        if (!cleanName) {
          res.writeHead(400, { "Content-Type": "application/json; charset=utf-8" });
          res.end(JSON.stringify({ error: "Tên sinh viên không được để trống" }));
          return;
        }

        const data = readSharedRegistry();
        if (!data.scholarships) data.scholarships = {};
        if (!data.students) data.students = {};

        if (scholarshipId !== undefined && scholarshipId !== null && String(scholarshipId).trim() !== "") {
          const idStr = String(scholarshipId).trim();
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
          res.writeHead(200, {
            "Content-Type": "application/json; charset=utf-8",
            "Cache-Control": "no-cache, no-store, must-revalidate"
          });
          res.end(JSON.stringify({
            success: true,
            message: "Đã lưu vào nguồn dùng chung thành công",
            record: {
              scholarshipId: scholarshipId ? (parseInt(String(scholarshipId), 10) || scholarshipId) : null,
              studentAddress: cleanAddr,
              studentName: cleanName
            }
          }));
        } else {
          res.writeHead(500, { "Content-Type": "application/json; charset=utf-8" });
          res.end(JSON.stringify({ error: "Lỗi ghi tệp trên máy chủ" }));
        }
      } catch (err) {
        res.writeHead(400, { "Content-Type": "application/json; charset=utf-8" });
        res.end(JSON.stringify({ error: "Payload JSON không hợp lệ: " + err.message }));
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
  const localIps = getLocalIpAddresses();
  console.log(`================================================================`);
  console.log(`TrustScholar Web + Shared Registry Server running!`);
  console.log(`Local (máy này):          http://localhost:${PORT}`);
  console.log(`Local IP (127.0.0.1):     http://127.0.0.1:${PORT}`);
  if (localIps.length > 0) {
    localIps.forEach(ip => {
      console.log(`Network (máy khác/LAN):   http://${ip}:${PORT}`);
    });
  } else {
    console.log(`Network (0.0.0.0):        http://0.0.0.0:${PORT}`);
  }
  console.log(`Serving Web UI:           ${WEB_DIR}`);
  console.log(`Shared Registry File:     ${STUDENTS_FILE}`);
  console.log(`API Endpoints:            GET  /api/health`);
  console.log(`                          GET  /api/students[?scholarshipId=...]`);
  console.log(`                          POST /api/students`);
  console.log(`================================================================`);
});

server.on("error", (err) => {
  if (err.code === "EADDRINUSE") {
    console.warn(`[Server] Cổng ${PORT} đang bận. Thử mở cổng ${PORT + 1}...`);
    server.listen(PORT + 1, "0.0.0.0");
  } else {
    console.error("[Server] Lỗi server:", err);
  }
});
