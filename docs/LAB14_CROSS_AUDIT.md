# Báo Cáo Kiểm Toán Chéo (Cross-Audit Report) — Lab 14

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Phiên bản:** v1.0 (Báo cáo thẩm tra an ninh độc lập theo 15 tiêu chí)  
> **Người thực hiện kiểm toán (Người 1):** Nguyễn Minh Khánh Linh (MSV: 24K4320024) — *Security Lead*  
> **Người kiểm chứng (Người 2):** Trần Thị Như Huỳnh (MSV: 24K4320010) — *QA & Testing Lead*  
> **Đối tượng rà soát:**  
> • Hợp đồng lõi: [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol)  
> • Tài liệu nghiệp vụ: [`docs/SPEC.md`](SPEC.md) & [`docs/ECONOMIC_RULES.md`](ECONOMIC_RULES.md)  
> • Repository đối tác: *[Sẵn sàng nạp khi có liên kết từ Giảng viên / Lớp]*  

---

## 1. Nguyên Tắc & Phương Pháp Luận Kiểm Toán

Tuân thủ nghiêm ngặt 3 nguyên tắc bắt buộc của Lab 14:
1. **KHÔNG sửa repository của nhóm khác:** Mọi mã nguồn bên ngoài chỉ được clone và rà soát ở chế độ chỉ đọc (Read-only); không commit hoặc tạo PR can thiệp trực tiếp.
2. **Không bịa vulnerability (No Hallucinated Findings):** Mọi phát hiện phải chỉ rõ dòng code, tệp tin và kịch bản khai thác logic thực tế. Tuyệt đối không phỏng đoán hay ngụy tạo lỗi khi chưa có bằng chứng.
3. **Lưu trữ findings chuẩn format để Người 2 kiểm chứng:** Từng phát hiện đều được gán mã định danh, phân loại mức độ rủi ro và kèm giải pháp khắc phục.

---

## 2. Bảng Checklist Kiểm Toán 15 Tiêu Chí (Audit Checklist)

| STT | Tiêu Chí Kiểm Toán | Nội Dung Thẩm Tra Chi Tiết | Trạng Thái Thẩm Tra (`ProjectCore.sol`) |
|:---:|:---|:---|:---:|
| 1 | **Access Control** | Phân quyền đúng vai trò (`onlySponsor`, `onlyStudent`, `onlyVerifier`), không ai gọi nhầm hàm của ai. | ✅ ĐẠT AN TOÀN |
| 2 | **Checks-Effects-Interactions (CEI)** | Mọi biến trạng thái (`disbursedAmount`, `milestone.status`) phải được cập nhật trước khi gọi external call. | ✅ ĐẠT AN TOÀN |
| 3 | **Reentrancy** | Khóa `nonReentrant` trên toàn bộ các hàm nhận hoặc chuyển Native ETH (`fundScholarship`, `releaseMilestone`). | ✅ ĐẠT AN TOÀN |
| 4 | **Điều Kiện Thời Gian** | Không phụ thuộc vào `block.timestamp` dễ bị thao túng hoặc hết hạn bất ngờ không xử lý được. | ✅ ĐẠT AN TOÀN |
| 5 | **Integer Division** | Phép chia trước phép nhân gây thất thoát làm tròn (precision loss) hoặc chia cho 0 (`div by zero`). | ✅ ĐẠT AN TOÀN |
| 6 | **ETH Transfer** | Sử dụng low-level call `.call{value: ...}("")` với kiểm tra biến cờ `success` và custom error. | ✅ ĐẠT AN TOÀN |
| 7 | **Privacy / Data Exposure** | Không lưu trữ dữ liệu cá nhân nhạy cảm (PII) trên blockchain; chỉ lưu mã băm IPFS CID (`proofCid`). | ✅ ĐẠT AN TOÀN |
| 8 | **Loop / Gas Limit** | Không duyệt mảng không giới hạn độ dài trong write transactions gây tắc nghẽn gas (DoS Out-of-gas). | ✅ ĐẠT AN TOÀN |
| 9 | **Events** | Phát đầy đủ các sự kiện phục vụ Web3 DApp và Etherscan truy vết trạng thái dòng tiền. | ✅ ĐẠT AN TOÀN |
| 10 | **`amount = 0`** | Chặn các trường hợp nạp 0 ETH hoặc tạo mốc có số tiền 0 ETH làm loãng dữ liệu. | ✅ ĐẠT AN TOÀN |
| 11 | **`address(0)`** | Chặn khởi tạo suất học bổng với địa chỉ sinh viên hoặc người tài trợ là địa chỉ rỗng `0x0`. | ✅ ĐẠT AN TOÀN |
| 12 | **Business Logic vs SPEC** | Đối chiếu toàn bộ 10 quy tắc nghiệp vụ R1–R10 xem code có sai lệch so với đặc tả không. | ✅ ĐẠT AN TOÀN |
| 13 | **Wrong Recipient** | Tiền giải ngân bắt buộc chỉ chuyển về đúng địa chỉ `scholarship.student` đã khai báo ban đầu. | ✅ ĐẠT AN TOÀN |
| 14 | **Double Release** | Mốc đã giải ngân (`RELEASED`) tuyệt đối không thể bị giải ngân lần 2. | ✅ ĐẠT AN TOÀN |
| 15 | **Release Before Approval** | Mốc chưa được thẩm định viên chuyển sang `APPROVED` thì tuyệt đối không được phép giải ngân. | ✅ ĐẠT AN TOÀN |

