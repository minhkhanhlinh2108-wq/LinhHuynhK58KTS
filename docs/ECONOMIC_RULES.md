# Quy Tắc Kinh Tế & Kiểm Soát Rủi Ro (Economic Rules) - TrustScholar

Tài liệu này xác định mô hình kinh tế, cơ chế khuyến khích, phân định quyền hạn và các phương án giảm thiểu rủi ro tài chính cho nền tảng giải ngân học bổng TrustScholar.

---

## 1. Dòng Tiền & Quyền Lợi (Cashflow & Value Incentives)

### 1.1. Luồng Dòng Tiền (Value Flow)
- **Cơ chế phi lưu ký (Non-custodial):** Tiền quỹ không chuyển về ví cá nhân của bất kỳ quản trị viên nào, mà được khóa trong Smart Contract `ScholarshipPool`.
- **Dòng tiền vào (Inflow):**
  - Nhà tài trợ (Sponsors) chuyển khoản ký quỹ bằng tiền mã hóa (ETH hoặc Stablecoin như USDC/USDT) vào hồ bơi học bổng.
  - Phí giao dịch (Gas fee) khi nạp quỹ do Nhà tài trợ tự chi trả.
- **Dòng tiền ra (Outflow):**
  - Giải ngân trực tiếp 100% đến ví cá nhân của sinh viên thụ hưởng sau khi đáp ứng các điều kiện giải ngân.
  - Tuyệt đối **không thu phí hoa hồng hoặc phí nền tảng** trên số tiền học bổng của sinh viên (`Zero platform fee for students`).
- **Khoản tiền dư thừa (Residual Flow):**
  - Nếu hết thời gian ân hạn mà sinh viên không rút hoặc không xét duyệt hết suất học bổng, tiền dư được hoàn trả đầy đủ về ví Nhà tài trợ.

### 1.2. Quyền Lợi & Khuyến Khích Của Các Bên
- **Nhà tài trợ:**
  - Được bảo đảm tiền cấp phát minh bạch 100%, có thể kiểm chứng mọi lúc trên sổ cái blockchain.
  - Nhận huy hiệu On-chain (Sponsor Impact NFT/SBT) ghi nhận đóng góp xã hội minh bạch, phục vụ việc đối soát thuế và trách nhiệm xã hội doanh nghiệp (CSR).
  - Có quyền thu hồi vốn nếu dự án học bổng không tìm được ứng viên phù hợp sau thời gian quy định.
- **Sinh viên:**
  - Nhận trọn vẹn số tiền học bổng mà không bị khấu trừ trung gian.
  - Tự chủ rút tiền về ví cá nhân ngay khi tới hạn mở khóa giải ngân mà không cần làm đơn từ xin xỏ phức tạp.
- **Đơn vị thẩm định (Nhà trường/Verifiers):**
  - Giảm thiểu 90% chi phí hành chính và thủ tục đối soát tiền mặt.
  - Nâng cao uy tín học viện nhờ sự minh bạch và ứng dụng công nghệ Web3 hiện đại.

---

## 2. Giới Hạn Chống Lạm Dụng (Abuse Prevention & Anti-Sybil)

Để bảo vệ nguồn quỹ khỏi các hành vi trục lợi, tấn công Sybil hoặc gian lận, hệ thống thiết lập các giới hạn cứng (hard caps) trên Smart Contract:

1. **Hạn mức cấp tối đa trên từng sinh viên (Per-Student Grant Cap):**
   - Mỗi sinh viên chỉ được nhận tối đa `MAX_GRANT_PER_STUDENT` (ví dụ: tối đa 2.000 USDC / kỳ học).
   - Ngăn chặn nguy cơ người duyệt thông đồng dồn toàn bộ quỹ lớn cho một tài khoản duy nhất.
2. **Ngăn chặn tấn công danh tính ảo (Anti-Sybil & Whitelist):**
   - Địa chỉ ví nhận học bổng phải được định danh hoặc xác thực chữ ký (ECDSA Signature / Merkle Proof) từ cổng dữ liệu sinh viên của nhà trường.
   - Một mã số sinh viên (MSSV) thực tế chỉ được gắn với duy nhất 01 địa chỉ ví trong mỗi đợt học bổng (`hash(Student_ID) => wallet_address`).
3. **Mức nạp quỹ tối thiểu (Minimum Pool Deposit):**
   - Đặt ngưỡng tối thiểu `MIN_DEPOSIT_AMOUNT` (ví dụ: 0.05 ETH hoặc 100 USDC) cho mỗi lần nạp quỹ nhằm ngăn chặn hành vi gửi vi giao dịch rác (dust spam) làm phình to dữ liệu contract.
4. **Cơ chế thời gian mở khóa từng đợt (Vesting / Tranche Distribution):**
   - Với các gói học bổng toàn phần có giá trị lớn, tiền không giải ngân một lần duy nhất mà chia thành nhiều kỳ (ví dụ: đầu kỳ I, đầu kỳ II).
   - Mỗi kỳ yêu cầu một mốc thời gian mở khóa riêng biệt (`claimUnlockTime`) kèm theo điều kiện duy trì GPA tương ứng.

---

## 3. Quyền Quản Trị & Kiểm Soát Truy Cập (Governance & Access Control)

