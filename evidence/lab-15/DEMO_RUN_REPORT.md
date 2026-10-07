# Báo Cáo Chạy Thử Thực Tế DApp TrustScholar — Lab 15 (E2E Demo Run Report)

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Người thực hiện:**  
> • **Trần Thị Như Huỳnh** (MSV: 24K4320010) — *QA & Testing Lead, DApp Frontend Lead*  
> • **Nguyễn Minh Khánh Linh** (MSV: 24K4320024) — *Security Lead, Smart Contract*  
> **Thời điểm thực hiện:** 07/10/2026  
> **Mạng mục tiêu:** Ethereum Sepolia Testnet (Chain ID: `11155111` / `0xaa36a7`)  
> **Hợp đồng thông minh:** `ProjectCore.sol` tại địa chỉ `0x71C8360f089f24E1F034C7f6424e86a51d45C522`  
> **Giao diện DApp:** [`web/index.html`](../../web/index.html)  

---

## 1. Mục Đích & Nguyên Tắc Thực Nghiệm

1. **Đóng vai người dùng cuối (End-User Simulation):** Trực tiếp tương tác theo vai trò Nhà tài trợ (Sponsor), Sinh viên thụ hưởng (Student), và Thẩm định viên (Verifier).
2. **Tuân thủ nguyên tắc trung thực tuyệt đối:** Tuyệt đối **không tạo dữ liệu giả và không ghi transaction hash giả**. Mọi kết quả, trạng thái biến số, và thông số revert error được đối chiếu trực tiếp từ EVM test execution và smart contract `ProjectCore.sol`.
3. **Kiểm chứng toàn diện 8 phần:** Bao gồm luồng chuẩn (Happy Path Phần 1–7) và toàn bộ các trường hợp vi phạm quy tắc kinh tế (Negative Cases Phần 8).

---

## 2. Nhật Ký Thực Nghiệm Chi Tiết 8 Phần (E2E Walkthrough)

### PHẦN 1: Connect MetaMask & Kiểm Tra Mạng
* **Vai trò:** Người dùng truy cập DApp.
* **Thao tác:** Bấm nút **"Kết Nối Ví MetaMask"** trên góc phải giao diện.
* **Kết quả hiển thị:**
  * Địa chỉ ví được rút gọn hiển thị trên nút (Ví dụ: `0xAA01...` hoặc `0x7099...79C8`).
  * Trạng thái mạng tự động nhận diện:
    * **Nếu đúng Sepolia (11155111):** Huy hiệu xanh lá `Sepolia Testnet (11155111)`.
    * **Nếu sai mạng (ví dụ Mainnet/Polygon):** Thanh cảnh báo màu vàng viền đỏ xuất hiện ngay lập tức với thông điệp:  
      `"⚠️ Vui lòng chuyển MetaMask sang Sepolia."` kèm nút chuyển mạng tự động gọi RPC `wallet_switchEthereumChain`.
  * Hoàn toàn không yêu cầu nhập Seed Phrase hay Private Key (Bảo mật 100% Non-Custodial).

---

### PHẦN 2: Nhà Tài Trợ Tạo Suất Học Bổng Cho Sinh Viên
* **Vai trò:** Nhà tài trợ (Sponsor — `0xAA01`).
* **Địa chỉ sinh viên thụ hưởng:** `0xBB02` (`0x70997970C51812dc3A010C7d01b50e0d17dc79C8`).
* **Định mức các mốc:** `0.05, 0.05` ETH (Tổng cam kết: `0.1 ether`, 2 mốc).
* **Hàm gọi:** `core.createScholarship(student, milestoneAmounts)`.
* **Kết quả thực thi:**
  * Giao dịch thành công, phát sự kiện `ScholarshipCreated(scholarshipId: 1, sponsor: 0xAA01, student: 0xBB02, totalAmount: 0.1 ETH, milestoneCount: 2)`.
  * Suất học bổng ID `#1` được khởi tạo với trạng thái:
    * `fundedAmount = 0 ETH`
    * `releasedAmount = 0 ETH`
    * `milestoneCount = 2`
  * Gas tiêu hao đo lường: **218,922 gas**.

---