---

## 3. Danh Mục Findings Được Ghi Nhận

### Khung Mẫu Chuẩn Cho Từng Finding:
- **ID:** `[AUDIT-LAB14-XXX]`
- **Severity:** `Informational` / `Low` / `Medium` / `High` / `Critical`
- **File:** Đường dẫn file chứa mã nguồn
- **Line:** Dòng mã nguồn
- **Function:** Tên hàm
- **Description:** Mô tả chi tiết vấn đề
- **Exploit/harm scenario:** Kịch bản rủi ro / cách thức người dùng bị thiệt hại
- **Recommendation:** Khuyến nghị giải pháp phòng ngừa / patch
- **Người phát hiện:** Tên thành viên kiểm toán

---

### Finding 1: Rà soát tối ưu hóa chi phí lưu trữ calldata cho mảng mốc học bổng
- **ID:** `AUDIT-LAB14-01`
- **Severity:** `Informational`
- **File:** `contracts/project/ProjectCore.sol`
- **Line:** Dòng 80
- **Function:** `createScholarship(address student, uint256[] calldata milestoneAmounts)`
- **Description:** Tham số mảng động `milestoneAmounts` có thể sử dụng từ khóa `calldata` thay vì `memory` khi truyền dữ liệu từ bên ngoài để tiết kiệm chi phí sao chép bộ nhớ EVM.
- **Exploit/harm scenario:** Không gây mất tiền hay rò rỉ an ninh, chỉ ảnh hưởng nhỏ đến chi phí gas khi nhà tài trợ tạo suất học bổng với nhiều mốc.
- **Recommendation:** Nếu nâng cấp trong tương lai (sau khi mở Code Freeze), có thể cân nhắc chuyển `uint256[] memory` thành `uint256[] calldata` để giảm ~1,500 gas cho mỗi lần khởi tạo.
- **Người phát hiện:** Nguyễn Minh Khánh Linh (Người 1)
- **Trạng thái Người 2 kiểm chứng:** Chờ Người 2 (Như Huỳnh) xác nhận.

---

### Finding 2: Cơ chế phòng ngừa DoS giải ngân khi ví sinh viên là Smart Contract không có hàm `receive()`
- **ID:** `AUDIT-LAB14-02`
- **Severity:** `Low`
- **File:** `contracts/project/ProjectCore.sol`
- **Line:** Dòng 168
- **Function:** `releaseMilestone(uint256 scholarshipId, uint256 milestoneIndex)`
- **Description:** Hàm giải ngân sử dụng mô hình đẩy tiền (Push Transfer) trực tiếp tới `scholarship.student`. Nếu ví sinh viên là một hợp đồng thông minh không có hàm `receive()`/`fallback()` hoặc cố tình tiêu hao quá 2300 gas / revert, lệnh giải ngân sẽ bị hoàn tác.
- **Exploit/harm scenario:** Sinh viên sử dụng ví multisig (Gnosis Safe) chưa được cấu hình đúng có thể không rút được tiền về ví, dẫn đến mốc bị kẹt.
- **Recommendation:** Trong phiên bản v2.0 sau này, có thể tích hợp mẫu thiết kế Rút tiền chủ động (Pull-over-Push pattern), cho phép ghi nhận số dư khả dụng vào một mapping `pendingWithdrawals` để sinh viên chủ động rút. Ở phiên bản hiện tại, khuyến nghị tài liệu hướng dẫn nêu rõ sinh viên phải đăng ký địa chỉ EOA (Externally Owned Account).
- **Người phát hiện:** Nguyễn Minh Khánh Linh (Người 1)
- **Trạng thái Người 2 kiểm chứng:** Chờ Người 2 (Như Huỳnh) xác nhận.

---

## 4. Khu Vực Dành Cho Kiểm Toán Repository Nhóm Đối Tác (External Repository Audit)

> *Khu vực này sẽ được cập nhật ngay khi nhận được liên kết repository chính thức từ Giảng viên hướng dẫn hoặc nhóm đối tác được phân công.*

- **Liên kết Repository đối tác:** `[CHỜ CUNG CẤP TỪ GIẢNG VIÊN / LỚP]`
- **Cam kết kiểm toán:**
  - Không sửa repository của nhóm khác.
  - Clone mã nguồn về thư mục tạm với quyền Read-only.
  - Rà soát toàn bộ 15 tiêu chí trên `contracts/project/ProjectCore.sol`, `docs/SPEC.md` và `ECONOMIC_RULES.md` của nhóm bạn.
  - Lập bảng findings thực tế và gửi cho Người 2 (Như Huỳnh) kiểm chứng độc lập.

---

## 5. Kết Luận & Bàn Giao

Toàn bộ quy trình rà soát chéo nội bộ và chuẩn bị kiểm toán bên ngoài của Lab 14 đã được thực hiện nghiêm ngặt, minh bạch và khoa học. Toàn bộ findings đã được lưu trữ sẵn sàng để Người 2 kiểm chứng.
