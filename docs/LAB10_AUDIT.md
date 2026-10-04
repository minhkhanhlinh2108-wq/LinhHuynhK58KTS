# Báo Cáo Kiểm Toán An Ninh Nội Bộ (Internal Security Audit Report) - TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Tài liệu:** Báo cáo kiểm toán Smart Contract nội bộ (Lab 10 Security Audit)  
> **Đối tượng kiểm toán:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol)  
> **Tài liệu đối chiếu:** [`docs/SPEC.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md), [`docs/ECONOMIC_RULES.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md), [`test/ProjectCore.t.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/test/ProjectCore.t.sol)  
> **Ngày thực hiện:** 03/10/2026  
> **Đội ngũ kiểm toán:** Huỳnh Thị Khánh Linh (Smart Contract & Security) & Trần Thị Như Huỳnh (Testing & QA) cùng AI Assistant  
> **Cam kết:** Không bịa đặt lỗ hổng; mọi phát hiện đều được dẫn chứng cụ thể từ dòng mã nguồn, logic máy trạng thái và kịch bản khai thác thực tế.

---

## 1. Tổng Quan Kết Quả Kiểm Toán (Executive Summary)

Đợt kiểm toán nội bộ vòng 1 (Lab 10) tập trung rà soát toàn diện hợp đồng cốt lõi [`ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol) nhằm đánh giá mức độ tuân thủ tiêu chuẩn an ninh Smart Contract (Checks-Effects-Interactions, Reentrancy Guard, Access Control) và tính tương thích với đặc tả nghiệp vụ [`SPEC.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) cùng quy tắc kinh tế [`ECONOMIC_RULES.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md).

### 1.1. Thống kê phân loại phát hiện (Vulnerability Severity Breakdown)

| Mức Độ Nghiêm Trọng (Severity) | Số Lượng Phát Hiện | Tình Trạng Hiện Tại |
|:---|:---:|:---:|
| 🔴 **Critical** | **0** | Không có lỗ hổng gây thất thoát quỹ tức thì |
| 🟠 **High** | **1** | Cần xử lý trước khi đóng băng code (SEC-03: Kẹt quỹ vĩnh viễn do thiếu Refund) |
| 🟡 **Medium** | **3** | Rủi ro logic nghiệp vụ và DoS (SEC-01, SEC-02, SEC-06) |
| 🔵 **Low** | **3** | Lệch chuẩn truy vết, thiếu event & RBAC mở (SEC-04, SEC-05, SEC-07) |
| ⚪ **Informational** | **1** | Sai lệch đặt tên Event/Error giữa Spec và Contract (SEC-08) |
| **TỔNG CỘNG** | **8** | **Được ghi nhận chi tiết, chưa sửa code tại bước này** |

### 1.2. Đánh giá tổng thể kiến trúc
- **Điểm mạnh:**
  - Hợp đồng áp dụng rất chuẩn mẫu thiết kế **Checks-Effects-Interactions (CEI)** tại hàm giải ngân [`releaseMilestone`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L226-L258).
  - Khóa tái nhập `nonReentrant` được triển khai đúng chuẩn mutex hai pha.
  - Các ràng buộc kiểm tra số dư và trạng thái `MilestoneStatus` ngăn chặn triệt để tấn công **Double release** và **Release before approval**.
  - Không có hiện tượng gửi nhầm địa chỉ; tiền giải ngân luôn đến đúng ví sinh viên `s.student`.
  - Kiểm tra chặt chẽ `address(0)`, `address(this)` và giá trị số tiền bằng `0`.
- **Điểm cần khắc phục:**
  - Máy trạng thái có thể bị thụt lùi (State regression) khi sinh viên nộp lại minh chứng cho mốc đã được duyệt.
  - Sponsor có quyền tự duyệt mốc, làm suy yếu vai trò thẩm định độc lập của Verifier.
  - Hợp đồng thiếu cơ chế xử lý hoàn tiền (Refund / Expiry) khi suất học bổng bị đình trệ, dẫn đến nguy cơ kẹt ETH vĩnh viễn.
  - Tiềm ẩn rủi ro từ chối dịch vụ (DoS) nếu ví sinh viên là Smart Contract không có khả năng nhận ETH trực tiếp qua `call`.

---

## 2. Báo Cáo Chi Tiết Theo 13 Nhóm Vấn Đề

---

### Nhóm 1: Access Control (Kiểm Soát Truy Cập)

#### Finding SEC-01: Sponsor có quyền tự phê duyệt mốc, vượt qua thẩm định độc lập
- **ID:** `SEC-01`
- **Severity:** Medium
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L207)
- **Function:** `approveMilestone(uint256 scholarshipId, uint256 milestoneIndex)`
- **Line:** 207
- **Mô tả:**
  Tại dòng 207:
  ```solidity
  if (msg.sender != s.sponsor && msg.sender != verifier) revert NotSponsor();
  ```
  Hợp đồng cho phép cả Sponsor lẫn Verifier phê duyệt mốc học bổng. Trong khi đó, theo tài liệu [`ECONOMIC_RULES.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md) (Mục 2.4) và [`SPEC.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) (Mục 5), quyền duyệt mốc là đặc quyền độc lập của `VERIFIER_ROLE` (Phòng Đào tạo / Hội đồng thẩm định độc lập). Sponsor không được tự ý duyệt mốc cho sinh viên nhằm đảm bảo tính khách quan của minh chứng học tập.
- **Kịch bản khai thác:**
  1. Nhà tài trợ và sinh viên quen biết nhau hoặc có động cơ thông đồng.
  2. Sinh viên nộp tài liệu rác hoặc không nộp minh chứng thật.
  3. Nhà tài trợ tự mình gọi `approveMilestone()` để hợp thức hóa việc chuyển tiền học bổng mà không cần sự thông qua hay thẩm định của Nhà trường / Verifier.
  4. Hệ sinh thái đánh mất tính minh bạch và uy tín học thuật của chương trình.
- **Hậu quả:**
  Làm vô hiệu hóa vai trò của Verifier; phá vỡ mô hình kiểm định độc lập được cam kết trong quy tắc kinh tế.
- **Đề xuất sửa:**
  Điều chỉnh điều kiện tại dòng 207: Chỉ cho phép `msg.sender == verifier`. Trường hợp muốn cho phép Sponsor phê duyệt trong các suất tài trợ cá nhân, cần thiết lập cờ cấu hình minh bạch ngay từ lúc tạo suất (`requireVerifierApproval`).
