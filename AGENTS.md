# Quy Chuẩn Hoạt Động Của AI Agent (AGENTS.md) — TrustScholar

> **Dự án:** TrustScholar — Nền Tảng Giải Ngân Học Bổng Minh Bạch Trên Blockchain  
> **Repository GitHub:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  
> **Phiên bản:** v1.0  
> **Mục đích:** Thiết lập khung nguyên tắc, quy trình vận hành và tiêu chuẩn an ninh bắt buộc dành cho mọi AI Agent (Antigravity, Claude, ChatGPT, v.v.) khi tham gia hỗ trợ nghiên cứu, lập trình, kiểm thử và biên soạn tài liệu trong kho mã nguồn này.

---

## 1. Thông Tin Nhóm & Phân Vai Thành Viên

Mọi AI Agent khi tương tác với dự án phải tuyệt đối tôn trọng sự phân công vai trò của 2 thành viên:

| STT | Thành Viên | Mã Sinh Viên | Vai Trò Chính | Khối Trách Nhiệm Kỹ Thuật |
|:---:|:---|:---:|:---|:---|
| 1 | **Nguyễn Minh Khánh Linh**<br>*(Nhóm trưởng)* | 24K4320024 | **Business/SPEC + Smart Contract/Security** | • Quản trị đặc tả nghiệp vụ ([docs/SPEC.md](docs/SPEC.md)) và mô hình kinh tế ([docs/ECONOMIC_RULES.md](docs/ECONOMIC_RULES.md)).<br>• Lập trình kiến trúc hợp đồng cốt lõi ([contracts/project/ProjectCore.sol](contracts/project/ProjectCore.sol)).<br>• Thiết kế các cơ chế phòng thủ an ninh (CEI, `nonReentrant`, RBAC, Solvency).<br>• Phụ trách Code Freeze và kiểm toán độc lập (Security Lead). |
| 2 | **Trần Thị Như Huỳnh**<br>*(Thành viên)* | 24K4320010 | **Testing + DApp + Audit** | • Xây dựng bộ test suite tự động toàn diện ([test/](test/)) bảo đảm 100% test pass.<br>• Lập trình và vận hành giao diện Web3 DApp ([web/index.html](web/index.html)).<br>• Thực hiện kiểm toán chéo (Cross-Audit Lead), đối chuẩn chi phí Gas và Slither.<br>• Chuẩn bị hồ sơ bằng chứng thực nghiệm ([evidence/](evidence/)) và kịch bản demo. |

---

## 2. Bộ 6 Nguyên Tắc Vàng Dành Cho AI Agent (Core Directives)

### 📌 Nguyên tắc 1: "Spec First, Code Later" (Ưu tiên đặc tả)
- Mọi logic nghiệp vụ phải bắt nguồn từ [docs/SPEC.md](docs/SPEC.md) và [docs/ECONOMIC_RULES.md](docs/ECONOMIC_RULES.md).
- AI Agent **tuyệt đối không tự ý phát minh hoặc suy diễn logic nghiệp vụ mới** nếu chưa có sự đồng thuận của nhóm và văn bản hóa trong SPEC.

### 📌 Nguyên tắc 2: Tôn trọng tuyệt đối "Code Freeze" của hợp đồng cốt lõi
- Hợp đồng [`contracts/project/ProjectCore.sol`](contracts/project/ProjectCore.sol) đã chính thức được **Code Freeze** tại Cột mốc Gate Review 1 (Lab 12).
- AI Agent **tuyệt đối không thay đổi chữ ký hàm (ABI), cấu trúc dữ liệu `struct` hoặc luồng trạng thái** của `ProjectCore.sol` mà không có yêu cầu rõ ràng từ người dùng.
- Mọi thực nghiệm lỗ hổng (như mô phỏng Reentrancy tại Lab 13) bắt buộc phải tạo hợp đồng riêng biệt trong thư mục [`contracts/training/`](contracts/training/).

### 📌 Nguyên tắc 3: Bảo mật tối thượng — Checks-Effects-Interactions (CEI)
- Khi gợi ý hoặc chỉnh sửa bất kỳ đoạn code liên quan đến chuyển tài sản Native ETH:
  1. **Checks:** Kiểm tra quyền gọi hàm, trạng thái mốc (`Approved`), số dư quỹ ký quỹ.
  2. **Effects:** Cập nhật biến trạng thái (`milestone.status = Disbursed`, `releasedAmount += amount`) **TRƯỚC KHI** thực hiện external call.
  3. **Interactions:** Sử dụng low-level call an toàn với cờ `(bool success, ) = recipient.call{value: amount}("")` và custom error `TransferFailed()`.
  4. Luôn kích hoạt khóa Mutex hai pha `nonReentrant` cho tất cả các hàm nhận hoặc gửi ETH.

### 📌 Nguyên tắc 4: Trung thực học thuật — Không tạo dữ liệu giả mạo (No Hallucinations)
- **Không tạo Test giả:** Toàn bộ test case phải chạy thật và kiểm chứng qua lệnh terminal thực tế (`npx hardhat test`).
- **Không tạo Bằng chứng giả:** Không photoshop, không tạo ảnh chụp màn hình giả lập khi chưa có giao diện thật, không giả mạo file log.
- **Không tạo Transaction Hash giả:** Không bịa các chuỗi hash placeholder ngẫu nhiên khi chưa có giao dịch thực thi trên mạng EVM.
- **Không tự ý phê duyệt:** Tại các biên bản thẩm định (như [docs/GATE_REVIEW_1.md](docs/GATE_REVIEW_1.md)), Agent không được tự ghi "Gate Passed" nếu chưa có quyết định chính thức từ Giảng viên hướng dẫn.