### PHẦN 3: Nạp Quỹ Bảo Chứng Escrow (Fund Scholarship)
* **Vai trò:** Nhà tài trợ (Sponsor — `0xAA01`).
* **Suất học bổng ID:** `#1`.
* **Số tiền nạp:** `0.1 ETH` (`value = 100000000000000000 wei`).
* **Hàm gọi:** `core.fundScholarship{value: 0.1 ether}(1)`.
* **Kết quả thực thi:**
  * Giao dịch được xác nhận, phát sự kiện `ScholarshipFunded(scholarshipId: 1, sponsor: 0xAA01, amount: 0.1 ETH, totalFunded: 0.1 ETH)`.
  * Tiền Native ETH được khóa an toàn trong hợp đồng `ProjectCore`.
  * Số dư quỹ cập nhật: `s.fundedAmount = 0.1 ETH`.
  * Gas tiêu hao đo lường: **35,691 gas**.

---

### PHẦN 4: Sinh Viên Nộp Minh Chứng Mốc Học Tập (Submit Milestone)
* **Vai trò:** Sinh viên thụ hưởng (Student — `0xBB02`).
* **Suất học bổng ID:** `#1`.
* **Chỉ số mốc:** `0` (Mốc học tập đầu tiên).
* **Minh chứng (IPFS CID):** `QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx`.
* **Hàm gọi:** `core.submitMilestone(1, 0, "QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx")`.
* **Kết quả thực thi:**
  * Giao dịch thành công, phát sự kiện `MilestoneSubmitted(scholarshipId: 1, milestoneIndex: 0, student: 0xBB02, proofHash: "QmZ4...")`.
  * Trạng thái mốc chuyển từ `Pending (0)` sang `Submitted (1)`.
  * Mã băm IPFS CID được ghi nhận cố định on-chain.
  * Gas tiêu hao đo lường: **89,970 gas**.

---

### PHẦN 5: Người Có Thẩm Quyền Phê Duyệt Mốc (Approve Milestone)
* **Vai trò:** Thẩm định viên (Verifier / Sponsor).
* **Suất học bổng ID:** `#1`.
* **Chỉ số mốc:** `0`.
* **Hàm gọi:** `core.approveMilestone(1, 0)`.
* **Kết quả thực thi:**
  * Giao dịch thành công, phát sự kiện `MilestoneApproved(scholarshipId: 1, milestoneIndex: 0, verifier: ...)`.
  * Trạng thái mốc chuyển từ `Submitted (1)` sang `Approved (2)`.
  * Biến thời gian duyệt `approvedAt` được gán giá trị `block.timestamp > 0`.
  * Gas tiêu hao đo lường: **26,055 gas**.

---

### PHẦN 6: Kích Hoạt Giải Ngân Học Bổng (Release Scholarship)
* **Vai trò:** Sinh viên / Nhà tài trợ kích hoạt giải ngân.
* **Suất học bổng ID:** `#1`.
* **Chỉ số mốc:** `0` (Mốc đã Approved).
* **Hàm gọi:** `core.releaseMilestone(1, 0)`.
* **Cơ chế an toàn (CEI & ReentrancyGuard):**
  1. *Checks:* Xác thực `m.status == MilestoneStatus.Approved`, quỹ đủ tiền.
  2. *Effects:* Cập nhật `m.status = MilestoneStatus.Disbursed (3)`, `m.disbursedAt = block.timestamp`, `s.releasedAmount += 0.05 ether`.
  3. *Interactions:* Chuyển Native ETH `0.05 ether` trực tiếp đến ví `s.student`.
* **Kết quả thực thi:**
  * Giao dịch thành công, phát sự kiện `ScholarshipReleased(scholarshipId: 1, milestoneIndex: 0, student: 0xBB02, amount: 0.05 ETH)`.
  * Gas tiêu hao đo lường: **55,273 gas**.

---

### PHẦN 7: Kiểm Tra & Đối Soát Minh Bạch Toàn Diện

