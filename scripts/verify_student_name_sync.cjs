const { ethers } = require('d:/crypto-smart-contract-2026/LinhHuynhK58KTS/node_modules/ethers');

// Mock localStorage environment
const store = {};
const mockLocalStorage = {
  getItem: (k) => store[k] !== undefined ? store[k] : null,
  setItem: (k, v) => { store[k] = String(v); },
  removeItem: (k) => { delete store[k]; },
  clear: () => { Object.keys(store).forEach(k => delete store[k]); }
};
global.localStorage = mockLocalStorage;

// Extract logic exactly matching web/index.html
const REGISTRY_KEY = "trustscholar_student_names";
const FALLBACK_REGISTRY_KEYS = [
  "trustscholar_student_names",
  "trustscholar_students",
  "student_names",
  "studentNameRegistry",
  "trustscholar_student_name"
];

function loadNameRegistry() {
  const merged = {};
  for (const key of FALLBACK_REGISTRY_KEYS) {
    try {
      const raw = localStorage.getItem(key);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
          for (const [addr, name] of Object.entries(parsed)) {
            if (typeof addr === "string" && typeof name === "string" && name.trim()) {
              merged[addr.trim().toLowerCase()] = name.trim();
            }
          }
        }
      }
    } catch (_) { }
  }
  return merged;
}

function saveNameRegistry(registry) {
  try {
    const normalized = {};
    for (const [addr, name] of Object.entries(registry)) {
      if (typeof addr === "string" && typeof name === "string" && name.trim()) {
        normalized[addr.trim().toLowerCase()] = name.trim();
      }
    }
    localStorage.setItem(REGISTRY_KEY, JSON.stringify(normalized));
  } catch (err) {
    console.warn("Lưu registry thất bại:", err);
  }
}

function lookupStudentName(walletAddress) {
  if (!walletAddress || typeof walletAddress !== "string") return null;
  const clean = walletAddress.trim().toLowerCase();
  if (!/^0x[0-9a-f]{40}$/.test(clean)) return null;

  const registry = loadNameRegistry();
  if (registry[clean]) return registry[clean];

  try {
    const direct = localStorage.getItem(clean) ||
                   localStorage.getItem(`student_${clean}`) ||
                   localStorage.getItem(walletAddress.trim());
    if (direct && typeof direct === "string" && !direct.startsWith("{") && !direct.startsWith("[")) {
      return direct.trim();
    }
  } catch (_) { }

  return null;
}

function registerStudentName(walletAddress, name, shouldDeleteIfEmpty = false) {
  if (!walletAddress || typeof walletAddress !== "string") return;
  const clean = walletAddress.trim().toLowerCase();
  if (!/^0x[0-9a-f]{40}$/.test(clean)) return;

  const registry = loadNameRegistry();
  const trimmedName = (name || "").trim();
  if (trimmedName) {
    registry[clean] = trimmedName;
  } else if (shouldDeleteIfEmpty) {
    delete registry[clean];
  } else {
    return;
  }
  saveNameRegistry(registry);
}

function exportNameRegistry() {
  const reg = loadNameRegistry();
  return JSON.stringify(reg, null, 2);
}

function importNameRegistry(jsonStr) {
  const parsed = JSON.parse(jsonStr.trim());
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error("JSON phải là object");
  }
  let added = 0;
  const current = loadNameRegistry();
  for (const [addr, name] of Object.entries(parsed)) {
    if (typeof addr === "string" && typeof name === "string" && name.trim()) {
      const clean = addr.trim().toLowerCase();
      if (/^0x[0-9a-f]{40}$/.test(clean)) {
        current[clean] = name.trim();
        added++;
      }
    }
  }
  saveNameRegistry(current);
  return added;
}