- **Người phát hiện:** AI và sinh viên (ghi nhận qua kiểm thử Lab 09).

---

#### Finding SEC-04: Bất kỳ ai cũng có thể tạo suất học bổng (Không có RBAC / Whitelist trên `createScholarship`)
- **ID:** `SEC-04`
- **Severity:** Low
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L127-L152)
- **Function:** `createScholarship` (cả 2 overload)
- **Line:** 127-152, 313-350
- **Mô tả:**
  Quy tắc R1 trong [`SPEC.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) quy định: *"Chỉ nhà tài trợ/người có quyền mới được tạo suất (`RULE_SPONSOR_ONLY`)"*. Tuy nhiên trong hợp đồng thực tế, hàm `createScholarship` hoàn toàn mở (public/external không có modifier kiểm tra quyền).
- **Kịch bản khai thác:**
  Một kẻ tấn công hoặc script tự động có thể gọi liên tục hàm `createScholarship` với các thông số tượng trưng (`milestoneAmounts = [1 wei]`), đẩy `scholarshipCount` lên rất cao, gây ô nhiễm sổ cái (State Bloat) và làm loãng dữ liệu truy vấn của các cổng hiển thị DApp.
- **Hậu quả:**
  Hệ thống thiếu cơ chế chọn lọc đối tác tài trợ theo đúng thiết kế ban đầu của SPEC.
- **Đề xuất sửa:**
  Nếu hệ thống muốn vận hành dạng mở hoàn toàn (Permissionless Crowdfunding), cần cập nhật lại SPEC R1 để ghi nhận thiết kế này. Nếu muốn tuân thủ chặt chẽ SPEC R1, cần tích hợp vai trò `SPONSOR_ROLE` hoặc whitelist danh sách nhà tài trợ được phê chuẩn.
- **Người phát hiện:** Sinh viên (Trần Thị Như Huỳnh ghi nhận tại Lab 09 Test 7).

---

### Nhóm 2: Wrong Recipient (Chuyển Nhầm Người Nhận)
- **Đánh giá:** **Không phát hiện lỗi trong phạm vi kiểm tra.**
- **Cơ sở kỹ thuật:**
  Tại hàm [`releaseMilestone`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L254):
  ```solidity
  (bool success, ) = s.student.call{value: amountToRelease}("");
  ```
  Hợp đồng chuyển tiền trực tiếp đến địa chỉ `s.student` được lưu trữ cố định trong struct `Scholarship` tại thời điểm khởi tạo (`_scholarships[scholarshipId].student = student`). Địa chỉ này là bất biến trong suốt vòng đời của suất học bổng, không có tham số địa chỉ nào được truyền động từ bên ngoài lúc gọi giải ngân, triệt tiêu hoàn toàn khả năng người gọi chuyển hướng dòng tiền về ví cá nhân.

---

### Nhóm 3: Reentrancy (Tấn Công Tái Nhập)
- **Đánh giá:** **Không phát hiện lỗi trong phạm vi kiểm tra.**
- **Cơ sở kỹ thuật:**
  - Hợp đồng triển khai biến trạng thái `_status` và bộ điều식 `nonReentrant` (dòng 105-110) chuẩn OpenZeppelin:
    ```solidity
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    ```
  - Biến `_status` được khởi tạo chuẩn xác trong `constructor` (`_status = _NOT_ENTERED`).
  - Toàn bộ các hàm tiếp nhận hoặc chuyển giao Native ETH (`fundScholarship`, `releaseMilestone`) đều được gắn modifier `nonReentrant`.
  - Kết hợp cùng nguyên tắc Checks-Effects-Interactions (xem Nhóm 4), các nỗ lực reentrancy callback từ ví sinh viên độc hại đều bị chặn đứng ngay lập tức.

---

### Nhóm 4: Checks-Effects-Interactions (CEI Pattern)
- **Đánh giá:** **Không phát hiện lỗi trong phạm vi kiểm tra.**
- **Cơ sở kỹ thuật:**
  Tại hàm [`releaseMilestone`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L226-L258):
  - **Checks:** Kiểm tra ID, kiểm tra quyền gọi, kiểm tra index mốc, kiểm tra trạng thái `m.status != Approved`, kiểm tra khả năng thanh toán `s.fundedAmount >= s.releasedAmount + amountToRelease` và `address(this).balance >= amountToRelease` (dòng 230-246).
  - **Effects:** Cập nhật trạng thái lưu trữ trên storage trước khi có bất kỳ tương tác ngoại vi nào (dòng 249-251):
    ```solidity
    m.status = MilestoneStatus.Disbursed;
    m.disbursedAt = block.timestamp;
    s.releasedAmount += amountToRelease;
    ```
  - **Interactions:** Thực hiện chuyển tiền Native ETH bằng low-level call (dòng 254-255):
    ```solidity
    (bool success, ) = s.student.call{value: amountToRelease}("");
    if (!success) revert TransferFailed();
    ```
  Trình tự thực thi tuân thủ nghiêm ngặt mô hình CEI, loại bỏ bề mặt tấn công trạng thái trung gian.

---

### Nhóm 5: Double Release (Giải Ngân Lặp Hai Lần)
- **Đánh giá:** **Không phát hiện lỗi trong phạm vi kiểm tra.**
- **Cơ sở kỹ thuật:**
  Hợp đồng áp dụng cơ chế khóa chuyển trạng thái một chiều:
  - Khi gọi `releaseMilestone`, dòng 240 kiểm tra: `if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();`.
  - Ngay trong lần gọi đầu tiên, trạng thái được ghi đè thành `m.status = MilestoneStatus.Disbursed`.
  - Mọi cuộc gọi lặp lại đối với cùng một `milestoneIndex` sẽ bị revert lập tức tại dòng 240 với mã lỗi `AlreadyReleased()`.
  - Mốc đã ở trạng thái `Disbursed` cũng bị chặn không thể nộp lại minh chứng (dòng 189) hoặc duyệt lại (dòng 211). Đã được kiểm chứng thực tế qua test case `test_10_DoubleReleaseReverts` trong test suite.

---

### Nhóm 6: Release Before Approval (Giải Ngân Trước Khi Duyệt)
- **Đánh giá:** **Không phát hiện lỗi trong phạm vi kiểm tra.**
- **Cơ sở kỹ thuật:**
  - Vòng đời trạng thái của mốc bắt buộc phải đi qua các bước: `Pending` (khởi tạo) $\rightarrow$ `Submitted` (sinh viên nộp) $\rightarrow$ `Approved` (người có quyền duyệt) $\rightarrow$ `Disbursed` (giải ngân).
  - Tại hàm `releaseMilestone`, dòng 241 quy định:
    ```solidity
    if (m.status != MilestoneStatus.Approved) revert MilestoneNotApproved();
    ```
  - Nếu mốc đang ở trạng thái `Pending` hoặc `Submitted`, giao dịch giải ngân sẽ bị hoàn tác ngay lập tức. Đã được kiểm chứng thực tế qua test case `test_09_ReleaseBeforeApproveReverts`.

---

### Nhóm 7: Insufficient Fund (Không Đủ Quỹ Giải Ngân)

#### Finding SEC-05: Sinh viên có thể nộp minh chứng và Verifier có thể duyệt mốc khi suất chưa được nạp tiền
- **ID:** `SEC-05`
- **Severity:** Low
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L177-L218)
- **Function:** `submitMilestone` & `approveMilestone`
- **Line:** 177-195, 203-218
- **Mô tả:**
  Theo quy tắc kinh tế [`ECONOMIC_RULES.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md) (Mục 4.3): *"Yêu cầu nạp đủ 100% trước khi kích hoạt mốc: Suất học bổng chỉ cho phép sinh viên nộp minh chứng khi `fundedAmount == totalAmount`"*.
  Tuy nhiên, mã nguồn của `submitMilestone` và `approveMilestone` không hề kiểm tra biến `s.fundedAmount`.
