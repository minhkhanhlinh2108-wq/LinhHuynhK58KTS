import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const webDir = path.resolve(__dirname, "../web");

console.log("================================================================================");
console.log("TEST VERIFICATION: SUẤT #24 (pHg) VÀ SUẤT #27 (Phương) CÙNG VÍ 0x73fff...");
console.log("================================================================================\n");

// Đọc mã nguồn index.html thật
const html = fs.readFileSync(path.join(webDir, "index.html"), "utf8");

// Mock môi trường Browser (localStorage, DOM)
function createMockBrowser() {
  const store = {};
  const mockLocalStorage = {
    getItem: (k) => store[k] !== undefined ? store[k] : null,
    setItem: (k, v) => { store[k] = String(v); },
    removeItem: (k) => { delete store[k]; },
    clear: () => { Object.keys(store).forEach(k => delete store[k]); }
  };

  const elements = {};
  function getElementById(id) {
    if (!elements[id]) {
      elements[id] = {
        id,
        value: "",
        textContent: "",
        innerHTML: "",
        style: {},
        classList: {
          classes: new Set(),
          add(c) { this.classes.add(c); },
          remove(c) { this.classes.delete(c); },
          contains(c) { return this.classes.has(c); }
        }
      };
    }
    return elements[id];
  }

  return { store, mockLocalStorage, getElementById, elements };
}

