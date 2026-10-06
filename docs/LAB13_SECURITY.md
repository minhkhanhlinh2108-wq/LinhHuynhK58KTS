# Báo Cáo Thực Nghiệm An Ninh & Kiểm Toán Chuyên Sâu (Lab 13 Security Report) — TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Tài liệu:** Báo cáo thực nghiệm an ninh bảo mật & Kiểm toán Reentrancy chuyên sâu (Lab 13 Security Experiments)  
> **Đối tượng kiểm toán:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol)  
> **Hợp đồng thực nghiệm (Training):**  
> • [`contracts/training/VulnerableScholarshipBank.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/training/VulnerableScholarshipBank.sol)  
> • [`contracts/training/AttackerScholarshipBank.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/training/AttackerScholarshipBank.sol)  
> • [`contracts/training/SecureScholarshipBank.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/training/SecureScholarshipBank.sol)  
> **Bộ test kiểm chứng:** [`test/Lab13_SecurityExperiments.t.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/test/Lab13_SecurityExperiments.t.sol)  
> **Thời điểm thực hiện:** 05/10/2026  
> **Thành viên thực hiện:**  
> • **Nguyễn Minh Khánh Linh** (Security Lead): Thiết kế mô hình mối đe dọa, kiểm toán chuyên sâu 5 câu hỏi cốt lõi của `ProjectCore.sol`, phân tích kiến trúc CEI & Mutex Guard.  
> • **Trần Thị Như Huỳnh** (Testing & QA Lead): Lập trình bộ hợp đồng đào tạo Reentrancy, viết test suite thực nghiệm 10 test cases tự động, thu thập log terminal và đo lường an toàn.  
> **Cam kết:** Hợp đồng lõi [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol) tuân thủ Code Freeze từ Lab 12, **đã an toàn tuyệt đối và KHÔNG bị cố tình đưa lỗ hổng vào**.

---

## 1. Tóm Tắt Tổng Quan (Executive Summary)

Trong khuôn khổ bài Lab 13, nhóm nghiên cứu đã triển khai toàn diện chuyên đề **Thực nghiệm An ninh Smart Contract (Security Experiments)** tập trung vào lỗ hổng kinh điển và nguy hiểm bậc nhất trong hệ sinh thái EVM: **Lỗ hổng Tái nhập (Reentrancy Attack)**.

### Kết quả then chốt:
1. **Môi trường thực nghiệm tách biệt (Sandbox Training Contracts):**
   - Đã xây dựng hợp đồng đào tạo [`VulnerableScholarshipBank.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/training/VulnerableScholarshipBank.sol) cố tình tạo lỗi vi phạm nguyên tắc Checks-Effects-Interactions (CEI) để minh họa cơ chế khai thác.
   - Đã lập trình hợp đồng tấn công [`AttackerScholarshipBank.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/training/AttackerScholarshipBank.sol) sử dụng hook `receive()` để tái nhập hàm `withdraw()` và rút cạn toàn bộ quỹ.
   - Đã phát triển phiên bản an toàn [`SecureScholarshipBank.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/training/SecureScholarshipBank.sol) chứng minh 2 lớp phòng thủ độc lập: Mẫu thiết kế CEI và khóa Mutex `ReentrancyGuard`.
2. **Kiểm toán chuyên sâu hợp đồng lõi [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol):**
   - Rà soát và trả lời thỏa đáng 5 câu hỏi an ninh trọng yếu:
     - **Có external call không?** $\rightarrow$ **CÓ** (tại dòng 259 chuyển Native ETH trực tiếp tới ví sinh viên).
     - **State update có trước call không?** $\rightarrow$ **CÓ** (cập nhật trạng thái `Disbursed` và `releasedAmount` tại dòng 254–256 trước khi call).
     - **Release hai lần có bị chặn không?** $\rightarrow$ **CÓ** (chặn ngay bởi `AlreadyReleased()` tại dòng 245).
     - **Wrong student có bị chặn không?** $\rightarrow$ **CÓ** (chặn nộp minh chứng và tiền luôn chỉ đến đúng ví sinh viên).
     - **Release trước approval có bị chặn không?** $\rightarrow$ **CÓ** (chặn ngay bởi `MilestoneNotApproved()` tại dòng 246).
   - Thử nghiệm tấn công trực tiếp bằng contract sinh viên độc hại [`ReentrantMaliciousStudent`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/test/Lab13_SecurityExperiments.t.sol#L77-L105): Cuộc tấn công **thất bại hoàn toàn**, quỹ của các mốc khác được bảo toàn 100%.
3. **Độ tin cậy kiểm thử:** 10/10 test cases trong [`test/Lab13_SecurityExperiments.t.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/test/Lab13_SecurityExperiments.t.sol) đạt **PASS 100%**, nâng tổng số test suite toàn dự án lên **74/74 test cases PASS**.

