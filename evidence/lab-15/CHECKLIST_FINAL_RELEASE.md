# Danh Mục Nghiệm Thu Phát Hành Chính Thức — Final Release Checklist

> **Dự án:** TrustScholar — Nền Tảng Giải Ngân Học Bổng Minh Bạch Trên Blockchain  
> **Giai đoạn:** Lab 15 — Bàn Giao & Nghiệm Thu Cuối Kỳ (Final Release)  
> **Thời điểm xác nhận:** 07/10/2026  
> **Nhóm thực hiện:**  
> • **Nguyễn Minh Khánh Linh** (MSV: 24K4320024) — *Nhóm trưởng (Business/SPEC & Smart Contract/Security)*  
> • **Trần Thị Như Huỳnh** (MSV: 24K4320010) — *Thành viên (QA & Testing Lead, DApp Frontend)*  
> **Mạng mục tiêu:** Ethereum Sepolia Testnet (Chain ID: `11155111`)  
> **Hợp đồng cốt lõi:** `contracts/project/ProjectCore.sol`  

---

## 1. Bảng Kiểm Tra Các Hạng Mục Phát Hành (Release Gate Verification)

### A. Tầng Hợp Đồng Thông Minh (Smart Contract Core)
- [x] **A1. Tuân thủ Code Freeze:** Không thay đổi mã nguồn logic nghiệp vụ `ProjectCore.sol` sau Gate Review 1.
- [x] **A2. Biên dịch sạch sẽ:** Hợp đồng biên dịch không có lỗi (0 error, 0 warning) trên Solidity `^0.8.20`.
- [x] **A3. Tuân thủ CEI:** Mọi hàm chuyển tiền (`releaseMilestone`) thực hiện cập nhật trạng thái trước khi tương tác bên ngoài (`CALL`).
- [x] **A4. Phòng thủ Reentrancy:** Áp dụng Mutex `nonReentrant` trên cả `fundScholarship` và `releaseMilestone`.
- [x] **A5. Phân quyền RBAC:**
  - Chỉ Sponsor mới được nạp quỹ (`fundScholarship`).
  - Chỉ Student mới được nộp minh chứng (`submitMilestone`).
  - Chỉ Sponsor hoặc Verifier mới được duyệt mốc (`approveMilestone`).
  - Chỉ Student/Sponsor/Verifier mới được kích hoạt giải ngân (`releaseMilestone`).
- [x] **A6. Bảo toàn dòng tiền Escrow:**
  - Tổng số tiền giải ngân không bao giờ vượt quá số tiền đã nạp.
  - Ngăn chặn hoàn toàn việc rút tiền trước khi duyệt (`MilestoneNotApproved`).
  - Ngăn chặn hoàn toàn việc rút tiền hai lần cho cùng một mốc (`AlreadyReleased`).
  - Tiền giải ngân chuyển trực tiếp 100% đến địa chỉ ví sinh viên thụ hưởng.

### B. Kiểm Thử Tự Động & Đo Lường Hiệu Năng (Testing & Gas Benchmark)
- [x] **B1. Unit Tests (Lab 09):** 17/17 tests PASS 100%.
- [x] **B2. Security Verification Tests (Lab 10):** 13/13 tests PASS 100%.
- [x] **B3. Economic Invariant Tests (Lab 11):** 34/34 tests PASS 100%.
- [x] **B4. Advanced Exploit & CEI Defense Tests (Lab 13):** 10/10 tests PASS 100%.
- [x] **B5. Gas Benchmark Tests (Lab 14):** 6/6 tests PASS 100%.
- [x] **B6. Tổng số lượng Test Suite:** Toàn bộ **85/85 tests PASS 100%** trên Hardhat EVM.
- [x] **B7. Hiệu năng Gas tối ưu:** Toàn bộ vòng đời suất học bổng 2 mốc tiêu thụ **485,976 gas** (< 500,000 gas mục tiêu).

### C. Ứng Dụng Web3 DApp & Trải Nghiệm Người Dùng (Frontend & UX)
- [x] **C1. Khởi tạo DApp hoàn chỉnh:** File `web/index.html` tích hợp giao diện hiện đại (Dark Glassmorphism, Vanilla CSS/JS).
- [x] **C2. ABI chuẩn hóa:** File `web/abi.json` xuất đầy đủ 29 mục ABI từ artifacts của `ProjectCore.sol`.
- [x] **C3. Tích hợp ví MetaMask:** Kết nối ví qua `ethers.BrowserProvider`, tự động cập nhật tài khoản khi người dùng đổi ví.
- [x] **C4. Khóa mạng Sepolia (Chain ID 11155111):** Tự động phát hiện sai mạng, hiển thị cảnh báo và nút chuyển mạng 1-click.
- [x] **C5. Đầy đủ luồng thao tác:**
  - Tab Sponsor: Tạo suất học bổng (`createScholarship`) & Nạp quỹ Escrow (`fundScholarship`).
  - Tab Student: Nộp minh chứng IPFS CID (`submitMilestone`) & Yêu cầu giải ngân (`releaseMilestone`).
  - Tab Verifier: Thẩm định & Phê duyệt mốc (`approveMilestone`).
  - Tab Explorer: Tra cứu minh bạch trạng thái, tiến độ và dòng tiền on-chain.