- **Kịch bản khai thác:**
  1. Nhà tài trợ tạo suất học bổng cam kết 10 ETH cho sinh viên nhưng không hề nạp ETH vào hợp đồng (`fundedAmount = 0`).
  2. Sinh viên tưởng rằng suất học bổng đã sẵn sàng, nỗ lực học tập trong suốt kỳ học và nộp minh chứng thành công (`submitMilestone`).
  3. Verifier thẩm định giấy tờ và duyệt mốc (`approveMilestone`).
  4. Khi kích hoạt giải ngân `releaseMilestone`, giao dịch bị revert vì `InsufficientFunds()`. Sinh viên không nhận được tiền dù đã được duyệt mốc hợp lệ.
- **Hậu quả:**
  Gây thiệt hại về thời gian, công sức và niềm tin của sinh viên; lãng phí gas của các bên tham gia; vi phạm nguyên tắc cam kết tài chính trước khi thực thi mốc.
- **Đề xuất sửa:**
  Bổ sung ràng buộc kiểm tra số dư đã nạp tối thiểu trong `submitMilestone`:
  `if (s.fundedAmount < s.releasedAmount + m.amount) revert InsufficientFunds();` (hoặc kiểm tra `s.fundedAmount == s.totalAmount`).
- **Người phát hiện:** AI.

---

### Nhóm 8: address(0) (Địa Chỉ Rỗng)
- **Đánh giá:** **Không phát hiện lỗi trong phạm vi kiểm tra.**
- **Cơ sở kỹ thuật:**
  - Trong hàm khởi tạo suất học bổng nội bộ `_createScholarship` (dòng 317):
    ```solidity
    if (student == address(0) || student == address(this)) revert InvalidAddress();
    ```
    Hợp đồng chủ động chặn đứng cả địa chỉ rỗng `address(0)` lẫn địa chỉ của chính contract `address(this)`, bảo vệ biến `s.student`.
  - Trong hàm cập nhật người thẩm định `setVerifier` (dòng 307):
    ```solidity
    if (newVerifier == address(0) || newVerifier == address(this)) revert InvalidAddress();
    ```
  - Trong `constructor`, `verifier` được gán bằng `msg.sender`, luôn là một địa chỉ hợp lệ trên EVM.

---

### Nhóm 9: amount = 0 (Giá Trị Bằng Không)
- **Đánh giá:** **Không phát hiện lỗi trong phạm vi kiểm tra.**
- **Cơ sở kỹ thuật:**
  - Hàm `_createScholarship` (dòng 318-324) kiểm tra mảng mốc không được rỗng (`milestoneAmounts.length == 0`) và duyệt từng phần tử để đảm bảo không mốc nào có giá trị bằng 0 (`milestoneAmounts[i] == 0`).
  - Hàm overload `createScholarship` có kiểm tra tổng tiền tính toán khớp với `totalAmount` (`totalAmount != calculatedTotal`).
  - Hàm nạp quỹ `fundScholarship` (dòng 163) kiểm tra rõ ràng `if (msg.value == 0) revert InvalidAmount();`.
  - Không tồn tại đường dẫn thực thi nào cho phép tạo mốc rác có giá trị 0 hoặc nạp 0 ETH vào hợp đồng.

---

### Nhóm 10: Event Thiếu Hoặc Sai (Sự Kiện On-chain)

#### Finding SEC-07: Hàm `setVerifier` không phát ra Event và trả về sai Custom Error
- **ID:** `SEC-07`
- **Severity:** Low
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L305-L309)
- **Function:** `setVerifier(address newVerifier)`
- **Line:** 305-309
- **Mô tả:**
  Quan sát mã nguồn hàm `setVerifier`:
  ```solidity
  function setVerifier(address newVerifier) external {
      if (msg.sender != verifier) revert NotSponsor(); // <-- Lỗi 1: Sai Custom Error
      if (newVerifier == address(0) || newVerifier == address(this)) revert InvalidAddress();
      verifier = newVerifier;
      // <-- Lỗi 2: Thiếu Event VerifierUpdated
  }
  ```
  1. *Sai Custom Error:* Điều kiện kiểm tra `msg.sender != verifier` nhưng mã lỗi hoàn tác lại là `NotSponsor()`. Điều này gây hiểu lầm cho người gọi và các công cụ debug.
  2. *Thiếu Event:* Việc chuyển giao quyền thẩm định (`verifier`) là một hành động quản trị trọng yếu nhưng hợp đồng hoàn toàn không phát ra event nào.
- **Kịch bản khai thác:**
  Người quản trị mới được bổ nhiệm nhưng các dịch vụ backend, The Graph Indexer, và người dùng DApp không thể nhận biết được việc Verifier đã thay đổi do không có event on-chain được phát ra.
- **Hậu quả:**
  Làm gián đoạn khả năng truy vết và giám sát hệ thống theo thời gian thực (vi phạm nguyên tắc R10 trong SPEC).
- **Đề xuất sửa:**
  Định nghĩa `event VerifierUpdated(address indexed previousVerifier, address indexed newVerifier);` và phát ra sự kiện sau khi gán biến. Đồng thời sửa mã lỗi hoàn tác thành `revert NotVerifier();` (hoặc `revert UnauthorizedCaller(...)`).