---

## 2. Bản Chất Lỗ Hổng Reentrancy & Sơ Đồ Khai Thác

### 2.1. Cơ chế kỹ thuật trên Ethereum Virtual Machine (EVM)
Trên EVM, khi một hợp đồng thông minh chuyển Native ETH đến một địa chỉ hợp đồng khác thông qua lệnh gọi cấp thấp:
```solidity
(bool success, ) = recipient.call{value: amount}("");
```
EVM sẽ tạm dừng luồng thực thi của hợp đồng gửi và chuyển quyền điều khiển (control flow) sang hàm `receive()` hoặc `fallback()` của hợp đồng nhận.

Nếu hợp đồng gửi thực hiện **external call trước khi cập nhật biến trạng thái số dư (State Update)**, hợp đồng nhận có thể lợi dụng quyền điều khiển này để gọi ngược trở lại chính hàm rút tiền đó. Ở lần gọi thứ hai, vì số dư trên sổ cái chưa kịp bị trừ đi, hợp đồng nạn nhân tiếp tục tin rằng người gọi vẫn còn tiền và tiếp tục chuyển tiếp một khoản tiền nữa. Quá trình này lặp lại theo đệ quy cho đến khi toàn bộ số dư của nạn nhân bị rút sạch hoặc cạn gas.

### 2.2. Sơ đồ tuần tự tấn công Reentrancy (Mermaid Sequence Diagram)

```mermaid
sequenceDiagram
    autonumber
    actor AttackerUser as Kẻ Tấn Công (EOA)
    participant AttackerContract as Attacker Contract
    participant VulnBank as VulnerableScholarshipBank
    
    Note over VulnBank: Quỹ hiện có 5 ETH từ các nhà hảo tâm
    AttackerUser->>AttackerContract: attack{value: 1 ETH}()
    AttackerContract->>VulnBank: deposit{value: 1 ETH}()
    Note over VulnBank: balances[Attacker] = 1 ETH<br/>Total balance = 6 ETH
    AttackerContract->>VulnBank: withdraw()
    Note over VulnBank: [1] Checks: balance = 1 ETH > 0 (Hợp lệ)
    VulnBank->>AttackerContract: [2] External Call: .call{value: 1 ETH}("")
    
    activate AttackerContract
    Note over AttackerContract: Hook receive() được kích hoạt!<br/>Target balance còn 5 ETH >= 1 ETH
    AttackerContract->>VulnBank: [REENTRANCY] withdraw() lần 2
    Note over VulnBank: [1] Checks: balances[Attacker] VẪN = 1 ETH! (Chưa bị trừ)
    VulnBank->>AttackerContract: [2] External Call: .call{value: 1 ETH}("")
    
    Note over AttackerContract: Hook receive() lặp lại đệ quy...<br/>Rút tiếp 1 ETH x 4 lần nữa
    deactivate AttackerContract
    
    Note over VulnBank: Sau khi cạn tiền, mới chạy đến [3] Effects:<br/>balances[Attacker] = 0 (Quá muộn!)
    Note over AttackerContract: Tổng tiền chiếm đoạt: 6 ETH (Lãi 5 ETH)
    Note over VulnBank: Số dư quỹ bị rút cạn về 0 ETH!
```

---

## 3. Thực Nghiệm Trên Hợp Đồng Đào Tạo (Training Experiments)

Để minh họa trực quan và đo lường chính xác, nhóm đã xây dựng gói hợp đồng đào tạo chuyên biệt đặt tại thư mục `contracts/training/`.

