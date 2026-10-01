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

### Chuyên Đề Đặc Tả: Chuẩn Hóa Đặc Tả Nghiệp Vụ & Bộ 10 Quy Tắc R1–R10 (TrustScholar SPEC v1.0)

- **Ngày thực hiện:** 01/10/2026
- **Nhiệm vụ:** Xây dựng đặc tả nghiệp vụ giải ngân học bổng minh bạch theo từng mốc (Milestone-based Scholarship Disbursement); chuẩn hóa tài liệu [SPEC.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) bao gồm mục đích, đối tượng, input/output, quyền hạn actor, quy trình nghiệp vụ 5 bước, bộ 10 quy tắc bất biến R1–R10, các tình huống ngoại lệ kèm Custom Errors, và xác lập ranh giới ngoài phạm vi (Out of Scope).
- **Prompt sử dụng:**
  > *"Mục tiêu của phần việc này là xây dựng đặc tả nghiệp vụ cho TrustScholar, chưa cần viết Smart Contract hoàn chỉnh. Dựa trên ý tưởng sản phẩm: Nhà tài trợ tạo suất học bổng, khóa/nạp quỹ; Sinh viên được chỉ định nhận học bổng, nộp minh chứng/mốc; Người có quyền xác nhận mốc; Khi mốc hợp lệ được xác nhận, Smart Contract cho phép giải ngân; Tiền chuyển đúng vào ví sinh viên đã đăng ký; Toàn bộ trạng thái và giao dịch quan trọng có thể truy vết trên blockchain. Tạo/cập nhật docs/SPEC.md với đầy đủ Mục đích, Đối tượng sử dụng, Input, Output, Actor và quyền, Quy trình nghiệp vụ, Quy tắc R1-R10, Trường hợp ngoại lệ, Ngoài phạm vi..."*
- **Phản hồi & Thiếu sót của AI phát hiện được:**
  1. *Xu hướng nhảy cóc sang code hợp đồng:* AI ban đầu có xu hướng viết ngay hợp đồng `ProjectCore.sol` hoặc hợp đồng mẫu hoàn chỉnh trước khi làm rõ ranh giới nghiệp vụ, vi phạm nguyên tắc "Spec First, Code Later" của công nghệ phần mềm.
  2. *Thiếu sót ràng buộc phân bổ mốc:* Khi chia nhỏ học bổng thành các mốc giải ngân, AI không tạo điều kiện kiểm tra tổng số tiền các mốc có khớp với tổng số tiền suất học bổng hay không (`sum(milestoneAmounts) == totalAmount`), dẫn tới nguy cơ kẹt quỹ hoặc cạn quỹ giữa chừng.
  3. *Nguy cơ DoS trong mô hình giải ngân tự động (Push vs Pull):* AI đề xuất giải ngân trực tiếp (Push Transfer) ngay trong hàm xác nhận mốc của Verifier. Nhóm phân tích thấy nếu ví sinh viên là một hợp đồng thông minh bị lỗi/tốn gas hoặc cố tình revert, giao dịch của Verifier sẽ thất bại vĩnh viễn, làm treo hệ thống.
  4. *Ảo giác về thẩm định minh chứng on-chain:* AI đề xuất đưa logic kiểm tra nội dung chứng chỉ/bảng điểm vào Smart Contract. Nhóm bác bỏ vì EVM không thể và không nên phân tích ngữ nghĩa tệp tài liệu off-chain; chỉ nên lưu trữ `proofHash` (IPFS CID) và giao quyền kiểm tra nội dung cho Verifier.
- **Quyết định sửa chữa của nhóm:**
  - Tuân thủ nghiêm ngặt phạm vi: Không viết file code `.sol` ở bước này; chỉ hoàn thiện tài liệu đặc tả [SPEC.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) và ghi chép [AI_JOURNAL.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/AI_JOURNAL.md).
  - Chuẩn hóa trọn vẹn 10 quy tắc cốt lõi từ R1 đến R10 với điều kiện kiểm thử độc lập, tương ứng với các Event truy vết on-chain (`ScholarshipCreated`, `FundDeposited`, `ProofSubmitted`, `MilestoneApproved`, `ScholarshipDisbursed`).
  - Định nghĩa rõ 10 trường hợp ngoại lệ cùng các mã lỗi Custom Errors (tiết kiệm gas hơn chuỗi `revert string`).
  - Phân định rõ 5 điểm Ngoài phạm vi (Out of Scope): Không xác minh giấy tờ thật, không kết nối ERP trường học, không xử lý fiat, không lưu PII on-chain, không thay thế ERP quản lý sinh viên.
  - Thiết lập danh mục 4 vấn đề cần Người 2 (Trần Thị Như Huỳnh - QA/Testing) kiểm tra chéo và đưa ra quyết định kiến trúc trước khi bước vào Lab 09 (Thiết kế Interface).
- **Kết quả đạt được:** Hoàn thành cập nhật [SPEC.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/SPEC.md) phiên bản v1.0 và cập nhật [AI_JOURNAL.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/AI_JOURNAL.md).

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