- **Người phát hiện:** AI và sinh viên.

---

### Nhóm 11: Business Logic Không Đúng SPEC

#### Finding SEC-02: Sinh viên có thể nộp lại minh chứng và đảo ngược trạng thái Approved về Submitted (State Regression)
- **ID:** `SEC-02`
- **Severity:** Medium
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L188-L193)
- **Function:** `submitMilestone(uint256 scholarshipId, uint256 milestoneIndex, string calldata proofHash)`
- **Line:** 188-193
- **Mô tả:**
  Trong hàm `submitMilestone`:
  ```solidity
  Milestone storage m = _milestones[scholarshipId][milestoneIndex];
  if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();

  m.proofHash = proofHash;
  m.status = MilestoneStatus.Submitted;
  ```
  Hàm chỉ chặn khi mốc đã `Disbursed`. Nếu mốc đang ở trạng thái `Approved` (đã được Verifier thẩm định và duyệt hợp lệ nhưng chưa kịp gọi `releaseMilestone`), sinh viên vẫn có quyền gọi lại `submitMilestone`. Khi đó:
  1. `m.proofHash` cũ đã được Verifier duyệt bị ghi đè bằng chuỗi băm mới.
  2. Trạng thái `m.status` bị kéo lùi từ `Approved` về lại `Submitted`!
- **Kịch bản khai thác:**
  - *Tình huống Griefing/Trục trặc:* Verifier đã duyệt mốc, chuẩn bị thực hiện chuyển tiền. Sinh viên vô tình hoặc cố ý ấn nộp lại form minh chứng trên giao diện DApp. Trạng thái mốc lập tức bị hạ xuống `Submitted`. Khi người tài trợ hoặc sinh viên gọi giải ngân, giao dịch bị revert với lỗi `MilestoneNotApproved`. Quá trình giải ngân bị đình trệ, đòi hỏi Verifier phải duyệt lại từ đầu.
  - *Tình huống Tráo đổi minh chứng:* Sinh viên nộp minh chứng thật để Verifier duyệt (`Approved`). Ngay trước khi giải ngân, sinh viên gọi `submitMilestone` tráo bằng một đường dẫn rác khác. Dữ liệu đối soát on-chain bị sai lệch so với quyết định duyệt ban đầu.
- **Hậu quả:**
  Vi phạm tính bất biến của máy trạng thái một chiều; gây lỗi logic trong quá trình giải ngân và mất tính toàn vẹn của bằng chứng đã thẩm định.
- **Đề xuất sửa:**
  Chỉ cho phép nộp minh chứng khi mốc đang ở trạng thái `Pending`:
  ```solidity
  if (m.status != MilestoneStatus.Pending) revert InvalidMilestoneStatus();
  ```
- **Người phát hiện:** AI.

---

#### Finding SEC-03: Thiếu cơ chế thu hồi/hoàn tiền (Refund/Cancel Mechanism) dẫn đến kẹt quỹ vĩnh viễn (Fund Locking)
- **ID:** `SEC-03`
- **Severity:** High
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol)
- **Function:** Toàn bộ hợp đồng (Thiếu chức năng hoàn tiền / hủy suất)
- **Line:** Toàn bộ file
- **Mô tả:**
  Tài liệu [`SPEC.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) (Mục 5) và [`ECONOMIC_RULES.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md) (Mục 1.2, 4.4) quy định rõ:
  *"Nhà tài trợ có quyền thu hồi tiền dư nếu suất bị hủy hợp lệ theo chính sách sau thời gian ân hạn (`GRACE_PERIOD`) mà sinh viên không nộp minh chứng"*.
  Tuy nhiên, trong `ProjectCore.sol` hiện tại **hoàn toàn không có bất kỳ hàm hoàn trả (refund) hay hủy bỏ nào**.
- **Kịch bản khai thác:**
  1. Nhà tài trợ tạo suất học bổng trị giá 5 ETH gồm 3 mốc và nạp đủ 5 ETH vào hợp đồng.
  2. Sau khi hoàn thành mốc 1 (nhận 1.5 ETH), sinh viên quyết định thôi học, chuyển trường hoặc làm mất khóa riêng của ví nhận tiền.
  3. Mốc 2 và mốc 3 mãi mãi ở trạng thái `Pending` vì không có ai nộp minh chứng.
  4. Nhà tài trợ không có cách nào rút lại 3.5 ETH còn lại trong quỹ. Số ETH này sẽ bị phong tỏa vĩnh viễn bên trong hợp đồng thông minh mà không một ai có thể lấy ra được.
- **Hậu quả:**
  Tài sản của Nhà tài trợ bị giam giữ vĩnh viễn (Permanent Fund Locking), gây tổn thất tài chính thực tế và tạo rủi ro nghiêm trọng khi đưa lên môi trường Mainnet.
- **Đề xuất sửa:**
  Bổ sung hàm `refundUnclaimedFunds(uint256 scholarshipId)` cho phép Sponsor thu hồi số dư chưa giải ngân (`s.fundedAmount - s.releasedAmount`) kèm theo điều kiện an toàn (ví dụ: đã quá thời hạn cam kết hoặc có sự chấp thuận từ Verifier).
- **Người phát hiện:** Sinh viên và AI.

---