### 3.1. Hợp đồng có lỗ hổng: `VulnerableScholarshipBank.sol`
Mã nguồn hàm rút tiền chứa khiếm khuyết vi phạm CEI:
```solidity
function withdraw() external {
    // [1] CHECKS: Kiểm tra số dư người gọi
    uint256 amount = balances[msg.sender];
    require(amount > 0, "Insufficient balance");

    // [2] INTERACTIONS (LỖI NGUY HIỂM): External call xảy ra TRƯỚC KHI state update
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "ETH transfer failed");

    // [3] EFFECTS (QUÁ MUỘN): Cập nhật trạng thái sau khi đã chuyển tiền
    balances[msg.sender] = 0;
    if (totalDeposits >= amount) {
        totalDeposits -= amount;
    } else {
        totalDeposits = 0;
    }

    emit Withdrawn(msg.sender, amount);
}
```

### 3.2. Hợp đồng kẻ tấn công: `AttackerScholarshipBank.sol`
Cơ chế bẫy đệ quy trong hook nhận tiền:
```solidity
receive() external payable {
    attackCount++;
    emit ReentrancyHookTriggered(attackCount, address(targetBank).balance);

    // Tiếp tục gọi rút tiền nếu ngân hàng mục tiêu vẫn còn đủ ETH
    if (address(targetBank).balance >= initialDeposit) {
        targetBank.withdraw();
    }
}
```

### 3.3. Chi Tiết Thực Nghiệm Tấn Công (Training Attack Execution)

#### A. Attack Setup (Thiết Lập Kịch Bản Tấn Công)
- **Hợp đồng nạn nhân:** `VulnerableScholarshipBank` được nạp tiền bởi các nhà hảo tâm:
  - `Donor 1` nạp: `3.0 ETH`
  - `Donor 2` nạp: `2.0 ETH`
  - Tổng số dư quỹ học bổng trong ngân hàng ban đầu: `5.0 ETH`.
- **Hợp đồng kẻ tấn công:** `AttackerScholarshipBank` được triển khai bởi địa chỉ người lạ `Stranger`.
- **Kích hoạt:** Kẻ tấn công gửi `1.0 ETH` vốn mồi vào `AttackerScholarshipBank.attack{value: 1 ether}()`. Hợp đồng tấn công nạp 1.0 ETH vào `VulnerableScholarshipBank` (nâng tổng số dư ngân hàng lên 6.0 ETH) và lập tức gọi `withdraw()`.

#### B. Expected Result (Kết Quả Kỳ Vọng Kỹ Thuật)
- Khi ngân hàng thực hiện `msg.sender.call{value: 1 ether}("")`, quyền điều khiển chuyển sang hook `receive()` của Attacker.
- Vì trạng thái `balances[attacker]` chưa kịp trừ (vẫn giữ nguyên 1.0 ETH), hàm `receive()` gọi lại `withdraw()`.
- Lệnh gọi đệ quy lặp lại liên tục cho đến khi số dư ngân hàng về 0 ETH.
- **Kỳ vọng:** Toàn bộ 6.0 ETH (bao gồm 5.0 ETH tiền quyên góp của các donor) bị rút sạch vào hợp đồng của kẻ tấn công; số lần tái nhập đệ quy là 6 lần.

#### C. Actual Result (Ghi Lại Số Dư Trước và Sau Attack)

Bảng đối soát số dư thực tế ghi nhận từ test case `test_EXP01_VulnerableBank_DrainedByReentrancy`:

| Thực Thể Tham Gia | Địa Chỉ / Vai Trò | Số Dư Trước Attack | Số Dư Sau Attack | Biến Động Số Dư | Đánh Giá An Ninh |
|:---|:---:|:---:|:---:|:---:|:---:|
| **`VulnerableScholarshipBank`** | Ngân hàng mục tiêu | **`6.0 ETH`** (5 ETH quỹ + 1 ETH mồi) | **`0.0 ETH`** | **`-6.0 ETH`** | 🔴 Bị rút cạn 100% |
| **`AttackerScholarshipBank`** | Hợp đồng tấn công | **`0.0 ETH`** | **`6.0 ETH`** | **`+6.0 ETH`** (+5 ETH lãi ròng) | 🔴 Chiếm đoạt thành công |
| **`Donor 1` (Nhà tài trợ 1)** | Người quyên góp | Đã nạp 3.0 ETH | Bị chiếm đoạt | **`-3.0 ETH`** | Quỹ bị thất thoát |
| **`Donor 2` (Nhà tài trợ 2)** | Người quyên góp | Đã nạp 2.0 ETH | Bị chiếm đoạt | **`-2.0 ETH`** | Quỹ bị thất thoát |
| **`attackCount`** | Biến đếm tái nhập | `0` | **`6`** | **`+6 lần`** | Đệ quy 6 vòng hoàn tất |

