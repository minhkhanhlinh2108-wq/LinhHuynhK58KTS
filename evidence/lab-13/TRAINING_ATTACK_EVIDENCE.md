# Bằng Chứng Thực Nghiệm Huấn Luyện Tấn Công (Training Attack & Defense Evidence) — Lab 13

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Chuyên đề:** Thực nghiệm tấn công Reentrancy trên Sandbox Training & Gia cố Bảo mật (Hardening)  
> **Thành viên:** Nguyễn Minh Khánh Linh & Trần Thị Như Huỳnh  
> **Thời điểm:** 06/10/2026  

---

## 1. Thiết Lập Tấn Công (Attack Setup)

### A. Môi Trường Huấn Luyện (Isolated Sandbox)
1. **Hợp đồng mục tiêu:** [`contracts/training/VulnerableScholarshipBank.sol`](../../contracts/training/VulnerableScholarshipBank.sol)
   - Chức năng: Nhận tiền gửi (`deposit`) và rút tiền (`withdraw`).
   - Lỗ hổng: External call gửi Native ETH bằng low-level `.call` được gọi **trước khi** cập nhật số dư `balances[msg.sender] = 0`.
2. **Hợp đồng tấn công:** [`contracts/training/AttackerScholarshipBank.sol`](../../contracts/training/AttackerScholarshipBank.sol)
   - Chức năng: Nạp 1.0 ETH vốn mồi, kích hoạt lệnh rút tiền và lợi dụng hook `receive()` để đệ quy gọi lại `withdraw()`.
3. **Hợp đồng gia cố (Hardened):** [`contracts/training/SecureScholarshipBank.sol`](../../contracts/training/SecureScholarshipBank.sol)
   - Lớp 1: Checks-Effects-Interactions (CEI).
   - Lớp 2: Khóa Mutex `ReentrancyGuard` (`nonReentrant`).

### B. Tham Số Khởi Tạo Thực Nghiệm
- **Nhà tài trợ 1 (`donor1`):** Nạp `3.0 ETH`
- **Nhà tài trợ 2 (`donor2`):** Nạp `2.0 ETH`
- **Số dư ngân hàng ban đầu:** `5.0 ETH`
- **Kẻ tấn công (`stranger`):** Cấp vốn mồi `1.0 ETH` vào `AttackerScholarshipBank`
- **Hành động tấn công:** Gọi `attacker.attack{value: 1 ether}()`

---

## 2. Ghi Nhận Số Dư Trước & Sau Attack

### A. Thực Nghiệm Trên `VulnerableScholarshipBank` (Test EXP-01)

| Chỉ Số / Thực Thể | Trước Attack | Sau Khi Nạp Mồi | Sau Attack (Kết thúc 6 vòng) | Biến Động Ròng | Trạng Thái |
|:---|:---:|:---:|:---:|:---:|:---:|
| **Ngân hàng (`VulnerableBank`)** | `5.0 ETH` | `6.0 ETH` | **`0.0 ETH`** | **`-6.0 ETH`** | 🔴 Bị rút sạch 100% |
| **Kẻ tấn công (`AttackerContract`)**| `0.0 ETH` | `0.0 ETH` | **`6.0 ETH`** | **`+6.0 ETH`** | 🔴 Chiếm đoạt +5 ETH lãi |
| **Nhà tài trợ 1 (`donor1`)** | Đã nạp 3.0 ETH | Ghi nhận trong bank | Bị chiếm đoạt | **`-3.0 ETH`** | Thất thoát hoàn toàn |
| **Nhà tài trợ 2 (`donor2`)** | Đã nạp 2.0 ETH | Ghi nhận trong bank | Bị chiếm đoạt | **`-2.0 ETH`** | Thất thoát hoàn toàn |
| **Số lần tái nhập (`attackCount`)** | 0 | 0 | **6 lần** | +6 lần | Đệ quy hoàn tất |

---

## 3. Chứng Minh Contract Vulnerable Training Có Vấn Đề (Proof of Vulnerability)