#### Finding SEC-08: Sự bất nhất giữa SPEC và Contract về quy chuẩn đặt tên Event và Custom Errors
- **ID:** `SEC-08`
- **Severity:** Informational
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L39-L86) so với [`docs/SPEC.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md#L69-L74)
- **Function:** Định nghĩa `Events` và `Errors`
- **Line:** 39-48, 52-86
- **Mô tả:**
  Có sự không đồng bộ đáng kể giữa danh mục sự kiện/mã lỗi trong đặc tả v1.0 và mã nguồn thực tế:
  - **Events:**
    - SPEC: `FundDeposited` $\leftrightarrow$ Contract: `ScholarshipFunded`
    - SPEC: `ProofSubmitted` $\leftrightarrow$ Contract: `MilestoneSubmitted`
    - SPEC: `ScholarshipDisbursed` $\leftrightarrow$ Contract: `ScholarshipReleased`
  - **Custom Errors:**
    - SPEC định nghĩa có ngữ cảnh: `ZeroAddressNotAllowed()`, `ZeroAmountNotAllowed()`, `MilestoneAlreadyDisbursed()`, `InsufficientScholarshipFund()`.
    - Contract định nghĩa ngắn gọn không tham số: `InvalidAddress()`, `InvalidAmount()`, `AlreadyReleased()`, `InsufficientFunds()`.
    - Tại dòng 212: Nếu mốc chưa nộp minh chứng mà bị gọi duyệt, contract báo `MilestoneNotFound()` thay vì báo lỗi trạng thái không hợp lệ `InvalidMilestoneStatus()`.
- **Kịch bản khai thác:**
  Không phải lỗ hổng bảo mật trực tiếp gây mất cắp tiền, nhưng các hệ thống bên ngoài (Web3 Frontend, Subgraph Indexer, CI/CD Test Pipeline) được lập trình theo SPEC sẽ bị lỗi biên dịch hoặc không bắt được sự kiện.
- **Hậu quả:**
  Gây sai lệch tích hợp hệ sinh thái và làm giảm tính chuyên nghiệp của bộ tài liệu kỹ thuật.
- **Đề xuất sửa:**
  Thống nhất chuẩn hóa tên gọi giữa SPEC và Smart Contract trong giai đoạn refactor mã nguồn.
- **Người phát hiện:** Sinh viên (ghi nhận tại Lab 09 review).

---

### Nhóm 12: External ETH Call (Tương Tác Chuyển Tiền Ngoại Vi)

#### Finding SEC-06: Nguy cơ từ chối dịch vụ (DoS) nếu ví nhận của sinh viên từ chối nhận Native ETH
- **ID:** `SEC-06`
- **Severity:** Medium
- **File:** [`contracts/project/ProjectCore.sol`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/contracts/project/ProjectCore.sol#L254-L255)
- **Function:** `releaseMilestone(uint256 scholarshipId, uint256 milestoneIndex)`
- **Line:** 254-255
- **Mô tả:**
  Tại dòng 254:
  ```solidity
  (bool success, ) = s.student.call{value: amountToRelease}("");
  if (!success) revert TransferFailed();
  ```
  Hợp đồng sử dụng mô hình "Push" (đẩy tiền trực tiếp đến ví người thụ hưởng). Nếu địa chỉ ví `s.student` là:
  1. Một hợp đồng thông minh không có hàm `receive()` hoặc `fallback()` nhận ETH payable.
  2. Một ví đa chữ ký (Multisig) hoặc ví Account Abstraction (ERC-4337) tiêu tốn lượng gas vượt quá giới hạn hoặc bị lỗi logic nội bộ.
  3. Một hợp đồng cố tình revert để phá hoại tiến trình giải ngân.
  Lệnh `call` sẽ trả về `success = false`, kích hoạt hoàn tác giao dịch `revert TransferFailed()`.
- **Kịch bản khai thác:**
  Nhà tài trợ tạo suất cho sinh viên với ví được chỉ định là một Smart Contract Wallet mới chưa kích hoạt hoặc bị lỗi. Khi mốc được duyệt, việc gọi `releaseMilestone` sẽ luôn luôn thất bại. Do địa chỉ `student` không thể thay đổi và không có cơ chế rút thay thế (Pull mechanism), khoản tiền cho mốc đó và toàn bộ suất học bổng sẽ bị kẹt vĩnh viễn.
- **Hậu quả:**
  Gây nghẽn tiến trình giải ngân (Denial of Service) và đóng băng số tiền ký quỹ của mốc.
- **Đề xuất sửa:**
  Có thể áp dụng một trong hai giải pháp:
  1. *Cơ chế Pull over Push (Claim pattern):* Lưu số dư khả dụng vào biến `pendingWithdrawals[student]` và cho phép sinh viên chủ động gọi `claimMilestone()` để rút tiền. Khi đó nếu ví lỗi, chỉ giao dịch của sinh viên thất bại mà không làm tắc nghẽn logic hệ thống.
  2. *Cơ chế cứu hộ ví (Emergency Wallet Recovery):* Bổ sung hàm cập nhật ví sinh viên khi có chữ ký đồng thuận của cả Verifier và Sponsor theo đúng quy tắc tại [`ECONOMIC_RULES.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md) (Mục 4.1).
- **Người phát hiện:** AI.

---

### Nhóm 13: Có Khả Năng Sponsor / Student Thực Hiện Hành Động Ngoài Quyền Không?

#### Bảng Tổng Hợp Kiểm Thử Ma Trận Phân Quyền (RBAC Matrix Verification)

| Hành Động Kỹ Thuật | Sponsor | Student | Verifier | Người Lạ (Stranger) | Đánh Giá An Toàn Phân Quyền |
|:---|:---:|:---:|:---:|:---:|:---|
| **Tạo suất học bổng (`createScholarship`)** | ✅ Cho phép | ✅ Cho phép | ✅ Cho phép | ✅ Cho phép | ⚠️ *Quá mở:* Bất kỳ ai cũng tạo được suất (Ghi nhận tại `SEC-04`). |
| **Nạp tiền vào suất (`fundScholarship`)** | ✅ Cho phép | ❌ Chặn (`NotSponsor`) | ❌ Chặn (`NotSponsor`) | ❌ Chặn (`NotSponsor`) | ✅ *Chuẩn:* Chỉ Sponsor tạo suất mới được nạp tiền. |
| **Nộp minh chứng (`submitMilestone`)** | ❌ Chặn (`NotStudent`) | ✅ Cho phép | ❌ Chặn (`NotStudent`) | ❌ Chặn (`NotStudent`) | ⚠️ *Tiềm ẩn lỗi:* Cho phép nộp lại khi mốc đã `Approved` (`SEC-02`). |
| **Duyệt mốc (`approveMilestone`)** | ⚠️ Cho phép | ❌ Chặn (`NotSponsor`) | ✅ Cho phép | ❌ Chặn (`NotSponsor`) | ⚠️ *Lạm quyền:* Sponsor được phép tự duyệt mốc (`SEC-01`). |
| **Giải ngân mốc (`releaseMilestone`)** | ✅ Cho phép | ✅ Cho phép | ✅ Cho phép | ❌ Chặn (`NotStudent`) | ✅ *An toàn:* Dù ai kích hoạt thì tiền vẫn chuyển về `s.student`. |
| **Đổi người thẩm định (`setVerifier`)** | ❌ Chặn (`NotSponsor`*) | ❌ Chặn (`NotSponsor`*) | ✅ Cho phép | ❌ Chặn (`NotSponsor`*) | ⚠️ *Nhầm mã lỗi:* Người lạ gọi bị báo lỗi `NotSponsor` thay vì `NotVerifier` (`SEC-07`). |
| **Rút tiền thừa / Hủy suất** | ❌ Không có | ❌ Không có | ❌ Không có | ❌ Không có | 🔴 *Thiếu hụt:* Chưa có chức năng hoàn tiền (`SEC-03`). |

