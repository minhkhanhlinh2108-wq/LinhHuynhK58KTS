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
  1. *Thiên vị kiểm tra cú pháp thay vì tư duy bảo mật nghịch đảo (Adversarial mindset):* Ban ### Lab 09 — Phần A: ProjectCore Biên Dịch Được (Smart Contract)

- **Ngày thực hiện:** 02/10/2026
- **Nhiệm vụ:** Thiết lập môi trường dự án Hardhat với Solidity `^0.8.20`, lập trình hợp đồng thông minh lõi `contracts/project/ProjectCore.sol` mô phỏng đầy đủ luồng nghiệp vụ TrustScholar (Tạo suất → Nạp quỹ → Nộp minh chứng → Xác nhận mốc → Giải ngân), tuân thủ Checks-Effects-Interactions (CEI), ngăn ngừa reentrancy, kiểm soát chặt chẽ quyền của từng actor, phát sinh đầy đủ events và custom errors, biên dịch thành công 100%.
- **Prompt sử dụng:**
  > *"Thực hiện lab09. Đọc trước: docs/SPEC.md, docs/ECONOMIC_RULES.md, docs/PROJECT_PLAN.md, docs/AI_JOURNAL.md, AGENTS.md, toàn bộ contracts hiện tại. Không thiết kế lại nghiệp vụ nếu SPEC đã có. Tạo: contracts/project/ProjectCore.sol..."*
- **Phản hồi \& Lỗi gặp phải:**
  1. *Lỗi cấu hình Hardhat ESM:* Khi chạy `npx hardhat compile`, phiên bản Hardhat 3.18.1 yêu cầu dự án phải được thiết lập ESM (`Hardhat only supports ESM projects`). Cần cấu hình `"type": "module"` trong `package.json` và chuyển `hardhat.config.js` sang cú pháp ES Module (`export default`).
  2. *Lỗi PowerShell Execution Policy trên Windows:* Windows chặn chạy tệp script PowerShell `npm.ps1` (`PSSecurityException`). Khắc phục bằng cách sử dụng `npm.cmd` và `npx.cmd`.
  3. *Nguy cơ vi phạm Checks-Effects-Interactions (CEI):* AI ban đầu có xu hướng thực hiện transfer ETH trước khi cập nhật trạng thái milestone và biến tổng giải ngân `releasedAmount`, tạo điều kiện cho tấn công tái nhập (reentrancy). Nhóm lập tức chuẩn hóa cập nhật trạng thái trước (`m.status = MilestoneStatus.Disbursed; s.releasedAmount += amountToRelease`), sau đó mới gọi external transfer qua `call{value: ...}("")` và kiểm tra biến `bool success`. Đồng thời tích hợp cơ chế khóa tái nhập `nonReentrant`.
  4. *Đảm bảo nguyên tắc chuyển tiền đúng ví sinh viên (R9):* Trong hàm `releaseMilestone`, địa chỉ nhận tiền được lấy trực tiếp từ trường lưu trữ `s.student` đã xác lập từ bước tạo suất, tuyệt đối không cho phép truyền địa chỉ ví tùy ý qua tham số hàm để ngăn chặn tấn công tráo đổi ví người nhận.
- **Quyết định sửa chữa của nhóm:**
  - Khởi tạo `package.json` với `"type": "module"` và tệp `hardhat.config.js` hỗ trợ Solidity compiler `0.8.20` cùng optimizer 200 runs.
  - Viết hợp đồng `contracts/project/ProjectCore.sol` tự chứa (self-contained), sạch sẽ, đầy đủ 10 custom errors, 5 sự kiện, các hàm nghiệp vụ đúng theo luồng đặc tả trong [SPEC.md](SPEC.md) và [ECONOMIC_RULES.md](ECONOMIC_RULES.md).
  - Tích hợp 2 overload cho `createScholarship` (hỗ trợ cả khai báo kèm `totalAmount` lẫn tự động cộng dồn mảng mốc) nhằm tối đa hóa tính linh hoạt cho test suite.
  - Biên dịch kiểm thử thành công bằng lệnh `npx.cmd hardhat compile`.
- **Kết quả đạt được:**
  - Tệp `contracts/project/ProjectCore.sol` biên dịch thành công 100% không cảnh báo (`Compiled 1 Solidity file with solc 0.8.20 (evm target: shanghai)`).
  - Tệp ABI và bytecode được sinh ra đầy đủ tại `artifacts/contracts/project/ProjectCore.sol/ProjectCore.json`.

---

### Lab 09 — Phần B: Kiểm Thử ProjectCore (Test Suite)

