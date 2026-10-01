# Nhật Ký Ứng Dụng AI (AI Journal) - TrustScholar

> **Dự án:** TrustScholar — Giải ngân học bổng minh bạch trên Blockchain  
> **Repository GitHub:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  
> **Điều hướng nhanh:** [Trang chủ README](../README.md) | [Đặc Tả Nghiệp Vụ (SPEC.md)](SPEC.md) | [Kế Hoạch Đồ Án (PROJECT_PLAN.md)](PROJECT_PLAN.md) | [Quy Tắc Kinh Tế (ECONOMIC_RULES.md)](ECONOMIC_RULES.md)  
> **Mục tiêu:** Tài liệu này ghi lại toàn bộ quá trình sử dụng các mô hình Trí tuệ Nhân tạo (Generative AI) trong quá trình nghiên cứu, thiết kế, lập trình và kiểm thử dự án TrustScholar. Mục tiêu là duy trì tính trung thực học thuật, minh bạch hóa các quyết định kỹ thuật và kiểm soát chất lượng mã nguồn.

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
- **Kết quả đạt được:** Hoàn thành trọn bộ 5 tài liệu chuẩn hóa: [README.md](../README.md), [PROJECT_PLAN.md](PROJECT_PLAN.md), [SPEC.md](SPEC.md), [ECONOMIC_RULES.md](ECONOMIC_RULES.md), và [AI_JOURNAL.md](AI_JOURNAL.md).

---

### Chuyên Đề Đặc Tả: Chuẩn Hóa Đặc Tả Nghiệp Vụ & Bộ 10 Quy Tắc R1–R10 (TrustScholar SPEC v1.0)

- **Ngày thực hiện:** 01/10/2026
- **Nhiệm vụ:** Xây dựng đặc tả nghiệp vụ giải ngân học bổng minh bạch theo từng mốc (Milestone-based Scholarship Disbursement); chuẩn hóa tài liệu [SPEC.md](SPEC.md) bao gồm mục đích, đối tượng, input/output, quyền hạn actor, quy trình nghiệp vụ 5 bước, bộ 10 quy tắc bất biến R1–R10, các tình huống ngoại lệ kèm Custom Errors, và xác lập ranh giới ngoài phạm vi (Out of Scope).
- **Prompt sử dụng:**
  > *"Mục tiêu của phần việc này là xây dựng đặc tả nghiệp vụ cho TrustScholar, chưa cần viết Smart Contract hoàn chỉnh. Dựa trên ý tưởng sản phẩm: Nhà tài trợ tạo suất học bổng, khóa/nạp quỹ; Sinh viên được chỉ định nhận học bổng, nộp minh chứng/mốc; Người có quyền xác nhận mốc; Khi mốc hợp lệ được xác nhận, Smart Contract cho phép giải ngân; Tiền chuyển đúng vào ví sinh viên đã đăng ký; Toàn bộ trạng thái và giao dịch quan trọng có thể truy vết trên blockchain. Tạo/cập nhật docs/SPEC.md với đầy đủ Mục đích, Đối tượng sử dụng, Input, Output, Actor và quyền, Quy trình nghiệp vụ, Quy tắc R1-R10, Trường hợp ngoại lệ, Ngoài phạm vi..."*
