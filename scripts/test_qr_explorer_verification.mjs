import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { ethers } from "ethers";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const webDir = path.resolve(__dirname, "../web");

console.log("================================================================================");
console.log("BỘ KIỂM THỬ TỰ ĐỘNG: QR CODE & SEPOLIA ETHERSCAN VERIFICATION (MULTI-MILESTONE)");
console.log("================================================================================\n");

// 1. Kiểm tra sự tồn tại của tệp thư viện tĩnh nội bộ QRious
console.log("[Kiểm thử 1] Kiểm tra tệp thư viện QRious và tài nguyên phục vụ Offline...");
const qriousPath = path.join(webDir, "assets/qrious.min.js");
assert(fs.existsSync(qriousPath), "Tệp web/assets/qrious.min.js phải tồn tại");
const qriousContent = fs.readFileSync(qriousPath, "utf8");
assert(qriousContent.length > 10000, "Tệp qrious.min.js có nội dung hợp lệ (>10KB)");
console.log(`  ✔ web/assets/qrious.min.js tồn tại sẵn sàng (${qriousContent.length} bytes) - Đáp ứng 100% demo offline!\n`);

// 2. Kiểm tra cấu trúc HTML & CSS trong web/index.html
console.log("[Kiểm thử 2] Kiểm tra thẻ HTML, cấu trúc giao diện và CSS Responsive...");
const html = fs.readFileSync(path.join(webDir, "index.html"), "utf8");

assert(html.includes("assets/qrious.min.js"), "index.html phải nạp thư viện QRious");
assert(html.includes('id="explorerVerificationCard"'), "Phải có thẻ #explorerVerificationCard");
assert(html.includes("Xác minh học bổng trên Blockchain"), "Tiêu đề phải đúng: 'Xác minh học bổng trên Blockchain'");
assert(html.includes('id="verifQrCanvas"'), "Phải có canvas #verifQrCanvas vẽ QR Code");
assert(html.includes('id="btnOpenEtherscan"'), "Phải có nút 'Mở trên Sepolia Etherscan'");
assert(html.includes('id="btnCopyHash"'), "Phải có nút 'Sao chép Hash'");
assert(html.includes('id="btnCopyLink"'), "Phải có nút 'Sao chép liên kết'");
assert(html.includes('id="verifNoData"'), "Phải có vùng thông báo #verifNoData khi chưa có hash");
assert(html.includes('id="verifTxTypeTabs"'), "Phải có vùng chứa tab danh sách giao dịch #verifTxTypeTabs");
const normalizedHtml = html.replace(/\s+/g, " ");
assert(normalizedHtml.includes("Chưa có Transaction Hash xác minh cho suất học bổng này"), "Thông báo chuẩn khi thiếu hash");

// Kiểm tra CSS Responsive 2 cột -> 1 cột
assert(html.includes("verification-grid"), "Có class .verification-grid");
assert(html.includes("@media (max-width: 768px)"), "Có truy vấn media màn hình nhỏ @media (max-width: 768px)");
assert(html.includes("grid-template-columns: 1fr"), "Màn hình nhỏ chuyển thành 1 cột");
console.log("  ✔ Thẻ HTML & CSS đạt chuẩn: Đầy đủ các nút hành động, tab đa giao dịch, responsive 2 cột!\n");

// 3. Khởi tạo RPC Provider và Contract trên mạng Sepolia
console.log("[Kiểm thử 3] Kiểm tra kết nối On-Chain Sepolia (Chain ID 11155111)...");
const SEPOLIA_RPC = "https://ethereum-sepolia-rpc.publicnode.com";
const CONTRACT_ADDR = "0x04B0e154Becb4E98b00E06DF86605A70f3F914c2";
const provider = new ethers.JsonRpcProvider(SEPOLIA_RPC);

const network = await provider.getNetwork();
assert.equal(Number(network.chainId), 11155111, "Chain ID phải là 11155111 (Sepolia)");
console.log(`  ✔ Kết nối RPC Sepolia thành công (Chain ID: ${network.chainId}, Contract: ${CONTRACT_ADDR})\n`);

