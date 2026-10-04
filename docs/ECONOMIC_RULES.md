# Quy Tắc Kinh Tế & Kiểm Soát Rủi Ro (Economic Rules) - TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Phiên bản:** v1.0 (Quy tắc kinh tế, dòng tiền & bảo vệ nguồn quỹ)  
> **Repository GitHub:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  
> **Điều hướng nhanh:** [Trang chủ README](../README.md) | [Đặc Tả Nghiệp Vụ (SPEC.md)](SPEC.md) | [Kế Hoạch Đồ Án (PROJECT_PLAN.md)](PROJECT_PLAN.md) | [Nhật Ký AI (AI_JOURNAL.md)](AI_JOURNAL.md)  
> **Mô tả:** Tài liệu này xác định mô hình kinh tế, cơ chế khuyến khích, phân định quyền hạn và các phương án giảm thiểu rủi ro tài chính cho nền tảng giải ngân học bổng TrustScholar.

---

## 1. Dòng Tiền & Quyền Lợi (Cashflow & Value Incentives)

Hệ thống TrustScholar vận hành theo cơ chế ký quỹ thông minh phi lưu ký (Non-custodial Escrow), bảo đảm từng đồng tiền đóng góp của Nhà tài trợ được giám sát chặt chẽ và giải ngân chính xác theo các nguyên tắc sau:

### 1.1. Nhà Tài Trợ Đưa ETH Testnet Vào Quỹ (100% Native ETH — Không Cần ERC-20)
- **Dòng tiền nạp (Funding Inflow):** Nhà tài trợ (Sponsor) chuyển trực tiếp đồng tiền mã hóa Native ETH thử nghiệm (ETH Testnet trên mạng Sepolia/Arbitrum Sepolia) vào Smart Contract của TrustScholar thông qua giao dịch `fundScholarship{value: ...}(scholarshipId)`.
- **Minh bạch ký quỹ:** Toàn bộ số dư nạp vào được ghi nhận công khai trên sổ cái blockchain, phát sinh sự kiện `ScholarshipFunded(scholarshipId, sponsor, amount, totalFunded)` để mọi bên đều có thể đối soát.
- **Tiêu chuẩn tiền tệ:** Nền tảng sử dụng 100% **Native ETH**, không sử dụng và không phụ thuộc vào bất kỳ token ERC-20 nào, giúp giảm thiểu rủi ro bảo mật từ bên thứ ba và tối ưu chi phí gas.
- **Trách nhiệm phí gas:** Nhà tài trợ tự chi trả phí gas mạng lưới khi thực hiện khởi tạo và nạp tiền vào quỹ.

### 1.2. Tiền Được Khóa Theo Từng Suất Học Bổng
- **Hạch toán độc lập (Escrow Per Scholarship):** Tiền không bị hòa lẫn vào một bể chung vô định, mà được phân bổ và khóa cứng (locked) tương ứng với từng mã suất học bổng duy nhất (`scholarshipId`).
- **Phân bổ theo mốc (Milestone Allocation):** Số tiền khóa cho mỗi suất được chia nhỏ thành các mốc giải ngân (`milestoneAmounts[i]`). Tổng giá trị các mốc bắt buộc phải bằng chính xác tổng giá trị suất học bổng:
  $$\sum_{i=0}^{n-1} \text{milestoneAmounts}[i] = \text{totalAmount}$$
- **Bảo toàn khả năng thanh toán (Solvency Guarantee):** Khi suất đã được nạp tiền (`fundedAmount`), số tiền này bị phong tỏa an toàn trong hợp đồng theo nguyên tắc phi lưu ký (Non-custodial Escrow) và chỉ được giải phóng cho đúng sinh viên khi hoàn thành mốc học tập được phê duyệt. Hợp đồng không mở bất kỳ backdoor nào cho phép rút tiền tùy tiện trái cam kết.

### 1.3. Sinh Viên Chỉ Nhận Tiền Khi Đạt Điều Kiện
- **Điều kiện kép (Two-condition Gate):** Sinh viên không thể tự ý rút tiền học bổng ngay sau khi được cấp suất, mà bắt buộc phải vượt qua 2 bước kiểm tra:
  1. *Nộp minh chứng:* Sinh viên chỉ định (`msg.sender == scholarship.student`) nộp mã băm minh chứng (`proofHash` / IPFS CID) qua hàm `submitMilestone`.
  2. *Thẩm định hợp lệ:* Người có thẩm quyền (Người thẩm định độc lập `verifier` hoặc Nhà tài trợ tạo suất `sponsor` theo cơ chế thẩm định kép của SPEC v1.0 Mục 6 Bước 4) thẩm định minh chứng off-chain và ký giao dịch xác nhận mốc đạt yêu cầu (`approveMilestone`).