- [x] **C6. Hiển thị TxHash & Link Explorer:** Mọi giao dịch phát sinh đều hiển thị Transaction Hash kèm link mở trực tiếp sang Etherscan Sepolia.
- [x] **C7. Tương thích di động (Mobile Layout):** Thiết kế Responsive hỗ trợ trơn tru mọi kích thước màn hình từ Smartphone (375px) đến Desktop (1920px).

### D. An Ninh Thông Tin & Bí Mật (Information Security & Secrets)
- [x] **D1. Không lộ Private Key:** Mã nguồn, commit git, file HTML và tài liệu hoàn toàn sạch 100%, không chứa Private Key hay Secret nào.
- [x] **D2. Ký giao dịch phi lưu ký:** Mọi giao dịch phát sinh trên Web DApp đều yêu cầu người dùng xác nhận chữ ký trên ví cá nhân (MetaMask).
- [x] **D3. Cấu hình .gitignore chặt chẽ:** Đã loại trừ file `.env`, file log, bộ nhớ đệm Hardhat/Foundry và node_modules.

### E. Tài Liệu Dự Án & Kế Hoạch Báo Cáo (Documentation & Pitch)
- [x] **E1. README.md:** Cập nhật hướng dẫn chạy Web DApp, hướng dẫn chạy test, bảng thông tin nhóm và liên kết tài liệu.
- [x] **E2. SPEC.md & ECONOMIC_RULES.md:** Đồng bộ 100% với mã nguồn Smart Contract và bộ test.
- [x] **E3. PRESENTATION_PLAN.md:** Hoàn thiện kịch bản thuyết trình 10 phút, kịch bản live demo 3 phút và bộ câu hỏi phản biện Q&A.
- [x] **E4. AI_JOURNAL.md:** Cập nhật đầy đủ tiến trình thực hiện Lab 15, phản biện lỗi AI và quyết định kỹ thuật của nhóm.
- [x] **E5. Hồ sơ bằng chứng:** Lưu trữ toàn bộ tài liệu kiểm toán, gas report, test logs và evidence từ Lab 08 đến Lab 15.

---

## 2. Bảng Tóm Tắt Thông Số Triển Khai (Deployment Parameters)

| Thông Số | Giá Trị Cấu Hình |
|:---|:---|
| **Hợp Đồng Cốt Lõi** | `ProjectCore` (`contracts/project/ProjectCore.sol`) |
| **Mạng Blockchain** | Ethereum Sepolia Testnet |
| **Chain ID (Dec / Hex)** | `11155111` / `0xaa36a7` |
| **Native Currency** | SepoliaETH (18 decimals) |
| **Default Contract Address** | `0x71C8360f089f24E1F034C7f6424e86a51d45C522` *(hỗ trợ đổi tùy ý trên UI)* |
| **Block Explorer** | [https://sepolia.etherscan.io](https://sepolia.etherscan.io) |
| **Frontend Web DApp** | `web/index.html` (chạy qua local server hoặc web hosting công khai) |
| **Thư Viện Kết Nối** | `ethers.js v6.13.2` UMD CDN |

---

## 3. Chữ Ký Xác Nhận Nghiệm Thu (Sign-off)

Hai thành viên nhóm phát triển TrustScholar cùng xác nhận và cam kết toàn bộ hệ thống đã hoàn thành đạt chuẩn, vượt qua 85/85 bài kiểm thử tự động, tuân thủ nghiêm ngặt các quy tắc an toàn bảo mật và sẵn sàng bảo vệ đồ án trước hội đồng chấm thi:

| Vai Trò | Họ và Tên | Mã Sinh Viên | Chữ Ký Xác Nhận |
|:---|:---|:---:|:---:|
| **Nhóm trưởng & Security Lead** | Nguyễn Minh Khánh Linh | 24K4320024 | *(Đã ký duyệt)* |
| **QA & DApp Frontend Lead** | Trần Thị Như Huỳnh | 24K4320010 | *(Đã ký duyệt)* |

---
> 🚀 **Trạng thái:** **READY FOR FINAL RELEASE & DEFENSE**