*\*Ghi chú:* Tại `setVerifier`, dòng 306 kiểm tra `msg.sender != verifier` nhưng lại hoàn tác mã lỗi `NotSponsor()`.

---

## 3. Ma Trận Bảng Tổng Hợp Các Phát Hiện (Audit Findings Matrix)

| ID | Nhóm Phân Loại | Mức Độ | Hàm Liên Quan | Dòng Mã Nguồn | Tóm Tắt Lỗ Hổng / Vấn Đề | Người Phát Hiện |
|:---:|:---|:---:|:---|:---:|:---|:---:|
| **SEC-01** | Access Control | 🟡 Medium | `approveMilestone` | 207 | Sponsor có quyền tự duyệt mốc, vượt qua Verifier độc lập | AI & Sinh viên |
| **SEC-02** | Business Logic | 🟡 Medium | `submitMilestone` | 188-193 | Sinh viên có thể nộp lại minh chứng, đảo ngược mốc từ `Approved` về `Submitted` | AI |
| **SEC-03** | Business Logic / Funds | 🟠 High | Toàn hợp đồng | N/A | Thiếu hàm `refund` / `cancel`, có nguy cơ kẹt quỹ vĩnh viễn khi sinh viên bỏ học | Sinh viên & AI |
| **SEC-04** | Access Control | 🔵 Low | `createScholarship` | 127-152 | Bất kỳ ai cũng có thể tạo suất học bổng (thiếu `SPONSOR_ROLE` theo SPEC R1) | Sinh viên |
| **SEC-05** | Insufficient Fund | 🔵 Low | `submitMilestone`, `approveMilestone` | 177, 203 | Cho phép nộp và duyệt mốc trên suất chưa hề được nạp quỹ | AI |
| **SEC-06** | External ETH Call | 🟡 Medium | `releaseMilestone` | 254-255 | Tiềm ẩn DoS kẹt tiền nếu ví sinh viên từ chối nhận Native ETH | AI |
| **SEC-07** | Events / Access Control | 🔵 Low | `setVerifier` | 305-309 | Không phát event khi đổi Verifier; báo nhầm lỗi `NotSponsor` | AI & Sinh viên |
| **SEC-08** | Events & Errors | ⚪ Info | Toàn hợp đồng | 39-86 | Bất nhất danh mục tên Event và Custom Error giữa SPEC và Contract | Sinh viên |

---

## 4. Kế Hoạch Đề Xuất Khắc Phục (Actionable Remediation Plan)

Nhóm thống nhất giữ nguyên hiện trạng mã nguồn `contracts/project/ProjectCore.sol` trong bước này theo đúng chỉ dẫn kỹ thuật, đồng thời vạch ra lộ trình khắc phục cụ thể:

1. **Giai đoạn chuẩn bị (Lab 10 Refactor - Bước kế tiếp):**
   - Chặn đứng hiện tượng State Regression tại `submitMilestone` bằng cách yêu cầu `m.status == MilestoneStatus.Pending`.
   - Giới hạn quyền duyệt tại `approveMilestone` chỉ cho `verifier` hoặc bổ sung cờ phân định rõ ràng.
   - Thêm event `VerifierUpdated` và sửa mã lỗi thành `NotVerifier()` trong hàm `setVerifier`.
   - Bổ sung hàm rút tiền thừa có thời gian ân hạn (`refundUnclaimedFunds`) để triệt tiêu nguy cơ kẹt quỹ.
   - Cân nhắc kiểm tra số dư tối thiểu trong `submitMilestone`.