Hệ thống áp dụng mô hình phân quyền chặt chẽ theo chuẩn `AccessControl` của OpenZeppelin:

| Vai Trò (Role) | Chủ Thể Nắm Giữ | Quyền Hạn Thực Thi | Giới Hạn Nghiệp Vụ |
|:---|:---|:---|:---|
| `DEFAULT_ADMIN_ROLE` | Đội ngũ phát triển / Multi-sig của Hội đồng | • Nâng cấp contract (nếu có proxy).<br>• Cấu hình các tham số hệ thống chung.<br>• Phân quyền / gỡ quyền `VERIFIER_ROLE`. | **Không có quyền** rút tiền từ bất kỳ hồ bơi học bổng nào của Nhà tài trợ vào ví admin. |
| `SPONSOR_ROLE` | Nhà tài trợ sở hữu hồ bơi | • Khởi tạo hồ bơi học bổng mới.<br>• Nạp thêm quỹ vào hồ bơi.<br>• Rút lại tiền thừa sau thời gian ân hạn (`refund`). | Chỉ thao tác trên đúng hồ bơi do chính mình tạo ra (`pool.sponsor == msg.sender`). |
| `VERIFIER_ROLE` | Phòng Công tác SV / Hội đồng xét duyệt | • Phê duyệt danh sách sinh viên đủ điều kiện (`approveRecipient`).<br>• Cập nhật minh chứng kết quả học tập. | Chỉ được duyệt trong phạm vi số dư khả dụng của quỹ, không thể tự chuyển tiền ra ngoài. |

### Cơ Chế Dừng Khẩn Cấp (Circuit Breaker)
- Kế thừa `Pausable` từ OpenZeppelin: Khi phát hiện dấu hiệu bất thường hoặc lỗ hổng bảo mật zero-day, Admin có quyền kích hoạt trạng thái `pause()` để đóng băng mọi hành động rút tiền/duyệt mới, bảo vệ số dư tài sản cho đến khi sự cố được khắc phục.

---

## 4. Tình Huống Người Dùng Bị Thiệt & Phương Án Giảm Thiểu (Adverse Scenarios & Mitigations)

| Tình Huống Bất Lợi | Đối Tượng Bị Thiệt | Nguyên Nhân Cốt Lõi | Phương Án Kỹ Thuật Giảm Thiểu (Mitigation) |
|:---|:---:|:---|:---|
| **1. Biến động giá Token (Price Volatility)** | Sinh viên & Nhà tài trợ | Nếu trao học bổng bằng đồng tiền biến động mạnh (như ETH), giá trị quy đổi sang học phí thực tế có thể giảm sâu khi đến hạn claim. | • Mặc định ưu tiên sử dụng Stablecoin (USDC/USDT) cho các quỹ học bổng gắn liền với chi phí sinh hoạt/học phí.<br>• Hỗ trợ hiển thị tỷ giá tham chiếu Oracle (Chainlink Price Feeds) nếu dùng ETH. |
| **2. Sinh viên bị mất quyền kiểm soát ví (Lost Key/Hacked)** | Sinh viên | Sinh viên bị lộ private key hoặc mất truy cập vào ví đã đăng ký nhận học bổng trước khi gọi `claim`. | • Cơ chế đổi ví khẩn cấp (`emergencyUpdateRecipientWallet`): Yêu cầu Verifier và Nhà tài trợ đồng ký (Multi-sig/chữ ký kép) xác thực danh tính ngoại tuyến của sinh viên để chuyển quyền nhận sang ví mới an toàn. |
| **3. Nhà tài trợ rút tiền sớm (Rug-pull / Backing out)** | Sinh viên | Nhà tài trợ đổi ý, cố tình hủy quỹ khi sinh viên đã hoàn thành xuất sắc kỳ học nhưng chưa kịp gọi hàm `claim`. | • Khóa quỹ bắt buộc (Timelock/Commitment Lock): Tiền đã cam kết cho sinh viên (`committedAmount`) sẽ bị khóa bất khả xâm phạm. Nhà tài trợ **chỉ** được hoàn tiền sau khi quá hạn ân hạn (`expiryTime + GRACE_PERIOD`) mà sinh viên không nhận. |
| **4. Đơn vị xác thực bỏ bê / Chậm duyệt (Verifier Inaction)** | Sinh viên & Nhà tài trợ | Trường hoặc bên thẩm định chậm trễ hoặc từ chối xử lý hồ sơ khiến quỹ bị treo quá hạn. | • Cơ chế Fallback / Timeout: Nếu Verifier không duyệt đúng hạn, quyền duyệt được trao trả tạm thời cho chính Nhà tài trợ để can thiệp trực tiếp hoặc hoàn tiền cho Nhà tài trợ để chuyển sang quỹ khác. |
| **5. Sinh viên không đủ Gas fee để claim** | Sinh viên | Ví sinh viên chỉ có địa chỉ nhận nhưng không có ETH làm phí giao dịch mạng để thực hiện giao dịch `claim`. | • Trong lộ trình Lab 13–14, tích hợp cơ chế tài trợ gas (Account Abstraction ERC-4337 / Biconomy Gasless Paymaster) để trừ thẳng gas vào phần thưởng hoặc cho phép Nhà tài trợ tài trợ phí rút cho sinh viên. |
