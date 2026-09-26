# Đặc Tả Kỹ Thuật (System Specification v0.1) - TrustScholar

Tài liệu này xác định các quy tắc nghiệp vụ cốt lõi, có thể kiểm thử độc lập (testable rules) cho hợp đồng thông minh quản lý quỹ học bổng `ScholarshipPool`.

---

## Danh Mục Quy Tắc Kiểm Thử (Testable Rules)

---

### Quy Tắc 1 (RULE-01): Nạp Quỹ Học Bổng (Deposit Scholarship Fund)

- **Mục tiêu:** Cho phép Nhà tài trợ khởi tạo và nạp tiền (ETH hoặc ERC-20) vào một hồ bơi học bổng cụ thể.
- **Ai được làm gì (Actor & Action):**
  - **Actor:** Bất kỳ ai sở hữu địa chỉ ví hợp lệ đóng vai trò Nhà tài trợ (`sponsor`).
  - **Action:** Gọi hàm `depositFund(uint256 poolId)` kèm theo tiền (ETH hoặc phê duyệt chuyển token ERC-20).
- **Khi nào (Preconditions & Timing):**
  - Hồ bơi `poolId` đã được tạo trên hệ thống và đang ở trạng thái nhận quỹ (`FundStatus.Open`).
  - Thời gian hiện tại `block.timestamp` phải nhỏ hơn thời hạn nộp quỹ của đợt học bổng (`depositDeadline`).
  - Hợp đồng không ở trạng thái tạm dừng khẩn cấp (`paused == false`).
- **Giới hạn bao nhiêu (Limits & Parameters):**
  - Số tiền nạp mỗi lần (`amount`) phải lớn hơn hoặc bằng mức nạp tối thiểu: `amount >= MIN_DEPOSIT_AMOUNT` (ví dụ: `0.01 ETH` hoặc `10 USDC`).
  - Tổng số tiền nạp vào quỹ không được vượt quá mức trần tối đa của hồ bơi: `totalDeposited + amount <= poolTargetCap`.
- **Lỗi thì sao (Revert & Error Handling):**
  - Nếu `amount < MIN_DEPOSIT_AMOUNT` $\rightarrow$ Revert với lỗi `DepositAmountTooLow(uint256 sent, uint256 minimum)`.
  - Nếu `block.timestamp >= depositDeadline` $\rightarrow$ Revert với lỗi `DepositPeriodClosed(uint256 currentTimestamp, uint256 deadline)`.
  - Nếu vượt trần `poolTargetCap` $\rightarrow$ Revert với lỗi `PoolCapExceeded(uint256 currentTotal, uint256 attempted)`.
  - Khi thành công: Cập nhật số dư `pool.balance += amount`, phát sự kiện `FundDeposited(uint256 indexed poolId, address indexed sponsor, uint256 amount)`.

---

### Quy Tắc 2 (RULE-02): Duyệt Điều Kiện Nhận Học Bổng (Approve Eligibility)

- **Mục tiêu:** Xác thực và đưa sinh viên vào danh sách người thụ hưởng được cấp học bổng sau khi đã kiểm tra hồ sơ đạt yêu cầu.
- **Ai được làm gì (Actor & Action):**
  - **Actor:** Địa chỉ được phân quyền quản trị hồ bơi (`poolOwner` / Nhà tài trợ) hoặc tài khoản được ủy quyền kiểm định (`VERIFIER_ROLE`).
  - **Action:** Gọi hàm `approveRecipient(uint256 poolId, address studentAddress, uint256 grantAmount, uint256 claimUnlockTime)`.
- **Khi nào (Preconditions & Timing):**
  - Hồ bơi `poolId` đã hoàn thành giai đoạn nạp quỹ và chuyển sang trạng thái xét duyệt (`FundStatus.Active`).
  - Sinh viên chưa từng được duyệt trong cùng đợt học bổng này (`isApproved[poolId][studentAddress] == false`).
  - Địa chỉ sinh viên `studentAddress != address(0)` và không trùng với địa chỉ của nhà tài trợ/người duyệt.
- **Giới hạn bao nhiêu (Limits & Parameters):**
  - Hạn mức học bổng cấp cho một sinh viên phải nằm trong ngưỡng: `MIN_GRANT <= grantAmount <= MAX_GRANT_PER_STUDENT`.
  - Tổng số tiền cam kết cấp cho các sinh viên đã duyệt không được vượt quá số dư hiện khả dụng của hồ bơi:
    `committedAmount + grantAmount <= pool.balance`.
  - Thời điểm mở khóa giải ngân: `claimUnlockTime >= block.timestamp`.
- **Lỗi thì sao (Revert & Error Handling):**
  - Nếu người gọi không có quyền $\rightarrow$ Revert với lỗi `UnauthorizedCaller(address caller)`.
  - Nếu sinh viên đã được duyệt trước đó $\rightarrow$ Revert với lỗi `RecipientAlreadyApproved(address student)`.
  - Nếu số tiền duyệt vượt quá số dư chưa cam kết của hồ bơi $\rightarrow$ Revert với lỗi `InsufficientPoolLiquidity(uint256 available, uint256 requested)`.
  - Nếu `grantAmount` nằm ngoài khoảng quy định $\rightarrow$ Revert với lỗi `InvalidGrantAmount(uint256 amount)`.
  - Khi thành công: Ghi nhận thông tin người thụ hưởng, tăng `pool.committedAmount`, phát sự kiện `RecipientApproved(uint256 indexed poolId, address indexed student, uint256 amount, uint256 unlockTime)`.