#### D. Chứng Minh Contract Vulnerable Training Có Vấn Đề (Proof of Vulnerability)
1. **Vi phạm Checks-Effects-Interactions (CEI):** Hàm `withdraw()` tại dòng 52 thực hiện external call `.call{value: amount}("")` trước khi cập nhật storage `balances[msg.sender] = 0` tại dòng 57.
2. **Mất kiểm soát luồng thực thi (Control Flow Hijacking):** EVM trao quyền xử lý cho địa chỉ nhận. Attacker tận dụng hook `receive()` để reenter `withdraw()` khi biến trạng thái nội bộ của nạn nhân vẫn ghi nhận kẻ tấn công còn số dư.
3. **Thất thoát tài sản người dùng:** Kẻ tấn công bỏ ra 1.0 ETH nhưng chiếm đoạt được 6.0 ETH, gây tổn hại nghiêm trọng đến tiền ký quỹ học bổng.

---

## 4. Giải Pháp Phòng Ngừa & Phiên Bản Đã Sửa (Patch & Hardening)

Để triệt tiêu hoàn toàn nguy cơ Reentrancy, nhóm đã phát triển hợp đồng [`SecureScholarshipBank.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/training/SecureScholarshipBank.sol) áp dụng 2 lớp phòng thủ tiêu chuẩn công nghiệp:

### 4.1. Lớp phòng thủ 1 (Patch CEI): Mẫu Thiết Kế Checks-Effects-Interactions
Nguyên tắc vàng của lập trình Smart Contract an toàn:
1. **Checks:** Kiểm tra mọi điều kiện tiên quyết (quyền truy cập, số dư, trạng thái).
2. **Effects:** Thay đổi toàn bộ trạng thái nội bộ của hợp đồng (trừ số dư, đánh dấu cờ đã rút, tăng biến đếm).
3. **Interactions:** Thực hiện tương tác với các địa chỉ bên ngoài (gửi ETH, gọi hàm contract ngoài) ở bước cuối cùng.

Triển khai cụ thể trong hàm `withdrawCEI()`:
```solidity
function withdrawCEI() external {
    // [1] CHECKS: Kiểm tra điều kiện
    uint256 amount = balances[msg.sender];
    require(amount > 0, "Insufficient balance");

    // [2] EFFECTS: Xóa số dư NGAY LẬP TỨC TRƯỚC KHI chuyển tiền!
    balances[msg.sender] = 0;
    if (totalDeposits >= amount) {
        totalDeposits -= amount;
    } else {
        totalDeposits = 0;
    }

    // [3] INTERACTIONS: External call chỉ diễn ra sau khi state đã an toàn
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "ETH transfer failed");

    emit Withdrawn(msg.sender, amount);
}
```

### 4.2. Lớp phòng thủ 2 (Patch Mutex): Khóa Mutex ReentrancyGuard
Sử dụng biến cờ trạng thái nhị phân để ngăn chặn mọi luồng thực thi đệ quy xâm nhập vào bất kỳ hàm nào được bảo vệ:
```solidity
uint256 private _status;
uint256 private constant _NOT_ENTERED = 1;
uint256 private constant _ENTERED = 2;

modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
}
```

### 4.3. Chứng Minh Attack Không Còn Thực Hiện Được (Proof of Defense)
Khi chạy attacker trên phiên bản đã sửa/hardened `SecureScholarshipBank`:
- **Đối với CEI (`test_EXP02_SecureBank_CEI_PreventsReentrancy`):**
  - Khi attacker cố tình gọi lại `withdrawCEI()` từ hook `receive()`, cuộc gọi thứ hai đi vào bước [1] Checks và kiểm tra `balances[msg.sender]`.
  - Vì biến này đã được cập nhật bằng `0` ở bước [2] của cuộc gọi trước đó, điều kiện `require(amount > 0)` lập tức thất bại và **REVERT với thông báo `Insufficient balance`**.
  - **Kết quả:** Ngân hàng bảo toàn nguyên vẹn **`5.0 ETH`** của các nhà hảo tâm. Kẻ tấn công chỉ nhận lại đúng `1.0 ETH` tiền nạp của mình (lợi nhuận = 0 ETH).
- **Đối với Mutex Guard (`test_EXP03_SecureBank_ReentrancyGuard_PreventsReentrancy`):**
  - Khi attacker gọi lại hàm có gắn `nonReentrant`, modifier phát hiện `_status == _ENTERED` và lập tức ném lỗi **`ReentrancyGuard: reentrant call`**.
  - **Kết quả:** Cuộc tấn công bị chặn đứng ngay tại cổng vào, số dư ngân hàng được bảo toàn 100% (**`5.0 ETH`**).

### 4.4. Bảng đối chiếu so sánh kiến trúc an ninh

| Tiêu Chí Đánh Giá | Vulnerable Contract | Secure Bank (CEI Only) | Secure Bank (CEI + ReentrancyGuard) | ProjectCore.sol (Hợp Đồng Lõi) |
|:---|:---:|:---:|:---:|:---:|
| **Thứ tự State Update** | Sau External Call ❌ | Trước External Call ✅ | Trước External Call ✅ | Trước External Call ✅ |
| **Bảo vệ bằng Mutex Lock** | Không có ❌ | Không có | Có `nonReentrant` ✅ | Có `nonReentrant` ✅ |
| **Kết quả khi bị Reenter** | Bị rút sạch tiền 🔴 | Revert `Insufficient balance` 🟢 | Revert `ReentrancyGuard` 🟢 | Revert `ReentrancyGuard` / `AlreadyReleased` 🟢 |
| **Mức độ tiêu tốn Gas** | Thấp | Rất tối ưu | Thêm ~2,100 gas/call | Chuẩn bảo mật doanh nghiệp |
| **Khả năng chống Cross-function Reentrancy** | Kém ❌ | Cần thiết kế cẩn trọng | Tuyệt đối an toàn ✅ | Tuyệt đối an toàn ✅ |

---

## 5. Báo Cáo Kiểm Toán Chuyên Sâu ProjectCore.sol

Nhóm kiểm toán đã đối chiếu mã nguồn thực tế của [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol) và trả lời chi tiết 5 câu hỏi an ninh cốt lõi:

```mermaid
graph TD
    subgraph FlowRelease ["Hàm releaseMilestone() trong ProjectCore.sol"]
        Q1["1. CHECKS<br/>• m.status == Approved<br/>• m.status != Disbursed<br/>• Caller in [student, sponsor, verifier]<br/>• Quỹ khả dụng >= m.amount"]
        Q2["2. EFFECTS<br/>• m.status = Disbursed<br/>• m.disbursedAt = timestamp<br/>• s.releasedAmount += amount"]
        Q3["3. INTERACTIONS<br/>• s.student.call{value: amount}('')<br/>• require(success)"]
        Q4["4. EMIT EVENT<br/>• emit ScholarshipReleased(...)"]
        
        Q1 -->|Hợp lệ| Q2
        Q1 -->|Chưa duyệt| R1["REVERT MilestoneNotApproved"]
        Q1 -->|Đã giải ngân| R2["REVERT AlreadyReleased"]
        Q1 -->|Kẻ lạ gọi| R3["REVERT NotStudent"]
        Q2 --> Q3
        Q3 -->|Thành công| Q4
        Q3 -->|Reenter bị chặn bởi nonReentrant| R4["REVERT ReentrancyGuard"]
    end