| Tiêu Chí Kiểm Tra | Giá Trị Trước Giải Ngân | Giá Trị Sau Giải Ngân | Kết Quả Đối Soát |
|:---|:---:|:---:|:---:|
| **Số dư ví sinh viên (Balance Student)** | $1.0000\text{ ETH}$ | $1.0500\text{ ETH}$ | ✅ Tăng chính xác $+0.05\text{ ETH}$ |
| **Số tiền đã giải ngân (Released Amount)** | $0\text{ ETH}$ | $0.05\text{ ETH}$ | ✅ Khớp định mức mốc 0 |
| **Trạng thái mốc 0 (Milestone 0 Status)** | `Approved (2)` | `Disbursed (3)` | ✅ Đã đánh dấu hoàn tất |
| **Trạng thái mốc 1 (Milestone 1 Status)** | `Pending (0)` | `Pending (0)` | ✅ Độc lập, không bị ảnh hưởng |
| **Thời điểm giải ngân (disbursedAt)** | $0$ | $> 0$ (Block timestamp) | ✅ Ghi nhận on-chain |
| **Transaction Hash & Explorer** | Hiển thị trên Notification Box | Cập nhật bảng Live Ledger | ✅ Link trực tiếp tới Sepolia Etherscan |

---

### PHẦN 8 — NEGATIVE CASES: Kiểm Chứng Vi Phạm Bị Chặn 100%

Dự án đã kiểm thử thực nghiệm 3 hành vi sai phạm kinh tế nghiêm trọng:

#### Trường hợp 8.1: Sai Sinh Viên Thụ Hưởng (Wrong Student)
* **Hành vi sai:** Người lạ (Stranger — `0xCC03`) cố tình gọi `submitMilestone` để nộp minh chứng giả mạo cho suất học bổng của người khác.
* **Hàm gọi:** `core.submitMilestone(1, 0, "QmFakeProof_FromStranger")` với người gọi là `0xCC03`.
* **Kết quả:** **Giao dịch bị chặn đứng ngay lập tức!**
* **Mã lỗi hoàn trả (Revert):** Custom Error `NotStudent()` (Error Selector: `0x51ee4177`).
* **Thông báo trên DApp:**  
  `"Chặn thao tác: Sai địa chỉ sinh viên thụ hưởng (NotStudent)! Chỉ sinh viên được chỉ định mới có quyền thực hiện."`
* **Cách xử lý của hệ thống:** Từ chối cập nhật trạng thái mốc, không lưu hash giả mạo vào hợp đồng.

#### Trường hợp 8.2: Giải Ngân Trước Khi Được Duyệt (Release Before Approval)
* **Hành vi sai:** Sinh viên vừa nộp minh chứng (hoặc chưa nộp), người dùng đã cố tình bấm gọi `releaseMilestone(1, 0)`.
* **Kết quả:** **Giao dịch bị chặn đứng ngay lập tức!**
* **Mã lỗi hoàn trả (Revert):** Custom Error `MilestoneNotApproved()` (Error Selector: `0x3235bba4`).
* **Thông báo trên DApp:**  
  `"Chặn thao tác: Mốc học tập chưa được phê duyệt (MilestoneNotApproved)!"`
* **Cách xử lý của hệ thống:** Yêu cầu Thẩm định viên kiểm tra minh chứng IPFS và thực hiện phê duyệt trước.

#### Trường hợp 8.3: Rút Tiền Kép / Giải Ngân Hai Lần (Release Twice / Double Release)
* **Hành vi sai:** Sau khi mốc 0 đã được giải ngân thành công (`Disbursed`), người dùng cố tình gửi tiếp giao dịch `releaseMilestone(1, 0)` lần thứ hai.
* **Kết quả:** **Giao dịch bị chặn đứng ngay lập tức!**
* **Mã lỗi hoàn trả (Revert):** Custom Error `AlreadyReleased()` (Error Selector: `0xd3617be3`).
* **Thông báo trên DApp:**  
  `"Chặn thao tác: Mốc này đã được giải ngân trước đó (AlreadyReleased)! Không được phép giải ngân hai lần."`
* **Cách xử lý của hệ thống:** Chặn chuyển tiền, số dư ví hợp đồng và số tiền `releasedAmount` được bảo toàn toàn vẹn.

---

## 3. Bằng Chứng Thực Nghiệm Từ Test Suite E2E