async function verifyAll() {
  console.log("=================================================================");
  console.log("TRUSTSCHOLAR: VERIFICATION OF STUDENT NAME SYNCHRONIZATION");
  console.log("=================================================================\n");

  const TARGET_WALLET_21 = "0xD1695ed2a73E1d13ec63A90653d357bAAC7467f8";
  const TARGET_NAME_21 = "Nguyễn Minh Khánh Linh";
  const TARGET_WALLET_20 = "0xaFB64EeF8093Cf3dC4e2c51BB1d18E16aFDdB6f5";
  const TARGET_NAME_20 = "Trần Thị Như Huỳnh";

  // Test 1: Register and Normalize
  console.log("[Test 1] Lưu tên sinh viên với địa chỉ hỗn hợp (Checksum):");
  registerStudentName(TARGET_WALLET_21, TARGET_NAME_21);
  const storedRaw = localStorage.getItem(REGISTRY_KEY);
  console.log("  localStorage content:", storedRaw);
  if (!storedRaw.includes(TARGET_WALLET_21.toLowerCase())) {
    throw new Error("FAIL: Key phải được chuẩn hóa chữ thường!");
  }
  console.log("  -> PASS: Đã lưu chuẩn hóa lowercase thành công.");

  // Test 2: Case-insensitive lookups
  console.log("\n[Test 2] Tra cứu tên với các định dạng địa chỉ khác nhau:");
  const lookup1 = lookupStudentName(TARGET_WALLET_21);
  const lookup2 = lookupStudentName(TARGET_WALLET_21.toLowerCase());
  const lookup3 = lookupStudentName(TARGET_WALLET_21.toUpperCase());
  const lookup4 = lookupStudentName(`  ${TARGET_WALLET_21}  `);
  console.log("  Lookup checksum:", lookup1);
  console.log("  Lookup lowercase:", lookup2);
  console.log("  Lookup uppercase:", lookup3);
  console.log("  Lookup with spaces:", lookup4);
  if (lookup1 !== TARGET_NAME_21 || lookup2 !== TARGET_NAME_21 || lookup3 !== TARGET_NAME_21 || lookup4 !== TARGET_NAME_21) {
    throw new Error("FAIL: Tra cứu không đồng nhất giữa các định dạng hoa/thường!");
  }
  console.log("  -> PASS: 100% định dạng địa chỉ tra cứu đều trả về đúng tên.");

  // Test 3: Query on-chain Sepolia for Scholarship #21
  console.log("\n[Test 3] Truy vấn on-chain Sepolia hợp đồng ProjectCore cho Suất #21:");
  const provider = new ethers.JsonRpcProvider("https://ethereum-sepolia-rpc.publicnode.com");
  const contractAddr = "0x04B0e154Becb4E98b00E06DF86605A70f3F914c2";
  const abi = [
    "function getScholarship(uint256) view returns (tuple(uint256 id, address sponsor, address student, uint256 totalAmount, uint256 fundedAmount, uint256 releasedAmount, uint8 milestoneCount))"
  ];
  const contract = new ethers.Contract(contractAddr, abi, provider);

  const s21 = await contract.getScholarship(21);
  console.log(`  On-chain Scholarship #21 Beneficiary: ${s21.student}`);
  if (s21.student.toLowerCase() !== TARGET_WALLET_21.toLowerCase()) {
    throw new Error(`FAIL: Ví on-chain ${s21.student} không khớp ${TARGET_WALLET_21}`);
  }

  const nameFor21 = lookupStudentName(s21.student);
  console.log(`  Tra cứu tên sinh viên cho Suất #21 (Card 2A render): "${nameFor21}"`);
  if (nameFor21 !== TARGET_NAME_21) {
    throw new Error(`FAIL: Tên không khớp! Nhận được: ${nameFor21}, mong đợi: ${TARGET_NAME_21}`);
  }
  console.log("  -> PASS: Trang nộp minh chứng (Card 2A) hiển thị đúng 'Nguyễn Minh Khánh Linh'!");

  // Test 4: Verify Multi-Student Isolation (No Swapping)
  console.log("\n[Test 4] Đảm bảo không tráo tên giữa các suất học bổng khác nhau:");
  registerStudentName(TARGET_WALLET_20, TARGET_NAME_20);
  const s20 = await contract.getScholarship(20);
  const nameFor20 = lookupStudentName(s20.student);
  const nameFor21Again = lookupStudentName(s21.student);

  console.log(`  Suất #20 (${s20.student}) -> Tên: "${nameFor20}"`);
  console.log(`  Suất #21 (${s21.student}) -> Tên: "${nameFor21Again}"`);
  if (nameFor20 !== TARGET_NAME_20 || nameFor21Again !== TARGET_NAME_21) {
    throw new Error("FAIL: Bị tráo tên giữa các suất học bổng!");
  }
  console.log("  -> PASS: Tên gắn chặt chính xác với địa chỉ ví on-chain của từng suất riêng biệt.");

  // Test 5: Isolated Machine / Fresh Browser Profile (No data)
  console.log("\n[Test 5] Mô phỏng trình duyệt mới / máy khác (localStorage trống):");
  mockLocalStorage.clear();
  const emptyLookup = lookupStudentName(s21.student);
  console.log(`  Kết quả tra cứu khi bộ nhớ máy chưa có dữ liệu: ${emptyLookup}`);
  if (emptyLookup !== null) {
    throw new Error("FAIL: Phải trả về null khi chưa có trong bộ nhớ!");
  }
  console.log("  -> PASS: Trả về null -> DApp hiển thị 'Chưa có thông tin tên sinh viên' & nút [✏️ Lưu tên trên máy này].");

  // Test 6: Cross-Device Synchronization via JSON Export/Import
  console.log("\n[Test 6] Đồng bộ giữa 2 máy / 2 trình duyệt qua JSON Export / Import:");
  // Giả lập máy 1 (Sponsor) có dữ liệu
  registerStudentName(TARGET_WALLET_21, TARGET_NAME_21);
  registerStudentName(TARGET_WALLET_20, TARGET_NAME_20);
  const exported = exportNameRegistry();
  console.log("  Máy 1 xuất JSON:\n", exported);

  // Giả lập máy 2 (Student) ban đầu trống
  mockLocalStorage.clear();
  console.log("  Máy 2 ban đầu trống -> lookup s21:", lookupStudentName(s21.student));

  // Máy 2 nhập JSON
  const importedCount = importNameRegistry(exported);
  console.log(`  Máy 2 đã nhập ${importedCount} hồ sơ từ JSON.`);
  const syncedLookup21 = lookupStudentName(s21.student);
  const syncedLookup20 = lookupStudentName(s20.student);
  console.log(`  Máy 2 sau khi nhập: Suất #21 -> "${syncedLookup21}", Suất #20 -> "${syncedLookup20}"`);
  if (syncedLookup21 !== TARGET_NAME_21 || syncedLookup20 !== TARGET_NAME_20) {
    throw new Error("FAIL: Đồng bộ qua JSON thất bại!");
  }
  console.log("  -> PASS: Đồng bộ đa thiết bị không cần sửa smart contract thành công mỹ mãn.");

  // Test 7: Safe Deletion Check (Empty input does not delete registered name)
  console.log("\n[Test 7] Kiểm tra chống xóa nhầm tên khi người dùng xóa ô nhập liệu:");
  registerStudentName(TARGET_WALLET_21, ""); // shouldDeleteIfEmpty = false mặc định
  const safeCheck = lookupStudentName(TARGET_WALLET_21);
  console.log("  Tên sau khi ô nhập liệu bị xóa trắng:", safeCheck);
  if (safeCheck !== TARGET_NAME_21) {
    throw new Error("FAIL: Tên bị xóa nhầm khi ô nhập liệu rỗng!");
  }
  console.log("  -> PASS: Tên vẫn được bảo toàn an toàn trong registry.");

  console.log("\n=================================================================");
  console.log(">>> TẤT CẢ 7 BÀI KIỂM THỬ XÁC MINH ĐỀU THÀNH CÔNG (100% PASS) <<<");
  console.log("=================================================================\n");
}

verifyAll().catch(err => {
  console.error("Test execution failed:", err);
  process.exit(1);
});