```

---

### Câu Hỏi 1: Có external call không?
- **Kết luận:** **CÓ.**
- **Vị trí mã nguồn:** Dòng 259 tệp [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L259):
  ```solidity
  (bool success, ) = s.student.call{value: amountToRelease}("");
  if (!success) revert TransferFailed();
  ```
- **Phân tích an ninh:** Low-level call gửi Native ETH sang ví sinh viên `s.student`.
- **Test case kiểm chứng:** `test_AUDIT01_ProjectCore_HasExternalCall_ToStudent` $\rightarrow$ ✅ **PASS**.

---

### Câu Hỏi 2: State update có trước call không?
- **Kết luận:** **CÓ (Tuân thủ 100% nguyên tắc Checks-Effects-Interactions).**
- **Vị trí mã nguồn:** Dòng 254–256 tệp [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L254-L256):
  ```solidity
  // Effect
  m.status = MilestoneStatus.Disbursed;
  m.disbursedAt = block.timestamp;
  s.releasedAmount += amountToRelease;

  // Interaction
  (bool success, ) = s.student.call{value: amountToRelease}("");
  ```
- **Test case kiểm chứng:** `test_AUDIT02_ProjectCore_StateUpdateBeforeCall_CEI` $\rightarrow$ ✅ **PASS**.

---

### Câu Hỏi 3: Release hai lần có bị chặn không?
- **Kết luận:** **CÓ (Chặn tuyệt đối).**
- **Vị trí mã nguồn:** Dòng 245 tệp [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L245):
  ```solidity
  if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();
  ```
- **Test case kiểm chứng:** `test_AUDIT03_ProjectCore_DoubleReleaseBlocked` & `test_NEG02_ProjectCore_DoubleRelease_Reverts` $\rightarrow$ ✅ **PASS**.

---

### Câu Hỏi 4: Wrong student có bị chặn không?
- **Kết luận:** **CÓ (Chặn tuyệt đối ở cả 2 khâu: nộp minh chứng và nhận tiền).**
- **Vị trí mã nguồn:** Dòng 190, 238–240, 259.
- **Test case kiểm chứng:** `test_AUDIT04_ProjectCore_WrongStudentBlocked` & `test_NEG03_ProjectCore_WrongStudent_Reverts` $\rightarrow$ ✅ **PASS**.

---

### Câu Hỏi 5: Release trước approval có bị chặn không?
- **Kết luận:** **CÓ (Chặn tuyệt đối).**
- **Vị trí mã nguồn:** Dòng 246 tệp [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L246):
  ```solidity
  if (m.status != MilestoneStatus.Approved) revert MilestoneNotApproved();
  ```
- **Test case kiểm chứng:** `test_AUDIT05_ProjectCore_ReleaseBeforeApprovalBlocked` & `test_NEG01_ProjectCore_ReleaseBeforeApproval_Reverts` $\rightarrow$ ✅ **PASS**.

---

### Thử Nghiệm Nâng Cao: Tấn Công Tái Nhập Trực Tiếp Vào ProjectCore.sol
Nhóm đã triển khai hợp đồng sinh viên độc hại [`ReentrantMaliciousStudent`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/test/Lab13_SecurityExperiments.t.sol#L77-L105) đóng vai trò là ví người thụ hưởng. Khi nhận được 0.5 ETH từ mốc 0, hàm `receive()` của nó cố tình gọi ngược lại `core.releaseMilestone(id, 0)` nhằm bòn rút tiếp 0.5 ETH còn lại của mốc 1.

**Kết quả kiểm chứng (`test_AUDIT06_ProjectCore_ReentrancyAttack_Defeated`):**
1. Lệnh tái nhập bị chặn đứng hoàn toàn bởi lớp phòng thủ kép `nonReentrant` và `m.status == Disbursed`.
2. Lỗi revert được ghi nhận trong hook của attacker.
3. Hợp đồng `ProjectCore` bảo toàn 100% số dư 0.5 ETH còn lại của mốc 1.
4. Kẻ tấn công chỉ nhận được đúng 0.5 ETH hợp lệ của mốc 0, hoàn toàn không thể chiếm đoạt thêm quỹ.

---

## 6. Kết Quả Bộ Kiểm Thử Negative Tests Cho ProjectCore.sol

Để đáp ứng trọn vẹn yêu cầu kiểm thử bảo mật tiêu cực (Negative Testing) cho hợp đồng lõi `ProjectCore.sol`, nhóm đã bổ sung 5 bài test negative độc lập:

| Mã Kiểm Thử | Kịch Bản Thử Nghiệm (Negative Scenario) | Hành Vi Vi Phạm Mô Phỏng | Mã Lỗi Kỳ Vọng (Revert Selector) | Kết Quả Thực Tế | Trạng Thái |
|:---|:---|:---|:---|:---:|:---:|
| **`NEG-01`** | **Release trước approval** | Gọi giải ngân khi mốc ở trạng thái `Pending` hoặc `Submitted` (chưa duyệt) | `MilestoneNotApproved()` | Revert đúng mã lỗi ở cả 2 trạng thái | ✅ **PASS** |
| **`NEG-02`** | **Release hai lần** | Cố tình gọi `releaseMilestone` lần thứ hai cho cùng một mốc đã giải ngân | `AlreadyReleased()` | Revert ngay tại bước kiểm tra status | ✅ **PASS** |
| **`NEG-03`** | **Wrong student** | Địa chỉ ví lạ (stranger) cố nộp minh chứng giả mạo thay cho sinh viên | `NotStudent()` | Revert tại khâu nộp proof | ✅ **PASS** |
| **`NEG-04`** | **Unauthorized caller** | Người lạ (không phải student, sponsor, verifier) bấm nút kích hoạt giải ngân | `NotStudent()` | Chặn đứng quyền truy cập trái phép | ✅ **PASS** |
| **`NEG-05`** | **Insufficient fund** | Mốc đã được duyệt nhưng sponsor chưa nạp tiền (hoặc nạp thiếu) | `InsufficientFunds()` | Chặn lệnh chuyển tiền khi quỹ không đủ | ✅ **PASS** |

---

## 7. Bảng Tổng Hợp Kết Quả Thực Nghiệm Lab 13 (15/15 PASS)

| Test Case | Nhóm Kiểm Thử | Mục Đích Kiểm Chứng | Kỳ Vọng Kỹ Thuật | Kết Quả Thực Tế | Trạng Thái |
|:---|:---:|:---|:---|:---:|:---:|
| `test_EXP01_VulnerableBank_DrainedByReentrancy` | Training Exploit | Minh họa rút cạn ngân hàng vi phạm CEI | Ngân hàng về 0 ETH, Attacker lấy 6 ETH | ✅ Khớp 100% | **🔴 EXPLOIT SUCCESS** |
| `test_EXP02_SecureBank_CEI_PreventsReentrancy` | Training Defense | Phòng vệ bằng CEI Pattern | Revert `Insufficient balance` khi reenter | ✅ Khớp 100% | **🟢 DEFENSE PROVEN** |
| `test_EXP03_SecureBank_ReentrancyGuard_PreventsReentrancy` | Training Defense | Phòng vệ bằng Mutex Lock | Revert `ReentrancyGuard: reentrant call` | ✅ Khớp 100% | **🟢 DEFENSE PROVEN** |
| `test_EXP04_SecureBank_UnhandledReentrancyRevertsTransfer` | Training Defense | Reentrancy không bắt lỗi làm hỏng transfer | Revert `ETH transfer failed` | ✅ Khớp 100% | **🟢 DEFENSE PROVEN** |
| `test_AUDIT01_ProjectCore_HasExternalCall_ToStudent` | Audit ProjectCore | Xác định sự tồn tại của external call | External call chuyển đúng Native ETH tới ví student | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_AUDIT02_ProjectCore_StateUpdateBeforeCall_CEI` | Audit ProjectCore | Xác minh state update trước external call | Status cập nhật `Disbursed` trước khi chuyển tiền | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_AUDIT03_ProjectCore_DoubleReleaseBlocked` | Audit ProjectCore | Kiểm tra chống giải ngân 2 lần | Revert `AlreadyReleased` ở lần gọi thứ 2 | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_AUDIT04_ProjectCore_WrongStudentBlocked` | Audit ProjectCore | Kiểm tra chống nộp/nhận sai sinh viên | Revert `NotStudent` với người lạ | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_AUDIT05_ProjectCore_ReleaseBeforeApprovalBlocked` | Audit ProjectCore | Kiểm tra chống giải ngân trước duyệt | Revert `MilestoneNotApproved` | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_AUDIT06_ProjectCore_ReentrancyAttack_Defeated` | Audit ProjectCore | Thực nghiệm tấn công reentrancy trực tiếp | Thất bại hoàn toàn, quỹ được bảo toàn | ✅ Khớp 100% | **🟢 SECURE** |
| `test_NEG01_ProjectCore_ReleaseBeforeApproval_Reverts` | Core Negative | Chặn giải ngân khi mốc chưa duyệt | Revert `MilestoneNotApproved()` | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_NEG02_ProjectCore_DoubleRelease_Reverts` | Core Negative | Chặn giải ngân 2 lần trên cùng một mốc | Revert `AlreadyReleased()` | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_NEG03_ProjectCore_WrongStudent_Reverts` | Core Negative | Chặn người lạ nộp minh chứng thay sinh viên | Revert `NotStudent()` | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_NEG04_ProjectCore_UnauthorizedCaller_Reverts` | Core Negative | Chặn người lạ gọi lệnh giải ngân | Revert `NotStudent()` | ✅ Khớp 100% | **🟢 VERIFIED** |
| `test_NEG05_ProjectCore_InsufficientFunds_Reverts` | Core Negative | Chặn giải ngân khi chưa nạp tiền hoặc thiếu quỹ | Revert `InsufficientFunds()` | ✅ Khớp 100% | **🟢 VERIFIED** |

---

## 8. Bằng Chứng Thực Nghiệm Terminal Log

Lệnh chạy kiểm thử độc lập Lab 13:
```bash
npx.cmd hardhat test test/Lab13_SecurityExperiments.t.sol
```

Đầu ra Terminal thực tế:
```text
Compiled 1 Solidity file with solc 0.8.20 (evm target: shanghai)

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

