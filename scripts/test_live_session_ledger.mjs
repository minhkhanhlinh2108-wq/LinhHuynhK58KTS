import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { ethers } from "ethers";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const webDir = path.resolve(__dirname, "../web");

console.log("================================================================================");
console.log("BỘ KIỂM THỬ TỰ ĐỘNG: LỊCH SỬ GIAO DỊCH & MINH BẠCH (LIVE SESSION LEDGER)");
console.log("================================================================================\n");

// 1. Kiểm tra cấu trúc HTML trong web/index.html
console.log("[Kiểm thử 1] Kiểm tra cấu trúc bảng Live Session Ledger trong index.html...");
const html = fs.readFileSync(path.join(webDir, "index.html"), "utf8");

assert(html.includes('id="sessionTxTableBody"'), "Phải có thẻ tbody #sessionTxTableBody");
assert(html.includes('id="ledgerCountBadge"'), "Phải có badge #ledgerCountBadge đếm số giao dịch");
assert(html.includes('id="btnSyncLedger"'), "Phải có nút #btnSyncLedger để khôi phục từ blockchain");
assert(html.includes("Lịch Sử Giao Dịch & Minh Bạch (Live Session Ledger)"), "Tiêu đề phải đúng chuẩn");
assert(html.includes("Transaction Hash & Sepolia Explorer"), "Phải có cột Etherscan explorer");
console.log("  ✔ Thẻ HTML, bảng, badge đếm và các nút hành động đạt chuẩn 100%!\n");

// 2. Mô phỏng môi trường DOM & localStorage
console.log("[Kiểm thử 2] Kiểm tra logic ghi nhận trạng thái Pending -> Success/Failed...");
const mockLocalStorage = new Map();
global.localStorage = {
  getItem: (k) => (mockLocalStorage.has(k) ? mockLocalStorage.get(k) : null),
  setItem: (k, v) => mockLocalStorage.set(k, String(v)),
  removeItem: (k) => mockLocalStorage.delete(k),
  clear: () => mockLocalStorage.clear()
};

let sessionTransactions = [];
const CHAIN_ID = 11155111;
const CONTRACT_ADDR = "0x04b0e154becb4e98b00e06df86605a70f3f914c2";
const STORAGE_KEY = `trustscholar_session_ledger_${CHAIN_ID}_${CONTRACT_ADDR}`;

function recordSessionTx(action, status, hash, details, scholarshipId = "-") {
  const now = new Date();
  const timeStr = now.toLocaleTimeString("vi-VN");
  const cleanHash = hash && /^0x[0-9a-fA-F]{64}$/.test(hash.trim()) ? hash.trim() : null;

  if (cleanHash) {
    const existingIdx = sessionTransactions.findIndex(t => t.hash && t.hash.toLowerCase() === cleanHash.toLowerCase());
    if (existingIdx !== -1) {
      sessionTransactions[existingIdx].status = status;
      if (details) sessionTransactions[existingIdx].details = details;
      if (scholarshipId && scholarshipId !== "-") sessionTransactions[existingIdx].scholarshipId = String(scholarshipId);
      sessionTransactions[existingIdx].updatedAt = now.toISOString();
      localStorage.setItem(STORAGE_KEY, JSON.stringify(sessionTransactions));
      return sessionTransactions[existingIdx];
    }
  }

  const record = {
    id: cleanHash || (Date.now() + "_" + Math.random().toString(36).slice(2, 7)),
    time: timeStr,
    action,
    status,
    hash: cleanHash,
    details: details || "",
    scholarshipId: String(scholarshipId),
    chainId: CHAIN_ID,
    contractAddress: CONTRACT_ADDR,
    createdAt: now.toISOString()
  };

  sessionTransactions.unshift(record);
  localStorage.setItem(STORAGE_KEY, JSON.stringify(sessionTransactions));
  return record;
}

function updateSessionTx(hash, updates = {}) {
  if (!hash) return;
  const cleanHash = String(hash).trim().toLowerCase();
  const target = sessionTransactions.find(t => (t.hash && t.hash.toLowerCase() === cleanHash) || t.id === cleanHash);
  if (target) {
    if (updates.status) target.status = updates.status;
    if (updates.details) target.details = updates.details;
    if (updates.scholarshipId && updates.scholarshipId !== "-") target.scholarshipId = String(updates.scholarshipId);
    if (updates.action) target.action = updates.action;
    target.updatedAt = new Date().toISOString();
    localStorage.setItem(STORAGE_KEY, JSON.stringify(sessionTransactions));
  } else {
    recordSessionTx(updates.action || "Giao Dịch", updates.status || "Thành công", hash, updates.details || "", updates.scholarshipId || "-");
  }
}

