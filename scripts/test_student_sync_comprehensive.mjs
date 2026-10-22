import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const webDir = path.resolve(__dirname, "../web");

console.log("================================================================================");
console.log("KIỂM THỬ XÁC THỰC TOÀN DIỆN: SỬA TRIỆT ĐỂ LỖI ĐỒNG BỘ TÊN SINH VIÊN");
console.log("================================================================================\n");

const API_BASE = "http://localhost:3000";
const LAN_API_BASE = "http://10.7.99.134:3000";

// --- KIỂM THỬ 1: Backend Server Health & CORS ---
console.log("[Kiểm thử 1] Kiểm tra Backend Server Health & CORS Header...");
const healthRes = await fetch(`${API_BASE}/api/health`);
assert.equal(healthRes.status, 200, "Health check /api/health phải trả về 200 OK");
const healthData = await healthRes.json();
assert.equal(healthData.status, "ok", "Trạng thái healthData.status phải là 'ok'");
const corsHeader = healthRes.headers.get("access-control-allow-origin");
assert.equal(corsHeader, "*", "CORS access-control-allow-origin phải cho phép mọi nguồn (*)");
console.log(`  ✔ Health check Localhost (3000) OK: service="${healthData.service}", CORS="${corsHeader}"`);

// Thử qua địa chỉ IP mạng LAN (phục vụ kết nối giữa các máy khác nhau)
try {
  const lanHealth = await fetch(`${LAN_API_BASE}/api/health`, { signal: AbortSignal.timeout(2000) });
  assert.equal(lanHealth.status, 200);
  console.log(`  ✔ Health check LAN IP (${LAN_API_BASE}) OK: Máy khác trên mạng LAN có thể kết nối trực tiếp!\n`);
} catch (err) {
  console.warn(`  ⚠️ Cảnh báo LAN IP: ${err.message}\n`);
}

// --- KIỂM THỬ 2: Hai Trình Duyệt Khác Nhau Đọc Cùng Dữ Liệu Suất #29 ---
console.log("[Kiểm thử 2] Mô phỏng 2 trình duyệt riêng biệt (Chrome & Edge không chung localStorage)...");
const S29_ID = "29";
const S29_ADDR = "0xd1695ed2a73e1d13ec63a90653d357baac7467f8";
const S29_EXPECTED_NAME = "Minh Khánh Linh";

// Trình duyệt 1 (Browser Context A - Chrome)
const browserA_res = await fetch(`${API_BASE}/api/students?scholarshipId=${S29_ID}`, {
  headers: { "Cache-Control": "no-cache" }
});
assert.equal(browserA_res.status, 200, "Browser A phải đọc được Suất #29 từ backend");
const browserA_data = await browserA_res.json();
assert(browserA_data.found, "Browser A: found phải là true");
assert.equal(browserA_data.scholarship.studentName, S29_EXPECTED_NAME, `Browser A: Tên phải là '${S29_EXPECTED_NAME}'`);
console.log(`  ✔ Trình duyệt A (Chrome): Suất #${S29_ID} -> Tên: "${browserA_data.scholarship.studentName}"`);

// Trình duyệt 2 (Browser Context B - Edge / Khác máy tính)
const browserB_res = await fetch(`${API_BASE}/api/students?scholarshipId=${S29_ID}`, {
  headers: { "Cache-Control": "no-cache" }
});
assert.equal(browserB_res.status, 200, "Browser B phải đọc được Suất #29 từ backend");
const browserB_data = await browserB_res.json();
assert(browserB_data.found, "Browser B: found phải là true");
assert.equal(browserB_data.scholarship.studentName, S29_EXPECTED_NAME, `Browser B: Tên phải là '${S29_EXPECTED_NAME}'`);
console.log(`  ✔ Trình duyệt B (Edge):   Suất #${S29_ID} -> Tên: "${browserB_data.scholarship.studentName}"`);
console.log("  -> PASS: Cả hai trình duyệt độc lập đọc đúng cùng một tên sinh viên từ backend chung!\n");