// Chạy test trong môi trường độc lập
async function runTests() {
  let passed = 0;
  let failed = 0;

  function assert(condition, testName) {
    if (condition) {
      console.log(`  ✅ PASS: ${testName}`);
      passed++;
    } else {
      console.error(`  ❌ FAIL: ${testName}`);
      failed++;
    }
  }

  const browser = createMockBrowser();
  const localStorage = browser.mockLocalStorage;
  const document = { getElementById: browser.getElementById };
  const window = {
    dispatchEvent: () => {},
    addEventListener: () => {}
  };
  globalThis.CustomEvent = class { constructor(type, detail) { this.type = type; this.detail = detail; } };

  // Trích xuất hàm và logic từ index.html
  // Đọc REGISTRY keys và sharedRegistry
  const REGISTRY_STORAGE_KEY = "trustscholar_shared_registry";
  const REGISTRY_KEY = "trustscholar_student_names";
  const FALLBACK_REGISTRY_KEYS = ["trustscholar_name_registry", "student_names", "student_name_registry", "trustscholar_students"];

  let _sharedRegistry = {
    scholarships: {},
    students: {}
  };

  function saveCachedRegistry(silent = false) {
    try {
      localStorage.setItem(REGISTRY_STORAGE_KEY, JSON.stringify(_sharedRegistry));
      localStorage.setItem(REGISTRY_KEY, JSON.stringify(_sharedRegistry.students));
    } catch (_) {}
  }

  function loadCachedRegistry() {
    try {
      const v2Raw = localStorage.getItem(REGISTRY_STORAGE_KEY);
      if (v2Raw) {
        const parsed = JSON.parse(v2Raw);
        if (parsed && typeof parsed === "object") {
          if (parsed.scholarships) _sharedRegistry.scholarships = parsed.scholarships;
          if (parsed.students) _sharedRegistry.students = parsed.students;
        }
      }
    } catch (_) {}
  }

  // Lấy chính xác hàm lookupStudentName, lookupStudentNameForScholarship, registerScholarshipStudentSync từ index.html
  // Trích xuất bằng regex an toàn
  const lookupStudentNameCode = html.match(/function lookupStudentName\(walletAddress\) \{[\s\S]*?\n    \}/)[0];
  const lookupForScholarshipCode = html.match(/function lookupStudentNameForScholarship\(scholarshipId, studentAddrOnChain\) \{[\s\S]*?\n    \}/)[0];
  const registerSyncCode = html.match(/function registerScholarshipStudentSync\(scholarshipId, studentAddress, studentName\) \{[\s\S]*?\n    \}/)[0];
  const registerStudentNameCode = html.match(/function registerStudentName\(walletAddress, name[\s\S]*?\n    \}/)[0];

  // Đánh giá hàm trong context của test
  const evalContext = new Function(
    "_sharedRegistry", "REGISTRY_STORAGE_KEY", "REGISTRY_KEY", "FALLBACK_REGISTRY_KEYS", "saveCachedRegistry", "localStorage",
    `
    ${lookupStudentNameCode}
    ${lookupForScholarshipCode}
    ${registerSyncCode}
    ${registerStudentNameCode}
    return { lookupStudentName, lookupStudentNameForScholarship, registerScholarshipStudentSync, registerStudentName };
    `
  );

  const funcs = evalContext(
    _sharedRegistry, REGISTRY_STORAGE_KEY, REGISTRY_KEY, FALLBACK_REGISTRY_KEYS, saveCachedRegistry, localStorage
  );

  const TARGET_WALLET = "0x73ffF099ADA86f63217B769Afcf00Da80F2B9Dca";

  console.log("--- TEST SUITE 1: Tải dữ liệu ban đầu từ students.json ---");
  const studentsJson = JSON.parse(fs.readFileSync(path.join(webDir, "students.json"), "utf8"));
  assert(studentsJson.scholarships["24"] !== undefined, "students.json có Suất #24");
  assert(studentsJson.scholarships["24"].studentName === "pHg", "Suất #24 trong students.json có tên 'pHg'");
  assert(studentsJson.scholarships["27"] !== undefined, "students.json có Suất #27");
  assert(studentsJson.scholarships["27"].studentName === "Phương", "Suất #27 trong students.json có tên 'Phương'");
  assert(
    studentsJson.scholarships["24"].studentAddress.toLowerCase() === studentsJson.scholarships["27"].studentAddress.toLowerCase(),
    "Suất #24 và Suất #27 có cùng địa chỉ ví sinh viên"
  );

  console.log("\n--- TEST SUITE 2: Nạp dữ liệu vào _sharedRegistry ---");
  _sharedRegistry.scholarships["24"] = {
    scholarshipId: 24,
    studentAddress: TARGET_WALLET.toLowerCase(),
    studentName: "pHg",
    updatedAt: "2026-10-21T00:00:00.000Z"
  };
  _sharedRegistry.scholarships["27"] = {
    scholarshipId: 27,
    studentAddress: TARGET_WALLET.toLowerCase(),
    studentName: "Phương",
    updatedAt: "2026-10-21T22:00:00.000Z"
  };
  _sharedRegistry.students[TARGET_WALLET.toLowerCase()] = "pHg"; // ví dụ registry mặc định có "pHg"

  console.log("\n--- TEST SUITE 3: Tra cứu Suất #27 và Suất #24 ---");
  const name27 = funcs.lookupStudentNameForScholarship(27, TARGET_WALLET);
  const name24 = funcs.lookupStudentNameForScholarship(24, TARGET_WALLET);

  assert(name27 === "Phương", `Suất #27 hiển thị đúng 'Phương' (thực tế: '${name27}')`);
  assert(name24 === "pHg", `Suất #24 hiển thị đúng 'pHg' (thực tế: '${name24}')`);
  assert(name27 !== name24, "Hai suất có cùng địa chỉ ví nhưng hiển thị 2 tên khác nhau độc lập");

  console.log("\n--- TEST SUITE 4: Tạo suất mới #28 cùng địa chỉ ví với tên động bất kỳ ---");
  // Nhà tài trợ nhập tên bất kỳ ở Bước 1
  const DYNAMIC_NAME = "Võ Thị Sáu — Học Bổng Đặc Biệt";
  funcs.registerScholarshipStudentSync(28, TARGET_WALLET, DYNAMIC_NAME);

  const name28 = funcs.lookupStudentNameForScholarship(28, TARGET_WALLET);
  const name27After = funcs.lookupStudentNameForScholarship(27, TARGET_WALLET);
  const name24After = funcs.lookupStudentNameForScholarship(24, TARGET_WALLET);

  assert(name28 === DYNAMIC_NAME, `Suất #28 hiển thị đúng tên vừa đăng ký '${DYNAMIC_NAME}'`);
  assert(name27After === "Phương", "Suất #27 KHÔNG bị Suất #28 ghi đè, vẫn giữ 'Phương'");
  assert(name24After === "pHg", "Suất #24 KHÔNG bị Suất #28 ghi đè, vẫn giữ 'pHg'");

  console.log("\n--- TEST SUITE 5: Tra cứu suất chưa từng đăng ký tên (Suất #99) cùng ví ---");
  // Suất #99 chưa đăng ký tên nhưng có cùng địa chỉ ví TARGET_WALLET
  const name99 = funcs.lookupStudentNameForScholarship(99, TARGET_WALLET);
  assert(name99 === null, "Suất #99 KHÔNG được mượn tên của Suất #24 hay #27 (phải trả về null)");

  console.log("\n--- TEST SUITE 6: Mô phỏng hành vi trên DOM trang Submit ---");
  function simulateSubmitTabLookup(id, studentAddrOnChain) {
    const nameVal = browser.getElementById("submitBeneficiaryNameVal");
    const foundName = funcs.lookupStudentNameForScholarship(id, studentAddrOnChain);
    if (foundName) {
      nameVal.textContent = foundName;
      nameVal.style.color = "var(--accent-primary)";
    } else {
      nameVal.textContent = "Chưa đăng ký tên cho suất này";
      nameVal.style.color = "var(--text-dim)";
    }
    return nameVal.textContent;
  }

  const domText27 = simulateSubmitTabLookup(27, TARGET_WALLET);
  assert(domText27 === "Phương", `Khi nhập ID 27 trên trang Submit, DOM hiển thị: '${domText27}'`);

  const domText24 = simulateSubmitTabLookup(24, TARGET_WALLET);
  assert(domText24 === "pHg", `Khi nhập ID 24 trên trang Submit, DOM hiển thị: '${domText24}'`);

  const domText99 = simulateSubmitTabLookup(99, TARGET_WALLET);
  assert(domText99 === "Chưa đăng ký tên cho suất này", `Khi nhập ID 99 chưa có tên, DOM hiển thị: '${domText99}'`);

  console.log("\n================================================================================");
  console.log(`KẾT QUẢ KIỂM THỬ: ${passed} PASS / ${failed} FAIL`);
  console.log("================================================================================");

  if (failed > 0) {
    process.exit(1);
  }
}

runTests();