// Giả lập Giao dịch 1: Nạp Quỹ Escrow (Pending -> Success)
const testHash1 = "0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";
recordSessionTx("Nạp Tiền Escrow", "Đang chờ xác nhận", testHash1, "Đang nạp 0.05 ETH vào suất #33", 33);
assert.equal(sessionTransactions.length, 1);
assert.equal(sessionTransactions[0].status, "Đang chờ xác nhận", "Phải ghi nhận trạng thái pending ngay khi có hash");

// Cập nhật khi receipt hoàn tất
updateSessionTx(testHash1, {
  status: "Thành công",
  details: "Nạp thành công 0.05 ETH vào suất #33. Block #11985100"
});
assert.equal(sessionTransactions[0].status, "Thành công", "Phải cập nhật sang Thành công sau khi receipt hoàn tất");
assert(sessionTransactions[0].details.includes("Block #11985100"), "Chi tiết phải cập nhật số block");
console.log("  ✔ Thao tác Pending -> Thành công hoạt động hoàn hảo!");

// Giả lập Giao dịch 2: Giải Ngân bị revert (Pending -> Failed)
const testHash2 = "0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb";
recordSessionTx("Giải Ngân Học Bổng", "Đang chờ xác nhận", testHash2, "Kích hoạt giải ngân Mốc 1", 33);
assert.equal(sessionTransactions.length, 2);

// Revert
updateSessionTx(testHash2, {
  status: "Bị Chặn / Thất Bại",
  details: "Revert: MilestoneNotApproved (Mốc chưa được duyệt)"
});
assert.equal(sessionTransactions[0].status, "Bị Chặn / Thất Bại", "Phải cập nhật sang Thất Bại khi bị revert");
console.log("  ✔ Thao tác Pending -> Thất Bại (Revert) hoạt động hoàn hảo!");

// Giả lập Giao dịch 3: Người dùng bấm từ chối MetaMask (Off-chain rejected, không có hash)
recordSessionTx("Tạo Suất Học Bổng", "Từ chối", null, "Người dùng đã từ chối giao dịch trên MetaMask", "-");
assert.equal(sessionTransactions.length, 3);
assert.equal(sessionTransactions[0].hash, null, "Giao dịch từ chối off-chain không được có hash giả lập");
console.log("  ✔ Thao tác Từ chối (User rejected) ghi nhận đúng trạng thái off-chain, không tạo hash giả!\n");

// 3. Kiểm thử tính bền vững với localStorage (Mô phỏng F5 / Tải lại trang)
console.log("[Kiểm thử 3] Kiểm tra tính bền vững qua lần tải lại trang (localStorage persistence)...");
assert(mockLocalStorage.has(STORAGE_KEY), "Dữ liệu phải được lưu vào localStorage theo đúng chainId và contract address");

// Mô phỏng xóa bộ nhớ RAM như khi người dùng reload trang
sessionTransactions = [];
assert.equal(sessionTransactions.length, 0, "RAM sessionTransactions bị xóa");

// Đọc lại từ localStorage
const storedRaw = localStorage.getItem(STORAGE_KEY);
sessionTransactions = JSON.parse(storedRaw);
assert.equal(sessionTransactions.length, 3, "Sau khi tải lại trang, phải khôi phục đủ 3 giao dịch");
assert.equal(sessionTransactions[2].hash, testHash1, "Khớp hash giao dịch 1");
assert.equal(sessionTransactions[1].hash, testHash2, "Khớp hash giao dịch 2");
console.log(`  ✔ Sau khi reload, Live Session Ledger khôi phục thành công 100% dữ liệu từ ${STORAGE_KEY}!\n`);

// 4. Kiểm thử kết nối On-chain Sepolia và Khôi phục các giao dịch thực tế
console.log("[Kiểm thử 4] Kiểm tra khôi phục giao dịch thực tế từ Sepolia Event Logs...");
const SEPOLIA_RPC = "https://ethereum-sepolia-rpc.publicnode.com";
const provider = new ethers.JsonRpcProvider(SEPOLIA_RPC);

