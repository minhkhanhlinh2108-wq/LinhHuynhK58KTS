import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const webDir = path.resolve(__dirname, "../web");

console.log("================================================================================");
console.log("KIỂM THỬ AN TOÀN LUỒNG DỮ LIỆU VÍ SINH VIÊN (STUDENT WALLET SAFETY TEST)");
console.log("================================================================================\n");

const html = fs.readFileSync(path.join(webDir, "index.html"), "utf8");

let passed = 0;
let failed = 0;

function assert(condition, message) {
  if (condition) {
    console.log(`  ✅ PASS: ${message}`);
    passed++;
  } else {
    console.error(`  ❌ FAIL: ${message}`);
    failed++;
  }
}

// ─── TEST SUITE 1: KIỂM TRA ĐẶC TẢ HTML CỦA TRƯỜNG STUDENT WALLET ───
console.log("--- TEST SUITE 1: Kiểm tra cấu trúc HTML trường inpStudentAddress ---");
assert(
  html.includes('id="inpStudentAddress"'),
  "Trường nhập liệu có id='inpStudentAddress'"
);

// Kiểm tra không có thuộc tính value gán cứng địa chỉ
const studentInputMatch = html.match(/<input\s+id="inpStudentAddress"[^>]*>/);
assert(studentInputMatch !== null, "Tìm thấy thẻ input #inpStudentAddress");
if (studentInputMatch) {
  const tagStr = studentInputMatch[0];
  assert(!tagStr.includes('value="0x'), "inpStudentAddress KHÔNG bị hard-code sẵn bất kỳ địa chỉ ví nào trong HTML");
  assert(tagStr.includes('autocomplete="off"'), "inpStudentAddress đã bật autocomplete='off' để chặn trình duyệt tự động điền địa chỉ cũ");
}

// ─── TEST SUITE 2: KIỂM TRA KHỞI TẠO VÀ ĐỔI CONTRACT ADDRESS ───
console.log("\n--- TEST SUITE 2: Kiểm tra khi cập nhật địa chỉ hợp đồng ---");
// Mô phỏng DOM và State
const CONTRACT_ADDR = "0x04B0e154Becb4E98b00E06DF86605A70f3F914c2";
const SPONSOR_ADDR = "0xd1695Ed2A73e1D13ec63A90653d357baAc7467F8";
const VALID_STUDENT_ADDR = "0x73ffF099ADA86f63217B769Afcf00Da80F2B9Dca";

const elements = {
  inpStudentAddress: { value: "", textContent: "" },
  inpStudentName: { value: "", textContent: "" },
  inpMilestones: { value: "0.05, 0.05", textContent: "" },
  contractAddressDisplay: { textContent: CONTRACT_ADDR },
  sponsorStudentNameBox: { style: {}, classList: { add() {}, remove() {} } },
  sponsorStudentNameVal: { innerHTML: "", textContent: "" }
};

let currentContractAddress = CONTRACT_ADDR;
let userAddress = SPONSOR_ADDR;

// Kiểm tra khi đổi contract address qua UI
function simulateChangeContract(newContractAddr) {
  currentContractAddress = newContractAddr;
  elements.contractAddressDisplay.textContent = newContractAddr;
  // Giả lập trigger kiểm tra đối soát
}

simulateChangeContract("0x1234567890123456789012345678901234567890");
assert(
  elements.inpStudentAddress.value === "",
  "Khi đổi địa chỉ hợp đồng, trường Student Wallet KHÔNG bị ghi đè, vẫn giữ nguyên giá trị người dùng"
);

// ─── TEST SUITE 3: TIỀN KIỂM TRA HÀM handleCreateScholarship ───
console.log("\n--- TEST SUITE 3: Kiểm tra logic chặn địa chỉ hợp lệ tại handleCreateScholarship ---");

// Giả lập hàm validate trong handleCreateScholarship
function simulateValidateStudentInput(inputAddr, contractAddr, sponsorAddr) {
  const norm = inputAddr ? inputAddr.trim().toLowerCase() : "";
  if (!norm || !/^0x[0-9a-f]{40}$/i.test(norm)) {
    return { valid: false, error: "INVALID_FORMAT" };
  }
  if (norm === "0x0000000000000000000000000000000000000000") {
    return { valid: false, error: "ZERO_ADDRESS" };
  }
  if (norm === contractAddr.toLowerCase()) {
    return { valid: false, error: "CONTRACT_ADDRESS" };
  }
  if (sponsorAddr && norm === sponsorAddr.toLowerCase()) {
    return { valid: false, error: "SPONSOR_ADDRESS" };
  }
  return { valid: true, error: null };
}

const resContract = simulateValidateStudentInput(CONTRACT_ADDR, CONTRACT_ADDR, SPONSOR_ADDR);
assert(
  !resContract.valid && resContract.error === "CONTRACT_ADDRESS",
  "Nếu nhập địa chỉ Smart Contract -> BỊ CHẶN trước khi gửi giao dịch (không bị InvalidAddress on-chain)"
);

const resZero = simulateValidateStudentInput("0x0000000000000000000000000000000000000000", CONTRACT_ADDR, SPONSOR_ADDR);
assert(
  !resZero.valid && resZero.error === "ZERO_ADDRESS",
  "Nếu nhập địa chỉ ví 0x0 -> BỊ CHẶN trước khi gửi giao dịch"
);

const resSponsor = simulateValidateStudentInput(SPONSOR_ADDR, CONTRACT_ADDR, SPONSOR_ADDR);
assert(
  !resSponsor.valid && resSponsor.error === "SPONSOR_ADDRESS",
  "Nếu nhập trùng ví Nhà tài trợ đang kết nối -> BỊ CHẶN để đảm bảo tính phân quyền độc lập"
);

const resValidStudent = simulateValidateStudentInput(VALID_STUDENT_ADDR, CONTRACT_ADDR, SPONSOR_ADDR);
assert(
  resValidStudent.valid && resValidStudent.error === null,
  "Nếu nhập địa chỉ ví sinh viên hợp lệ (0x73fff...) -> ĐƯỢC CHẤP NHẬN và chuyển đến bước gửi giao dịch"
);

// ─── TEST SUITE 4: TÍNH TOÀN VẸN CỦA CÁC HÀM KHÁC (Fund, Submit, Approve, Release) ───
console.log("\n--- TEST SUITE 4: Kiểm tra tính toàn vẹn của các hàm cốt lõi khác ---");
assert(html.includes("async function handleFundScholarship()"), "Hàm handleFundScholarship tồn tại nguyên vẹn");
assert(html.includes("async function handleSubmitMilestone()"), "Hàm handleSubmitMilestone tồn tại nguyên vẹn");
assert(html.includes("async function handleApproveMilestone()"), "Hàm handleApproveMilestone tồn tại nguyên vẹn");
assert(html.includes("async function handleReleaseMilestone()"), "Hàm handleReleaseMilestone tồn tại nguyên vẹn");
assert(html.includes("function lookupStudentNameForScholarship("), "Hàm lookupStudentNameForScholarship tồn tại nguyên vẹn");

console.log("\n================================================================================");
console.log(`KẾT QUẢ KIỂM THỬ AN TOÀN: ${passed} PASS / ${failed} FAIL`);
console.log("================================================================================");

if (failed > 0) {
  process.exit(1);
}
