# Báo Cáo Kiểm Toán An Ninh Độc Lập (Cross-Audit Report) — TrustScholar

> **Dự án được kiểm toán:** TrustScholar — Nền tảng Giải ngân Học bổng Minh bạch trên Blockchain  
> **Tài liệu:** Báo cáo Thẩm tra & Xác minh Kiểm toán Chéo (Lab 14 Cross-Audit Verification Report)  
> **Mã nguồn kiểm toán:** [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)  
> **Commit / Version được kiểm toán:** `00edde110a83d11ec1d8e69b31742420527a4c4d` (Phiên bản v1.0 — Code Freeze tại Lab 12)  
> **Trình biên dịch:** Solidity `^0.8.20` (EVM target: `shanghai`)  
> **Người thực hiện kiểm toán ban đầu (Người 1):** Nguyễn Minh Khánh Linh (MSV: 24K4320024) — *Security Lead*  
> **Người thẩm tra & kiểm chứng độc lập (Người 2):** Trần Thị Như Huỳnh (MSV: 24K4320010) — *QA & Testing Lead*  
> **Cam kết an ninh:**  
> 1. **Tuyệt đối KHÔNG thay đổi mã nguồn:** Giữ nguyên 100% source code của nhóm/hợp đồng được kiểm toán nhằm bảo đảm tính toàn vẹn của Code Freeze.  
> 2. **Không bịa đặt lỗ hổng (No Hallucinated Findings):** Mọi phát hiện đều được đối chiếu trực tiếp trên từng dòng code, kiểm chứng bằng kịch bản thực thi và test case thực tế.  
> 3. **Phân định minh bạch:** Phân loại rõ ràng giữa *Confirmed Issue*, *Potential Issue* và *False Positive*.

---

## 1. Phạm Vi Kiểm Toán (Audit Scope)

### 1.1. Mục tiêu và Đối tượng Thẩm tra
Phạm vi kiểm toán tập trung vào hợp đồng thông minh lõi và các tài liệu đặc tả kinh tế - kỹ thuật liên quan:

| Đối tượng | Đường dẫn / Định danh | Dòng code / Trạng thái | Mục đích kiểm tra |
|:---|:---|:---:|:---|
| **Hợp đồng cốt lõi** | [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol) | 359 dòng code | Khả năng quản lý dòng tiền, chống Reentrancy, kiểm soát quyền truy cập và máy trạng thái. |
| **Đặc tả nghiệp vụ** | [`docs/SPEC.md`](SPEC.md) | v1.0 | Đối soát luồng nghiệp vụ tạo suất, nạp quỹ, nộp minh chứng, duyệt và giải ngân. |
| **Quy tắc kinh tế** | [`docs/ECONOMIC_RULES.md`](ECONOMIC_RULES.md) | v1.0 (R1–R10) | Kiểm tra tính bảo toàn số dư, chống thất thoát quỹ và quyền hạn các vai trò. |
| **Biên bản Code Freeze**| [`docs/GATE_REVIEW_1.md`](GATE_REVIEW_1.md) | Lab 12 Gate 1 | Rà soát các cam kết bất biến của Smart Contract tại mốc đánh giá cổng. |
| **Hồ sơ Findings Người 1**| [`docs/LAB14_CROSS_AUDIT.md`](LAB14_CROSS_AUDIT.md) | Mục 3 | Danh mục các phát hiện ban đầu do Thành viên 1 ghi nhận cần Người 2 kiểm chứng. |

### 1.2. Danh mục Hàm Nghiệp vụ trong Phạm vi Rà soát
Toàn bộ 6 hàm trạng thái ghi (State-modifying functions) và 3 hàm đọc dữ liệu (View functions) đã được rà soát chi tiết:
1. `createScholarship(address student, uint256[] calldata milestoneAmounts)`
2. `createScholarship(address student, uint256 totalAmount, uint256[] calldata milestoneAmounts)`
3. `fundScholarship(uint256 scholarshipId)`
4. `submitMilestone(uint256 scholarshipId, uint256 milestoneIndex, string calldata proofHash)`
5. `approveMilestone(uint256 scholarshipId, uint256 milestoneIndex)`
6. `releaseMilestone(uint256 scholarshipId, uint256 milestoneIndex)`
7. `setVerifier(address newVerifier)`
8. Các hàm truy vấn: `getScholarship`, `getMilestoneStatus`, `getMilestone`.

---

## 2. Bảng Checklist Kiểm Toán 15 Tiêu Chí (15-Point Audit Checklist)

Tuân thủ quy chuẩn kiểm toán an ninh Smart Contract Lab 14, toàn bộ 15 tiêu chí kỹ thuật đã được kiểm tra chéo độc lập:

| STT | Tiêu Chí Kiểm Toán | Nội Dung Thẩm Tra Chi Tiết | Kết Quả Đánh Giá | Ghi Chú / Phân Loại |
|:---:|:---|:---|:---:|:---|
| 1 | **Access Control** | Phân quyền đúng vai trò (`onlySponsor`, `onlyStudent`, `onlyVerifier`), không ai gọi nhầm hàm của ai. | ⚠️ **Lưu ý** | Quyền duyệt kép `approveMilestone` (Sponsor tự duyệt song song với Verifier) — *Potential Issue*. |
| 2 | **Checks-Effects-Interactions (CEI)** | Biến trạng thái (`disbursedAmount`, `milestone.status`) phải được cập nhật trước khi gọi external call. | ✅ **ĐẠT AN TOÀN** | 100% tuân thủ CEI tại `releaseMilestone` (dòng 254–260). |
| 3 | **Reentrancy** | Khóa `nonReentrant` trên toàn bộ các hàm nhận hoặc chuyển Native ETH (`fundScholarship`, `releaseMilestone`). | ✅ **ĐẠT AN TOÀN** | Khóa Mutex 2 pha hoạt động hoàn hảo, chặn đứng tấn công tái nhập đệ quy. |
| 4 | **Điều Kiện Thời Gian** | Không phụ thuộc vào `block.timestamp` dễ bị thợ đào thao túng hoặc hết hạn bất ngờ không xử lý được. | ✅ **ĐẠT AN TOÀN** | `block.timestamp` chỉ dùng để ghi log lịch sử (`approvedAt`, `disbursedAt`), không ảnh hưởng logic. |
| 5 | **Integer Division** | Phép chia trước phép nhân gây thất thoát làm tròn (precision loss) hoặc chia cho 0 (`div by zero`). | ✅ **ĐẠT AN TOÀN** | Contract không sử dụng phép chia; toàn bộ tính toán là phép cộng dồn tuyến tính. |
| 6 | **ETH Transfer** | Sử dụng low-level call `.call{value: ...}("")` với kiểm tra biến cờ `success` và custom error. | ⚠️ **Cảnh báo** | Sử dụng Push transfer, tiềm ẩn DoS nếu ví sinh viên từ chối nhận ETH — *Confirmed Issue* (`AUDIT-LAB14-02`). |
| 7 | **Privacy / Data Exposure** | Không lưu trữ dữ liệu cá nhân nhạy cảm (PII) trên blockchain; chỉ lưu mã băm IPFS CID (`proofHash`). | ✅ **ĐẠT AN TOÀN** | Chỉ lưu chuỗi băm IPFS CID ngoại tuyến, đảm bảo quyền riêng tư người học. |
| 8 | **Loop / Gas Limit** | Không duyệt mảng không giới hạn độ dài trong write transactions gây tắc nghẽn gas (DoS Out-of-gas). | ✅ **ĐẠT AN TOÀN** | Vòng lặp chỉ duyệt qua `milestoneAmounts.length` khi tạo suất; số mốc thực tế nhỏ (1–10 mốc). |
| 9 | **Events** | Phát đầy đủ các sự kiện phục vụ Web3 DApp và Etherscan truy vết trạng thái dòng tiền. | ✅ **ĐẠT AN TOÀN** | Phát đầy đủ 6 events: `ScholarshipCreated`, `ScholarshipFunded`, `MilestoneSubmitted`, v.v. |
| 10 | **`amount = 0`** | Chặn các trường hợp nạp 0 ETH hoặc tạo mốc có số tiền 0 ETH làm loãng dữ liệu. | ✅ **ĐẠT AN TOÀN** | Revert `InvalidAmount()` khi `msg.value == 0` hoặc bất kỳ mốc nào có số tiền bằng `0`. |
| 11 | **`address(0)`** | Chặn khởi tạo suất học bổng với địa chỉ sinh viên hoặc người tài trợ là địa chỉ rỗng `0x0`. | ✅ **ĐẠT AN TOÀN** | Bắt chặt chẽ `student == address(0)` và `student == address(this)`. |
| 12 | **Business Logic vs SPEC** | Đối chiếu toàn bộ quy tắc nghiệp vụ xem code có sai lệch so với đặc tả không. | ⚠️ **Lưu ý** | Thiếu cơ chế Refund khi sinh viên bỏ học — *Confirmed Architectural Limitation* (`AUDIT-LAB14-03`). |
| 13 | **Wrong Recipient** | Tiền giải ngân bắt buộc chỉ chuyển về đúng địa chỉ `scholarship.student` đã khai báo ban đầu. | ✅ **ĐẠT AN TOÀN** | Tiền chỉ chuyển bất biến về `s.student`, không chuyển cho bất kỳ ai khác. |
| 14 | **Double Release** | Mốc đã giải ngân (`RELEASED`) tuyệt đối không thể bị giải ngân lần 2. | ✅ **ĐẠT AN TOÀN** | Chặn bởi kiểm tra `m.status == MilestoneStatus.Disbursed` và `m.status != MilestoneStatus.Approved`. |
| 15 | **Release Before Approval** | Mốc chưa được thẩm định viên chuyển sang `APPROVED` thì tuyệt đối không được phép giải ngân. | ✅ **ĐẠT AN TOÀN** | Bắt buộc `m.status == MilestoneStatus.Approved`, revert `MilestoneNotApproved()` nếu vi phạm. |