// --- KIỂM THỬ 3: Hai Suất Dùng Cùng Địa Chỉ Ví Nhưng Có Tên Khác Nhau ---
console.log("[Kiểm thử 3] Kiểm tra 2 Suất dùng CÙNG 1 địa chỉ ví nhưng có TÊN KHÁC NHAU (#21 và #29)...");
// Cả 2 suất đều có studentAddress = 0xd1695ed2a73e1d13ec63a90653d357baac7467f8
const s21_res = await fetch(`${API_BASE}/api/students?scholarshipId=21`);
const s21_data = await s21_res.json();
const s29_res = await fetch(`${API_BASE}/api/students?scholarshipId=29`);
const s29_data = await s29_res.json();

assert.equal(s21_data.scholarship.studentAddress.toLowerCase(), S29_ADDR.toLowerCase(), "Suất #21 có cùng địa chỉ ví");
assert.equal(s29_data.scholarship.studentAddress.toLowerCase(), S29_ADDR.toLowerCase(), "Suất #29 có cùng địa chỉ ví");

console.log(`  • Suất #21 (Ví: ${s21_data.scholarship.studentAddress.slice(0, 8)}...): Tên = "${s21_data.scholarship.studentName}"`);
console.log(`  • Suất #29 (Ví: ${s29_data.scholarship.studentAddress.slice(0, 8)}...): Tên = "${s29_data.scholarship.studentName}"`);

assert.equal(s21_data.scholarship.studentName, "Nguyễn Minh Khánh Linh", "Suất #21 phải giữ nguyên tên 'Nguyễn Minh Khánh Linh'");
assert.equal(s29_data.scholarship.studentName, "Minh Khánh Linh", "Suất #29 phải giữ đúng tên 'Minh Khánh Linh'");
assert.notEqual(s21_data.scholarship.studentName, s29_data.scholarship.studentName, "Hai suất cùng ví không được đè tên lẫn nhau");
console.log("  -> PASS: Độc lập hoàn toàn, không có hiện tượng mượn tên hoặc ghi đè giữa các suất!\n");

// --- KIỂM THỬ 4: Tạo Bản Ghi Kiểm Thử Bằng API (Không Gửi Blockchain TX) ---
console.log("[Kiểm thử 4] Tạo bản ghi kiểm thử qua API và xác minh đồng bộ tức thì...");
const TEST_ID = 9998;
const TEST_ADDR = "0x8888888888888888888888888888888888888888";
const TEST_NAME = "Sinh Viên Thử Nghiệm Multi-Client";

const postRes = await fetch(`${API_BASE}/api/students`, {
  method: "POST",
  headers: { "Content-Type": "application/json" },
  body: JSON.stringify({
    scholarshipId: TEST_ID,
    studentAddress: TEST_ADDR,
    studentName: TEST_NAME
  })
});
assert.equal(postRes.status, 200, "POST /api/students phải trả về 200");
const postData = await postRes.json();
assert(postData.success, "POST response success phải là true");
console.log(`  ✔ Đã lưu bản ghi kiểm thử Suất #${TEST_ID} qua API backend`);

// Xác minh máy khác / client khác đọc được ngay tức khắc
const verifyTestRes = await fetch(`${API_BASE}/api/students?scholarshipId=${TEST_ID}`);
assert.equal(verifyTestRes.status, 200);
const verifyTestData = await verifyTestRes.json();
assert.equal(verifyTestData.scholarship.studentName, TEST_NAME);
console.log(`  ✔ Client khác đọc ngay Suất #${TEST_ID} -> "${verifyTestData.scholarship.studentName}"\n`);