- **Không đạt - Không giải ngân:** Nếu sinh viên không nộp minh chứng hoặc minh chứng không đạt tiêu chuẩn, trạng thái mốc sẽ không chuyển sang `Approved`, Smart Contract tuyệt đối từ chối lệnh chuyển tiền (`MilestoneNotApproved`).

### 1.4. Tiền Phải Đến Đúng Ví Sinh Viên
- **Chuyển tiền trực tiếp (Direct Payout):** Tiền giải ngân của từng mốc được chuyển thẳng từ số dư ký quỹ của hợp đồng vào chính xác địa chỉ ví cá nhân của sinh viên (`scholarship.student`) đã được ấn định bất biến từ lúc khởi tạo.
- **Không qua trung gian (Zero Intermediary):** Hệ thống không chuyển tiền qua ví của người duyệt, ví admin, hay bất kỳ tài khoản trung gian nào. Dù Verifier, Sponsor hay Student kích hoạt `releaseMilestone`, tiền luôn chuyển về đúng ví sinh viên.
- **Không thu phí khấu trừ (Zero Platform Fee):** Sinh viên nhận trọn vẹn 100% số tiền học bổng của mốc cam kết mà không bị cắt xén hoa hồng nền tảng.

---

## 2. Giới Hạn Chống Lạm Dụng (Abuse Prevention & Constraints)

Nhằm triệt tiêu mọi khả năng gian lận, trục lợi hoặc khai thác lỗ hổng kỹ thuật, Smart Contract thiết lập 4 giới hạn cứng bất biến (Invariants):

```mermaid
graph TD
    A[Yêu Cầu Giải Ngân Mốc: releaseMilestone] --> B{Quy tắc 1: Đã giải ngân chưa?}
    B -- Đã giải ngân rồi --> X[REVERT: AlreadyReleased]
    B -- Chưa giải ngân --> C{Quy tắc 2: Đã được duyệt hợp lệ?}
    C -- Chưa duyệt / Pending / Submitted --> Y[REVERT: MilestoneNotApproved]
    C -- Đã duyệt Approved --> D{Quy tắc 3: Quỹ suất còn đủ tiền?}
    D -- Không đủ tiền / Underfunded --> Z[REVERT: InsufficientFunds]
    D -- Đủ tiền --> E{Quy tắc 4: Người gọi có thẩm quyền?}
    E -- Không thuộc Student/Sponsor/Verifier --> W[REVERT: NotStudent]
    E -- Hợp lệ toàn bộ --> F[Chuyển ETH trực tiếp về đúng ví sinh viên & Emit Event]
```

### 2.1. Không Giải Ngân Hai Lần Cho Cùng Một Mốc (No Double Disbursement)
- **Cơ chế trạng thái một chiều (One-way State Transition):** Mỗi mốc học bổng chỉ được chuyển sang trạng thái `Disbursed` đúng 01 lần duy nhất trong toàn bộ vòng đời.
- **Kiểm soát Checks-Effects-Interactions (CEI):** Khi thực hiện lệnh giải ngân, hợp đồng kiểm tra cờ `milestone.status == MilestoneStatus.Approved`, ngay lập tức cập nhật trạng thái `milestone.status = MilestoneStatus.Disbursed` và cộng dồn `scholarship.releasedAmount += milestone.amount` trước khi thực hiện chuyển Native ETH.
- **Chống tấn công tái nhập (Reentrancy Guard):** Sử dụng khóa chống tái nhập `nonReentrant` cho toàn bộ các hàm nhận và chuyển ETH (`fundScholarship`, `releaseMilestone`).