---

## 3. Thẩm Định Chi Tiết Các Findings của Thành Viên 1

Dưới đây là kết quả rà soát trực tiếp mã nguồn, thẩm tra thực tế và phân loại cho từng finding do Thành viên 1 ghi nhận tại [`docs/LAB14_CROSS_AUDIT.md`](LAB14_CROSS_AUDIT.md):

```
┌────────────────────────────────────────────────────────────────────────┐
│                        MA TRẬN PHÂN LOẠI FINDINGS                      │
├──────────────────┬─────────────────┬─────────────────┬─────────────────┤
│    Finding ID    │   Mức Độ Rủi Ro │ Kết Luận Thực Tế│    Phân Loại    │
├──────────────────┼─────────────────┼─────────────────┼─────────────────┤
│ AUDIT-LAB14-01   │  Informational  │  Không tồn tại  │ FALSE POSITIVE  │
│ AUDIT-LAB14-02   │       Low       │  Có tồn tại     │ CONFIRMED ISSUE │
│ AUDIT-LAB14-03   │      High       │  Có tồn tại     │ CONFIRMED ISSUE │
│ AUDIT-LAB14-04   │    Medium/Low   │  Thiết kế SPEC  │ POTENTIAL ISSUE │
│ AUDIT-LAB14-05   │       Low       │  Có tồn tại     │ POTENTIAL ISSUE │
│ AUDIT-LAB14-06   │       Low       │  Có tồn tại     │ CONFIRMED ISSUE │
└──────────────────┴─────────────────┴─────────────────┴─────────────────┘
```

---

### Finding 1: Rà soát tối ưu hóa chi phí lưu trữ calldata cho mảng mốc học bổng

- **Mã phát hiện (ID):** `AUDIT-LAB14-01`
- **Mức độ nghiêm trọng (Severity):** `Informational`
- **Tệp mã nguồn (File):** [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)
- **Vị trí dòng (Line):** Dòng 134, 149, 322
- **Hàm liên quan (Function):** `createScholarship` & `_createScholarship`
- **Mô tả của Thành viên 1:**  
  *Thành viên 1 ghi nhận rằng tham số mảng động `milestoneAmounts` có thể sử dụng từ khóa `calldata` thay vì `memory` khi truyền dữ liệu từ bên ngoài để tiết kiệm chi phí sao chép bộ nhớ EVM (~1,500 gas).*