- **Ngày thực hiện:** 03/10/2026
- **Nhiệm vụ:** Xây dựng và chạy test suite đầy đủ 13 trường hợp bắt buộc (6 SUCCESS + 7 FAIL) cho `ProjectCore.sol` theo API thực tế của contract, sử dụng Hardhat 3 Solidity tests (Foundry-style). Ghi nhận sai lệch giữa SPEC và contract thực tế. Lưu bằng chứng vào `evidence/lab-09/`.
- **Prompt sử dụng:**
  > *"lm típ lab09 kiểm thử TrustScholar. Đọc: docs/SPEC.md, docs/ECONOMIC_RULES.md, contracts/project/ProjectCore.sol. Không sửa nghiệp vụ của contract nếu chưa trao đổi với Thành viên 1. Tạo test/ cho ProjectCore. Viết các test tối thiểu: SUCCESS: 1-6, FAIL: 7-13. Nếu contract hiện tại không có đúng tên hàm/error như trên, hãy đọc code và viết test theo API thực tế, không tự bịa. Chạy toàn bộ test. Nếu test fail: xác định fail do test sai hay contract sai; không sửa contract một cách tùy tiện; ghi vấn đề vào docs/AI_JOURNAL.md. Tạo evidence/lab-09/ để lưu bằng chứng test/compile..."*
- **Phân tích API thực tế của contract (trước khi viết test):**
  - Hardhat 3 dùng **Solidity tests** kiểu Foundry, không phải JS/TS. File test phải là `.t.sol` với hàm `test_*()`.
  - Cheatcode `Vm` interface phải tự định nghĩa inline (dự án chưa cài `forge-std`). Dùng địa chỉ chuẩn `0x7109709ECfa91a80626fF3989D68f67F5b1DD12D`.
- **Phản hồi \& Lỗi gặp phải:**
  1. *Lỗi `Vm` identifier not found:* Khi import `Vm` không khai báo interface, compiler báo `DeclarationError: Identifier not found or not unique`. Khắc phục: định nghĩa inline `interface Vm { prank, deal, expectRevert }` trong file test.
  2. *Sai lệch Test 7 (R1):* SPEC R1 yêu cầu chỉ SPONSOR_ROLE mới được tạo suất — nhưng contract thực tế KHÔNG có kiểm tra quyền trên `createScholarship()`. AI ban đầu muốn viết test `vm.expectRevert` cho người lạ gọi `createScholarship` → test sẽ fail vì contract KHÔNG revert. Nhóm quyết định KHÔNG sửa contract, thay vào đó viết test cho gate RBAC thực tế: `approveMilestone` chỉ cho sponsor/verifier.
  3. *Tên event/error khác SPEC:* SPEC định nghĩa `FundDeposited`, `ZeroAddressNotAllowed`, `MilestoneAlreadyDisbursed` — contract dùng `ScholarshipFunded`, `InvalidAddress`, `AlreadyReleased`. Test phải dùng tên từ **contract thực tế**, không phải SPEC lý tưởng.
- **4 Sai lệch SPEC ↔ Contract được ghi nhận (chuyển Khánh Linh xem lại):**
  1. **R1 — createScholarship không có access control:** Bất kỳ ai cũng tạo được suất học bổng, không cần SPONSOR_ROLE như SPEC yêu cầu.
  2. **Tên event không khớp SPEC:** `ScholarshipFunded`/`MilestoneSubmitted`/`ScholarshipReleased` vs SPEC `FundDeposited`/`ProofSubmitted`/`ScholarshipDisbursed`.
  3. **Tên custom error không khớp SPEC:** `InvalidAddress`/`InvalidAmount`/`AlreadyReleased` vs SPEC `ZeroAddressNotAllowed`/`ZeroAmountNotAllowed`/`MilestoneAlreadyDisbursed`.
  4. **releaseMilestone quá rộng quyền:** Cả student, sponsor VÀ verifier đều có thể trigger release — SPEC không rõ ràng về ai được gọi hàm này.
- **Quyết định sửa chữa của nhóm:**
  - Viết test theo **API thực tế** của contract, không bịa selector/tên không tồn tại.
  - Không sửa contract — ghi nhận tất cả sai lệch để Thành viên 1 (Khánh Linh) xem lại SPEC hoặc contract ở Lab 10.
  - Lưu toàn bộ evidence tại `evidence/lab-09/TEST_RESULTS.md`.
- **Kết quả đạt được:**
  - Tệp `test/ProjectCore.t.sol` hoàn chỉnh với **17 test cases** (13 bắt buộc + 4 edge case bổ sung).
  - Kết quả: **17/17 PASS — 0 FAIL** (exit code 0).
  - Bằng chứng lưu tại `evidence/lab-09/TEST_RESULTS.md`.
  - 4 sai lệch giữa SPEC và contract được ghi lại để chuyển Thành viên 1 xem lại.

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

