# TrustScholar - Nền Tảng Giải Ngân Học Bổng Minh Bạch Trên Blockchain

> **Dự án:** TrustScholar — Giải ngân học bổng minh bạch trên Blockchain  
> **Repository GitHub:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  
> **Điều hướng nhanh:** [Kế Hoạch Đồ Án](docs/PROJECT_PLAN.md) | [Đặc Tả Nghiệp Vụ](docs/SPEC.md) | [Quy Tắc Kinh Tế](docs/ECONOMIC_RULES.md) | [Gate Review 1](docs/GATE_REVIEW_1.md) | [Kế Hoạch Thuyết Trình](docs/PRESENTATION_PLAN.md) | [Nhật Ký AI](docs/AI_JOURNAL.md) | [Danh Mục Nghiệm Thu](evidence/lab-15/CHECKLIST_FINAL_RELEASE.md)  
> **Slogan:** *Nhóm xây dựng nền tảng TrustScholar cho nhà tài trợ và sinh viên để đảm bảo giải ngân học bổng tự động, minh bạch và chống sai đối tượng.*

---

## 1. Thông Tin Nhóm & Đồ Án
- **Môn học:** Lập trình Smart Contract / Web3 (2026)
- **Tên dự án:** TrustScholar
- **Quy mô:** Nhóm 2 thành viên

| STT | Họ và Tên | Mã Sinh Viên | Email | Vai Trò Chính |
|:---:|:---|:---:|:---|:---|
| 1 | Nguyễn Minh Khánh Linh | 24K4320024 | 24k4320024@hce.edu.vn | Nhóm trưởng *(Business/SPEC + Smart Contract/Security)* |
| 2 | Trần Thị Như Huỳnh | 24K4320010 | 24K4320010@hce.edu.vn | Thành viên *(Testing + DApp + Audit)* |

---

## 2. Cấu Trúc Thư Mục Dự Án
```text
.
├── README.md                  # Giới thiệu tổng quan, hướng dẫn chạy và thông tin nhóm
├── contracts/                 # Mã nguồn Smart Contract
│   ├── project/
│   │   └── ProjectCore.sol    # Hợp đồng lõi Escrow phi lưu ký theo mốc (Code Freeze)
│   └── training/              # Hợp đồng đào tạo thực nghiệm an ninh Lab 13
│       ├── VulnerableScholarshipBank.sol # Mô phỏng lỗi Reentrancy vi phạm CEI
│       ├── AttackerScholarshipBank.sol   # Contract tấn công tái nhập đệ quy
│       └── SecureScholarshipBank.sol     # Phiên bản vá lỗi bằng CEI & Mutex Guard
├── web/                       # Ứng dụng Web3 DApp (Lab 15 Final Release)
│   ├── index.html             # Giao diện Web3 DApp hoàn chỉnh (Vanilla CSS/JS, Dark Glassmorphism)
│   └── abi.json               # ABI chính thức trích xuất từ ProjectCore.sol
├── scripts/                   # Kịch bản triển khai tự động
│   └── deploy.js              # Script triển khai hợp đồng lên Sepolia Testnet
├── docs/                      # Tài liệu kỹ thuật và quản trị đồ án
│   ├── PROJECT_PLAN.md        # Phân công vai trò, đối tượng & lộ trình mốc Lab 08–15
│   ├── SPEC.md                # Đặc tả nghiệp vụ v1.0 với bộ 10 quy tắc R1–R10
│   ├── ECONOMIC_RULES.md      # Quy tắc kinh tế, dòng tiền, hạn mức & chống lạm dụng
│   ├── LAB10_AUDIT.md         # Báo cáo kiểm toán an ninh nội bộ vòng 1 (8 findings)
│   ├── GATE_REVIEW_1.md       # Biên bản thẩm định mốc 1 & Code Freeze Smart Contract
│   ├── LAB13_SECURITY.md      # Báo cáo thực nghiệm an ninh & kiểm toán chuyên sâu Lab 13
│   ├── LAB14_CROSS_AUDIT.md   # Báo cáo kiểm toán chéo Lab 14
│   ├── PRESENTATION_PLAN.md   # Kế hoạch thuyết trình 10 phút, kịch bản demo 3 phút & Q&A
│   └── AI_JOURNAL.md          # Nhật ký ứng dụng AI xuyên suốt từ Lab 08 đến Lab 15
├── evidence/                  # Bằng chứng thực nghiệm từng bài Lab
│   ├── lab-08/                # Bằng chứng đặc tả & quy tắc kinh tế ban đầu
│   ├── lab-09/                # Bằng chứng biên dịch & 17 unit tests đầu tiên
│   ├── lab-10/                # Bằng chứng kiểm toán an ninh & 13 verification tests
│   ├── lab-11/                # Bằng chứng 8 yêu cầu kinh tế & 34 tests chuyên sâu
│   ├── lab-13/                # Bằng chứng thực nghiệm an ninh Reentrancy & 10 tests
│   ├── lab-14/                # Bằng chứng kiểm toán chéo & benchmark gas EVM
│   └── lab-15/                # Bằng chứng đánh giá kỹ thuật cuối kỳ & E2E Demo Walkthrough
│       ├── DEMO_RUN_REPORT.md         # Báo cáo chạy thử DApp thực tế 8 phần & đối soát số dư
│       ├── FINAL_TECHNICAL_REVIEW.md  # Báo cáo rà soát 17 tiêu chí kỹ thuật
│       ├── CHECKLIST_FINAL_RELEASE.md # Danh mục kiểm tra nghiệm thu chính thức
│       └── DAPP_VERIFICATION.md       # Bằng chứng kiểm thử giao diện DApp & mạng Sepolia
└── test/                      # Hệ thống kiểm thử tự động (91/91 tests PASS 100%)
    ├── ProjectCore.t.sol      # Test suite chuẩn Lab 09 (17 tests)
    ├── Lab10_Verify.t.sol     # Test suite kiểm chứng findings Lab 10 (13 tests)
    ├── Lab11_EconomicRules.t.sol # Test suite kinh tế Lab 11 (34 tests)
    ├── Lab13_SecurityExperiments.t.sol # Test suite thực nghiệm an ninh Lab 13 (10 tests)
    ├── Lab14_GasReport.t.sol           # Test suite đo lường gas benchmark Lab 14 (6 tests)
    └── Lab15_E2E_Demo.t.sol            # Test suite mô phỏng 8 phần E2E Demo Lab 15 (6 tests)
```

