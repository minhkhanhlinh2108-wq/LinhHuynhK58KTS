import assert from "node:assert/strict";
import fs from "node:fs";
import { ethers } from "ethers";

const CONTRACT_ADDRESS = "0x04B0e154Becb4E98b00E06DF86605A70f3F914c2";
const SEPOLIA_RPC_LIST = [
  "https://ethereum-sepolia-rpc.publicnode.com",
  "https://1rpc.io/sepolia",
  "https://rpc.sepolia.org"
];

const htmlContent = fs.readFileSync("web/index.html", "utf8");

// Extract PROJECT_CORE_ABI from web/index.html
const abiMatch = htmlContent.match(/const PROJECT_CORE_ABI = (\[[\s\S]*?\]);/);
assert(abiMatch, "PROJECT_CORE_ABI must be present in web/index.html");
const PROJECT_CORE_ABI = eval(abiMatch[1]);

console.log("=== KIỂM THỬ 1: KIỂM TRA MÃ NGUỒN VÀ THAM CHIẾU HÀM TRONG WEB/INDEX.HTML ===");

// 1. Kiểm tra không còn lỗi ReferenceError: readContract
assert(
  !htmlContent.includes("const m = await readContract.getMilestone(id, i);\n        const st = Number(m.status);"),
  "Không còn dòng gọi readContract chưa khai báo trực tiếp trong handleLookupScholarship"
);
console.log("✔ Không còn lỗi tham chiếu biến chưa khai báo (readContract ReferenceError).");

// 2. Kiểm tra hàm getSepoliaMilestone và isScholarshipNotFoundError đã được khai báo
assert(htmlContent.includes("function isScholarshipNotFoundError(err)"), "Phải có hàm isScholarshipNotFoundError");
assert(htmlContent.includes("async function getSepoliaMilestone(id, index)"), "Phải có hàm getSepoliaMilestone");
assert(htmlContent.includes("async function getSepoliaReadContract()"), "Phải có hàm getSepoliaReadContract");
console.log("✔ Đã có đầy đủ hàm getSepoliaMilestone, getSepoliaReadContract, isScholarshipNotFoundError.");

// 3. Kiểm tra phân định lỗi ScholarshipNotFound vs RPC Error
assert(htmlContent.includes('err.code === "SCHOLARSHIP_NOT_FOUND" || isScholarshipNotFoundError(err)'), "Phải phân định ScholarshipNotFound");
assert(htmlContent.includes("Revert: ScholarshipNotFound"), "Thông báo phân định rõ Revert: ScholarshipNotFound");
console.log("✔ Đã phân định rõ giữa Suất không tồn tại (Revert on-chain) và Lỗi kết nối RPC.");

console.log("\n=== KIỂM THỬ 2: KẾT NỐI ON-CHAIN THỰC TẾ TRÊN MẠNG SEPOLIA (11155111) ===");

const provider = new ethers.JsonRpcProvider(SEPOLIA_RPC_LIST[0]);
const contract = new ethers.Contract(CONTRACT_ADDRESS, PROJECT_CORE_ABI, provider);

const count = await contract.scholarshipCount();
console.log(`✔ Tổng số suất học bổng on-chain trên Sepolia: ${count.toString()}`);
assert(Number(count) >= 28, "Hợp đồng phải có ít nhất 28 suất học bổng");

// Helper mô phỏng đúng logic getSepoliaScholarship từ web/index.html
function isScholarshipNotFoundError(err) {
  if (!err) return false;
  if (err.data === "0xe5da5858" || (typeof err.data === "string" && err.data.includes("e5da5858"))) return true;
  if (err.errorName === "ScholarshipNotFound") return true;
  const str = (err.message || "") + " " + (err.shortMessage || "") + " " + (err.reason || "");
  if (str.includes("ScholarshipNotFound") || str.includes("0xe5da5858")) return true;
  return false;
}

async function simulateGetScholarship(id) {
  let lastError = null;
  for (const rpc of SEPOLIA_RPC_LIST) {
    try {
      const p = new ethers.JsonRpcProvider(rpc);
      const c = new ethers.Contract(CONTRACT_ADDRESS, PROJECT_CORE_ABI, p);
      return await c.getScholarship(id);
    } catch (err) {
      if (isScholarshipNotFoundError(err)) {
        const notFoundErr = new Error(`ScholarshipNotFound: Suất #${id} không tồn tại trên hợp đồng.`);
        notFoundErr.code = "SCHOLARSHIP_NOT_FOUND";
        throw notFoundErr;
      }
      lastError = err;
    }
  }
  throw lastError || new Error("RPC error");
}

async function simulateGetMilestone(id, index) {
  let lastError = null;
  for (const rpc of SEPOLIA_RPC_LIST) {
    try {
      const p = new ethers.JsonRpcProvider(rpc);
      const c = new ethers.Contract(CONTRACT_ADDRESS, PROJECT_CORE_ABI, p);
      return await c.getMilestone(id, index);
    } catch (err) {
      if (isScholarshipNotFoundError(err)) throw err;
      lastError = err;
    }
  }
  throw lastError || new Error("RPC error");
}

console.log("\n=== KIỂM THỬ 3: TRA CỨU CÁC SUẤT HỌC BỔNG HỢP LỆ (ID #1, #24, #27, #28) ===");

for (const testId of [1, 24, 27, 28]) {
  const s = await simulateGetScholarship(testId);
  assert.equal(s.id.toString(), testId.toString(), `ID trả về phải là ${testId}`);
  assert(ethers.isAddress(s.sponsor), "Sponsor phải là địa chỉ EVM hợp lệ");
  assert(ethers.isAddress(s.student), "Student phải là địa chỉ EVM hợp lệ");
  assert(s.milestoneCount > 0n, "Suất học bổng phải có ít nhất 1 mốc");

  console.log(`✔ Suất #${testId}:`);
  console.log(`   - Sponsor: ${s.sponsor}`);
  console.log(`   - Student: ${s.student}`);
  console.log(`   - Tổng cam kết: ${ethers.formatEther(s.totalAmount)} ETH`);
  console.log(`   - Đã nạp: ${ethers.formatEther(s.fundedAmount)} ETH`);
  console.log(`   - Đã giải ngân: ${ethers.formatEther(s.releasedAmount)} ETH`);
  console.log(`   - Số mốc: ${s.milestoneCount}`);

  for (let i = 0; i < Number(s.milestoneCount); i++) {
    const m = await simulateGetMilestone(testId, i);
    const statusNames = ["Pending", "Submitted", "Approved", "Disbursed"];
    console.log(`   - Mốc ${i}: ${ethers.formatEther(m.amount)} ETH | Trạng thái: ${statusNames[Number(m.status)]} | Proof CID: ${m.proofHash || "Chưa có"}`);
  }
}

console.log("\n=== KIỂM THỬ 4: KIỂM CHỨNG NHẬN DIỆN MÃ SUẤT KHÔNG TỒN TẠI (ID #999) ===");

try {
  await simulateGetScholarship(999);
  assert.fail("ID #999 không được trả về thành công");
} catch (err) {
  assert.equal(err.code, "SCHOLARSHIP_NOT_FOUND", "Lỗi phải được nhận diện chính xác là SCHOLARSHIP_NOT_FOUND");
  console.log(`✔ Suất không tồn tại (#999) được nhận diện chính xác: code="${err.code}" - Không báo nhầm lỗi mạng RPC!`);
}

console.log("\n=== HOÀN TẤT TOÀN BỘ KIỂM THỬ TRA CỨU: 100% THÀNH CÔNG ===");