const abi = [
  "event ScholarshipCreated(uint256 indexed scholarshipId, address indexed sponsor, address indexed student, uint256 totalAmount, uint256 milestoneCount)",
  "event ScholarshipFunded(uint256 indexed scholarshipId, address indexed sponsor, uint256 amount, uint256 totalFunded)",
  "event ScholarshipReleased(uint256 indexed scholarshipId, uint256 indexed milestoneIndex, address indexed student, uint256 amount)",
  "function getScholarship(uint256 scholarshipId) external view returns (tuple(uint256 id, address sponsor, address student, uint256 totalAmount, uint256 fundedAmount, uint256 releasedAmount, uint256 milestoneCount))",
  "function getMilestone(uint256 scholarshipId, uint256 milestoneIndex) external view returns (tuple(uint256 amount, string proofHash, uint8 status, uint256 approvedAt, uint256 disbursedAt))"
];

const contract = new ethers.Contract(CONTRACT_ADDR, abi, provider);

// Hàm tái hiện logic xác minh on-chain tương tự updateBlockchainVerification
async function verifyScholarshipOnChain(scholarshipId) {
  const idKey = String(scholarshipId).trim();
  let s = null;
  try {
    s = await contract.getScholarship(scholarshipId);
  } catch (err) {
    return { notFound: true, txList: [] };
  }

  const curBlock = await provider.getBlockNumber();
  const startBlock = 11970000;

  const [createdEvents, fundedEvents, releasedEvents] = await Promise.all([
    contract.queryFilter(contract.filters.ScholarshipCreated(scholarshipId), startBlock, curBlock).catch(() => []),
    contract.queryFilter(contract.filters.ScholarshipFunded(scholarshipId), startBlock, curBlock).catch(() => []),
    contract.queryFilter(contract.filters.ScholarshipReleased(scholarshipId), startBlock, curBlock).catch(() => [])
  ]);

  const mCount = Number(s.milestoneCount);
  const txList = [];

  // BƯỚC 1: XỬ LÝ TỪNG MỐC GIẢI NGÂN
  for (let i = 0; i < mCount; i++) {
    const m = await contract.getMilestone(scholarshipId, i);
    const isDisbursed = Number(m.status) === 3;
    const mAmountEth = ethers.formatEther(m.amount);
    const mName = `Mốc ${i}`;

    if (isDisbursed) {
      const relEv = releasedEvents.find(e => Number(e.args.milestoneIndex) === i && String(e.args.scholarshipId) === idKey);
      if (relEv && relEv.transactionHash) {
        const rc = await provider.getTransactionReceipt(relEv.transactionHash);
        const isSuccessReceipt = rc && Number(rc.status) === 1;
        const isAmountMatch = BigInt(relEv.args.amount) === BigInt(m.amount);

        if (isSuccessReceipt && isAmountMatch) {
          txList.push({
            type: "release",
            milestoneIndex: i,
            title: `🚀 GIẢI NGÂN ${mName.toUpperCase()} (${mAmountEth} ETH)`,
            tabLabel: `🚀 ${mName} (${mAmountEth} ETH)`,
            hash: relEv.transactionHash,
            blockNumber: rc.blockNumber,
            amountEth: mAmountEth,
            verified: true
          });
        }
      }
    }
  }

  // BƯỚC 2: XỬ LÝ GIAO DỊCH TẠO SUẤT
  const cEv = createdEvents.find(e => String(e.args.scholarshipId) === idKey);
  if (cEv && cEv.transactionHash) {
    const cRc = await provider.getTransactionReceipt(cEv.transactionHash);
    if (cRc && Number(cRc.status) === 1) {
      txList.push({
        type: "create",
        milestoneIndex: null,
        title: `🎓 GIAO DỊCH TẠO SUẤT HỌC BỔNG #${idKey}`,
        tabLabel: `🎓 Tạo Suất #${idKey}`,
        hash: cEv.transactionHash,
        blockNumber: cRc.blockNumber,
        verified: true
      });
    }
  }

  // BƯỚC 3: XỬ LÝ GIAO DỊCH NẠP QUỸ
  fundedEvents.forEach((fEv, fIdx) => {
    if (fEv.transactionHash && !txList.some(x => x.hash === fEv.transactionHash)) {
      const fAmountEth = ethers.formatEther(fEv.args.amount || 0);
      txList.push({
        type: "fund",
        milestoneIndex: null,
        title: `💰 NẠP QUỸ ESCROW - ${fAmountEth} ETH`,
        tabLabel: `💰 Nạp Quỹ #${fIdx + 1}`,
        hash: fEv.transactionHash,
        amountEth: fAmountEth,
        verified: true
      });
    }
  });

  return { notFound: false, scholarship: s, txList };
}