- **Phản hồi & Thiếu sót của AI phát hiện được:**
  1. *Xu hướng nhảy cóc sang code hợp đồng:* AI ban đầu có xu hướng viết ngay hợp đồng `ProjectCore.sol` hoặc hợp đồng mẫu hoàn chỉnh trước khi làm rõ ranh giới nghiệp vụ, vi phạm nguyên tắc "Spec First, Code Later" của công nghệ phần mềm.
  2. *Thiếu sót ràng buộc phân bổ mốc:* Khi chia nhỏ học bổng thành các mốc giải ngân, AI không tạo điều kiện kiểm tra tổng số tiền các mốc có khớp với tổng số tiền suất học bổng hay không (`sum(milestoneAmounts) == totalAmount`), dẫn tới nguy cơ kẹt quỹ hoặc cạn quỹ giữa chừng.
  3. *Nguy cơ DoS trong mô hình giải ngân tự động (Push vs Pull):* AI đề xuất giải ngân trực tiếp (Push Transfer) ngay trong hàm xác nhận mốc của Verifier. Nhóm phân tích thấy nếu ví sinh viên là một hợp đồng thông minh bị lỗi/tốn gas hoặc cố tình revert, giao dịch của Verifier sẽ thất bại vĩnh viễn, làm treo hệ thống.
  4. *Ảo giác về thẩm định minh chứng on-chain:* AI đề xuất đưa logic kiểm tra nội dung chứng chỉ/bảng điểm vào Smart Contract. Nhóm bác bỏ vì EVM không thể và không nên phân tích ngữ nghĩa tệp tài liệu off-chain; chỉ nên lưu trữ `proofHash` (IPFS CID) và giao quyền kiểm tra nội dung cho Verifier.
- **Quyết định sửa chữa của nhóm:**
  - Tuân thủ nghiêm ngặt phạm vi: Không viết file code `.sol` ở bước này; chỉ hoàn thiện tài liệu đặc tả [SPEC.md](SPEC.md) và ghi chép [AI_JOURNAL.md](AI_JOURNAL.md).
  - Chuẩn hóa trọn vẹn 10 quy tắc cốt lõi từ R1 đến R10 với điều kiện kiểm thử độc lập, tương ứng với các Event truy vết on-chain (`ScholarshipCreated`, `FundDeposited`, `ProofSubmitted`, `MilestoneApproved`, `ScholarshipDisbursed`).
  - Định nghĩa rõ 10 trường hợp ngoại lệ cùng các mã lỗi Custom Errors (tiết kiệm gas hơn chuỗi `revert string`).
  - Phân định rõ 5 điểm Ngoài phạm vi (Out of Scope): Không xác minh giấy tờ thật, không kết nối ERP trường học, không xử lý fiat, không lưu PII on-chain, không thay thế ERP quản lý sinh viên.
  - Thiết lập danh mục 4 vấn đề cần Người 2 (Trần Thị Như Huỳnh - QA/Testing) kiểm tra chéo và đưa ra quyết định kiến trúc trước khi bước vào Lab 09 (Thiết kế Interface).
- **Kết quả đạt được:** Hoàn thành cập nhật [SPEC.md](SPEC.md) phiên bản v1.0 và cập nhật [AI_JOURNAL.md](AI_JOURNAL.md).

---

### Chuyên Đề Economic Rules & Phân Tích Rủi Ro Lạm Dụng (Lab 08 Hoàn Thiện)

- **Ngày thực hiện:** 01/10/2026
- **Nhiệm vụ:**
  1. Tạo và chuẩn hóa tài liệu [ECONOMIC_RULES.md](ECONOMIC_RULES.md) cho TrustScholar: Làm rõ dòng tiền/quyền lợi (nạp ETH testnet, khóa theo suất, sinh viên nhận tiền đúng điều kiện, tiền về đúng ví), 4 giới hạn chống lạm dụng, 3 câu hỏi quyền quản trị, và 4 tình huống người dùng bị thiệt kèm phương án phòng ngừa.
  2. Cập nhật [PROJECT_PLAN.md](PROJECT_PLAN.md): Phân vai trách nhiệm chi tiết (Khánh Linh: Business/SPEC + Smart Contract/Security; Như Huỳnh: Testing + DApp + Audit) và chuẩn hóa lộ trình 7 mốc bắt buộc (Lab 09: ProjectCore biên dịch được; Lab 10: audit và sửa lỗi; Lab 11: economic rules chạy đúng; Lab 12: Gate Review; Lab 13: security experiment; Lab 14: cross-audit; Lab 15: public DApp).
  3. Đóng vai người dùng thận trọng (Adversary/Auditor), phân tích 5 kịch bản có thể lạm dụng TrustScholar dựa trên SPEC và ECONOMIC_RULES; chỉ ra rule liên quan, đánh giá độ chặt và đề xuất cải tiến rule.
  4. Tuân thủ tuyệt đối quy tắc không tự ý sinh mã Smart Contract (`.sol`) ở Lab 08.
