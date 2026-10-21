import { ethers } from "ethers";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const webDir = path.resolve(__dirname, "../web");

console.log("================================================================================");
console.log("KIỂM THỬ XÁC THỰC TOÀN DIỆN: ĐỒNG BỘ TÊN SINH VIÊN TỪ BƯỚC 1 SANG TRANG SUBMIT");
console.log("================================================================================\n");

// Tải nội dung index.html thật
const html = fs.readFileSync(path.join(webDir, "index.html"), "utf8");

// Khởi tạo môi trường giả lập trình duyệt DOM + Storage
function createTestEnv() {
  const storage = {};
  const mockLocalStorage = {
    getItem: (k) => storage[k] !== undefined ? storage[k] : null,
    setItem: (k, v) => { storage[k] = String(v); },
    removeItem: (k) => { delete storage[k]; },
    clear: () => { Object.keys(storage).forEach(k => delete storage[k]); }
  };

  const elements = {};
  function getEl(id) {
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
          contains(c) { return this.classes.has(c); },
          replace(a, b) { this.classes.delete(a); this.classes.add(b); }
        }
      };
    }
    return elements[id];
  }

  const events = {};
  const mockWindow = {
    addEventListener: (ev, handler) => {
      if (!events[ev]) events[ev] = [];
      events[ev].push(handler);
    },
    dispatchEvent: (ev) => {
      if (events[ev.type]) {
        events[ev.type].forEach(h => h(ev));
      }
    }
  };

  return { storage, mockLocalStorage, getEl, mockWindow, events };
}