---

## 3. Hướng Dẫn Cài Đặt & Chạy Kiểm Thử (Run Tests)

### Bước 1: Cài đặt thư viện phụ thuộc
```bash
npm install
```

### Bước 2: Biên dịch Smart Contract
```bash
npx hardhat compile
# Hoặc trên Windows PowerShell:
cmd /c npx hardhat compile
```

### Bước 3: Chạy toàn bộ 91 bài test tự động (bao gồm 6 E2E Demo tests)
```bash
npx hardhat test
# Hoặc trên Windows PowerShell:
cmd /c npx hardhat test
```
*Kết quả mong đợi:* **91 passing (91 solidity)** không có lỗi nào.

---

## 4. Hướng Dẫn Vận Hành Web3 DApp (Run DApp)

### Cách 1: Khởi chạy bằng máy chủ cục bộ (Khuyến nghị)
1. Khởi động HTTP server tại thư mục `web/`:
   ```bash
   # Dùng Python:
   python -m http.server 8080 --directory web

   # Hoặc dùng Node.js npx:
   cmd /c npx serve web
   ```
2. Mở trình duyệt web và truy cập địa chỉ: [http://localhost:8080](http://localhost:8080)

### Cách 2: Mở trực tiếp file HTML
- Nhấp đúp chuột vào file [`web/index.html`](web/index.html) để mở trên trình duyệt Chrome, Edge, Brave hoặc Firefox có cài đặt tiện ích ví **MetaMask**.

### Các bước tương tác với DApp:
1. **Kết nối ví:** Bấm nút **"Kết Nối Ví MetaMask"** ở góc phải thanh điều hướng. Đảm bảo ví đang chọn mạng **Sepolia Testnet** (Chain ID: `11155111`).
2. **Nhà tài trợ (Sponsor):**
   - Nhập địa chỉ ví sinh viên và định mức các mốc (ví dụ: `0.05, 0.05` ETH). Bấm **"Khởi Tạo Suất Học Bổng"**.
   - Nhập ID suất học bổng và số tiền cần nạp (ví dụ: `0.1` ETH). Bấm **"Nạp Tiền Vào Escrow"**.
3. **Sinh viên (Student):**
   - Nhập ID suất học bổng, chỉ số mốc (bắt đầu từ 0) và mã băm minh chứng IPFS (CID). Bấm **"Gửi Minh Chứng"**.
4. **Thẩm định viên (Verifier):**
   - Nhập ID suất học bổng và chỉ số mốc cần duyệt. Bấm **"Phê Duyệt Mốc"**.
5. **Giải ngân (Release):**
   - Sinh viên hoặc Nhà tài trợ bấm **"Kích Hoạt Giải Ngân"**. Native ETH được chuyển tự động và trực tiếp vào ví sinh viên thụ hưởng.
6. **Tra cứu minh bạch (Explorer):**
   - Chuyển sang Tab Explorer, nhập ID suất học bổng để xem toàn bộ thông số, lịch sử duyệt và timestamp on-chain.

---

## 5. Thông Số Kỹ Thuật Mạng Sepolia & Smart Contract

| Thuộc Tính | Chi Tiết Cấu Hình |
|:---|:---|
| **Hợp Đồng Cốt Lõi** | `ProjectCore` (`contracts/project/ProjectCore.sol`) |
| **Mạng Blockchain** | Ethereum Sepolia Testnet |
| **Chain ID** | `11155111` (Thập lục phân: `0xaa36a7`) |
| **Đơn Vị Tiền Tệ** | Native SepoliaETH (18 chữ số thập phân) |
| **Địa Chỉ Hợp Đồng Mặc Định** | `0x71C8360f089f24E1F034C7f6424e86a51d45C522` *(có thể thay đổi linh hoạt trên giao diện DApp)* |
| **Block Explorer** | [https://sepolia.etherscan.io](https://sepolia.etherscan.io) |
| **An Toàn Khóa Riêng Tư** | **100% Phi Lưu Ký** — Không lưu trữ hay yêu cầu Private Key trên hệ thống |

---

## 6. Điều Hướng Tài Liệu & Kho Lưu Trữ

- 🌐 **Mã nguồn GitHub:** [https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)
- 📋 **Kế hoạch & Phân công vai trò:** [PROJECT_PLAN.md](docs/PROJECT_PLAN.md)
- 📐 **Đặc tả nghiệp vụ & 10 Quy tắc R1–R10:** [SPEC.md](docs/SPEC.md)
- 💰 **Quy tắc kinh tế & Chống lạm dụng:** [ECONOMIC_RULES.md](docs/ECONOMIC_RULES.md)
- 🛡️ **Báo cáo kiểm toán bảo mật Lab 10:** [LAB10_AUDIT.md](docs/LAB10_AUDIT.md)
- 🚦 **Biên bản thẩm định Gate Review 1:** [GATE_REVIEW_1.md](docs/GATE_REVIEW_1.md)
- 🔬 **Báo cáo thực nghiệm an ninh Lab 13:** [LAB13_SECURITY.md](docs/LAB13_SECURITY.md)
- 🔍 **Báo cáo kiểm toán chéo Lab 14:** [LAB14_CROSS_AUDIT.md](docs/LAB14_CROSS_AUDIT.md)
- ⛽ **Báo cáo đối chuẩn Gas Lab 14:** [GAS_REPORT.md](evidence/lab-14/GAS_REPORT.md)
- 🎤 **Kế hoạch thuyết trình & Demo Lab 15:** [PRESENTATION_PLAN.md](docs/PRESENTATION_PLAN.md)
- 🖥️ **Báo cáo chạy thử DApp thực tế 8 phần:** [DEMO_RUN_REPORT.md](evidence/lab-15/DEMO_RUN_REPORT.md)
- 📝 **Đánh giá kỹ thuật cuối kỳ Lab 15:** [FINAL_TECHNICAL_REVIEW.md](evidence/lab-15/FINAL_TECHNICAL_REVIEW.md)
- 🚀 **Danh mục nghiệm thu phát hành chính thức:** [CHECKLIST_FINAL_RELEASE.md](evidence/lab-15/CHECKLIST_FINAL_RELEASE.md)
- 🖥️ **Bằng chứng xác minh DApp:** [DAPP_VERIFICATION.md](evidence/lab-15/DAPP_VERIFICATION.md)
- 🤖 **Nhật ký ứng dụng AI xuyên suốt:** [AI_JOURNAL.md](docs/AI_JOURNAL.md)

---
> 🔗 **Liên kết nhanh:** [Trang chủ](README.md) • [Kế hoạch đồ án](docs/PROJECT_PLAN.md) • [Đặc tả nghiệp vụ](docs/SPEC.md) • [Quy tắc kinh tế](docs/ECONOMIC_RULES.md) • [Thuyết trình](docs/PRESENTATION_PLAN.md) • [Nghiệm thu](evidence/lab-15/CHECKLIST_FINAL_RELEASE.md) • [Nhật ký AI](docs/AI_JOURNAL.md) • [GitHub Repo](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)