### 📌 Nguyên tắc 5: Quy chuẩn kiểm toán khách quan (Audit Discipline)
- Khi thực hiện kiểm toán (như tại Lab 10 hoặc Lab 14):
  - **Tuyệt đối KHÔNG sửa source code của nhóm được kiểm toán.**
  - **Không bịa đặt lỗ hổng (No Hallucinated Findings):** Mọi phát hiện phải được chỉ rõ tên tệp, số dòng, kịch bản khai thác cụ thể và có test case PoC tái hiện.
  - Phải phân định rạch ròi 3 nhóm: **Confirmed Issue**, **Potential Issue**, và **False Positive**.

### 📌 Nguyên tắc 6: Duy trì nhật ký AI minh bạch ([docs/AI_JOURNAL.md](docs/AI_JOURNAL.md))
- Mọi bài Lab đều phải ghi nhận trung thực quá trình làm việc cùng AI:
  - Prompt đã nhập.
  - Phản hồi của AI cùng các lỗi sai / ảo giác / nguy cơ bảo mật mà AI đưa ra.
  - Quyết định can thiệp và sửa sai của thành viên con người.
  - Kết quả nghiệm thu thực tế.

---

## 3. Môi Trường Phát Triển & Quy Chuẩn Lệnh Thực Thi

AI Agent cần tuân thủ cấu hình kỹ thuật của dự án:

| Thông Số | Giá Trị Chuẩn |
|:---|:---|
| **Hệ Điều Hành** | Windows 11 / Windows PowerShell & CMD |
| **Node.js** | v20+ (ES Module: `"type": "module"` trong `package.json`) |
| **Framework** | Hardhat 3.18.1 |
| **Solidity** | `^0.8.20` (Trình tối ưu: `optimizer: { enabled: true, runs: 200 }`, EVM Target: `shanghai`) |
| **Bộ Kiểm Thử** | Hardhat 3 Solidity Tests (Foundry-style `.t.sol`) |
| **Mạng Thử Nghiệm** | Ethereum Sepolia Testnet (Chain ID: `11155111`) |

### Lệnh thực thi chuẩn trên môi trường Windows:
```bash
# Biên dịch hợp đồng
npx.cmd hardhat compile
# hoặc
cmd /c npx hardhat compile

# Chạy toàn bộ 91 bài test tự động
npx.cmd hardhat test
# hoặc
cmd /c npx hardhat test

# Chạy riêng từng test suite
npx.cmd hardhat test test/ProjectCore.t.sol
npx.cmd hardhat test test/Lab10_Verify.t.sol
npx.cmd hardhat test test/Lab11_EconomicRules.t.sol
npx.cmd hardhat test test/Lab13_SecurityExperiments.t.sol
npx.cmd hardhat test test/Lab14_GasReport.t.sol
npx.cmd hardhat test test/Lab15_E2E_Demo.t.sol
```

---

## 4. Cấu Trúc Lưu Trữ Hồ Sơ Bằng Chứng (`evidence/`)

Mọi bằng chứng thực nghiệm của các bài Lab phải được tổ chức ngăn nắp theo cấu trúc sau:

```text
evidence/
├── lab-08/       # Hồ sơ đặc tả nghiệp vụ v1.0 & phân tích rủi ro kinh tế
├── lab-09/       # Bằng chứng biên dịch & 17 unit tests đầu tiên
├── lab-10/       # Bằng chứng kiểm toán an ninh vòng 1 & 13 verification tests
├── lab-11/       # Bằng chứng 8 quy tắc kinh tế & 34 tests chuyên sâu
├── lab-12/       # Bằng chứng thẩm định Gate Review 1 & Code Freeze
├── lab-13/       # Bằng chứng thực nghiệm Reentrancy & 15 tests an ninh
├── lab-14/       # Bằng chứng kiểm toán chéo & benchmark Gas EVM
└── lab-15/       # Bằng chứng Final Release, DApp Web3 & E2E Demo Walkthrough
```

---

## 5. Quy Chuẩn Giao Tiếp Dành Cho AI Agent

Khi phản hồi hoặc trao đổi với người dùng trong kho lưu trữ này:
1. **Ngôn ngữ:** Tiếng Việt chuẩn mực, mạch lạc, chính xác về thuật ngữ chuyên ngành Web3/Blockchain.
2. **Định dạng:** GitHub Flavored Markdown có cấu trúc bảng, blockquote, danh sách phân cấp.
3. **Liên kết file:** Bắt buộc sử dụng cú pháp markdown liên kết clickable với tiền tố `file:///` và dấu gạch xuôi `/` cho đường dẫn Windows (ví dụ: `[ProjectCore.sol](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol)`).
4. **Trực quan hóa:** Sử dụng biểu đồ Mermaid (`mermaid`) cho các máy trạng thái, sequence diagram và sơ đồ luồng dữ liệu.