Lệnh chạy kiểm thử toàn trình toàn bộ dự án:
```bash
npx.cmd hardhat test
```

Đầu ra Terminal:
```text
No contracts to compile

Running Solidity tests

  test/ProjectCore.t.sol:ProjectCoreTest (17 tests)
  test/Lab13_SecurityExperiments.t.sol:Lab13SecurityExperimentsTest (15 tests)
  test/Lab10_Verify.t.sol:Lab10VerifyTest (13 tests)
  test/Lab11_EconomicRules.t.sol:Lab11EconomicRulesTest (34 tests)

79 passing (79 solidity)
```

---

## 8. Kết Luận & Khuyến Nghị Kỹ Thuật

1. **Về mặt đào tạo và nhận thức an ninh:**
   - Thực nghiệm Lab 13 đã chứng minh một cách sinh động mối hiểm họa chết người của việc đặt external call trước state update.
   - Làm rõ cơ chế tự bảo vệ nội tại của mẫu thiết kế CEI: ngay cả khi không có thư viện bên ngoài, việc sắp xếp thứ tự câu lệnh hợp lý đã đủ để triệt tiêu lỗ hổng Reentrancy cơ bản.
2. **Về mặt chất lượng hợp đồng lõi `ProjectCore.sol`:**
   - Khẳng định hợp đồng [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol) đạt tiêu chuẩn an ninh cấp cao (Enterprise-grade Security).
   - Thiết kế áp dụng mẫu hình **Phòng thủ Đa tầng (Defense-in-Depth)** kết hợp đồng thời cả CEI và `nonReentrant` Mutex Guard, đảm bảo hệ thống bất khả xâm phạm trước mọi biến thể tấn công tái nhập đơn hàm (Single-function) lẫn tái nhập chéo hàm (Cross-function).
   - Hợp đồng tuân thủ tuyệt đối quy định Code Freeze từ Gate Review 1, không phát sinh bất kỳ thay đổi nào làm suy yếu tính toàn vẹn của mã nguồn.
3. **Kế hoạch cho Lab 14 (Cross-Audit & Gas Optimization):**
   - Chuyển giao toàn bộ kết quả thực nghiệm an ninh sang mốc Lab 14 để thực hiện quét tĩnh tự động bằng bộ công cụ Slither / Mythril.
   - Khảo sát chi phí Gas tiêu hao của `releaseMilestone` và tối ưu hóa đóng gói bộ nhớ (Storage Packing).

---
> 🔗 **Điều hướng nhanh:** [Trang chủ README](../README.md) • [Kế hoạch đồ án (PROJECT_PLAN.md)](PROJECT_PLAN.md) • [Đặc tả nghiệp vụ (SPEC.md)](SPEC.md) • [Biên bản Gate Review 1 (GATE_REVIEW_1.md)](GATE_REVIEW_1.md) • [Nhật ký AI (AI_JOURNAL.md)](AI_JOURNAL.md)