### 2.2. Không Giải Ngân Khi Chưa Đủ Điều Kiện (No Unapproved Disbursement)
- **Khóa logic nghiêm ngặt:** Hàm giải ngân bắt buộc phải xác thực điều kiện `milestone.status == MilestoneStatus.Approved`. 
- Bất kỳ nỗ lực gọi giải ngân nào khi mốc đang ở trạng thái `Pending` (chờ nộp minh chứng) hoặc `Submitted` (mới nộp minh chứng, chưa được duyệt) đều bị lập tức đảo ngược giao dịch (revert) với lỗi `MilestoneNotApproved()`.
- Ngăn chặn việc sinh viên tự kích hoạt nhận tiền khi chưa có xác nhận từ người có thẩm quyền.

### 2.3. Không Giải Ngân Vượt Số Tiền Đã Cấp (Solvency & Overdraft Prevention)
- **Bảo toàn hạn mức ký quỹ:** Tổng số tiền giải ngân lũy kế của một suất học bổng tuyệt đối không bao giờ được vượt quá số tiền thực tế mà Nhà tài trợ đã nạp vào hợp đồng:
  $$\text{scholarship.releasedAmount} + \text{milestoneAmount} \le \text{scholarship.fundedAmount}$$
- **Hạch toán cô lập:** Nghiêm cấm việc lấy tiền ký quỹ của suất học bổng A để chi trả cho suất học bổng B. Nếu một suất học bổng chưa được nạp đủ tiền cho mốc tiếp theo, hệ thống sẽ từ chối giải ngân (`InsufficientFunds`) thay vì rút lẹm vào số dư của các suất khác.

### 2.4. Phân Quyền Thẩm Định & Chống Can Thiệp Trái Phép (Strict Role-Based Access Control)
- **Cơ chế thẩm định kép theo SPEC v1.0 Mục 6 Bước 4:**
  - Đối với các chương trình học bổng thông qua trường đại học / tổ chức chuyên môn: Người thẩm định độc lập (`verifier`) là người thực thi hàm `approveMilestone`.
  - Đối với các suất học bổng tài trợ trực tiếp của cá nhân/doanh nghiệp: Nhà tài trợ tạo suất (`s.sponsor`) có quyền thẩm định và phê duyệt trực tiếp mốc của sinh viên.
- **Chống can thiệp trái phép:**
  - Sinh viên tuyệt đối không thể tự phê duyệt minh chứng của chính mình (revert `NotSponsor`).
  - Người lạ (`stranger`) tuyệt đối không thể duyệt mốc hoặc can thiệp trái phép.
  - Quản trị viên/Người triển khai tuyệt đối không có hàm rút tiền ký quỹ về ví cá nhân.

---

## 3. Quyền Quản Trị & Phân Định Trách Nhiệm (Governance & RBAC)

Hệ thống trả lời tường minh 3 câu hỏi cốt lõi về quyền quản trị và thực thi:

| Câu Hỏi Trọng Yếu | Chủ Thể Thực Hiện | Vai Trò Kỹ Thuật | Phương Thức Tương Tác | Điều Kiện Ràng Buộc |
|:---|:---|:---:|:---|:---|
| **1. Ai tạo suất học bổng?** | **Nhà tài trợ (Sponsor)** | Caller / `s.sponsor` | `createScholarship(...)` | • Khai báo địa chỉ ví sinh viên hợp lệ (`!= address(0)` và `!= address(this)`).<br>• Khai báo danh sách số tiền từng mốc (`> 0`).<br>• Cam kết nạp đủ tiền vào hợp đồng. |
| **2. Ai xác nhận mốc?** | **Người thẩm định / Nhà tài trợ** | `verifier` hoặc `s.sponsor` | `approveMilestone(...)` | • Phải là Verifier độc lập hoặc chính Sponsor tạo suất.<br>• Mốc phải đang ở trạng thái đã nộp minh chứng (`Submitted`).<br>• Đã kiểm tra tính xác thực của minh chứng ngoại tuyến. |
| **3. Ai nộp minh chứng?** | **Sinh viên thụ hưởng (Student)** | Designated Beneficiary | `submitMilestone(...)` | • Chỉ đúng địa chỉ ví được gán cho suất (`msg.sender == scholarship.student`).<br>• Nộp chuỗi băm IPFS CID hợp lệ trước thời hạn mốc. |

### Các Vai Trò Khác Trong Hệ Thống:
- **Người xác thực (Verifier):**
  - Thực hiện thẩm định và phê duyệt các mốc học bổng độc lập.
  - Chuyển giao quyền Verifier cho địa chỉ mới hợp lệ thông qua hàm `setVerifier` (phát sinh event `VerifierUpdated`).
  - **Nguyên tắc phi lưu ký tối cao:** Verifier **tuyệt đối không có hàm rút tiền** quỹ của Nhà tài trợ hay sinh viên về ví cá nhân.