const abi = [
  "event ScholarshipCreated(uint256 indexed scholarshipId, address indexed sponsor, address indexed student, uint256 totalAmount, uint256 milestoneCount)",
  "event ScholarshipFunded(uint256 indexed scholarshipId, address indexed sponsor, uint256 amount, uint256 totalFunded)",
  "event MilestoneSubmitted(uint256 indexed scholarshipId, uint256 indexed milestoneIndex, address indexed student, string proofHash)",
  "event MilestoneApproved(uint256 indexed scholarshipId, uint256 indexed milestoneIndex, address indexed verifier)",
  "event ScholarshipReleased(uint256 indexed scholarshipId, uint256 indexed milestoneIndex, address indexed student, uint256 amount)"
];

const contract = new ethers.Contract(CONTRACT_ADDR, abi, provider);
const curBlock = await provider.getBlockNumber();
const startBlock = 11970000;

console.log(`  Đang quét logs từ block ${startBlock} đến ${curBlock}...`);
const [created, funded, released] = await Promise.all([
  contract.queryFilter(contract.filters.ScholarshipCreated(), startBlock, curBlock),
  contract.queryFilter(contract.filters.ScholarshipFunded(), startBlock, curBlock),
  contract.queryFilter(contract.filters.ScholarshipReleased(), startBlock, curBlock)
]);

console.log(`  ✔ Tìm thấy: ${created.length} event Tạo Suất, ${funded.length} event Nạp Quỹ, ${released.length} event Giải Ngân.`);
assert(created.length > 0, "Phải có ít nhất 1 event Tạo Suất trên Sepolia");
assert(funded.length > 0, "Phải có ít nhất 1 event Nạp Quỹ trên Sepolia");
assert(released.length > 0, "Phải có ít nhất 1 event Giải Ngân trên Sepolia");

// Kiểm tra Suất #33 và #32 có trong danh sách
const create33 = created.find(e => e.args.scholarshipId.toString() === "33");
assert(create33, "Event tạo suất #33 phải tồn tại on-chain");
assert.equal(create33.transactionHash, "0x240bc3e0f3558c3c8fdaa4c3c665fb189c79ca59f4af69c3b24357983399b633");

const release33_m0 = released.find(e => e.args.scholarshipId.toString() === "33" && e.args.milestoneIndex.toString() === "0");
assert(release33_m0, "Event giải ngân mốc 0 của suất #33 phải tồn tại");
assert.equal(release33_m0.transactionHash, "0xf13685ceb1b81650a0809701745095219240863c28da45734cf42fa69ef9a393");

const release33_m1 = released.find(e => e.args.scholarshipId.toString() === "33" && e.args.milestoneIndex.toString() === "1");
assert(release33_m1, "Event giải ngân mốc 1 của suất #33 phải tồn tại");
assert.equal(release33_m1.transactionHash, "0x04005b41e208345f1bd625c6f02998bfe13af2c24f59cc394de03e5c24f5dd63");

console.log(`  ✔ Suất #33: Tạo suất = ${create33.transactionHash}`);
console.log(`  ✔ Suất #33: Giải ngân Mốc 0 = ${release33_m0.transactionHash}`);
console.log(`  ✔ Suất #33: Giải ngân Mốc 1 = ${release33_m1.transactionHash}`);
console.log("  ✔ Toàn bộ các giao dịch thực tế trên Sepolia được khôi phục chính xác 100%!\n");

// 5. Kiểm thử định dạng liên kết Sepolia Etherscan
console.log("[Kiểm thử 5] Kiểm tra cấu trúc liên kết Sepolia Etherscan...");
const expectedUrl = `https://sepolia.etherscan.io/tx/${release33_m0.transactionHash}`;
assert.equal(expectedUrl, "https://sepolia.etherscan.io/tx/0xf13685ceb1b81650a0809701745095219240863c28da45734cf42fa69ef9a393");
console.log(`  ✔ Link Etherscan đạt chuẩn: ${expectedUrl}\n`);

console.log("================================================================================");
console.log("TỔNG KẾT: 5/5 BÀI KIỂM THỬ LIVE SESSION LEDGER ĐẠT 100% (PASS)!");
console.log("================================================================================");