- **Prompt sử dụng:**
  > *"TrustScholar. Repository: https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS.git. Trước tiên hãy đọc: docs/SPEC.md, README.md, docs/AI_JOURNAL.md. Không sửa SPEC.md ngay. Hãy review SPEC trước. Thực hiện: Tạo docs/ECONOMIC_RULES.md (Dòng tiền/quyền lợi, Giới hạn chống lạm dụng, Quyền quản trị, Tình huống người dùng bị thiệt)... Tạo/cập nhật docs/PROJECT_PLAN.md (Phân vai Khánh Linh và Như Huỳnh; 7 Mốc Lab 09-15)... Đóng vai người dùng thận trọng và đưa ra 5 cách có thể lạm dụng TrustScholar... Không viết code... Cập nhật docs/AI_JOURNAL.md. Không tự ý tạo Smart Contract ở Lab 08. Cuối cùng báo cáo: File đã tạo/sửa, 5 rủi ro, Các điểm SPEC cần Thành viên 1 xem lại."*
- **Phản hồi & Thiếu sót của AI phát hiện được:**
  1. *Thiên vị kiểm tra cú pháp thay vì tư duy bảo mật nghịch đảo (Adversarial mindset):* Ban đầu AI cho rằng bộ 10 quy tắc R1-R10 trong SPEC v1.0 đã "hoàn hảo". Tuy nhiên khi nhóm đóng vai người dùng thận trọng / kẻ trục lợi, AI đã bộc lộ 5 điểm hở chết người:
     - R4 chỉ kiểm tra đủ quỹ ở thời điểm gọi giải ngân, không ép buộc nạp đủ 100% trước khi mở mốc cho sinh viên nộp bài (Underfunding exploit).
     - R6 trao quyền tuyệt đối cho 01 Verifier mà không có thời gian thử thách (Challenge Period / Timelock) hay cơ chế đa chữ ký cho mốc lớn, dẫn đến nguy cơ Verifier thông đồng duyệt minh chứng giả.
     - R9 quy định chuyển tiền đúng ví sinh viên nhưng SPEC chưa chốt cơ chế Pull hay Push, tiềm ẩn nguy cơ DoS làm kẹt tiền toàn bộ hệ thống nếu ví sinh viên từ chối nhận ETH.
     - R2 gắn cứng ví sinh viên nhưng chưa có cơ chế khôi phục khẩn cấp an toàn nếu sinh viên mất private key.
     - Thiếu quy tắc ràng buộc việc Nhà tài trợ rút tiền (Refund Front-running) khi sinh viên đã hoàn thành nghĩa vụ.
  2. *Lẫn lộn mô hình kinh tế:* AI có xu hướng áp đặt mô hình pool token ERC-20 và các thông số giả định (như 2.000 USDC/kỳ), không sát với cấu trúc suất học bổng theo mốc nạp ETH testnet của TrustScholar.
  3. *Nguy cơ vi phạm quy trình:* AI định viết sẵn code Solidity cho Lab 09 để "thể hiện", nhưng nhóm đã kiên quyết chặn lại để giữ đúng phạm vi Lab 08.
- **Quyết định sửa chữa của nhóm:**
  - Viết lại toàn diện [ECONOMIC_RULES.md](ECONOMIC_RULES.md) tập trung chuẩn xác vào mô hình Escrow theo từng suất bằng ETH testnet, giải quyết triệt để 4 câu hỏi chống lạm dụng và 4 tình huống thiệt hại.
  - Cập nhật chuẩn xác [PROJECT_PLAN.md](PROJECT_PLAN.md) theo 2 vai trò chuyên môn hóa và 7 mốc kỹ thuật chuẩn (từ Lab 09 đến Lab 15).
  - Đóng gói 5 rủi ro kèm kiến nghị sửa đổi rule để chuyển giao cho Thành viên 1 (Khánh Linh) rà soát lại SPEC v1.0 trước khi thiết kế Interface tại Lab 09.