- **Cộng đồng & Kiểm toán viên (Public Observers):**
  - Xem và kiểm tra dữ liệu công khai trên hợp đồng qua các hàm view (`getScholarship`, `getMilestone`, `getMilestoneStatus`).
  - Lắng nghe và đối soát các sự kiện on-chain thông qua Blockchain Explorer (`ScholarshipCreated`, `ScholarshipFunded`, `MilestoneSubmitted`, `MilestoneApproved`, `ScholarshipReleased`, `VerifierUpdated`).

---

## 4. Tình Huống Người Dùng Bị Thiệt & Phương Án Phòng Ngừa (Adverse Scenarios & Mitigations)

Hệ thống nhận diện 4 tình huống người dùng có nguy cơ bị thiệt hại tài chính hoặc gián đoạn quyền lợi, từ đó thiết lập các giải pháp kỹ thuật phòng ngừa triệt để:

### 4.1. Tình Huống 1: Giải Ngân Nhầm Người (Wrong Recipient)
- **Kịch bản rủi ro:** Nhà tài trợ nhập nhầm địa chỉ ví khi tạo suất, hoặc sinh viên bị kẻ gian tráo địa chỉ ví nhận thưởng.
- **Thiệt hại:** Tiền học bổng của Nhà tài trợ rơi vào tay người lạ; sinh viên thực sự nỗ lực học tập không nhận được hỗ trợ.
- **Giải pháp phòng ngừa:**
  - *Kiểm tra địa chỉ hợp lệ tại gốc:* Revert ngay lập tức nếu `studentAddress == address(0)` hoặc là địa chỉ của chính hợp đồng `address(this)` (`InvalidAddress`).
  - *Địa chỉ ví bất biến (Immutability):* Sau khi suất đã tạo và nạp tiền, địa chỉ ví sinh viên được khóa cố định, không ai có thể đơn phương chỉnh sửa.
  - *Chuyển tiền trực tiếp:* Dù ai gọi `releaseMilestone`, tiền luôn chuyển về `s.student`.

### 4.2. Tình Huống 2: Giải Ngân Khi Chưa Đủ Điều Kiện (Disbursement Without Qualification)
- **Kịch bản rủi ro:** Sinh viên nộp tài liệu rác hoặc chưa hoàn thành mốc nhưng tiền vẫn bị chuyển ra khỏi quỹ.
- **Thiệt hại:** Quỹ học bổng của Nhà tài trợ bị bòn rút bất chính; suy giảm uy tín của chương trình học bổng.
- **Giải pháp phòng ngừa:**
  - *Máy trạng thái nghiêm ngặt (Strict State Machine):* Trạng thái mốc phải tuân thủ nghiêm ngặt luồng tuần tự: `Pending` $\rightarrow$ `Submitted` $\rightarrow$ `Approved` $\rightarrow$ `Disbursed`. Nghiêm cấm nhảy cóc trạng thái.
  - *Tách biệt quyền hạn:* Chỉ sinh viên có quyền nộp (`submitMilestone`), chỉ Verifier/Sponsor có quyền duyệt (`approveMilestone`). Sinh viên không thể tự duyệt mốc.
  - *Minh chứng công khai bất biến:* Mã băm IPFS CID được ghi vĩnh viễn trên blockchain cùng sự kiện `MilestoneSubmitted`, cho phép cộng đồng và Nhà tài trợ kiểm toán chéo bất cứ lúc nào.