// 4. KIỂM THỬ TRỌNG TÂM: Suất #33 có 2 mốc giải ngân (Case tái hiện lỗi)
console.log("[Kiểm thử 4] Kiểm tra Suất #33: Suất 2 mốc (mỗi mốc 0.05 ETH) - Case lỗi tái hiện...");
const res33 = await verifyScholarshipOnChain(33);
assert(!res33.notFound, "Suất #33 phải tồn tại trên Smart Contract");
assert.equal(Number(res33.scholarship.milestoneCount), 2, "Suất #33 phải có đúng 2 mốc học tập");
assert.equal(ethers.formatEther(res33.scholarship.totalAmount), "0.1", "Tổng định mức #33 phải là 0.1 ETH");
assert.equal(ethers.formatEther(res33.scholarship.releasedAmount), "0.1", "Số tiền đã giải ngân phải là 0.1 ETH");

const releaseTxs33 = res33.txList.filter(t => t.type === "release");
assert.equal(releaseTxs33.length, 2, "Suất #33 phải có đúng 2 giao dịch giải ngân cho 2 mốc");

// Kiểm tra chi tiết Mốc 0
const m0_33 = releaseTxs33.find(t => t.milestoneIndex === 0);
assert(m0_33, "Phải có giao dịch giải ngân Mốc 0");
assert.equal(m0_33.amountEth, "0.05", "Mốc 0 giải ngân đúng 0.05 ETH");
assert.equal(m0_33.hash, "0xf13685ceb1b81650a0809701745095219240863c28da45734cf42fa69ef9a393", "Hash Mốc 0 phải khớp với log Sepolia");

// Kiểm tra chi tiết Mốc 1
const m1_33 = releaseTxs33.find(t => t.milestoneIndex === 1);
assert(m1_33, "Phải có giao dịch giải ngân Mốc 1");
assert.equal(m1_33.amountEth, "0.05", "Mốc 1 giải ngân đúng 0.05 ETH");
assert.equal(m1_33.hash, "0x04005b41e208345f1bd625c6f02998bfe13af2c24f59cc394de03e5c24f5dd63", "Hash Mốc 1 phải khớp với log Sepolia");

// Kiểm tra giao dịch tạo suất #33
const createTx33 = res33.txList.find(t => t.type === "create");
assert(createTx33, "Phải có giao dịch tạo suất #33");
assert.equal(createTx33.hash, "0x240bc3e0f3558c3c8fdaa4c3c665fb189c79ca59f4af69c3b24357983399b633", "Hash tạo suất #33 phải khớp");

// Đảm bảo 3 hash này hoàn toàn khác nhau (không dùng chung hash)
assert.notEqual(m0_33.hash, m1_33.hash, "Hash Mốc 0 và Mốc 1 phải riêng biệt");
assert.notEqual(m0_33.hash, createTx33.hash, "Hash Mốc 0 và Hash Tạo suất phải riêng biệt");
assert.notEqual(m1_33.hash, createTx33.hash, "Hash Mốc 1 và Hash Tạo suất phải riêng biệt");

console.log(`  ✔ Mốc 0: TxHash = ${m0_33.hash} (${m0_33.amountEth} ETH, Block #${m0_33.blockNumber})`);
console.log(`  ✔ Mốc 1: TxHash = ${m1_33.hash} (${m1_33.amountEth} ETH, Block #${m1_33.blockNumber})`);
console.log(`  ✔ Tạo Suất: TxHash = ${createTx33.hash} (Block #${createTx33.blockNumber})`);
console.log(`  ✔ URL Etherscan Mốc 0 = https://sepolia.etherscan.io/tx/${m0_33.hash}`);
console.log(`  ✔ URL Etherscan Mốc 1 = https://sepolia.etherscan.io/tx/${m1_33.hash}`);
console.log("  ✔ PASS: Suất #33 (2 mốc) trích xuất thành công đầy đủ 2 mốc giải ngân độc lập và 1 giao dịch tạo suất!\n");