- **Kết quả đạt được:** Hoàn thành cập nhật [ECONOMIC_RULES.md](ECONOMIC_RULES.md), [PROJECT_PLAN.md](PROJECT_PLAN.md) và [AI_JOURNAL.md](AI_JOURNAL.md); giữ nguyên [SPEC.md](SPEC.md) để chuyển giao phản biện cho Khánh Linh; không phát sinh code `.sol`.

---

### Lab 09: ProjectCore Biên Dịch Được
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Thiết kế interface `IScholarshipPool.sol`, định nghĩa struct/enum, lập trình khung xương hợp đồng `ProjectCore.sol` và đảm bảo biên dịch thành công.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 9)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chú các thiếu sót về kiểu dữ liệu, đóng gói gas struct khi AI gợi ý)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 10: Audit Và Sửa Lỗi
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Rà soát an ninh nội bộ vòng 1, kiểm tra phân quyền RBAC, kiểm tra ReentrancyGuard, CEI pattern và vá triệt để các lỗi phát hiện được.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 10)*
- **Phản hồi & Lỗi của AI:** *(Sẽ kiểm tra các lỗi reentrancy, check-effects-interactions do AI sinh ra)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 11: Economic Rules Chạy Đúng
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Xây dựng test suite tự động kiểm chứng 100% các quy tắc kinh tế trong ECONOMIC_RULES.md và bộ quy tắc R1–R10 trong SPEC.md, đạt độ bao phủ coverage > 90%.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 11)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các test cases bị AI bỏ sót hoặc mock sai ngữ cảnh)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 12: Gate Review
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Đánh giá cột mốc chất lượng toàn diện (Gate Review), rà soát sự đồng bộ giữa SPEC, Hợp đồng và Test suite; tiến hành Code Freeze tầng smart contract.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 12)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các đánh giá chủ quan của AI khi thẩm định)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 13: Security Experiment
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Thực nghiệm bảo mật nâng cao (Security Experiment): Mô phỏng tấn công reentrancy, tấn công DoS chuyển tiền, và stress testing.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 13)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các thiếu sót khi AI dựng kịch bản tấn công giả lập)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 14: Cross-Audit
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Tiến hành kiểm toán chéo (Cross-audit) độc lập giữa 2 thành viên, chạy phân tích tĩnh Slither, tối ưu hóa gas và kiểm thử tích hợp E2E.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 14)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các gợi ý tối ưu gas không hiệu quả hoặc làm giảm tính dễ đọc)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---

### Lab 15: Public DApp
- **Ngày thực hiện:** [Chưa thực hiện]
- **Nhiệm vụ:** Triển khai Smart Contract lên Sepolia/Arbitrum Sepolia Testnet, deploy Frontend Web3 DApp lên hosting công khai, quay video demo và nghiệm thu đồ án.
- **Prompt sử dụng:** *(Sẽ cập nhật khi triển khai Lab 15)*
- **Phản hồi & Lỗi của AI:** *(Sẽ ghi chép các nội dung slide/kịch bản thuyết trình được AI hỗ trợ)*
- **Quyết định sửa chữa của nhóm:** *(Sẽ cập nhật)*
- **Kết quả đạt được:** *(Sẽ cập nhật)*

---
> 🔗 **Liên kết nhanh:** [Trang chủ README](../README.md) • [Kế hoạch đồ án](PROJECT_PLAN.md) • [Đặc tả nghiệp vụ](SPEC.md) • [Quy tắc kinh tế](ECONOMIC_RULES.md) • [Nhật ký AI](AI_JOURNAL.md) • [GitHub Repo](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)