### 4.3. Tình Huống 3: Giải Ngân Vượt Quỹ (Pool Overdraft / Insolvency)
- **Kịch bản rủi ro:** Suất học bổng cam kết 5 ETH nhưng Nhà tài trợ mới chỉ nạp 1 ETH; hoặc lỗi số học khiến hợp đồng giải ngân vượt quá số dư ký quỹ thực tế.
- **Thiệt hại:** Hợp đồng cạn kiệt thanh khoản; sinh viên hoàn thành mốc sau bị từ chối rút tiền dù đã đủ điều kiện; tiền của suất khác bị chiếm đoạt chéo.
- **Giải pháp phòng ngừa:**
  - *Hạch toán số dư ký quỹ độc lập (`fundedAmount` & `releasedAmount`):* Mỗi suất học bổng theo dõi riêng biến `fundedAmount` và `releasedAmount`.
  - *Kiểm tra đủ quỹ trước khi thanh toán (SPEC R4):* Áp dụng bắt buộc điều kiện tại `releaseMilestone`:
    ```solidity
    if (s.fundedAmount < s.releasedAmount + amountToRelease || address(this).balance < amountToRelease) {
        revert InsufficientFunds();
    }
    ```
  - *Linh hoạt tiến độ nạp quỹ:* Sinh viên có thể nộp minh chứng và được thẩm định mốc theo tiến độ học kỳ thực tế; quỹ bắt buộc phải được nạp đủ trước khi lệnh giải ngân được chấp thuận thực thi.

### 4.4. Tình Huống 4: Người Không Có Quyền Can Thiệp (Unauthorized Intervention)
- **Kịch bản rủi ro:** Hacker, bên thứ ba lạ mặt, hoặc Quản trị viên can thiệp rút trộm tiền hoặc chiếm đoạt quỹ học bổng.
- **Thiệt hại:** Sinh viên bị tước đoạt học bổng bất công; dòng tiền bị chuyển hướng trái phép.
- **Giải pháp phòng ngừa:**
  - *Kiểm soát truy cập nghiêm ngặt:* Mọi hàm thay đổi trạng thái đều được bảo vệ (`msg.sender == s.sponsor`, `msg.sender == s.student`, `msg.sender == verifier || msg.sender == s.sponsor`).
  - *Cam kết phi lưu ký (Non-custodial Commitment):* Tiền đã nạp vào suất học bổng bị khóa bất biến và chỉ có thể được giải ngân cho chính sinh viên thụ hưởng theo từng mốc hợp lệ.
  - *Hợp đồng không có backdoor rút tiền:* Không lập trình bất kỳ hàm "rút khẩn cấp" (`emergencyWithdraw`) hay quyền rút tiền tùy tiện nào cho phép Admin chuyển số dư hợp đồng về ví cá nhân.

---

## 5. Bảng Ánh Xạ Giữa Economic Rules Và Quy Tắc Kỹ Thuật (SPEC Rules R1–R10)

| Quy Tắc Kinh Tế | Quy Tắc SPEC Tương Ứng | Hàm Triển Khai Thực Tế | Custom Error / Event Trong Contract |
|:---|:---:|:---|:---|
| Nhà tài trợ tạo suất hợp lệ | **R1, R3** | `createScholarship(...)` | `InvalidAddress()`, `InvalidAmount()`, `ScholarshipCreated` |
| Ví sinh viên hợp lệ, không rỗng | **R2, R9** | `createScholarship(...)` | `InvalidAddress()` (chặn `address(0)` & `address(this)`) |
| Tiền ký quỹ đủ trước khi giải ngân | **R4** | `releaseMilestone(...)` | `InsufficientFunds()` |
| Sinh viên chính chủ nộp minh chứng | **R5** | `submitMilestone(...)` | `NotStudent()`, `MilestoneSubmitted` |
| Người có quyền mới được duyệt mốc | **R6** | `approveMilestone(...)` | `NotSponsor()`, `MilestoneNotFound()`, `MilestoneApproved` |
| Không giải ngân khi chưa duyệt | **R7** | `releaseMilestone(...)` | `MilestoneNotApproved()` |
| Không giải ngân 2 lần một mốc | **R8** | `releaseMilestone(...)` | `AlreadyReleased()` |
| Tiền về đúng ví sinh viên | **R9** | `releaseMilestone(...)` | `TransferFailed()`, `s.student.call{value: ...}` |
| Các hành động quan trọng phát sinh Event | **R10** | Toàn bộ hàm thay đổi trạng thái | `ScholarshipCreated`, `ScholarshipFunded`, `MilestoneSubmitted`, `MilestoneApproved`, `ScholarshipReleased`, `VerifierUpdated` |

---
> 🔗 **Liên kết nhanh:** [Trang chủ README](../README.md) • [Kế hoạch đồ án](PROJECT_PLAN.md) • [Đặc tả nghiệp vụ](SPEC.md) • [Quy tắc kinh tế](ECONOMIC_RULES.md) • [Nhật ký AI](AI_JOURNAL.md) • [GitHub Repo](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)