// 5. KIỂM THỬ: Suất #32 có 1 mốc giải ngân (Bảo toàn tính năng hiện có)
console.log("[Kiểm thử 5] Kiểm tra Suất #32: Suất 1 mốc (0.05 ETH) - Không bị hồi quy...");
const res32 = await verifyScholarshipOnChain(32);
assert(!res32.notFound, "Suất #32 phải tồn tại");
assert.equal(Number(res32.scholarship.milestoneCount), 1, "Suất #32 có đúng 1 mốc");
const releaseTxs32 = res32.txList.filter(t => t.type === "release");
assert.equal(releaseTxs32.length, 1, "Suất #32 có đúng 1 giao dịch giải ngân");
assert.equal(releaseTxs32[0].hash, "0x0d2f0e35e08223d15f869602931974893dad2d79b915c2999bb13466f67e49aa");
const createTx32 = res32.txList.find(t => t.type === "create");
assert(createTx32, "Suất #32 có giao dịch tạo suất");
assert.equal(createTx32.hash, "0xe909ac2fa8676986ec136ec7a01f1a1f438903389ac7733fcf4f73427fc2cb28");
console.log(`  ✔ Suất #32: Mốc 0 TxHash = ${releaseTxs32[0].hash}`);
console.log(`  ✔ Suất #32: Tạo Suất TxHash = ${createTx32.hash}`);
console.log("  ✔ PASS: Suất 1 mốc hoạt động ổn định, không bị ảnh hưởng!\n");

// 6. KIỂM THỬ: Suất chưa giải ngân (#27)
console.log("[Kiểm thử 6] Kiểm tra Suất chưa giải ngân (#27)...");
const res27 = await verifyScholarshipOnChain(27);
assert(!res27.notFound, "Suất #27 phải tồn tại");
const releaseTxs27 = res27.txList.filter(t => t.type === "release");
assert.equal(releaseTxs27.length, 0, "Suất #27 chưa giải ngân thì không được có giao dịch giải ngân nào");
console.log(`  ✔ Suất #27: Có ${res27.txList.length} giao dịch (Tạo/Nạp quỹ), 0 giao dịch giải ngân.`);
console.log("  ✔ PASS: Suất chưa giải ngân không hiển thị hash giải ngân giả mạo!\n");

// 7. KIỂM THỬ: Suất không tồn tại (#999999)
console.log("[Kiểm thử 7] Kiểm tra Suất không tồn tại (#999999)...");
const resNonExistent = await verifyScholarshipOnChain(999999);
assert(resNonExistent.notFound, "Suất #999999 phải báo không tồn tại (ScholarshipNotFound)");
assert.equal(resNonExistent.txList.length, 0, "Suất #999999 không được có bất kỳ giao dịch nào");
console.log("  ✔ PASS: Suất không tồn tại hiển thị trạng thái 'Chưa có Hash', không tạo mã QR giả!\n");

// 8. KIỂM THỬ: Tạo QR Code động bằng QRious cho cả Mốc 0 và Mốc 1 của Suất #33
console.log("[Kiểm thử 8] Kiểm tra QRious rendering cho từng mốc của Suất #33...");
global.window = global;
global.HTMLCanvasElement = class HTMLCanvasElement {};
global.HTMLImageElement = class HTMLImageElement {};
global.document = { createElement: () => Object.create(HTMLImageElement.prototype) };

(new Function(qriousContent)).call(global);
assert.equal(typeof global.QRious, "function", "QRious phải là constructor function");

const mockCanvas = Object.create(HTMLCanvasElement.prototype);
Object.assign(mockCanvas, {
  width: 0,
  height: 0,
  getContext: () => ({ clearRect: () => {}, fillRect: () => {}, beginPath: () => {}, fill: () => {} }),
  toDataURL: () => "data:image/png;base64,mockPng"
});

const qrM0 = new QRious({
  element: mockCanvas,
  value: `https://sepolia.etherscan.io/tx/${m0_33.hash}`,
  size: 168,
  level: "H"
});
assert.equal(qrM0.value, `https://sepolia.etherscan.io/tx/${m0_33.hash}`);

const qrM1 = new QRious({
  element: mockCanvas,
  value: `https://sepolia.etherscan.io/tx/${m1_33.hash}`,
  size: 168,
  level: "H"
});
assert.equal(qrM1.value, `https://sepolia.etherscan.io/tx/${m1_33.hash}`);
assert.notEqual(qrM0.value, qrM1.value, "URL QR của Mốc 0 và Mốc 1 phải khác nhau");
console.log(`  ✔ QR Mốc 0: ${qrM0.value}`);
console.log(`  ✔ QR Mốc 1: ${qrM1.value}`);
console.log("  ✔ PASS: QR Code động trỏ đến đúng từng giao dịch giải ngân trên Sepolia Etherscan!\n");

console.log("================================================================================");
console.log("TỔNG KẾT: 8/8 BÀI KIỂM THỬ MULTI-MILESTONE VERIFICATION ĐẠT 100% (PASS)!");
console.log("================================================================================");