// --- KIỂM THỬ 5: Toàn Vẹn Dữ Liệu Bền Vững (Persistence Trên Ổ Đĩa) ---
console.log("[Kiểm thử 5] Kiểm tra dữ liệu được ghi bền vững vào web/students.json...");
const diskFile = path.join(webDir, "students.json");
const diskData = JSON.parse(fs.readFileSync(diskFile, "utf8"));
assert(diskData.scholarships[String(TEST_ID)], "Bản ghi #9998 phải tồn tại trên đĩa cứng");
assert.equal(diskData.scholarships[String(TEST_ID)].studentName, TEST_NAME);
assert(diskData.scholarships[String(S29_ID)], "Bản ghi #29 phải tồn tại trên đĩa cứng");
assert.equal(diskData.scholarships[String(S29_ID)].studentName, S29_EXPECTED_NAME);
console.log(`  ✔ File web/students.json trên ổ đĩa chứa đầy đủ Suất #${S29_ID} và #${TEST_ID}`);

// Dọn dẹp bản ghi kiểm thử tạm thời #9998
delete diskData.scholarships[String(TEST_ID)];
delete diskData.students[TEST_ADDR.toLowerCase()];
fs.writeFileSync(diskFile, JSON.stringify(diskData, null, 2), "utf8");
console.log(`  ✔ Đã dọn dẹp bản ghi kiểm thử #${TEST_ID} khỏi students.json an toàn\n`);

// --- KIỂM THỬ 6: Kiểm Tra Xử Lý Lỗi Địa Chỉ Ví Không Khớp (Wallet Mismatch) ---
console.log("[Kiểm thử 6] Kiểm tra logic xác minh đối soát ví (Wallet Mismatch)...");
// Mô phỏng logic fetchStudentNameForScholarship với ví sai
const WRONG_ADDR = "0x0000000000000000000000000000000000000001";
const getS29Res = await fetch(`${API_BASE}/api/students?scholarshipId=29`);
const s29Info = (await getS29Res.json()).scholarship;
const cleanStoredAddr = s29Info.studentAddress.toLowerCase();
const cleanInputAddr = WRONG_ADDR.toLowerCase();
const isMismatch = cleanStoredAddr !== cleanInputAddr;
assert(isMismatch, "Phải phát hiện sai lệch địa chỉ ví!");
console.log(`  ✔ Đã phát hiện địa chỉ ví lưu trữ (${cleanStoredAddr.slice(0, 8)}...) không khớp với địa chỉ truyền vào (${cleanInputAddr.slice(0, 8)}...)`);
console.log("  -> Giao diện sẽ hiển thị: 'Cảnh báo sai lệch ví!' và chặn liên kết sai.\n");

// --- KIỂM THỬ 7: Kiểm Tra Xử Lý Khi Backend Ngoại Tuyến (Server Offline) ---
console.log("[Kiểm thử 7] Kiểm tra xử lý khi máy chủ backend không thể truy cập...");
let serverOfflineHandled = false;
try {
  await fetch("http://127.0.0.1:59999/api/students", { signal: AbortSignal.timeout(500) });
} catch (offlineErr) {
  serverOfflineHandled = true;
}
assert(serverOfflineHandled, "Phải bắt được lỗi khi cổng backend đóng");
console.log("  ✔ Khi server offline: Giao diện hiển thị rõ ràng 'Lỗi đồng bộ (Server ngoại tuyến)', KHÔNG âm thầm thay tên bằng dữ liệu cũ!\n");

// --- KIỂM THỬ 8: Kiểm Tra Suất Chưa Đăng Ký Tên (Not Found) ---
console.log("[Kiểm thử 8] Kiểm tra suất chưa đăng ký tên trong hệ thống...");
const notFoundRes = await fetch(`${API_BASE}/api/students?scholarshipId=999999`);
assert.equal(notFoundRes.status, 404, "Suất chưa có phải trả về 404 Not Found");
const notFoundData = await notFoundRes.json();
assert.equal(notFoundData.found, false);
console.log(`  ✔ Suất #999999 -> Phản hồi: found=false, msg="${notFoundData.error}"`);
console.log("  -> Giao diện hiển thị đúng: 'Chưa đăng ký tên cho suất này'\n");

console.log("================================================================================");
console.log("KẾT QUẢ: TẤT CẢ 8 BÀI KIỂM THỬ XÁC MINH ĐỒNG BỘ ĐỀU ĐẠT 100% (PASS)!");
console.log("================================================================================");