---

### Quy Tắc 3 (RULE-03): Sinh Viên Rút Tiền Học Bổng (Claim Scholarship)

- **Mục tiêu:** Sinh viên tự rút khoản tiền học bổng đã được phê duyệt trực tiếp về ví cá nhân mà không qua trung gian nào giữ hộ.
- **Ai được làm gì (Actor & Action):**
  - **Actor:** Chính chủ địa chỉ ví của sinh viên thụ hưởng (`msg.sender == studentAddress`).
  - **Action:** Gọi hàm `claimScholarship(uint256 poolId)`.
- **Khi nào (Preconditions & Timing):**
  - Địa chỉ ví `msg.sender` đã được duyệt hợp lệ cho hồ bơi `poolId` (`isApproved[poolId][msg.sender] == true`).
  - Sinh viên chưa rút khoản học bổng này (`hasClaimed[poolId][msg.sender] == false`).
  - Thời gian hiện tại đã đến hoặc vượt qua mốc thời gian mở khóa: `block.timestamp >= claimUnlockTime`.
  - Hợp đồng không bị tạm dừng (`paused == false`).
- **Giới hạn bao nhiêu (Limits & Parameters):**
  - Rút chính xác bằng khoản tiền đã được duyệt (`grantAmount`). Không cho phép rút từng phần tùy tiện để tránh phức tạp trạng thái và tấn công tái nhập.
  - Mỗi sinh viên chỉ được gọi rút đúng 01 lần cho mỗi đợt học bổng được phê duyệt.
- **Lỗi thì sao (Revert & Error Handling):**
  - Nếu `msg.sender` không nằm trong danh sách được duyệt $\rightarrow$ Revert với lỗi `NotApprovedRecipient(address sender)`.
  - Nếu sinh viên đã rút rồi $\rightarrow$ Revert với lỗi `ScholarshipAlreadyClaimed(address sender)`.
  - Nếu gọi rút trước thời điểm mở khóa (`block.timestamp < unlockTime`) $\rightarrow$ Revert với lỗi `ClaimNotUnlockedYet(uint256 currentTime, uint256 unlockTime)`.
  - Khi thành công:
    - Đánh dấu `hasClaimed[poolId][msg.sender] = true`.
    - Trừ số dư quỹ: `pool.balance -= grantAmount; pool.committedAmount -= grantAmount;`.
    - Chuyển an toàn số tiền (sử dụng Call value có ReentrancyGuard hoặc `SafeERC20.safeTransfer`) tới `msg.sender`.
    - Phát sự kiện `ScholarshipClaimed(uint256 indexed poolId, address indexed student, uint256 amount)`.

---

### Quy Tắc 4 (RULE-04): Thu Hồi Quỹ Dư Chưa Sử Dụng (Refund Unclaimed Funds)

- **Mục tiêu:** Cho phép Nhà tài trợ rút lại phần tiền còn thừa trong hồ bơi khi kỳ học bổng kết thúc mà không có sinh viên nhận hoặc sau thời hạn claim ân hạn (grace period).
- **Ai được làm gì (Actor & Action):**
  - **Actor:** Nhà tài trợ khởi tạo hồ bơi (`pool.sponsor == msg.sender`).
  - **Action:** Gọi hàm `refundUnclaimedFunds(uint256 poolId)`.
- **Khi nào (Preconditions & Timing):**
  - Đợt học bổng đã hết hạn toàn bộ, bao gồm cả thời gian ân hạn rút tiền cho sinh viên:
    `block.timestamp > pool.expiryTime + GRACE_PERIOD` (ví dụ: ân hạn 30 ngày sau khi kỳ kết thúc).
  - Hoặc hồ bơi bị hủy bỏ hợp lệ trước khi bất kỳ sinh viên nào được duyệt (`committedAmount == 0`).
- **Giới hạn bao nhiêu (Limits & Parameters):**
  - Số tiền được rút hoàn lại chỉ là phần **số dư chưa cam kết** hoặc số tiền học bổng của sinh viên đã quá hạn không đến claim:
    `refundableAmount = pool.balance - remainingCommittedToActiveStudents`.
  - Không được phép rút phần tiền của sinh viên đã đủ điều kiện đang trong thời hạn hợp lệ chờ claim.
- **Lỗi thì sao (Revert & Error Handling):**
  - Nếu người gọi không phải là Nhà tài trợ tạo quỹ $\rightarrow$ Revert với lỗi `OnlySponsorCanRefund(address caller)`.
  - Nếu thời gian ân hạn chưa kết thúc $\rightarrow$ Revert với lỗi `RefundPeriodNotReached(uint256 currentTime, uint256 allowedRefundTime)`.
  - Nếu số dư có thể hoàn trả bằng 0 $\rightarrow$ Revert với lỗi `NoRefundableBalance()`.
  - Khi thành công:
    - Giảm số dư hồ bơi về 0 tương ứng.
    - Chuyển khoản hoàn trả về ví của Nhà tài trợ.
    - Đóng hồ bơi (`pool.status = FundStatus.Closed`).
    - Phát sự kiện `FundsRefunded(uint256 indexed poolId, address indexed sponsor, uint256 amount)`.
