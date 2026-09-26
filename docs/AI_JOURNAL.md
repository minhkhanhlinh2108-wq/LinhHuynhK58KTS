# Nhật Ký Ứng Dụng AI (AI Journal) - TrustScholar

Tài liệu này ghi lại toàn bộ quá trình sử dụng các mô hình Trí tuệ Nhân tạo (Generative AI) trong quá trình nghiên cứu, thiết kế, lập trình và kiểm thử dự án TrustScholar. Mục tiêu là duy trì tính trung thực học thuật, minh bạch hóa các quyết định kỹ thuật và kiểm soát chất lượng mã nguồn.

---

## 1. Hướng Dẫn & Tiêu Chuẩn Ghi Chép

Mỗi phiên làm việc có sử dụng AI cần được ghi chép theo cấu trúc chuẩn sau:
- **Ngày thực hiện (Date):** Thời điểm tương tác.
- **Nhiệm vụ (Task):** Mục tiêu kỹ thuật cần giải quyết trong bài Lab.
- **Prompt sử dụng (Prompt):** Câu lệnh/ngữ cảnh chi tiết cung cấp cho AI.
- **Phản hồi / Lỗi của AI (AI Output & Flaws):** Những điểm chưa chính xác, ảo giác (hallucinations), thiếu sót bảo mật hoặc logic kinh tế chưa phù hợp do AI đưa ra.
- **Quyết định sửa chữa của nhóm (Human Verification & Correction):** Phân tích của nhóm và cách thức tinh chỉnh, viết lại hoặc cải tiến để đảm bảo an toàn và đúng yêu cầu kỹ thuật.
- **Kết quả đạt được (Outcome):** Sản phẩm/tệp tài liệu hoàn thiện sau khi kiểm chứng.

---

## 2. Nhật Ký Chi Tiết Từng Bài Lab (Lab 08 – Lab 15)

### Lab 08: Khởi Tạo Dự Án & Đặc Tả Nghiệp Vụ Ban Đầu

- **Ngày thực hiện:** 26/09/2026
- **Nhiệm vụ:** Khởi tạo cấu trúc dự án, xây dựng kế hoạch phân công 2 thành viên, đặc tả v0.1 và mô hình kinh tế chống gian lận cho TrustScholar.
- **Prompt sử dụng:**
  > *"Hãy đóng vai một kỹ sư phần mềm Web3, thiết kế cấu trúc đồ án giải ngân học bổng minh bạch TrustScholar cho nhóm 2 người luân phiên vai trò qua Lab 8-11 và Lab 12-15; xây dựng đặc tả v0.1 với 4 quy tắc kiểm thử nạp/duyệt/claim/refund; thiết lập quy tắc kinh tế kiểm soát dòng tiền, chống lạm dụng, phân quyền và các trường hợp người dùng bị thiệt hại."*
- **Phản hồi & Thiếu sót của AI phát hiện được:**
  1. *Ảo giác logic quản trị:* Ban đầu AI đề xuất quyền `admin` có thể can thiệp rút quỹ bất kỳ lúc nào để "xử lý tranh chấp". Nhóm nhận định đây là lỗ hổng bảo mật nghiêm trọng (nguy cơ Rug-pull tập trung).
  2. *Thiếu sót bảo vệ sinh viên:* AI chưa tính đến trường hợp sinh viên đạt điều kiện nhưng Nhà tài trợ đổi ý rút tiền trước khi sinh viên kịp claim, hoặc sinh viên bị mất private key trước khi nhận học bổng.
  3. *Lỗi kiểu dữ liệu nạp/rút:* AI đề xuất cho phép rút tiền nhiều lần tự do với số tiền tùy ý mà không có kiểm tra số dư cam kết (`committedAmount`), dễ dẫn đến cạn kiệt thanh khoản cho các sinh viên được duyệt sau.
- **Quyết định sửa chữa của nhóm:**
  - Thiết kế hợp đồng theo mô hình phi lưu ký (Non-custodial): Admin tuyệt đối không thể rút tiền quỹ của Nhà tài trợ.
  - Bổ sung khái niệm `committedAmount` và thời gian ân hạn (`GRACE_PERIOD`) để bảo vệ quyền lợi sinh viên đã được phê duyệt.
  - Thêm cơ chế đa chữ ký khẩn cấp (`emergencyUpdateRecipientWallet`) cho trường hợp sinh viên mất ví.
  - Quy định số tiền claim phải đúng bằng `grantAmount` được duyệt theo từng đợt để chống tấn công tái nhập (reentrancy) và sai lệch số dư.
- **Kết quả đạt được:** Hoàn thành trọn bộ 5 tài liệu chuẩn hóa: [README.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/README.md), [PROJECT_PLAN.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/PROJECT_PLAN.md), [SPEC.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md), [ECONOMIC_RULES.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/ECONOMIC_RULES.md), và [AI_JOURNAL.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/AI_JOURNAL.md).

---

### Lab 09: Thiết Kế Kiến Trúc & Interface Hợp Đồng
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Thiết kế interface `IScholarshipPool.sol` và cấu trúc dữ liệu lưu trữ (Storage Layout).
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 9)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chú các thiếu sót về kiểu dữ liệu, đóng gói gas struct khi AI gợi ý)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 10: Hiện Thực Hóa Core Smart Contracts
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Viết mã nguồn Solidity cho logic nạp quỹ, phê duyệt sinh viên và giải ngân tự động.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 10)*
- **Phản hồi & Lỗi của AI:** *(Sẽ kiểm tra các lỗi reentrancy, check-effects-interactions do AI sinh ra)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 11: Unit Test, Fuzzing & Kiểm Thử Bảo Mật Nội Bộ
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Xây dựng test suite tự động (Foundry/Hardhat), kiểm thử biên và quét phân tích tĩnh Slither.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 11)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các test cases bị AI bỏ sót hoặc mock sai ngữ cảnh)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 12: Phát Triển Giao Diện Web3 dApp
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Khởi tạo Frontend Dashboard cho Nhà tài trợ và Sinh viên, tích hợp kết nối ví Web3.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 12)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các lỗi tương thích RPC, xử lý state asynchronous trong React)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 13: Tích Hợp Hợp Đồng & Triển Khai Lên Testnet
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Deploy Smart Contract lên Sepolia/Arbitrum Testnet, verify contract và kết nối dApp.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 13)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép lỗi cấu hình script deploy, quản lý biến môi trường)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 14: Kiểm Thử Toàn Trình (E2E), Tối Ưu Gas & UAT
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Chạy kịch bản E2E toàn diện, đo lường chi phí Gas và tiến hành UAT với người dùng thử nghiệm.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 14)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các gợi ý tối ưu gas không hiệu quả hoặc làm giảm tính dễ đọc)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 15: Hoàn Thiện Đóng Gói, Tài Liệu Hóa & Báo Cáo Nghiệm Thu
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Đóng gói toàn bộ sản phẩm dApp, làm video demo, chuẩn bị slide và hoàn thiện tài liệu báo cáo.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 15)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các nội dung slide/kịch bản thuyết trình được AI hỗ trợ)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*