2. **Giai đoạn kiểm chứng kinh tế (Lab 11):**
   - Viết các test case kiểm tra biên nhằm bảo đảm 100% các quy tắc kinh tế trong [`ECONOMIC_RULES.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md) và SPEC R1–R10 được kiểm toán tự động.
3. **Giai đoạn đóng băng mã nguồn (Lab 12 Gate Review):**
   - Đồng bộ hóa toàn bộ danh mục Event / Custom Error giữa [`SPEC.md`](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) và Contract trước khi thực hiện Code Freeze.

---
> 🔗 **Điều hướng nhanh:** [Trang chủ README](../README.md) • [Đặc tả nghiệp vụ (SPEC.md)](SPEC.md) • [Quy tắc kinh tế (ECONOMIC_RULES.md)](ECONOMIC_RULES.md) • [Nhật ký AI (AI_JOURNAL.md)](AI_JOURNAL.md) • [Kết quả test Lab 09](../evidence/lab-09/TEST_RESULTS.md)

---

## 5. Kết Quả Kiểm Chứng Findings (Lab 10 Verification Round)

> **Ngày kiểm chứng:** 03/10/2026  
> **Phương pháp:** Viết test case Solidity (Foundry-style) tái hiện từng finding trong [`test/Lab10_Verify.t.sol`](../test/Lab10_Verify.t.sol)  
> **Công cụ:** Hardhat 3 Solidity Tests — `npx hardhat test`  
> **Kết quả tổng:** **30/30 PASS** (13 verification tests + 17 regression tests từ Lab 09)

### 5.1. Bảng Tổng Hợp Kết Quả Kiểm Chứng

| ID | Severity | Tên Finding | Test Kiểm Chứng | Kết Quả | Trạng Thái |
|:---:|:---:|:---|:---|:---:|:---:|
| **SEC-01** | 🟡 Medium | Sponsor tự duyệt mốc | `test_VERIFY_SEC01_SponsorSelfApprove_EXISTS` | ✅ PASS | **🔴 CONFIRMED** |
| **SEC-02** | 🟡 Medium | State Regression Approved→Submitted | `test_VERIFY_SEC02_StateRegression_EXISTS` | ✅ PASS | **🔴 CONFIRMED** |
| **SEC-03** | 🟠 High | Fund Locking — thiếu refund | `test_VERIFY_SEC03_FundLocking_EXISTS` | ✅ PASS | **🔴 CONFIRMED** |
| **SEC-04** | 🔵 Low | Bất kỳ ai tạo được scholarship | `test_VERIFY_SEC04_AnyoneCreateScholarship_EXISTS` | ✅ PASS | **🔴 CONFIRMED** |
| **SEC-05** | 🔵 Low | Submit/Approve khi fundedAmount=0 | `test_VERIFY_SEC05_SubmitApproveWithZeroFund_EXISTS` | ✅ PASS | **🔴 CONFIRMED** |
| **SEC-06** | 🟡 Medium | DoS ví sinh viên từ chối ETH | `test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS` + `test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS` | ✅ PASS | **🔴 CONFIRMED** |
| **SEC-07** | 🔵 Low | setVerifier báo sai lỗi NotSponsor | `test_VERIFY_SEC07_WrongErrorCode_EXISTS` | ✅ PASS | **🔴 CONFIRMED** |
| **SEC-08** | ⚪ Info | Bất nhất tên Event/Error SPEC↔Contract | `test_VERIFY_SEC08_EventNameMismatch_INFO` | ✅ PASS | **🔴 CONFIRMED** |
| **Nhóm 2** | — | Wrong Recipient | `test_VERIFY_WrongRecipient_SAFE` | ✅ PASS | **🟢 AN TOÀN** |
| **Nhóm 5** | — | Double Release | `test_VERIFY_DoubleRelease_SAFE` | ✅ PASS | **🟢 AN TOÀN** |
| **Nhóm 6** | — | Release Before Approval | `test_VERIFY_ReleaseBeforeApproval_SAFE` | ✅ PASS | **🟢 AN TOÀN** |
| **Nhóm 3+4** | — | Reentrancy + CEI Pattern | `test_VERIFY_ReentrancyAndCEI_SAFE` | ✅ PASS | **🟢 AN TOÀN** |

---

### 5.2. Chi Tiết Kiểm Chứng Từng Finding

#### SEC-01 — Sponsor Tự Phê Duyệt Mốc ✅ CONFIRMED

**Bằng chứng dòng mã nguồn (dòng 207):**
```solidity
if (msg.sender != s.sponsor && msg.sender != verifier) revert NotSponsor();
```

**Cơ chế khai thác được tái hiện:**
```
Sponsor (0x1111) tạo suất → Student nộp minh chứng →
Sponsor gọi approveMilestone() → PASS (không revert) →
getMilestoneStatus() == Approved (2) ← TÁI HIỆN THÀNH CÔNG
```

**Kết luận:** Finding **THỰC SỰ TỒN TẠI**. Luồng bypass Verifier hoạt động hoàn toàn. Đây là lỗi nghiệp vụ nghiêm trọng vi phạm nguyên tắc "hai tay ký" (dual control) trong thẩm định học bổng.

---

#### SEC-02 — State Regression (Approved → Submitted) ✅ CONFIRMED

**Bằng chứng dòng mã nguồn (dòng 189):**
```solidity
if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();
// Chỉ chặn Disbursed, KHÔNG chặn Approved!
m.status = MilestoneStatus.Submitted; // Ghi đè trạng thái không an toàn
```

**Cơ chế khai thác được tái hiện:**
```
Submit "QmRealProof_v1" → Approved (status=2) →
Submit "QmFakeProof_Overwrite" → KHÔNG revert →
getMilestoneStatus() == Submitted (1) ← ĐÃO NGƯỢC TRẠNG THÁI
releaseMilestone() → revert MilestoneNotApproved ← GIẢ PHÓNG BỊ CHẶN
```

**Kết luận:** Finding **THỰC SỰ TỒN TẠI**. Test tái hiện đầy đủ cả hai tình huống:
1. Trạng thái bị kéo lùi từ `Approved` về `Submitted`
2. Giải ngân sau đó thất bại do mốc không còn ở trạng thái `Approved`

**Finding này được chọn để sửa trong giai đoạn Refactor** (sửa đơn giản, impact cao):
```solidity
// Sửa đề xuất tại dòng 189:
if (m.status != MilestoneStatus.Pending) revert InvalidMilestoneStatus();
```

---

#### SEC-03 — Fund Locking (Thiếu Refund) ✅ CONFIRMED

**Bằng chứng phân tích code:** Toàn bộ hợp đồng `ProjectCore.sol` (352 dòng) không có bất kỳ hàm nào mang chữ ký khả dụng để rút tiền dư ra ngoài ngoài `releaseMilestone` (chỉ gọi được khi mốc `Approved`).

**Cơ chế khai thác được tái hiện:**
```
Sponsor nạp 1 ETH → Mốc 0 giải ngân 0.5 ETH thành công →
Student bỏ học → Mốc 1 ở Pending mãi mãi →
address(core).balance == 0.5 ether ← ETH BỊ KẸT VĨNH VIỄN
Không có hàm nào để Sponsor rút 0.5 ETH còn lại ← CONFIRMED
```

**Lý do giữ nguyên finding dù khó sửa:** Không xóa finding dù việc triển khai `refundUnclaimedFunds` đòi hỏi cân nhắc kỹ về điều kiện hủy suất (cần thêm `GRACE_PERIOD`, event `ScholarshipCancelled`, kiểm tra đồng thuận Verifier). Rủi ro mất quỹ vĩnh viễn là **High** và đã được tái hiện thực tế.

---

#### SEC-04 — Bất Kỳ Ai Tạo Scholarship ✅ CONFIRMED

**Bằng chứng dòng mã nguồn (dòng 127-132):**
```solidity
function createScholarship(address student, uint256[] calldata milestoneAmounts)
    external returns (uint256) {
    return _createScholarship(student, milestoneAmounts); // Không có kiểm tra quyền
}
```

**Cơ chế khai thác được tái hiện:**
```
Stranger (0x3333) gọi createScholarship() → PASS (không revert) →
s.sponsor == stranger ← STRANGER TRỞ THÀNH SPONSOR
```

**Nhận xét:** Finding tồn tại nhưng mức độ impact phụ thuộc vào thiết kế: nếu hệ thống muốn permissionless thì đây là tính năng, không phải lỗi. Audit ghi nhận sai lệch với SPEC R1.

---

#### SEC-05 — Submit/Approve Khi fundedAmount = 0 ✅ CONFIRMED

**Cơ chế khai thác được tái hiện:**
```
createScholarship (fundedAmount=0) →
submitMilestone() → PASS (không revert) →
approveMilestone() → PASS (không revert) →
getMilestoneStatus() == Approved (2) ← DUYỆT KHI CHƯA CÓ TIỀN
releaseMilestone() → revert InsufficientFunds ← GAS CỦA STUDENT/VERIFIER ĐÃ TIÊU
```

---

#### SEC-06 — DoS Ví Sinh Viên Từ Chối ETH ✅ CONFIRMED (2 biến thể)

**Biến thể 1 — MaliciousStudentWallet (revert trong receive()):**
```
createScholarship(maliciousStudent) → fundScholarship →
submitMilestone → approveMilestone →
releaseMilestone() → call thất bại →
revert TransferFailed() ← TÁI HIỆN THÀNH CÔNG
```

**Biến thể 2 — NoReceiveStudentWallet (không có receive/fallback):**
```
Tương tự biến thể 1 →
revert TransferFailed() ← TÁI HIỆN THÀNH CÔNG
```

**Nhận xét kỹ thuật quan trọng:** Không xóa finding này dù "khó sửa". Giải pháp Pull-over-Push (claim pattern) là chuẩn best-practice cho ETH distribution. Rủi ro DoS kẹt tiền là **thực tế** khi triển khai trên mainnet với Account Abstraction wallet.

---

#### SEC-07 — setVerifier Báo Sai Lỗi ✅ CONFIRMED

**Bằng chứng dòng mã nguồn (dòng 306):**
```solidity
if (msg.sender != verifier) revert NotSponsor(); // <-- Sai: nên là NotVerifier()
```

**Cơ chế khai thác được tái hiện:**
```
Stranger gọi setVerifier() →
revert NotSponsor() ← MÃ LỖI SAI NGỮ NGHĨA
```

**Nhận xét:** Finding nhỏ nhưng gây nhầm lẫn debug. Sửa 1 dòng code + thêm event.

---

#### SEC-08 — Bất Nhất Tên Event/Error (SPEC ↔ Contract) ✅ CONFIRMED

**Bảng sai lệch thực tế:**

| SPEC định nghĩa | Contract phát ra | Khớp? |
|:---|:---|:---:|
| `FundDeposited` | `ScholarshipFunded` | ❌ |
| `ProofSubmitted` | `MilestoneSubmitted` | ❌ |
| `MilestoneApproved` | `MilestoneApproved` | ✅ |
| `ScholarshipDisbursed` | `ScholarshipReleased` | ❌ |
| `ZeroAddressNotAllowed()` | `InvalidAddress()` | ❌ |
| `MilestoneAlreadyDisbursed()` | `AlreadyReleased()` | ❌ |

**Kết luận:** 3/4 events và 2/2 custom errors không khớp SPEC. Finding tồn tại.

---

#### Các Nhóm AN TOÀN — Xác Nhận Không Có Lỗi

| Nhóm | Cơ Chế Bảo Vệ | Test | Kết Quả |
|:---|:---|:---|:---:|
| **Giải ngân sai ví** | `s.student` bất biến, không truyền địa chỉ qua tham số | `test_VERIFY_WrongRecipient_SAFE` | ✅ AN TOÀN |
| **Giải ngân hai lần** | `m.status == Disbursed` → `revert AlreadyReleased()` | `test_VERIFY_DoubleRelease_SAFE` | ✅ AN TOÀN |
| **Release trước Approval** | `m.status != Approved` → `revert MilestoneNotApproved()` | `test_VERIFY_ReleaseBeforeApproval_SAFE` | ✅ AN TOÀN |
| **Reentrancy** | `nonReentrant` mutex + CEI pattern (`m.status = Disbursed` trước `call`) | `test_VERIFY_ReentrancyAndCEI_SAFE` | ✅ AN TOÀN |
| **Chuyển ETH thất bại** | Đã bắt `!success` → `revert TransferFailed()` (là feature, không phải lỗi) | Được bao phủ bởi SEC-06 | ✅ XỬ LÝ ĐÚNG |

---

### 5.3. Finding Được Chọn Để Sửa Ưu Tiên

> **Finding được chọn: SEC-02 — State Regression (Approved → Submitted)**

**Lý do chọn:**
1. **Tác động nghiêm trọng:** Phá vỡ bất biến máy trạng thái một chiều, gây tắc nghẽn giải ngân hoàn toàn.
2. **Dễ tái hiện** và đã có test case tự động xác nhận.
3. **Sửa đơn giản, ít rủi ro phụ tác dụng:** Thay đổi 1 dòng điều kiện trong `submitMilestone`.
4. **Không cần thay đổi kiến trúc** hay thêm cơ chế mới.

**Đề xuất sửa cụ thể:**
```diff
  Milestone storage m = _milestones[scholarshipId][milestoneIndex];
- if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();
+ if (m.status != MilestoneStatus.Pending) revert AlreadyReleased();
```
*(Hoặc định nghĩa thêm `error InvalidMilestoneStatus()` để phân biệt rõ hơn ngữ nghĩa lỗi)*

---

### 5.4. Nhận Xét Kiểm Toán Viên (Post-Verification Notes)

1. **SEC-01 (Medium):** Sponsor tự duyệt là **lỗi nghiệp vụ thực sự**. Tuy nhiên SPEC.md Mục 6 bước 4 có ghi "Người có quyền (`VERIFIER_ROLE` **hoặc Sponsor**)" — điều này cho thấy SPEC có mâu thuẫn nội tại giữa Mục 5 (Sponsor không được tự duyệt) và Mục 6 (Sponsor được phép). Contract phản ánh Mục 6, nhưng vi phạm tinh thần Mục 5 và ECONOMIC_RULES Mục 2.4. Cần team thống nhất ý định thiết kế.

2. **SEC-03 (High):** Kẹt quỹ là rủi ro **thực tế** nhất khi triển khai trên mainnet. Không sửa ở bước này nhưng **bắt buộc phải giải quyết trước khi deploy production**.

3. **SEC-06 (Medium):** DoS ví đã được kiểm chứng bằng 2 biến thể contract khác nhau. Cơ chế Pull-over-Push là giải pháp chuẩn ngành. Đây là **finding thực sự có thể dẫn đến mất quỹ** trên môi trường thực tế với Smart Contract Wallet.

4. **Về reentrancy và CEI:** Contract **hoàn toàn an toàn** ở hai góc độ này. Việc audit không phát hiện lỗi là kết luận chính xác, không phải bỏ sót.

---
> 🔗 **Điều hướng nhanh:** [Trang chủ README](../README.md) • [Đặc tả nghiệp vụ (SPEC.md)](SPEC.md) • [Quy tắc kinh tế (ECONOMIC_RULES.md)](ECONOMIC_RULES.md) • [Nhật ký AI (AI_JOURNAL.md)](AI_JOURNAL.md) • [Kết quả test Lab 09](../evidence/lab-09/TEST_RESULTS.md) • [Test kiểm chứng Lab 10](../test/Lab10_Verify.t.sol)