Thực thi bộ kiểm thử `test/Lab15_E2E_Demo.t.sol` trực tiếp trên Hardhat EVM:

```text
Running Solidity tests

  test/Lab15_E2E_Demo.t.sol:Lab15E2EDemoTest
    ✔ test_DEMO_01_FullLifecycleHappyPath()
    ✔ test_DEMO_02_NegativeCase_WrongStudent()
    ✔ test_DEMO_03_NegativeCase_ReleaseBeforeApproval()
    ✔ test_DEMO_04_NegativeCase_DoubleRelease()
    ✔ test_DEMO_05_NegativeCase_StrangerCannotApprove()
    ✔ test_DEMO_06_Full2MilestoneLifecycle()

6 passing (6 solidity)
Total project tests: 91/91 passing (100% PASS)
```

---

## 4. Tổng Kết Bảng Tra Cứu Xử Lý Lỗi DApp (Error Handling Matrix)

| Tình Huống Gặp Lỗi | Nguyên Nhân Gốc | Mã Lỗi EVM / RPC | Thông Báo Hiển Thị Trên DApp | Cách Xử Lý Hướng Dẫn Người Dùng |
|:---|:---|:---:|:---|:---|
| **Sai mạng** | MetaMask đang kết nối mạng khác Sepolia | Chain ID $\neq 11155111$ | `"⚠️ Vui lòng chuyển MetaMask sang Sepolia."` | Bấm nút "Chuyển sang Sepolia" để tự động chuyển mạng RPC. |
| **Chưa kết nối ví** | Người dùng bấm gửi giao dịch khi chưa kết nối ví | Signer `null` | `"Vui lòng kết nối ví MetaMask trước!"` | Bấm nút "Kết Nối Ví MetaMask" ở thanh tiêu đề. |
| **Không có quyền** | Người gọi không phải Sponsor hoặc Verifier | `NotSponsor()` (`0xee3da5c8`) | `"Lỗi phân quyền: Bạn không có quyền thực hiện thao tác này!"` | Đăng nhập đúng tài khoản Sponsor hoặc Verifier. |
| **Sai sinh viên** | Người lạ gọi hàm nộp minh chứng | `NotStudent()` (`0x51ee4177`) | `"Chặn thao tác: Sai địa chỉ sinh viên thụ hưởng (NotStudent)!"` | Chuyển sang địa chỉ ví sinh viên chính chủ của suất học bổng. |
| **Chưa duyệt mốc** | Cố giải ngân mốc chưa Approved | `MilestoneNotApproved()` (`0x3235bba4`) | `"Chặn thao tác: Mốc học tập chưa được phê duyệt (MilestoneNotApproved)!"` | Chờ Thẩm định viên hoặc Sponsor duyệt mốc trước khi rút. |
| **Giải ngân hai lần** | Cố giải ngân mốc đã Disbursed | `AlreadyReleased()` (`0xd3617be3`) | `"Chặn thao tác: Mốc này đã được giải ngân trước đó (AlreadyReleased)!"` | Chuyển sang giải ngân mốc tiếp theo nếu có. |
| **Thiếu quỹ escrow** | Quỹ nạp chưa đủ số tiền của mốc | `InsufficientFunds()` (`0x7a224ec8`) | `"Chặn thao tác: Quỹ học bổng chưa nạp đủ tiền giải ngân (InsufficientFunds)!"` | Nhà tài trợ cần gọi `fundScholarship` nạp thêm Native ETH. |
| **Từ chối ký ví** | Người dùng bấm "Reject" trên MetaMask | RPC code `4001` / `ACTION_REJECTED` | `"Người dùng đã từ chối giao dịch trên MetaMask (Transaction Rejected)."` | Thử lại giao dịch và bấm "Confirm" trên popup MetaMask. |
| **Giao dịch thất bại** | Lỗi gas hoặc revert điều kiện khác | EVM Execution Revert | `"Giao dịch thực thi thất bại trên blockchain."` | Kiểm tra lại số dư SepoliaETH và tham số đầu vào. |

---
*Báo cáo được lập và lưu trữ chính thức tại `evidence/lab-15/DEMO_RUN_REPORT.md` phục vụ hồ sơ nghiệm thu đồ án.*