### Cơ chế khai thác dòng mã:
Trong file [`contracts/training/VulnerableScholarshipBank.sol`](../../contracts/training/VulnerableScholarshipBank.sol#L45-L65):
```solidity
function withdraw() external {
    uint256 amount = balances[msg.sender];
    require(amount > 0, "Insufficient balance");

    // [LỖI NGUY HIỂM TẠI DÒNG 52] External call diễn ra TRƯỚC state update!
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "ETH transfer failed");

    // [QUÁ MUỘN TẠI DÒNG 57]
    balances[msg.sender] = 0;
    ...
}
```

1. Tại vòng 1, `balances[attacker] = 1 ETH`. Lệnh `call{value: 1 ether}("")` được gửi sang `AttackerScholarshipBank`.
2. EVM chuyển quyền điều khiển sang hàm `receive()` của Attacker.
3. Khi này dòng 57 `balances[msg.sender] = 0` **chưa từng được chạy**.
4. Hàm `receive()` của Attacker lập tức kích hoạt `targetBank.withdraw()`.
5. Ngân hàng kiểm tra `balances[attacker]` vẫn là `1 ETH > 0`, tiếp tục gửi thêm 1 ETH.
6. Chu trình này lặp lại đúng 6 lần cho đến khi số dư trong ngân hàng còn `0 ETH`.
7. **Hậu quả:** 5 ETH của nhà tài trợ bị đánh cắp hoàn toàn.

---

## 4. Chạy Phiên Bản Đã Sửa / Hardened (`SecureScholarshipBank`)

Nhóm tiến hành kiểm thử trên hợp đồng [`contracts/training/SecureScholarshipBank.sol`](../../contracts/training/SecureScholarshipBank.sol) dưới 2 cơ chế phòng thủ:

### A. Cơ chế 1: Checks-Effects-Interactions (Test EXP-02)
- Hàm `withdrawCEI()` cập nhật `balances[msg.sender] = 0` **trước** lệnh `call`.
- Khi `receive()` của attacker tái nhập gọi lại `withdrawCEI()`, bước kiểm tra `require(amount > 0)` đọc giá trị `0` và lập tức ném lỗi:
  ```text
  Reverted with: Insufficient balance
  ```
- **Số dư sau thực nghiệm:**
  - `SecureScholarshipBank`: **`5.0 ETH`** (Bảo toàn 100%).
  - `AttackerContract`: **`1.0 ETH`** (Chỉ rút lại vốn gốc của chính mình).
  - Lãi chiếm đoạt: **`0 ETH`**.

### B. Cơ chế 2: Khóa Mutex ReentrancyGuard (Test EXP-03)
- Hàm `withdraw()` gắn modifier `nonReentrant`.
- Biến trạng thái `_status` được đặt thành `_ENTERED` ngay khi bước vào hàm.
- Khi hook `receive()` của attacker gọi lại `withdraw()`, modifier phát hiện `_status == _ENTERED` và lập tức ném lỗi:
  ```text
  Reverted with: ReentrancyGuard: reentrant call
  ```
- **Số dư sau thực nghiệm:**
  - `SecureScholarshipBank`: **`5.0 ETH`** (Bảo toàn 100%).
  - `AttackerContract`: **`1.0 ETH`** (Chỉ rút lại vốn gốc của chính mình).
  - Lãi chiếm đoạt: **`0 ETH`**.

---

## 5. Chứng Minh Attack Không Còn Thực Hiện Được

### Bảng So Sánh Số Dư Sau Cuộc Tấn Công

| Tiêu Chí | Vulnerable Bank (Chưa sửa) | Secure Bank (CEI Patch) | Secure Bank (Mutex Guard Patch) |
|:---|:---:|:---:|:---:|
| **Số dư ngân hàng sau attack** | `0.0 ETH` 🔴 | `5.0 ETH` 🟢 | `5.0 ETH` 🟢 |
| **Tiền bị kẻ tấn công chiếm đoạt** | `5.0 ETH` 🔴 | `0.0 ETH` 🟢 | `0.0 ETH` 🟢 |
| **Số lần tái nhập thành công** | 6 lần | 0 lần (Revert tại vòng 2) | 0 lần (Revert tại vòng 2) |
| **Mã lỗi chặn tái nhập** | Không có (Success) | `Insufficient balance` | `ReentrancyGuard: reentrant call` |

---

## 6. Bộ Negative Tests Cho Hợp Đồng Lõi `ProjectCore.sol`

Nhóm đã kiểm chứng 5 kịch bản tiêu cực trọng yếu để chứng minh `ProjectCore.sol` hoàn toàn an toàn:

1. **NEG-01: Release trước approval**
   - Mốc ở trạng thái `Pending`: Revert `MilestoneNotApproved()` ✅
   - Mốc ở trạng thái `Submitted`: Revert `MilestoneNotApproved()` ✅
2. **NEG-02: Release hai lần**
   - Giải ngân lần 1 thành công (`Disbursed`).
   - Giải ngân lần 2: Revert `AlreadyReleased()` ✅
3. **NEG-03: Wrong student**
   - Địa chỉ ví lạ nộp minh chứng: Revert `NotStudent()` ✅
4. **NEG-04: Unauthorized caller**
   - Địa chỉ lạ bấm nút giải ngân: Revert `NotStudent()` ✅
5. **NEG-05: Insufficient funds**
   - Suất học bổng chưa nạp tiền (fundedAmount = 0): Revert `InsufficientFunds()` ✅

---

## 7. Bằng Chứng Terminal Thực Thi
```text
Running Solidity tests

  test/Lab13_SecurityExperiments.t.sol:Lab13SecurityExperimentsTest
    ✔ test_NEG05_ProjectCore_InsufficientFunds_Reverts()
    ✔ test_NEG04_ProjectCore_UnauthorizedCaller_Reverts()
    ✔ test_NEG03_ProjectCore_WrongStudent_Reverts()
    ✔ test_NEG02_ProjectCore_DoubleRelease_Reverts()
    ✔ test_NEG01_ProjectCore_ReleaseBeforeApproval_Reverts()
    ✔ test_EXP04_SecureBank_UnhandledReentrancyRevertsTransfer()
    ✔ test_EXP03_SecureBank_ReentrancyGuard_PreventsReentrancy()
    ✔ test_EXP02_SecureBank_CEI_PreventsReentrancy()
    ✔ test_EXP01_VulnerableBank_DrainedByReentrancy()
    ✔ test_AUDIT06_ProjectCore_ReentrancyAttack_Defeated()
    ✔ test_AUDIT05_ProjectCore_ReleaseBeforeApprovalBlocked()
    ✔ test_AUDIT04_ProjectCore_WrongStudentBlocked()
    ✔ test_AUDIT03_ProjectCore_DoubleReleaseBlocked()
    ✔ test_AUDIT02_ProjectCore_StateUpdateBeforeCall_CEI()
    ✔ test_AUDIT01_ProjectCore_HasExternalCall_ToStudent()

15 passing (15 solidity)
```