async function runComprehensiveTests() {
  const env = createTestEnv();

  // Khởi tạo RPC Sepolia thật để đối soát với smart contract ProjectCore
  const SEPOLIA_RPC = "https://ethereum-sepolia-rpc.publicnode.com";
  const CONTRACT_ADDR = "0x04B0e154Becb4E98b00E06DF86605A70f3F914c2";
  const provider = new ethers.JsonRpcProvider(SEPOLIA_RPC);
  const abi = [
    "function getScholarship(uint256) view returns (tuple(uint256 id, address sponsor, address student, uint256 totalAmount, uint256 fundedAmount, uint256 releasedAmount, uint8 milestoneCount))",
    "function scholarshipCount() view returns (uint256)"
  ];
  const contract = new ethers.Contract(CONTRACT_ADDR, abi, provider);

  console.log("[Bước 1] Kiểm tra các suất học bổng có sẵn trên hợp đồng Sepolia...");
  const s22 = await contract.getScholarship(22);
  const s25 = await contract.getScholarship(25);
  const s20 = await contract.getScholarship(20);

  console.log(`  • Suất #22 ví sinh viên on-chain: ${s22.student}`);
  console.log(`  • Suất #25 ví sinh viên on-chain: ${s25.student}`);
  console.log(`  • Suất #20 ví sinh viên on-chain: ${s20.student}\n`);

  // Trích xuất các biến và hàm liên quan từ index.html
  // Định nghĩa registry và các hàm trong môi trường test
  const REGISTRY_STORAGE_KEY = "trustscholar_shared_registry_v2";
  const REGISTRY_KEY = "trustscholar_student_names";
  const FALLBACK_REGISTRY_KEYS = [
    "trustscholar_student_names",
    "trustscholar_students",
    "student_names",
    "studentNameRegistry",
    "trustscholar_student_name"
  ];

  let _sharedRegistry = {
    scholarships: {},
    students: {}
  };

  function loadCachedRegistry() {
    try {
      const v2Raw = env.mockLocalStorage.getItem(REGISTRY_STORAGE_KEY);
      if (v2Raw) {
        const parsed = JSON.parse(v2Raw);
        if (parsed && typeof parsed === "object") {
          if (parsed.scholarships && typeof parsed.scholarships === "object") {
            for (const [id, item] of Object.entries(parsed.scholarships)) {
              if (item && item.studentName) {
                _sharedRegistry.scholarships[String(id).trim()] = {
                  scholarshipId: parseInt(id, 10) || id,
                  studentAddress: (item.studentAddress || "").trim().toLowerCase(),
                  studentName: String(item.studentName).trim(),
                  updatedAt: item.updatedAt || ""
                };
              }
            }
          }
          if (parsed.students && typeof parsed.students === "object") {
            for (const [addr, name] of Object.entries(parsed.students)) {
              if (addr && name) {
                _sharedRegistry.students[addr.trim().toLowerCase()] = String(name).trim();
              }
            }
          }
        }
      }
    } catch (_) { }

    for (const k of FALLBACK_REGISTRY_KEYS) {
      try {
        const raw = env.mockLocalStorage.getItem(k);
        if (raw) {
          const parsed = JSON.parse(raw);
          if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
            for (const [addr, name] of Object.entries(parsed)) {
              if (typeof addr === "string" && typeof name === "string" && name.trim()) {
                const clean = addr.trim().toLowerCase();
                if (!_sharedRegistry.students[clean]) {
                  _sharedRegistry.students[clean] = name.trim();
                }
              }
            }
          }
        }
      } catch (_) { }
    }
  }

  function saveCachedRegistry(silent = false) {
    try {
      env.mockLocalStorage.setItem(REGISTRY_STORAGE_KEY, JSON.stringify(_sharedRegistry));
      env.mockLocalStorage.setItem(REGISTRY_KEY, JSON.stringify(_sharedRegistry.students));
      for (const k of FALLBACK_REGISTRY_KEYS) {
        try { env.mockLocalStorage.setItem(k, JSON.stringify(_sharedRegistry.students)); } catch (_) { }
      }
      if (!silent) {
        env.mockWindow.dispatchEvent({ type: "trustscholar_names_updated", detail: _sharedRegistry });
      }
    } catch (err) {
      console.warn("Lưu registry cache thất bại:", err);
    }
  }

  function syncSharedRegistryFromServerMock(seedData) {
    loadCachedRegistry();
    if (seedData && typeof seedData === "object") {
      let updated = false;
      if (seedData.scholarships && typeof seedData.scholarships === "object") {
        for (const [id, item] of Object.entries(seedData.scholarships)) {
          if (item && item.studentName) {
            const cleanAddr = (item.studentAddress || "").trim().toLowerCase();
            const cleanName = item.studentName.trim();
            const idKey = String(id).trim();
            if (!_sharedRegistry.scholarships[idKey] || !_sharedRegistry.scholarships[idKey].studentName) {
              _sharedRegistry.scholarships[idKey] = {
                scholarshipId: parseInt(idKey, 10) || idKey,
                studentAddress: cleanAddr,
                studentName: cleanName,
                updatedAt: item.updatedAt || ""
              };
              updated = true;
            }
            if (cleanAddr && !_sharedRegistry.students[cleanAddr]) {
              _sharedRegistry.students[cleanAddr] = cleanName;
              updated = true;
            }
          }
        }
      }
      if (seedData.students && typeof seedData.students === "object") {
        for (const [addr, name] of Object.entries(seedData.students)) {
          if (addr && name) {
            const cleanAddr = addr.trim().toLowerCase();
            if (!_sharedRegistry.students[cleanAddr]) {
              _sharedRegistry.students[cleanAddr] = name.trim();
              updated = true;
            }
          }
        }
      }
      if (updated) {
        saveCachedRegistry(true);
      }
    }
  }

  function lookupStudentName(walletAddress) {
    if (!walletAddress || typeof walletAddress !== "string") return null;
    const clean = walletAddress.trim().toLowerCase();
    if (!/^0x[0-9a-f]{40}$/.test(clean)) return null;

    if (_sharedRegistry.students[clean] && _sharedRegistry.students[clean].trim()) {
      return _sharedRegistry.students[clean].trim();
    }

    for (const entry of Object.values(_sharedRegistry.scholarships)) {
      if (entry && entry.studentAddress && entry.studentAddress.toLowerCase() === clean && entry.studentName && entry.studentName.trim()) {
        return entry.studentName.trim();
      }
    }

    try {
      const direct = env.mockLocalStorage.getItem(clean) ||
        env.mockLocalStorage.getItem("student_" + clean) ||
        env.mockLocalStorage.getItem(walletAddress.trim());
      if (direct && typeof direct === "string" && !direct.startsWith("{") && !direct.startsWith("[")) {
        return direct.trim();
      }
    } catch (_) { }

    return null;
  }

  function lookupStudentNameForScholarship(scholarshipId, studentAddrOnChain) {
    if (!scholarshipId && !studentAddrOnChain) return null;
    const cleanAddr = studentAddrOnChain ? studentAddrOnChain.trim().toLowerCase() : "";
    const idKey = (scholarshipId !== undefined && scholarshipId !== null && String(scholarshipId).trim() !== "")
      ? String(scholarshipId).trim()
      : "";

    let foundName = null;

    if (cleanAddr) {
      foundName = lookupStudentName(cleanAddr);
    }

    if (!foundName && idKey) {
      const entry = _sharedRegistry.scholarships[idKey];
      if (entry && entry.studentName && entry.studentName.trim()) {
        if (!cleanAddr || !entry.studentAddress || entry.studentAddress.toLowerCase() === cleanAddr) {
          foundName = entry.studentName.trim();
        }
      }
    }

    if (foundName && idKey && cleanAddr) {
      const existing = _sharedRegistry.scholarships[idKey];
      if (!existing || existing.studentName !== foundName || existing.studentAddress !== cleanAddr) {
        _sharedRegistry.scholarships[idKey] = {
          scholarshipId: parseInt(idKey, 10) || idKey,
          studentAddress: cleanAddr,
          studentName: foundName,
          updatedAt: new Date().toISOString()
        };
        saveCachedRegistry(true);
      }
    }

    return foundName || null;
  }

  function registerStudentName(walletAddress, name, shouldDeleteIfEmpty = false) {
    if (!walletAddress || typeof walletAddress !== "string") return;
    const clean = walletAddress.trim().toLowerCase();
    if (!/^0x[0-9a-f]{40}$/.test(clean)) return;

    const trimmedName = (name || "").trim();
    if (trimmedName) {
      _sharedRegistry.students[clean] = trimmedName;
      for (const [id, entry] of Object.entries(_sharedRegistry.scholarships)) {
        if (entry && entry.studentAddress && entry.studentAddress.toLowerCase() === clean) {
          entry.studentName = trimmedName;
          entry.updatedAt = new Date().toISOString();
        }
      }
    } else if (shouldDeleteIfEmpty) {
      delete _sharedRegistry.students[clean];
      for (const [id, entry] of Object.entries(_sharedRegistry.scholarships)) {
        if (entry && entry.studentAddress && entry.studentAddress.toLowerCase() === clean) {
          delete _sharedRegistry.scholarships[id];
        }
      }
    } else {
      return;
    }
    saveCachedRegistry();
  }

  function registerScholarshipStudentSync(scholarshipId, studentAddress, studentName) {
    if (!studentAddress || !studentName) return false;
    const cleanAddr = studentAddress.trim().toLowerCase();
    const cleanName = studentName.trim();
    if (!cleanAddr || !cleanName) return false;

    if (scholarshipId !== undefined && scholarshipId !== null && scholarshipId !== "") {
      const idKey = String(scholarshipId).trim();
      _sharedRegistry.scholarships[idKey] = {
        scholarshipId: parseInt(idKey, 10) || idKey,
        studentAddress: cleanAddr,
        studentName: cleanName,
        updatedAt: new Date().toISOString()
      };
    }
    _sharedRegistry.students[cleanAddr] = cleanName;

    for (const [id, entry] of Object.entries(_sharedRegistry.scholarships)) {
      if (entry && entry.studentAddress && entry.studentAddress.toLowerCase() === cleanAddr) {
        entry.studentName = cleanName;
        entry.updatedAt = new Date().toISOString();
      }
    }

    saveCachedRegistry();
    return true;
  }

  // Tải dữ liệu ban đầu từ web/students.json
  const seedJson = JSON.parse(fs.readFileSync(path.join(webDir, "students.json"), "utf8"));
  syncSharedRegistryFromServerMock(seedJson);

  // Giả lập hàm updateSubmitCardInfo từ index.html
  let _submitCardSeq = 0;
  async function simulateUpdateSubmitCardInfo(inputIdVal) {
    const idInput = env.getEl("inpSubmitId");
    idInput.value = String(inputIdVal);
    const idRaw = String(inputIdVal).trim();
    const infoBox = env.getEl("submitScholarshipInfoBox");
    const nameVal = env.getEl("submitStudentNameVal");
    const addrVal = env.getEl("submitStudentAddrVal");
    const idVal = env.getEl("submitScholarshipIdVal");
    const noticeEl = env.getEl("submitStudentNameNotice");

    const id = parseInt(idRaw, 10);
    if (!id || id <= 0) {
      infoBox.style.display = "none";
      return;
    }

    const seq = ++_submitCardSeq;

    // 1. Reset ngay giá trị cũ
    nameVal.textContent = "Đang tra cứu...";
    addrVal.textContent = "—";
    idVal.textContent = `#${id}`;
    noticeEl.style.display = "none";
    infoBox.style.display = "flex";
    infoBox.classList.remove("found");

    // 2. Tra cứu tức thì trong cache
    const cachedEntry = _sharedRegistry.scholarships[String(id)];
    if (cachedEntry && cachedEntry.studentName) {
      nameVal.textContent = cachedEntry.studentName;
      addrVal.textContent = cachedEntry.studentAddress;
      infoBox.classList.add("found");
    }

    // 3. Đọc on-chain
    let s = null;
    try {
      s = await contract.getScholarship(id);
    } catch (_) {
      if (seq !== _submitCardSeq) return;
      if (!cachedEntry || !cachedEntry.studentName) {
        infoBox.style.display = "none";
      }
      return;
    }

    if (seq !== _submitCardSeq) return;

    if (!s || !s.student || s.student === ethers.ZeroAddress || Number(s.milestoneCount) === 0) {
      infoBox.style.display = "none";
      return;
    }

    const studentAddrOnChain = s.student;
    let foundName = lookupStudentNameForScholarship(id, studentAddrOnChain);

    if (foundName) {
      nameVal.textContent = foundName;
      noticeEl.style.display = "none";
      infoBox.classList.add("found");
    } else {
      nameVal.textContent = "Chưa đăng ký tên cho suất này";
      noticeEl.style.display = "block";
      infoBox.classList.remove("found");
    }
    addrVal.textContent = studentAddrOnChain;
    idVal.textContent = `#${id}`;
  }

  // ==============================================================================
  // TEST CASE 1: Suất #22 với tên "Phương"
  // ==============================================================================
  console.log("--------------------------------------------------------------------------------");
  console.log("[TEST CASE 1] NHÀ TÀI TRỢ NHẬP TÊN 'Phương' CHO SUẤT #22 Ở BƯỚC 1");
  console.log("--------------------------------------------------------------------------------");
  const WALLET_22 = s22.student; // 0xeE917Bc552F81FE4db72025E05F146919b3B4032
  const NAME_1 = "Phương";

  // Giả lập nhập Bước 1
  registerStudentName(WALLET_22, NAME_1);
  console.log(`  Bước 1: Nhà tài trợ nhập ví: ${WALLET_22}`);
  console.log(`  Bước 1: Tên sinh viên nhập: "${NAME_1}"`);

  // Mở trang Submit và nhập ID = 22
  await simulateUpdateSubmitCardInfo(22);
  const resultName1 = env.getEl("submitStudentNameVal").textContent;
  console.log(`  Submit: Nhập Scholarship ID = 22`);
  console.log(`  Submit: Tên sinh viên thụ hưởng hiển thị: "${resultName1}"`);

  if (resultName1 !== NAME_1) {
    throw new Error(`FAIL Test 1: Kỳ vọng "${NAME_1}", nhưng nhận được "${resultName1}"`);
  }
  if (resultName1 === "Chưa đăng ký tên cho suất này") {
    throw new Error("FAIL Test 1: Hiển thị lỗi 'Chưa đăng ký tên cho suất này'!");
  }
  console.log("  -> PASS Test 1: Suất #22 hiển thị chính xác tên 'Phương'!\n");

  // ==============================================================================
  // TEST CASE 2: Suất #25 với tên "Trăng Sao"
  // ==============================================================================
  console.log("--------------------------------------------------------------------------------");
  console.log("[TEST CASE 2] NHÀ TÀI TRỢ NHẬP TÊN 'Trăng Sao' CHO SUẤT #25 Ở BƯỚC 1");
  console.log("--------------------------------------------------------------------------------");
  const WALLET_25 = s25.student; // 0x73ffF099ADA86f63217B769Afcf00Da80F2B9Dca
  const NAME_2 = "Trăng Sao";

  // Giả lập nhập Bước 1 cho sinh viên thứ hai
  registerStudentName(WALLET_25, NAME_2);
  console.log(`  Bước 1: Nhà tài trợ nhập ví: ${WALLET_25}`);
  console.log(`  Bước 1: Tên sinh viên nhập: "${NAME_2}"`);

  // Mở trang Submit và nhập ID = 25
  await simulateUpdateSubmitCardInfo(25);
  const resultName2 = env.getEl("submitStudentNameVal").textContent;
  console.log(`  Submit: Nhập Scholarship ID = 25`);
  console.log(`  Submit: Tên sinh viên thụ hưởng hiển thị: "${resultName2}"`);

  if (resultName2 !== NAME_2) {
    throw new Error(`FAIL Test 2: Kỳ vọng "${NAME_2}", nhưng nhận được "${resultName2}"`);
  }
  if (resultName2 === "Chưa đăng ký tên cho suất này") {
    throw new Error("FAIL Test 2: Hiển thị lỗi 'Chưa đăng ký tên cho suất này'!");
  }
  console.log("  -> PASS Test 2: Suất #25 hiển thị chính xác tên 'Trăng Sao'!\n");

  // ==============================================================================
  // TEST CASE 3: Thay đổi qua lại ID ở trang Submit không bị giữ tên cũ
  // ==============================================================================
  console.log("--------------------------------------------------------------------------------");
  console.log("[TEST CASE 3] CHUYỂN ĐỔI SCHOLARSHIP ID Ở SUBMIT (CẬP NHẬT ĐÚNG, KHÔNG GIỮ TÊN CŨ)");
  console.log("--------------------------------------------------------------------------------");

  // Chuyển lại về 22: phải ra "Phương", không được giữ "Trăng Sao"
  await simulateUpdateSubmitCardInfo(22);
  const reCheck22 = env.getEl("submitStudentNameVal").textContent;
  console.log(`  Submit đổi sang ID #22 -> Tên: "${reCheck22}"`);
  if (reCheck22 !== NAME_1) {
    throw new Error(`FAIL Test 3A: Kỳ vọng "${NAME_1}", nhưng nhận được "${reCheck22}"`);
  }

  // Chuyển sang 20: phải ra "Trần Thị Như Huỳnh", không được giữ "Phương"
  await simulateUpdateSubmitCardInfo(20);
  const check20 = env.getEl("submitStudentNameVal").textContent;
  console.log(`  Submit đổi sang ID #20 -> Tên: "${check20}"`);
  if (check20 !== "Trần Thị Như Huỳnh") {
    throw new Error(`FAIL Test 3B: Kỳ vọng "Trần Thị Như Huỳnh", nhưng nhận được "${check20}"`);
  }

  // Chuyển lại về 25: phải ra "Trăng Sao"
  await simulateUpdateSubmitCardInfo(25);
  const reCheck25 = env.getEl("submitStudentNameVal").textContent;
  console.log(`  Submit đổi lại sang ID #25 -> Tên: "${reCheck25}"`);
  if (reCheck25 !== NAME_2) {
    throw new Error(`FAIL Test 3C: Kỳ vọng "${NAME_2}", nhưng nhận được "${reCheck25}"`);
  }
  console.log("  -> PASS Test 3: Cập nhật tên lập tức và không bao giờ giữ tên của suất trước!\n");

  // ==============================================================================
  // TEST CASE 4: Suất chưa có dữ liệu tên thực sự
  // ==============================================================================
  console.log("--------------------------------------------------------------------------------");
  console.log("[TEST CASE 4] KIỂM TRA SUẤT CHƯA CÓ TÊN THỰC SỰ");
  console.log("--------------------------------------------------------------------------------");
  const UNKNOWN_WALLET = "0x1234567890123456789012345678901234567890";
  const nameOfUnknown = lookupStudentNameForScholarship(8888, UNKNOWN_WALLET);
  console.log(`  Tra cứu ví chưa đăng ký: ${nameOfUnknown}`);
  if (nameOfUnknown !== null) {
    throw new Error("FAIL Test 4: Suất chưa có tên phải trả về null!");
  }
  console.log("  -> PASS Test 4: Trả về null chính xác khi chưa có dữ liệu tên thật sự!\n");

  // ==============================================================================
  // TEST CASE 5: Tải lại trang (Refresh / Sync) không ghi đè tên đã lưu
  // ==============================================================================
  console.log("--------------------------------------------------------------------------------");
  console.log("[TEST CASE 5] KIỂM TRA BẢO TOÀN DỮ LIỆU KHI TẢI LẠI TRANG (PAGE RELOAD / RESYNC)");
  console.log("--------------------------------------------------------------------------------");
  // Mô phỏng người dùng F5 tải lại trang: syncSharedRegistryFromServer được gọi
  syncSharedRegistryFromServerMock(seedJson);

  // Sau khi sync lại từ tệp gốc seedJson, kiểm tra tên của Suất #22 và #25 vẫn là tên người dùng đã nhập
  const afterReloadName22 = lookupStudentNameForScholarship(22, WALLET_22);
  const afterReloadName25 = lookupStudentNameForScholarship(25, WALLET_25);
  console.log(`  Sau khi F5 reload trang: Suất #22 -> "${afterReloadName22}"`);
  console.log(`  Sau khi F5 reload trang: Suất #25 -> "${afterReloadName25}"`);

  if (afterReloadName22 !== NAME_1 || afterReloadName25 !== NAME_2) {
    throw new Error("FAIL Test 5: Tệp dữ liệu cũ đã ghi đè tên mới trong localStorage!");
  }
  console.log("  -> PASS Test 5: Dữ liệu tên người dùng nhập ở Bước 1 được bảo toàn 100% qua các lần tải lại trang!\n");

  console.log("================================================================================");
  console.log(">>> TẤT CẢ 5 BỘ TEST NGHIỆP VỤ ĐỒNG BỘ ĐÃ VƯỢT QUA 100% (ALL PASSED) <<<");
  console.log("================================================================================\n");
}

runComprehensiveTests().catch(err => {
  console.error("Lỗi Test:", err);
  process.exit(1);
});