#### 1. Đọc trực tiếp mã nguồn:
Kiểm tra trực tiếp tại [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol#L132-L157):
```solidity
// Dòng 132-137
function createScholarship(
    address student,
    uint256[] calldata milestoneAmounts
) external returns (uint256) {
    return _createScholarship(student, milestoneAmounts);
}

// Dòng 146-150
function createScholarship(
    address student,
    uint256 totalAmount,
    uint256[] calldata milestoneAmounts
) external returns (uint256) { ... }

// Dòng 320-323
function _createScholarship(
    address student,
    uint256[] calldata milestoneAmounts
) internal returns (uint256) { ... }
```

#### 2. Xác định finding có thật không:
- **KHÔNG THẬT.** Trong phiên bản mã nguồn hiện tại đang kiểm toán (commit `00edde1`), cả hai hàm quá tải `createScholarship` và hàm nội bộ `_createScholarship` **ĐÃ SỬ DỤNG** từ khóa `calldata` cho mảng `milestoneAmounts`.
- Không hề có khai báo `memory` nào đối với mảng này trong signature hàm public/external.

#### 3. Phân loại chuẩn xác:
- ❌ **FALSE POSITIVE (Phát hiện cảnh báo sai)**.
- *Nguyên nhân gây ra false positive:* Thành viên 1 đã căn cứ trên bản dự thảo nháp ban đầu của contract trước khi hoàn thiện Lab 10/11 mà chưa đồng bộ với phiên bản code thực tế đã được freeze.

#### 4. Bằng chứng thực tế:
- Trình biên dịch `solc 0.8.20` biên dịch thành công 100% calldata slices.
- Test benchmark gas [`test/Lab14_GasReport.t.sol`](../test/Lab14_GasReport.t.sol) thực thi hàm `createScholarship` với mảng `calldata` tiêu tốn **218,922 gas**, đạt chuẩn tối ưu gas nghiêm ngặt (< 250,000 gas).

#### 5. Khuyến nghị (Recommendation):
- Đóng finding này. Giữ nguyên khai báo `calldata` hiện tại trong `ProjectCore.sol`, không cần chỉnh sửa mã nguồn.

---

### Finding 2: Cơ chế phòng ngừa DoS giải ngân khi ví sinh viên là Smart Contract không có hàm `receive()`

- **Mã phát hiện (ID):** `AUDIT-LAB14-02` (Tương đương `SEC-06` tại Lab 10)
- **Mức độ nghiêm trọng (Severity):** `Low` (đối với sinh viên dùng ví cá nhân EOA thông thường) / `Medium` (nếu dùng ví Smart Contract / Account Abstraction)
- **Tệp mã nguồn (File):** [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)
- **Vị trí dòng (Line):** Dòng 259–260
- **Hàm liên quan (Function):** `releaseMilestone(uint256 scholarshipId, uint256 milestoneIndex)`
- **Mô tả của Thành viên 1:**  
  *Hàm giải ngân sử dụng mô hình đẩy tiền trực tiếp (Push Transfer) qua low-level call tới `scholarship.student`. Nếu ví sinh viên là Smart Contract không có hàm `receive()`/`fallback()` hoặc cố tình tiêu hao gas / revert, lệnh giải ngân sẽ bị hoàn tác với lỗi `TransferFailed()`, làm kẹt tiền của mốc đó.*

#### 1. Đọc trực tiếp mã nguồn:
Kiểm tra tại dòng 258–261 trong [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol#L258-L261):
```solidity
// Interaction
(bool success, ) = s.student.call{value: amountToRelease}("");
if (!success) revert TransferFailed();
```
Hợp đồng kiểm tra `student == address(0)` hoặc `student == address(this)` khi khởi tạo, nhưng **hoàn toàn không kiểm tra** địa chỉ `student` là EOA hay Smart Contract, và địa chỉ `s.student` là bất biến (không có cơ chế cập nhật lại ví nhận sau khi tạo suất).

#### 2. Xác định finding có thật không:
- **CÓ THẬT (CONFIRMED).** Nếu `s.student` là một Smart Contract (ví dụ ví đa chữ ký Multisig chưa cấu hình fallback nhận Native ETH, hoặc ví hợp đồng sinh viên cố tình viết hàm `revert()`), giao dịch `releaseMilestone` sẽ luôn bị revert. Hậu quả là số tiền của mốc học bổng đó không thể giải ngân ra ngoài.

#### 3. Phân biệt & Phân loại:
- ⚠️ **CONFIRMED ISSUE (Vấn đề đã được xác nhận về mặt kiến trúc chuyển tiền EVM)**.
- Tuy nhiên, trong mô hình hoạt động thực tế của TrustScholar hiện nay, người học được hướng dẫn sử dụng ví EOA (MetaMask, Rabby), nên rủi ro khai thác thực tế được xếp ở mức `Low`.

#### 4. Kịch bản thực thi & Test Scenario:
Kịch bản tấn công / nghẽn giao dịch (Execution Path):
1. **Bước 1:** Kẻ tấn công hoặc sinh viên vô ý deploy một hợp đồng không có hàm `receive()`:
   ```solidity
   contract NoReceiveStudentWallet {
       // Không có receive() external payable
       // Không có fallback() external payable
   }
   ```
2. **Bước 2:** Sponsor tạo suất học bổng với địa chỉ nhận là `address(noReceiveStudentWallet)` và nạp quỹ 0.5 ETH.
3. **Bước 3:** Sinh viên nộp minh chứng `submitMilestone` và Verifier gọi `approveMilestone`.
4. **Bước 4:** Bất kỳ ai gọi `releaseMilestone(scholarshipId, 0)` -> EVM thực thi `student.call{value: 0.5 ether}("")` -> Trả về `success = false`.
5. **Bước 5:** Hợp đồng revert với custom error `TransferFailed()`. Toàn bộ 0.5 ETH bị kẹt vô thời hạn trong hợp đồng.

#### 5. Bằng chứng kiểm chứng thực tế (Evidence):
Finding này đã được kiểm chứng bằng 2 bài test tự động chạy thực tế trong file [`test/Lab10_Verify.t.sol`](../test/Lab10_Verify.t.sol):
- `test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS()`: Giả lập ví sinh viên cố tình `revert()` trong hàm nhận ETH -> Kết quả: `revert TransferFailed()` được kích hoạt chính xác.
- `test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS()`: Giả lập ví sinh viên là hợp đồng không có `receive()` -> Kết quả: `revert TransferFailed()` được kích hoạt chính xác.
- Cả 2 bài test đều **PASS 100%**, chứng minh lỗ hổng tồn tại khách quan.

#### 6. Khuyến nghị khắc phục (Recommendation):
- **Ngắn hạn (Phiên bản v1.0 — Tuân thủ Code Freeze):**
  - Không sửa mã nguồn `ProjectCore.sol` hiện tại.
  - Ban hành tài liệu hướng dẫn người dùng (`User Guidelines`) quy định bắt buộc: Sinh viên chỉ được đăng ký địa chỉ ví cá nhân EOA (Externally Owned Account) khi nhận học bổng; nghiêm cấm sử dụng địa chỉ Smart Contract chưa được kiểm thử khả năng nhận Native ETH.
- **Dài hạn (Phiên bản v2.0):**
  - Chuyển đổi từ mô hình Đẩy (Push Transfer) sang mô hình Rút tiền chủ động (Pull-over-Push Pattern / Withdrawal Pattern):
    ```solidity
    mapping(address => uint256) public pendingWithdrawals;
    
    function releaseMilestone(uint256 scholarshipId, uint256 milestoneIndex) external nonReentrant {
        // ... kiểm tra điều kiện ...
        m.status = MilestoneStatus.Disbursed;
        pendingWithdrawals[s.student] += amountToRelease;
        emit MilestoneDisbursedToBalance(scholarshipId, milestoneIndex, s.student, amountToRelease);
    }
    
    function withdrawScholarship() external nonReentrant {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "No funds to withdraw");
        pendingWithdrawals[msg.sender] = 0;
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
    }
    ```

---

### Finding 3: Rủi ro kẹt vốn do thiếu cơ chế hoàn tiền khi học bổng bị đình trệ (Fund Locking)

- **Mã phát hiện (ID):** `AUDIT-LAB14-03` (Tương đương `SEC-03` tại Lab 10)
- **Mức độ nghiêm trọng (Severity):** `High`
- **Tệp mã nguồn (File):** [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)
- **Hàm liên quan (Function):** Toàn bộ hợp đồng (Thiếu hàm `refund` / `cancelScholarship`)
- **Đọc trực tiếp code:** Trong toàn bộ 359 dòng code của `ProjectCore.sol`, chỉ có 1 luồng giải ngân duy nhất là `releaseMilestone` chuyển tiền về ví sinh viên `s.student`. Hoàn toàn không tồn tại bất kỳ hàm nào cho phép Nhà tài trợ rút lại số tiền chưa giải ngân.
- **Xác định finding có thật không:** **CÓ THẬT (CONFIRMED)**.
- **Phân loại:** ⚠️ **CONFIRMED ISSUE (Hạn chế kiến trúc bậc cao)**.
- **Kịch bản rủi ro (Execution Path):**
  1. Nhà tài trợ nạp 2.0 ETH cho 2 mốc học bổng.
  2. Mốc 1 giải ngân thành công 1.0 ETH.
  3. Đến mốc 2, sinh viên nghỉ học hoặc vi phạm kỷ luật nên không nộp minh chứng; hoặc Verifier từ chối duyệt.
  4. 1.0 ETH còn lại của Nhà tài trợ sẽ bị kẹt vĩnh viễn trong hợp đồng `ProjectCore.sol` mà không có cách nào thu hồi.
- **Bằng chứng thực tế:** Test case `test_VERIFY_SEC03_FundLocking_EXISTS()` trong [`test/Lab10_Verify.t.sol`](../test/Lab10_Verify.t.sol) chứng minh số dư 0.5 ETH còn lại bị giữ lại trong `address(core).balance` mà không có hàm nào có thể tương tác. Test chạy **PASS 100%**.
- **Khuyến nghị:** Trong phiên bản v2.0, bổ sung cơ chế Khóa thời gian & Hoàn tiền bảo trợ (Time-locked Emergency Refund / Cancel), cho phép Sponsor rút lại các mốc chưa được duyệt sau một khoảng thời gian chờ (ví dụ 180 ngày) có sự xác nhận của Verifier.

---

### Finding 4: Mô hình thẩm định kép cho phép Sponsor tự phê duyệt mốc

- **Mã phát hiện (ID):** `AUDIT-LAB14-04` (Tương đương `SEC-01` tại Lab 10)
- **Mức độ nghiêm trọng (Severity):** `Low` / `Medium`
- **Tệp mã nguồn (File):** [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)
- **Vị trí dòng (Line):** Dòng 212
- **Hàm liên quan (Function):** `approveMilestone(uint256 scholarshipId, uint256 milestoneIndex)`
- **Đọc trực tiếp code:**
  ```solidity
  if (msg.sender != s.sponsor && msg.sender != verifier) revert NotSponsor();
  ```
  Hợp đồng cho phép cả `s.sponsor` lẫn `verifier` gọi lệnh phê duyệt mốc.
- **Xác định finding có thật không:** **CÓ THẬT VỀ MẶT CODE, NHƯNG LÀ TÍNH NĂNG ĐƯỢC CHẤP NHẬN THEO THIẾT KẾ ĐẶC TẢ (ACCEPTED BY DESIGN).**
- **Phân loại:** ℹ️ **POTENTIAL ISSUE / INTENDED SPEC DESIGN**.
- **Phân tích:** 
  - Trong tài liệu [`docs/SPEC.md`](SPEC.md) (Mục 6 Bước 4) và [`docs/ECONOMIC_RULES.md`](ECONOMIC_RULES.md) (Mục 2.4), nhóm tác giả đã chủ động định nghĩa mô hình "Thẩm định kép linh hoạt": Đối với các suất học bổng tư nhân tài trợ trực tiếp, Sponsor có thể tự duyệt mốc giải ngân; đối với học bổng trường học, Verifier độc lập thực hiện.
  - Do đó, việc Sponsor duyệt được mốc không phải là bug ngoài ý muốn, mà là một sự lựa chọn thiết kế đã được ghi nhận tại biên bản Gate Review 1.
- **Khuyến nghị:** Đối với các chương trình học bổng mang tính học thuật cấp trường, khuyến nghị chỉ định rõ cờ `requiresIndependentVerifier = true` khi tạo suất trong phiên bản nâng cấp v2.0 để vô hiệu hóa quyền tự duyệt của Sponsor.

---

### Finding 5: Cho phép nộp và duyệt mốc trên suất học bổng chưa nạp quỹ

- **Mã phát hiện (ID):** `AUDIT-LAB14-05` (Tương đương `SEC-05` tại Lab 10)
- **Mức độ nghiêm trọng (Severity):** `Low`
- **Tệp mã nguồn (File):** [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)
- **Vị trí dòng (Line):** Dòng 182–223
- **Hàm liên quan (Function):** `submitMilestone` & `approveMilestone`
- **Đọc trực tiếp code:** Hai hàm này kiểm tra quyền hạn của sinh viên và người duyệt, nhưng không kiểm tra biến `s.fundedAmount >= m.amount`.
- **Xác định finding có thật không:** **CÓ THẬT (CONFIRMED)**.
- **Phân loại:** ℹ️ **POTENTIAL ISSUE (Lãng phí Gas, không gây mất tiền)**.
- **Phân tích:** 
  - Sinh viên có thể nộp bằng chứng và Verifier có thể duyệt mốc khi Sponsor chưa nạp 1 đồng ETH nào vào hợp đồng.
  - Tuy nhiên, **tiền không thể bị rút trái phép** vì tại hàm `releaseMilestone` (dòng 249–251), hợp đồng kiểm tra nghiêm ngặt:
    ```solidity
    if (s.fundedAmount < s.releasedAmount + amountToRelease || address(this).balance < amountToRelease) {
        revert InsufficientFunds();
    }
    ```
  - Do đó, quỹ được bảo vệ an toàn 100%, chỉ có sinh viên và verifier bị mất phí gas vô ích nếu sponsor quỵt tiền nạp.
- **Bằng chứng:** Đã kiểm chứng qua test case `test_VERIFY_SEC05_SubmitApproveWithZeroFund_EXISTS()` trong [`test/Lab10_Verify.t.sol`](../test/Lab10_Verify.t.sol).
- **Khuyến nghị:** Phiên bản v2.0 có thể bổ sung điều kiện `if (s.fundedAmount < s.releasedAmount + m.amount) revert InsufficientFunds();` ngay tại hàm `submitMilestone`.

---

### Finding 6: Bất nhất ngữ nghĩa mã lỗi tại hàm cập nhật người thẩm định

- **Mã phát hiện (ID):** `AUDIT-LAB14-06` (Tương đương `SEC-07` tại Lab 10)
- **Mức độ nghiêm trọng (Severity):** `Low`
- **Tệp mã nguồn (File):** [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)
- **Vị trí dòng (Line):** Dòng 311
- **Hàm liên quan (Function):** `setVerifier(address newVerifier)`
- **Đọc trực tiếp code:**
  ```solidity
  function setVerifier(address newVerifier) external {
      if (msg.sender != verifier) revert NotSponsor(); // <--- Sai mã lỗi ngữ nghĩa
      ...
  }
  ```
- **Xác định finding có thật không:** **CÓ THẬT (CONFIRMED)**.
- **Phân loại:** ⚠️ **CONFIRMED ISSUE (Lỗi ngữ nghĩa - Semantic Mismatch)**.
- **Phân tích:** Khi một địa chỉ không phải là Verifier cố tình gọi hàm này, contract lại hoàn tác với lỗi `NotSponsor()` thay vì `NotVerifier()` hoặc `UnauthorizedCaller()`. Lỗi này không gây rò rỉ bảo mật nhưng làm sai lệch thông điệp gỡ lỗi của Web3 DApp và người dùng.
- **Bằng chứng:** Đã kiểm chứng qua test case `test_VERIFY_SEC07_WrongErrorCode_EXISTS()` trong [`test/Lab10_Verify.t.sol`](../test/Lab10_Verify.t.sol) (PASS 100%).
- **Khuyến nghị:** Định nghĩa thêm `error NotVerifier();` và cập nhật tại v2.0 sau khi mở Code Freeze.

---

## 4. Các Mục Không Phát Hiện Vấn Đề (Safe & Resilient Areas)

Qua rà soát chuyên sâu 15 tiêu chí, nhóm kiểm toán xác nhận 11 nhóm tiêu chí sau đây đạt mức **An toàn Tuyệt đối (100% Safe & Compliant)**:

```
┌────────────────────────────────────────────────────────────────────────┐
│                      KHU VỰC ĐẠT TIÊU CHUẨN AN TOÀN                    │
├────────────────────────────────┬───────────────────────────────────────┤
│ 1. Checks-Effects-Interactions │ Cập nhật trạng thái trước transfer.  │
│ 2. Reentrancy Protection       │ Khóa Mutex 2 pha chống tái nhập.      │
│ 3. Timestamp Independence      │ Không phụ thuộc miner timestamp.      │
│ 4. Integer Division Safety     │ Tuyệt đối không có phép chia.         │
│ 5. Data Privacy & PII          │ Chỉ lưu mã băm IPFS CID ngoại tuyến.  │
│ 6. Loop & Gas DoS Limits       │ Mảng mốc giới hạn tự nhiên.           │
│ 7. Event Logging & Tracing     │ Phát đầy đủ sự kiện cho DApp.         │
│ 8. Zero Value Validation       │ Chặn hoàn toàn amount = 0.            │
│ 9. Zero Address Validation     │ Chặn hoàn toàn address(0).            │
│ 10. Wrong Recipient Shield     │ Tiền chỉ chuyển về đúng ví sinh viên. │
│ 11. Double Release Defense     │ Chặn triệt để giải ngân 2 lần.        │
└────────────────────────────────┴───────────────────────────────────────┘
```

1. **Tuân thủ triệt để Checks-Effects-Interactions (CEI):**  
   Tại hàm nhạy cảm dòng tiền nhất `releaseMilestone`, toàn bộ các cập nhật biến trạng thái (`m.status = MilestoneStatus.Disbursed;`, `m.disbursedAt = block.timestamp;`, `s.releasedAmount += amountToRelease;`) đều được hoàn tất **trước** khi dòng lệnh external call `s.student.call{value: amountToRelease}("")` được kích hoạt. Không có bất kỳ khoảng trống trạng thái nào để hacker khai thác.

2. **Khóa chống tái nhập (ReentrancyGuard):**  
   Được trang bị trên cả hai hàm nhận và chuyển ETH (`fundScholarship` và `releaseMilestone`). Thực nghiệm tấn công đệ quy chuyên sâu tại Lab 13 với hợp đồng `AttackerScholarshipBank` đã chứng minh khóa Mutex vô hiệu hóa 100% nỗ lực tái nhập.

3. **Chống giải ngân lặp lại (Double Release Prevention):**  
   Biến cờ `MilestoneStatus` hoạt động như một máy trạng thái 1 chiều (Pending → Submitted → Approved → Disbursed). Khi mốc đã sang trạng thái `Disbursed`, mọi lệnh gọi tiếp theo đều bị chặn đứng bởi `if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();`.

4. **Chống giải ngân trước khi được duyệt (Release Before Approval Prevention):**  
   Ràng buộc cứng `if (m.status != MilestoneStatus.Approved) revert MilestoneNotApproved();` bảo đảm không có kịch bản nào tiền được giải ngân khi chưa có chữ ký thẩm định của Verifier/Sponsor.

5. **Bảo vệ địa chỉ thụ hưởng (Wrong Recipient Immunity):**  
   Địa chỉ nhận tiền là thuộc tính bất biến `s.student` được lưu trữ trong Storage slot của hợp đồng từ lúc khởi tạo. Không ai có quyền chuyển hướng dòng tiền sang ví khác.

6. **Kiểm tra biên số tiền và địa chỉ rác (`amount = 0` & `address(0)`):**  
   Toàn bộ ngõ vào của hệ thống đều có chốt chặn kiểm tra: cấm tạo mốc 0 ETH, cấm nạp 0 ETH, cấm gán sinh viên là `address(0)` hoặc `address(this)`, cấm chuyển Verifier sang `address(0)`.

---

## 5. Bằng Chứng Thực Nghiệm & Kết Quả Chạy Kiểm Thử (Audit Evidence)

Toàn bộ kết quả kiểm toán đã được kiểm chứng độc lập thông qua bộ kiểm thử tự động với **85/85 test cases PASS 100%**:

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

  test/Lab10_Verify.t.sol:Lab10VerifyTest
    ✔ test_VERIFY_WrongRecipient_SAFE()
    ✔ test_VERIFY_SEC08_EventNameMismatch_INFO()
    ✔ test_VERIFY_SEC07_WrongErrorCode_EXISTS()
    ✔ test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS()
    ✔ test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS()
    ✔ test_VERIFY_SEC05_SubmitApproveWithZeroFund_EXISTS()
    ✔ test_VERIFY_SEC04_AnyoneCreateScholarship_EXISTS()
    ✔ test_VERIFY_SEC03_FundLocking_EXISTS()
    ✔ test_VERIFY_SEC02_StateRegression_EXISTS()
    ✔ test_VERIFY_SEC01_SponsorSelfApprove_EXISTS()
    ✔ test_VERIFY_ReleaseBeforeApproval_SAFE()
    ✔ test_VERIFY_ReentrancyAndCEI_SAFE()
    ✔ test_VERIFY_DoubleRelease_SAFE()

  test/Lab14_GasReport.t.sol:Lab14GasReportTest
    ✔ test_GAS06_FullLifecycle_TotalGas() (485,976 gas)
    ✔ test_GAS05_ReleaseMilestone_Benchmark() (55,273 gas)
    ✔ test_GAS04_ApproveMilestone_Benchmark() (26,055 gas)
    ✔ test_GAS03_SubmitMilestone_Benchmark() (89,970 gas)
    ✔ test_GAS02_FundScholarship_Benchmark() (35,691 gas)
    ✔ test_GAS01_CreateScholarship_Benchmark() (218,922 gas)

  test/ProjectCore.t.sol:ProjectCoreTest (17 passing)
  test/Lab11_EconomicRules.t.sol:Lab11EconomicRulesTest (34 passing)

85 passing (85 solidity)
```

---

## 6. Kết Luận & Khuyến Nghị (Conclusion & Action Plan)

### 6.1. Đánh giá chung
Hợp đồng lõi `ProjectCore.sol` của dự án TrustScholar tại phiên bản commit `00edde1` đạt chất lượng bảo mật rất cao:
- **0 lỗ hổng Critical:** Không có lỗ hổng gây thất thoát Native ETH trực tiếp.
- **Tuân thủ nguyên tắc Code Freeze:** Giữ nguyên 100% mã nguồn của hợp đồng, không tự ý sửa đổi code sau khi đã thông qua Gate Review 1.
- **Finding 1 của Người 1 được phân loại chính xác là False Positive** do code thực tế đã được tối ưu hóa `calldata`.
- **Finding 2 của Người 1 được xác nhận là Confirmed Issue** về mặt mô hình Push-payment, được kiểm soát rủi ro bằng khuyến cáo vận hành EOA.

### 6.2. Kế hoạch hành động
1. **Giai đoạn hiện tại (Lab 14 & 15):**
   - Giữ nguyên trạng hợp đồng lõi để phục vụ triển khai Testnet và kết nối giao diện Web3 DApp trong Lab 15.
   - Bổ sung cảnh báo trong tài liệu hướng dẫn giao diện người dùng: "Chỉ đăng ký ví cá nhân EOA (MetaMask), không đăng ký địa chỉ Contract để nhận học bổng".
2. **Giai đoạn nâng cấp tương lai (v2.0 Post-Demo):**
   - Nâng cấp mô hình giải ngân sang Pull-over-Push (Pending Withdrawals).
   - Tích hợp cơ chế khôi phục quỹ (Emergency Cancel/Refund) có sự đồng thuận đa bên.
   - Đồng bộ custom error `NotVerifier()` tại hàm `setVerifier`.

---
*Báo cáo được lập và kiểm chứng độc lập bởi đội ngũ QA & Security TrustScholar — Lab 14.*
