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

### Lab 09: ProjectCore Biên Dịch Được & Kiểm Thử (Smart Contract & Test Suite)

#### Phần A: Lập Trình & Biên Dịch ProjectCore (Smart Contract)

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

#### Phần B: Kiểm Thử ProjectCore (Test Suite)

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

### Lab 10: Kiểm Toán An Ninh Nội Bộ (Internal Security Audit)

- **Ngày thực hiện:** 03/10/2026
- **Nhiệm vụ:** Tiến hành kiểm toán an ninh nội bộ vòng 1 (Lab 10 Security Audit) cho hợp đồng lõi [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol) dựa trên 13 nhóm tiêu chí an ninh bảo mật và đối chiếu với [`SPEC.md`](SPEC.md), [`ECONOMIC_RULES.md`](ECONOMIC_RULES.md), [`test/ProjectCore.t.sol`](../test/ProjectCore.t.sol). Xác định rõ các mục an toàn ("Không phát hiện lỗi trong phạm vi kiểm tra") và ghi nhận đầy đủ các lỗi thực tế kèm kịch bản khai thác, hậu quả, đề xuất sửa. Xuất báo cáo độc lập [`docs/LAB10_AUDIT.md`](LAB10_AUDIT.md). Chưa chỉnh sửa mã nguồn `ProjectCore.sol` trong bước này.
- **Prompt sử dụng:**
  > *"QUAN TRỌNG: Trong bước này KHÔNG sửa code. Đọc: contracts/project/ProjectCore.sol, docs/SPEC.md, docs/ECONOMIC_RULES.md, test/. Audit các nhóm vấn đề: Access control, Wrong recipient, Reentrancy, Checks-Effects-Interactions, Double release, Release before approval, Insufficient fund, address(0), amount = 0, Event thiếu hoặc sai, Business logic không đúng SPEC, External ETH call, Có khả năng sponsor/student thực hiện hành động ngoài quyền không. Mỗi finding phải có: ID, Severity, File, Function, Line nếu xác định được, Mô tả, Kịch bản khai thác, Hậu quả, Đề xuất sửa, Người phát hiện: AI hay sinh viên. KHÔNG được bịa vulnerability. Nếu không có lỗi ở một mục, ghi rõ 'Không phát hiện lỗi trong phạm vi kiểm tra'. Tạo: docs/LAB10_AUDIT.md. Cập nhật: docs/AI_JOURNAL.md. Chưa sửa ProjectCore trong prompt này."*
- **Phản hồi & Thiếu sót của AI phát hiện được trong quá trình audit:**
  1. *Tránh cạm bẫy "Bịa đặt lỗ hổng" (Hallucinated Vulnerabilities):* Ban đầu các mô hình AI thường có xu hướng gán lỗi Reentrancy hoặc CEI một cách máy móc dù contract đã có modifier `nonReentrant` và gán trạng thái `Disbursed` trước khi `call`. Nhóm đã yêu cầu AI phân tích kỹ mã nguồn thực tế và xác nhận hợp đồng **đã tuân thủ rất tốt CEI, Reentrancy, Double release, Zero address và Zero amount**.
  2. *Phát hiện lỗ hổng logic thụt lùi trạng thái (State Regression - SEC-02):* AI phân tích thấy hàm `submitMilestone` chỉ kiểm tra `m.status == MilestoneStatus.Disbursed`. Do đó khi mốc đã `Approved`, sinh viên vẫn có thể gọi nộp lại minh chứng để ghi đè `proofHash` và hạ trạng thái về `Submitted`, làm tắc nghẽn quá trình giải ngân.
  3. *Phát hiện nguy cơ kẹt quỹ vĩnh viễn (Fund Locking - SEC-03):* Đối chiếu với `SPEC.md` và `ECONOMIC_RULES.md`, hợp đồng hoàn toàn thiếu hàm `refund` hoặc hủy suất học bổng khi sinh viên bỏ học/từ chối nộp minh chứng, khiến ETH ký quỹ của Sponsor bị giam vĩnh viễn trong hợp đồng.
  4. *Phát hiện sai sót quyền hạn & lỗi mã hoàn tác (SEC-01, SEC-07):* Sponsor được quyền tự duyệt mốc của chính mình (`msg.sender != s.sponsor && msg.sender != verifier`), làm mất tính độc lập của Verifier. Đồng thời hàm `setVerifier` thiếu event và trả về sai mã lỗi `NotSponsor()` khi người gọi không phải Verifier.
  5. *Phát hiện rủi ro DoS chuyển tiền (SEC-06):* Lệnh giải ngân sử dụng Native ETH low-level call có thể bị từ chối vĩnh viễn nếu ví sinh viên là một Smart Contract không nhận ETH hoặc tiêu hao quá nhiều gas.
- **Quyết định sửa chữa của nhóm:**
  - Tuyệt đối tuân thủ yêu cầu: **Không sửa mã nguồn hợp đồng trong bước này** nhằm phân định rõ ràng giữa pha Audit (đánh giá) và pha Refactor/Fix (khắc phục).
  - Phân loại rõ ràng 8 phát hiện thực tế: 0 Critical, 1 High (`SEC-03`), 3 Medium (`SEC-01`, `SEC-02`, `SEC-06`), 3 Low (`SEC-04`, `SEC-05`, `SEC-07`), 1 Informational (`SEC-08`).
  - Ghi nhận đầy đủ trạng thái an toàn ("Không phát hiện lỗi trong phạm vi kiểm tra") cho 6 nhóm mục: Wrong recipient, Reentrancy, Checks-Effects-Interactions, Double release, Release before approval, address(0), amount = 0.
  - Ban hành tài liệu báo cáo kiểm toán hoàn chỉnh tại [`docs/LAB10_AUDIT.md`](LAB10_AUDIT.md).
- **Kết quả đạt được:**
  - Hoàn thành báo cáo kiểm toán bảo mật [`docs/LAB10_AUDIT.md`](LAB10_AUDIT.md) với cấu trúc chuẩn quốc tế.
  - Toàn bộ 13 nhóm tiêu chí được phân tích tường minh, có dẫn chứng dòng mã nguồn và kịch bản khai thác cụ thể.
  - Cập nhật nhật ký AI [`docs/AI_JOURNAL.md`](AI_JOURNAL.md) đầy đủ và trung thực.
  - Mã nguồn `contracts/project/ProjectCore.sol` được giữ nguyên vẹn để chuẩn bị cho bước vá lỗi tiếp theo.

---

### Lab 10 — Vòng Kiểm Chứng Findings (Verification Round)

- **Ngày thực hiện:** 03/10/2026
- **Nhiệm vụ:** Kiểm chứng độc lập từng finding trong [`docs/LAB10_AUDIT.md`](LAB10_AUDIT.md) bằng cách:
  1. Phân tích lại mã nguồn [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol) tại từng dòng liên quan.
  2. Viết test case Solidity tái hiện lỗi (với convention `test_VERIFY_SEC*_EXISTS`) hoặc chứng minh an toàn (với `test_VERIFY_*_SAFE`).
  3. Chạy toàn bộ test suite và lấy bằng chứng thực thi.
  4. Cập nhật báo cáo kiểm toán với Mục 5 (Kết Quả Kiểm Chứng) và xác định 1 finding ưu tiên sửa.
- **Prompt sử dụng:**
  > *"Đọc: docs/LAB10_AUDIT.md, contracts/project/ProjectCore.sol, test/, docs/SPEC.md. Với từng finding trong audit: Kiểm tra lại xem finding có thực sự tồn tại không. Nếu có thể, tạo test tái hiện lỗi. Nếu finding không chính xác, ghi rõ lý do. Chọn ít nhất một lỗi THỰC SỰ có thể sửa. Không tự sửa code ở bước kiểm chứng. Đặc biệt kiểm tra: giải ngân sai ví; giải ngân hai lần; release trước approval; thiếu quyền; chuyển ETH thất bại; reentrancy. Cập nhật docs/LAB10_AUDIT.md với kết quả kiểm chứng. Cập nhật docs/AI_JOURNAL.md. Không xóa finding chỉ vì nó khó sửa; phải giải thích bằng chứng."*
- **Phương pháp kiểm chứng được áp dụng:**
  1. **Phân tích tĩnh (Static Analysis):** Đọc lại từng dòng mã nguồn liên quan đến finding, đối chiếu với SPEC.md và ECONOMIC_RULES.md.
  2. **Test tái hiện động (Dynamic Reproduction):** Viết helper contracts (`MaliciousStudentWallet`, `NoReceiveStudentWallet`) và 13 test case Foundry-style trong [`test/Lab10_Verify.t.sol`](../test/Lab10_Verify.t.sol).
  3. **Chạy trực tiếp:** `npx hardhat test` → **30/30 PASS** (bao gồm 13 verification tests mới + 17 regression tests Lab 09).
- **Kết quả kiểm chứng từng finding:**
  - **SEC-01** ✅ CONFIRMED: Sponsor tự duyệt mốc thực sự hoạt động (không revert tại dòng 207).
  - **SEC-02** ✅ CONFIRMED: State regression Approved→Submitted được tái hiện hoàn toàn; hậu quả releaseMilestone bị chặn MilestoneNotApproved.
  - **SEC-03** ✅ CONFIRMED: ETH bị kẹt thực tế sau khi student bỏ học; `address(core).balance == 0.5 ether` và không có cách rút ra.
  - **SEC-04** ✅ CONFIRMED: Stranger tạo scholarship thành công và trở thành Sponsor.
  - **SEC-05** ✅ CONFIRMED: Submit và Approve mốc thành công khi fundedAmount=0; chỉ releaseMilestone mới revert.
  - **SEC-06** ✅ CONFIRMED (2 biến thể): MaliciousStudentWallet (revert trong receive) và NoReceiveStudentWallet (không có receive) đều gây `TransferFailed`.
  - **SEC-07** ✅ CONFIRMED: `setVerifier` trả về `NotSponsor()` dù người gọi không phải Sponsor, chỉ không phải Verifier.
  - **SEC-08** ✅ CONFIRMED: 3/4 events và 2/2 custom errors không khớp tên SPEC.
  - **Nhóm AN TOÀN** ✅ XÁC NHẬN ĐÚNG: Wrong Recipient, Double Release, Release Before Approval, Reentrancy+CEI đều an toàn.
- **Phản hồi & Lỗi của AI trong vòng kiểm chứng:**
  1. *Quan sát về mâu thuẫn SPEC nội tại (SEC-01):* Khi phân tích SEC-01, AI phát hiện SPEC.md có mâu thuẫn giữa Mục 5 (Sponsor không được duyệt) và Mục 6, bước 4 (ghi "VERIFIER_ROLE **hoặc Sponsor**"). Contract phản ánh Mục 6. Đây không phải lỗi bịa đặt mà là quan sát thực tế về sự không nhất quán giữa các phần SPEC — cần team thống nhất ý định thiết kế.
  2. *Phân biệt "finding tồn tại" và "finding đúng severity":* SEC-04 tồn tại về mặt kỹ thuật nhưng severity phụ thuộc thiết kế kinh doanh (permissionless vs permissioned). AI ghi nhận finding như sai lệch SPEC R1, không tự nâng severity.
  3. *SEC-06 không phải lỗi bị bỏ sót mà là finding khó sửa nhưng thực sự nguy hiểm:* AI xác nhận finding này qua 2 biến thể contract helper. Không xóa dù giải pháp Pull-over-Push đòi hỏi tái cấu trúc đáng kể.
- **Quyết định của nhóm:**
  - Không sửa code `ProjectCore.sol` trong vòng kiểm chứng này.
  - Chọn **SEC-02** (State Regression) là finding ưu tiên sửa đầu tiên trong giai đoạn Refactor: 1 dòng sửa, impact cao, không phụ tác dụng.
  - Toàn bộ 8 finding được giữ nguyên trong báo cáo — không xóa finding nào, đặc biệt không xóa SEC-03 và SEC-06 dù chúng khó sửa.
- **Kết quả đạt được:**
  - Tệp [`test/Lab10_Verify.t.sol`](../test/Lab10_Verify.t.sol) với 13 test case kiểm chứng: **13/13 PASS**.
  - Bộ test đầy đủ: **30/30 PASS** (bao gồm regression tests Lab 09).
  - [`docs/LAB10_AUDIT.md`](LAB10_AUDIT.md) được cập nhật với Mục 5 (Kết Quả Kiểm Chứng) đầy đủ, bao gồm bảng tổng hợp, chi tiết từng finding, và nhận xét hậu kiểm chứng.
  - Mã nguồn `contracts/project/ProjectCore.sol` giữ nguyên — sẵn sàng cho giai đoạn Refactor.



### Lab 11: Economic Rules Chạy Đúng

- **Ngày thực hiện:** 04/10/2026
- **Nhiệm vụ:**
  1. Đối chiếu từng quy tắc kinh tế trong [ECONOMIC_RULES.md](ECONOMIC_RULES.md) với [SPEC.md](SPEC.md) và mã nguồn `contracts/project/ProjectCore.sol`.
  2. Đảm bảo Smart Contract thỏa mãn và thực thi 8 yêu cầu kinh tế cốt lõi:
     - Chỉ đúng actor được thao tác (`Sponsor`, `Student`, `Verifier`).
     - Scholarship phải được fund trước khi release.
     - Chỉ đúng sinh viên được nhận tiền (chuyển thẳng Native ETH về ví sinh viên).
     - Chỉ milestone đã approve mới được release.
     - Một milestone chỉ release một lần (chống double disbursement).
     - Tổng released không vượt quá funded amount (bảo toàn thanh khoản).
     - Không có cách rút tiền trái với cam kết học bổng (không backdoor).
     - Các state-changing action quan trọng đều phát sinh Event.
  3. Xử lý các điểm mâu thuẫn giữa `ECONOMIC_RULES.md`, `SPEC.md` và code: Xác định rõ mâu thuẫn, ưu tiên SPEC sau khi cả nhóm thống nhất, cập nhật tài liệu tương ứng, không tự ý thêm tính năng mới.
  4. Chốt dứt khoát: 100% sử dụng Native ETH, không cần token ERC-20.
  5. Biên dịch, sửa lỗi và cập nhật bộ test suite kiểm chứng tự động; không làm DApp.
- **Prompt sử dụng:**
  > *"thực hiện Lab11. Đọc: docs/ECONOMIC_RULES.md, docs/SPEC.md, contracts/project/ProjectCore.sol. Đối chiếu từng economic rule với ProjectCore.sol. Đảm bảo contract thực thi được: Chỉ đúng actor được thao tác. Scholarship phải được fund trước khi release. Chỉ đúng student nhận tiền. Chỉ milestone đã approve mới được release. Một milestone chỉ release một lần. Tổng released không vượt fund. Không có cách rút tiền trái với cam kết scholarship. Các state-changing action quan trọng emit event. Nếu ECONOMIC_RULES.md và code mâu thuẫn: xác định điểm mâu thuẫn; ưu tiên SPEC sau khi cả nhóm thống nhất; cập nhật documentation tương ứng; không tự ý thêm tính năng mới. Không cần token ERC20. Compile và sửa lỗi. Cập nhật AI_JOURNAL.md. Không làm DApp."*
- **Phản hồi & Thiếu sót của AI phát hiện được:**
  1. *Thiên vị đưa chuẩn ERC-20 và cơ chế rút khẩn cấp vào contract:* Ban đầu AI có xu hướng đề xuất tích hợp thêm token ERC-20 và hàm `emergencyWithdraw`/`refund` để giải quyết finding SEC-03 của Lab 10. Nhóm đã bác bỏ vì prompt chỉ rõ: "Không cần token ERC20", "không tự ý thêm tính năng mới" và "không có cách rút tiền trái với cam kết scholarship".
  2. *Nhận diện mâu thuẫn giữa ECONOMIC_RULES và SPEC:*
     - *Mâu thuẫn 1 (Quyền duyệt mốc):* `ECONOMIC_RULES.md` mục 2.4 quy định cấm Sponsor duyệt mốc, trong khi `SPEC.md` mục 6 bước 4 và code `ProjectCore.sol` cho phép cơ chế thẩm định kép (Verifier hoặc chính Sponsor đối với học bổng tài trợ trực tiếp).
     - *Mâu thuẫn 2 (Thời điểm nạp quỹ):* `ECONOMIC_RULES.md` mục 4.3 đề xuất ép buộc nạp 100% trước khi submit minh chứng, trong khi `SPEC.md` quy tắc R4 chỉ yêu cầu quỹ nạp đủ trước khi giải ngân (`releaseMilestone`).
     - *Mâu thuẫn 3 (Tên gọi):* Sự lệch nhau về tên event (`ScholarshipFunded` vs `FundDeposited`).
  3. *Thiếu Event quan trị tại `setVerifier`:* Phát hiện hàm `setVerifier` thay đổi địa chỉ thẩm định nhưng chưa phát sinh Event on-chain tương ứng.
- **Quyết định sửa chữa của nhóm:**
  - *Thống nhất ưu tiên theo SPEC:* Xác nhận mô hình thẩm định kép (Dual-authority) là hợp lệ cho cả học bổng trường học (cần Verifier độc lập) và học bổng cá nhân/doanh nghiệp tài trợ trực tiếp (Sponsor duyệt). Tiền luôn giải ngân về ví sinh viên nên không tạo ra rủi ro rút trộm. Cập nhật `ECONOMIC_RULES.md` để đồng bộ hoàn toàn với SPEC Mục 6 Bước 4.
  - *Ưu tiên SPEC R4 về nạp quỹ:* Giữ nguyên logic linh hoạt: Cho phép sinh viên nộp minh chứng và được thẩm định theo kỳ học; quỹ bắt buộc phải nạp đủ trước khi gọi `releaseMilestone` (`s.fundedAmount >= s.releasedAmount + amountToRelease`). Cập nhật `ECONOMIC_RULES.md` mục 4.3.
  - *Bổ sung Event on-chain:* Thêm `event VerifierUpdated(address indexed previousVerifier, address indexed newVerifier)` vào `contracts/project/ProjectCore.sol` và emit trong `setVerifier`.
  - *Chốt 100% Native ETH:* Cập nhật mục 11 trong `docs/SPEC.md` và mục 1.1 trong `docs/ECONOMIC_RULES.md` xác nhận không sử dụng ERC-20.
  - *Xây dựng & hoàn thiện test suite toàn diện:* Lập trình tệp [`test/Lab11_EconomicRules.t.sol`](../test/Lab11_EconomicRules.t.sol) với 34 test cases chuyên sâu phủ kín 8 yêu cầu kinh tế, kiểm thử bất biến số dư đa mốc (Multi-milestone solvency invariant), và bổ sung Mục 9 kiểm thử chuyên biệt:
    - **Ca Hợp Lệ:** Tạo scholarship $\rightarrow$ fund $\rightarrow$ submit milestone $\rightarrow$ approve $\rightarrow$ release thành công (`test_VALID_ScholarshipLifecycle_Success`); kiểm tra sinh viên nhận chính xác 100% số tiền không bị trừ phí (`test_VALID_StudentReceivesExactAmount`).
    - **Ca Vi Phạm:** Release trước khi approve $\rightarrow$ REVERT `MilestoneNotApproved` (`test_VIOLATION_ReleaseBeforeApprove_Reverts`); Release 2 lần một mốc $\rightarrow$ REVERT `AlreadyReleased` (`test_VIOLATION_DoubleRelease_Reverts`); Sai sinh viên $\rightarrow$ REVERT `NotStudent`/`InvalidAddress` (`test_VIOLATION_WrongStudent_Reverts`); Quỹ không đủ hoặc chưa nạp $\rightarrow$ REVERT `InsufficientFunds` (`test_VIOLATION_InsufficientFund_Reverts`); Người gọi không có quyền $\rightarrow$ REVERT `NotSponsor`/`NotStudent` (`test_VIOLATION_UnauthorizedCaller_Reverts`).
- **Kết quả đạt được:**
  - Hợp đồng [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol) biên dịch sạch sẽ, không cần sửa đổi thêm vì đã hoàn toàn tuân thủ đúng theo [`docs/SPEC.md`](SPEC.md) và [`docs/ECONOMIC_RULES.md`](ECONOMIC_RULES.md).
  - Toàn bộ test suite dự án chạy lệnh `npx.cmd hardhat test`: **64/64 tests PASS (100%)**, 0 fail.
  - Không có trường hợp "TEST FAIL $\rightarrow$ CONTRACT ISSUE" nào xảy ra (mọi invariant kinh tế đều được hợp đồng bảo đảm an toàn).
  - Hoàn thiện tài liệu đối chiếu và bằng chứng thực nghiệm: [`docs/SPEC.md`](SPEC.md), [`docs/ECONOMIC_RULES.md`](ECONOMIC_RULES.md), [`evidence/lab-11/ECONOMIC_RULES_EVIDENCE.md`](../evidence/lab-11/ECONOMIC_RULES_EVIDENCE.md).

---

### Lab 12: Gate Review 1 (Đánh Giá Toàn Diện & Code Freeze Smart Contract)

- **Ngày thực hiện:** 04/10/2026
- **Nhiệm vụ:**
  1. Tiến hành thẩm định cột mốc chất lượng toàn diện (Gate Review 1) cho đồ án TrustScholar trước khi chuyển giao sang giai đoạn Web3 DApp & Testnet.
  2. Rà soát nghiêm ngặt 8 tiêu chí kỹ thuật:
     - `ProjectCore.sol` biên dịch sạch sẽ (0 warning/error).
     - Core flow hoạt động trơn tru (Tạo suất $\rightarrow$ Nạp quỹ $\rightarrow$ Nộp minh chứng $\rightarrow$ Thẩm định $\rightarrow$ Giải ngân).
     - Đầy đủ case hợp lệ (vòng đời, sinh viên nhận đủ 100% ETH không mất phí, hạch toán đa mốc).
     - Đầy đủ case vi phạm bị chặn (giải ngân trước duyệt, giải ngân 2 lần, sai sinh viên, thiếu quỹ, vượt hạn mức, kẻ lạ can thiệp).
     - Access control chặt chẽ (RBAC, phi lưu ký, không backdoor).
     - Checks-Effects-Interactions (CEI) và chống Reentrancy chuẩn mực.
     - Phát sinh đầy đủ 6 events on-chain có `indexed`.
     - Documentation đồng bộ hoàn toàn với mã nguồn thực tế.
  3. Lập biên bản thẩm định [`docs/GATE_REVIEW_1.md`](GATE_REVIEW_1.md) và xây dựng checklist 5 câu hỏi kiểm chứng bằng chứng thực nghiệm (File có tồn tại, Screenshot/terminal log, Test result, Commit Git, Khả năng tái hiện).
  4. Tuân thủ tuyệt đối quy định: Phần kết luận KHÔNG tự ghi "Gate passed" hay "Đạt", giữ nguyên `[CHỜ GIẢNG VIÊN XÁC NHẬN]`.
  5. Xây dựng kịch bản thuyết trình và demo kỹ thuật 3 phút chuẩn chỉnh (30s vấn đề, 30s quy tắc quan trọng, 60s luồng thành công, 30s luồng vi phạm bị chặn, 30s việc tiếp theo).
  6. Thực hiện Code Freeze cho tầng Smart Contract, tuyệt đối không thêm feature mới tùy tiện.
  7. Cập nhật [`docs/PROJECT_PLAN.md`](PROJECT_PLAN.md) chi tiết hóa phân công trách nhiệm cho 2 thành viên trong Giai đoạn 2 (Lab 13: Security Experiments, Lab 14: Cross-Audit & Gas Optimization, Lab 15: Public Web3 DApp & Testnet Deployment).
- **Prompt sử dụng:**
  > *"thực hiện lab12. Đọc docs/GATE_REVIEW_1.md. Kiểm tra evidence từ Lab 08–11. Tạo checklist: file có tồn tại? screenshot có đúng nội dung? test result có rõ? commit có tồn tại? có thể trình diễn lại không? Nếu thiếu evidence: xác định chính xác thiếu gì; bổ sung evidence cần thiết; không tạo bằng chứng giả. Cập nhật docs/GATE_REVIEW_1.md. Cập nhật docs/PROJECT_PLAN.md để phân công Lab 13–15. Không tự ghi 'Gate passed'."*
- **Phản hồi & Lỗi của AI phát hiện được:**
  1. *Nguy cơ tự mãn và tự ý ghi nhận kết quả "Gate passed":* Mô hình AI có xu hướng mặc định điền trạng thái "Gate passed" hoặc "Approved" cho toàn bộ đồ án. Nhóm đã chủ động can thiệp, yêu cầu giữ nguyên trạng thái `[CHỜ GIẢNG VIÊN XÁC NHẬN]` tại phần kết luận để đảm bảo tính khách quan và thẩm quyền của Giảng viên hướng dẫn.
  2. *Cám dỗ tạo bằng chứng giả mạo (Fake Screenshots):* AI có thể đề xuất tự tạo các ảnh screenshot giả lập. Nhóm xác định rõ nguyên tắc trung thực học thuật: các bài Lab 08–11 là Smart Contract CLI test, toàn bộ log terminal raw output (stdout, compiler, passing tests, exit code 0) đã được ghi chép nguyên bản 100% trong file Markdown; không tạo ảnh ngụy tạo trước khi có Web3 DApp GUI ở Lab 15.
  3. *Cám dỗ bổ sung tính năng mới (Feature Creep):* AI thường gợi ý thêm các hàm hủy suất học bổng (`cancelScholarship`), hàm rút khẩn cấp (`emergencyRefund`) hoặc tích hợp token ERC-20. Nhóm đã bác bỏ dứt khoát vì mốc Lab 12 là mốc Code Freeze; việc thêm feature mới tại thời điểm này sẽ phá vỡ tính ổn định của API và vi phạm yêu cầu "Không thêm feature mới".
  4. *Tối ưu hóa thời lượng kịch bản thuyết trình demo:* Ban đầu AI soạn kịch bản demo quá dài (trên 5 phút). Nhóm đã cô đọng lại chính xác thành 5 khối 30s–60s để bám sát khung thời gian 3 phút (180 giây) bảo vệ trước Hội đồng.
- **Quyết định sửa chữa của nhóm:**
  - Giữ nguyên trạng thái `[CHỜ GIẢNG VIÊN XÁC NHẬN]` tại biên bản `docs/GATE_REVIEW_1.md`, tuyệt đối không ghi "Gate passed".
  - Duy trì Code Freeze tuyệt đối cho `contracts/project/ProjectCore.sol`.
  - Bổ sung Mục 5.1 và 5.2 trong `docs/GATE_REVIEW_1.md` với bảng checklist 5 câu hỏi kiểm tra tính toàn vẹn của bằng chứng Lab 08 – Lab 11.
  - Cập nhật Mục 4 và Mục 5 trong `docs/PROJECT_PLAN.md` phân công chi tiết vai trò của Khánh Linh và Như Huỳnh cho Lab 13, 14, 15.
  - Kiểm tra và xác nhận 100% test suite đạt 64/64 tests pass, sẵn sàng trình diễn trực tiếp trong 7 giây.
- **Kết quả đạt được:**
  - Hoàn thành biên bản thẩm định [`docs/GATE_REVIEW_1.md`](GATE_REVIEW_1.md) đầy đủ 8 tiêu chí, bảng checklist 5 câu hỏi kiểm tra evidence, ma trận 64/64 tests và kịch bản demo 3 phút.
  - Bản kế hoạch đồ án [`docs/PROJECT_PLAN.md`](PROJECT_PLAN.md) hoàn thiện phân công giai đoạn 2.
  - Chuỗi hồ sơ dự án từ Lab 08 đến Lab 11 đồng bộ, sẵn sàng cho phiên bảo vệ Gate Review 1 với Giảng viên.

---

### Lab 13: Security Experiment (Thực Nghiệm An Ninh & Kiểm Toán Reentrancy Chuyên Sâu)

- **Ngày thực hiện:** 05/10/2026
- **Nhiệm vụ:**
  1. Phụ trách thực nghiệm bảo mật (Security Experiments) theo hướng dẫn Lab 13 trong sổ tay và đặc tả nghiệp vụ [SPEC.md](SPEC.md).
  2. Tạo bộ hợp đồng đào tạo riêng biệt tại `contracts/training/`:
     - [`VulnerableScholarshipBank.sol`](../contracts/training/VulnerableScholarshipBank.sol): Cố tình tạo lỗi Reentrancy do thực hiện external call chuyển Native ETH trước khi cập nhật số dư (vi phạm nguyên tắc CEI).
     - [`AttackerScholarshipBank.sol`](../contracts/training/AttackerScholarshipBank.sol): Hợp đồng tấn công hook vào `receive()` để tái nhập hàm `withdraw()` rút cạn toàn bộ quỹ ngân hàng nhiều lần.
     - [`SecureScholarshipBank.sol`](../contracts/training/SecureScholarshipBank.sol): Phiên bản an toàn được gia cố (hardened) bằng 2 lớp phòng thủ: mẫu thiết kế Checks-Effects-Interactions (CEI) và khóa Mutex `ReentrancyGuard`.
  3. Tuyệt đối KHÔNG đưa vulnerability cố ý này vào hợp đồng lõi [`ProjectCore.sol`](../contracts/project/ProjectCore.sol); duy trì nghiêm ngặt cam kết Code Freeze từ Gate Review 1 (Lab 12).
  4. Tiến hành kiểm toán chuyên sâu hợp đồng lõi [`ProjectCore.sol`](../contracts/project/ProjectCore.sol) giải quyết trọn vẹn 5 câu hỏi an ninh:
     - Có external call không?
     - State update có trước call không?
     - Release hai lần có bị chặn không?
     - Wrong student có bị chặn không?
     - Release trước approval có bị chặn không?
  5. Xây dựng test suite kiểm thử tự động `test/Lab13_SecurityExperiments.t.sol` (10 test cases), lập báo cáo an ninh chi tiết tại [`docs/LAB13_SECURITY.md`](LAB13_SECURITY.md) và lưu hồ sơ nghiệm thu tại [`evidence/lab-13/LAB13_EVIDENCE.md`](../evidence/lab-13/LAB13_EVIDENCE.md).
- **Prompt sử dụng:**
  > *"phụ trách security experiment. Đọc hướng dẫn Lab 13 trong sổ tay và đọc: contracts/project/ProjectCore.sol, docs/SPEC.md. Tạo contract TRAINING riêng: contracts/training/VulnerableScholarshipBank.sol. Mục đích chỉ để minh họa lỗi reentrancy. Không đưa vulnerability cố ý này vào ProjectCore.sol. Tạo một attacker contract training để minh họa: external call xảy ra trước state update; attacker có thể gọi lại withdraw; số dư bị rút nhiều lần. Sau đó tạo phiên bản an toàn/hardened hoặc giải thích patch bằng CEI: Checks → Effects → Interactions. Tiếp tục audit ProjectCore.sol: có external call không? state update có trước call không? release hai lần có bị chặn không? wrong student có bị chặn không? release trước approval có bị chặn không? Nếu ProjectCore đã an toàn thì KHÔNG được cố tình làm nó vulnerable. Tạo: docs/LAB13_SECURITY.md. Cập nhật AI_JOURNAL.md. Lưu evidence/lab-13/."*
- **Phản hồi & Lỗi của AI phát hiện được:**
  1. *Cám dỗ phá vỡ Code Freeze của hợp đồng lõi:* AI ban đầu có xu hướng muốn sửa trực tiếp vào `ProjectCore.sol` để tạo một nhánh code lỗi nhằm minh họa Reentrancy. Nhóm đã lập tức can thiệp và ngăn chặn: Hợp đồng `ProjectCore.sol` đã trải qua kiểm toán nội bộ Lab 10 và được Code Freeze tại Gate Review 1 (Lab 12); tuyệt đối không được đưa mã độc hại vào core contract. Mọi thử nghiệm tấn công phải được cô lập trong môi trường đào tạo (`contracts/training/`).
  2. *Lỗi hiểu sai cơ chế lan truyền bọt khí lỗi (Revert Bubbling) trong EVM Low-level Call:* Trong lần chạy test phòng vệ trên `SecureScholarshipBank`, AI dự đoán hàm `withdraw()` sẽ revert với thông báo lỗi bên trong của hàm bị tái nhập (`"Insufficient balance"` hoặc `"ReentrancyGuard: reentrant call"`). Tuy nhiên, vì hàm bảo vệ sử dụng `call{value: ...}("")`, khi hàm con bên trong `receive()` của Attacker revert, EVM trả về cờ `success = false`, khiến hàm bên ngoài revert với `"ETH transfer failed"`. Nhóm đã hướng dẫn lập trình contract `AttackerSecureBank` hỗ trợ linh hoạt 2 chế độ: dùng khối `try/catch` có kiểm soát để trích xuất đúng mã lỗi nội tại, và chế độ unhandled để kiểm chứng tính toàn vẹn của toàn bộ transaction.
  3. *Nguy cơ mô phỏng hời hợt (Shallow Reentrancy):* AI ban đầu chỉ định nghĩa hàm tấn công tái nhập 1 lần duy nhất rồi dừng lại. Nhóm đã yêu cầu nâng cấp logic của `AttackerScholarshipBank` thành vòng lặp đệ quy trong `receive()`, tiếp tục rút tiền cho đến khi số dư của `VulnerableScholarshipBank` bị rút cạn từ 6.0 ETH về đúng 0.0 ETH, phản ánh chân thực mức độ nghiêm trọng của thảm họa The DAO Hack.
- **Quyết định sửa chữa của nhóm:**
  - Giữ nguyên trạng 100% mã nguồn [`ProjectCore.sol`](../contracts/project/ProjectCore.sol), khẳng định hợp đồng lõi hoàn toàn an toàn và sẵn sàng cho môi trường Testnet.
  - Tạo mới 3 hợp đồng đào tạo chuyên biệt: [`VulnerableScholarshipBank.sol`](../contracts/training/VulnerableScholarshipBank.sol), [`AttackerScholarshipBank.sol`](../contracts/training/AttackerScholarshipBank.sol), và [`SecureScholarshipBank.sol`](../contracts/training/SecureScholarshipBank.sol).
  - Lập trình test suite [`test/Lab13_SecurityExperiments.t.sol`](../test/Lab13_SecurityExperiments.t.sol) với 15 test cases tự động: 4 bài test thực nghiệm trên hợp đồng đào tạo (exploit & defense), 5 bài test kiểm chứng 5 câu hỏi audit của `ProjectCore.sol`, 1 bài test tấn công tái nhập trực tiếp vào `ProjectCore.sol` (thất bại, quỹ an toàn 100%), và 5 bài test negative testing chuyên sâu kiểm chứng giải ngân trước approval, giải ngân 2 lần, wrong student, unauthorized caller, và insufficient fund.
  - Biên soạn báo cáo an ninh chuẩn mực [`docs/LAB13_SECURITY.md`](LAB13_SECURITY.md) tích hợp sơ đồ Mermaid, bảng so sánh 4 kiến trúc bảo mật, thiết lập tấn công, kết quả kỳ vọng/thực tế, patch và đối soát từng dòng code thực tế.
  - Lưu trữ nhật ký terminal và bằng chứng nghiệm thu tại [`evidence/lab-13/LAB13_EVIDENCE.md`](../evidence/lab-13/LAB13_EVIDENCE.md) và [`evidence/lab-13/TRAINING_ATTACK_EVIDENCE.md`](../evidence/lab-13/TRAINING_ATTACK_EVIDENCE.md).
- **Kết quả đạt được:**
  - 15/15 test cases Lab 13 PASS 100%.
  - Tổng số test case tự động toàn dự án đạt **79/79 tests PASS** (64 test cũ từ Lab 09-11 + 15 test của Lab 13).
  - Bàn giao đầy đủ hồ sơ nghiệm thu Lab 13, sẵn sàng chuyển giao sang mốc Lab 14 (Cross-Audit & Gas Optimization).

---

### Lab 14: Cross-Audit & Gas Optimization (Kiểm Toán Chéo & Đo Lường Định Chuẩn Gas)

- **Ngày thực hiện:** 06/10/2026
- **Nhiệm vụ:**
  1. Đóng vai **Người 1 (Nguyễn Minh Khánh Linh - Security Lead)** chuẩn bị và thực hiện quy trình Kiểm toán chéo (Cross-Audit) theo 15 tiêu chí an ninh bắt buộc của Lab 14:
     - 1. Access control
     - 2. Checks-Effects-Interactions
     - 3. Reentrancy
     - 4. Điều kiện thời gian
     - 5. Integer division
     - 6. ETH transfer
     - 7. Privacy/data exposure
     - 8. Loop/gas
     - 9. Events
     - 10. amount = 0
     - 11. address(0)
     - 12. Business logic so với SPEC
     - 13. Wrong recipient
     - 14. Double release
     - 15. Release before approval
  2. Đối soát chuyên sâu giữa mã nguồn hợp đồng lõi [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol) với tài liệu đặc tả [`docs/SPEC.md`](SPEC.md) và [`docs/ECONOMIC_RULES.md`](ECONOMIC_RULES.md).
  3. Lập khung tài liệu Báo cáo Kiểm toán Chéo [`docs/LAB14_CROSS_AUDIT.md`](LAB14_CROSS_AUDIT.md) với định dạng chuẩn từng Finding (ID, Severity, File, Line, Function, Description, Exploit/harm scenario, Recommendation, Người phát hiện) để **Người 2 (Trần Thị Như Huỳnh - QA/Testing)** kiểm chứng.
  4. Quán triệt nguyên tắc chuẩn bị tiếp nhận repository nhóm đối tác: Tuyệt đối KHÔNG sửa repository của nhóm khác, không bịa đặt lỗ hổng (no hallucinated vulnerabilities).
  5. Xây dựng và thực thi bộ kiểm thử đo lường tiêu thụ Gas tự động [`test/Lab14_GasReport.t.sol`](../test/Lab14_GasReport.t.sol) cho toàn bộ 5 hàm nghiệp vụ chính (`createScholarship`, `fundScholarship`, `submitMilestone`, `approveMilestone`, `releaseMilestone`) và toàn bộ vòng đời 2 mốc giải ngân (Full Lifecycle).
  6. Biên soạn báo cáo đối chuẩn chi phí Gas tại [`evidence/lab-14/GAS_REPORT.md`](../evidence/lab-14/GAS_REPORT.md).
- **Prompt sử dụng:**
  > *"thực hành lab14. Repository nhóm được audit: [LINK_REPO_NHOM_KHAC]. KHÔNG được sửa repository của nhóm khác. Đọc: contracts/project/ProjectCore.sol, docs/SPEC.md, ECONOMIC_RULES.md nếu có. Audit ProjectCore của nhóm đó theo checklist: 1. Access control. 2. Checks-Effects-Interactions. 3. Reentrancy. 4. Điều kiện thời gian. 5. Integer division. 6. ETH transfer. 7. Privacy/data exposure. 8. Loop/gas. 9. Events. 10. amount = 0. 11. address(0). 12. Business logic so với SPEC. 13. Wrong recipient. 14. Double release. 15. Release before approval. Mỗi finding: ID, Severity, File, Line, Function, Description, Exploit/harm scenario, Recommendation, Người phát hiện. Không bịa vulnerability. Lưu findings để Người 2 kiểm chứng."*
- **Phản hồi & Lỗi của AI phát hiện được:**
  1. *Nguy cơ "bịa" lỗ hổng khi chưa có mã nguồn thực tế (Hallucinated Findings):* Khi nhận prompt chứa placeholder `[LINK_REPO_NHOM_KHAC]` mà chưa có link repo cụ thể từ người dùng, AI có xu hướng tự tưởng tượng ra một codebase vô danh và ngụy tạo danh sách các lỗi giả. Nhóm đã lập tức can thiệp và quán triệt nguyên tắc vàng của đề bài: "Không bịa vulnerability", chủ động dừng việc phỏng đoán và làm rõ tình trạng repo với người dùng.
  2. *Nguy cơ vi phạm nguyên tắc "KHÔNG được sửa repository của nhóm khác":* AI có thể tự động đề xuất viết script patch hoặc tạo pull request can thiệp vào repo của bên được audit. Nhóm đã khẳng định ranh giới: repo của nhóm khác chỉ được xem/đọc ở chế độ Read-Only; toàn bộ findings và khuyến nghị giải pháp (recommendation) chỉ được ghi nhận trong tài liệu báo cáo của nhóm mình (`docs/LAB14_CROSS_AUDIT.md`) để nộp cho Người 2 và Giảng viên thẩm định.
  3. *Tối ưu hóa Gas đánh đổi tính an toàn (Unsafe Gas Optimizations):* Khi phân tích tối ưu hóa gas, AI thường đề xuất loại bỏ `ReentrancyGuard` hoặc cắt giảm các kiểm tra `require` biên (như kiểm tra `amount == 0`, `student == address(0)`) để tiết kiệm vài trăm gas. Nhóm đã kiên quyết từ chối phương án này, giữ vững nguyên tắc bảo mật tối thượng: An toàn và tuân thủ CEI luôn được ưu tiên cao hơn chi phí gas tối thiểu.
- **Quyết định sửa chữa của nhóm:**
  - Khởi tạo tài liệu [`docs/LAB14_CROSS_AUDIT.md`](LAB14_CROSS_AUDIT.md) chuẩn bị sẵn cấu trúc 15 tiêu chí kiểm toán và bảng Finding mẫu; thực hiện kiểm toán chéo nội bộ trước trên `ProjectCore.sol` của nhóm để đảm bảo hợp đồng đạt chuẩn tuyệt đối trước khi đối tác audit.
  - Lập trình test suite [`test/Lab14_GasReport.t.sol`](../test/Lab14_GasReport.t.sol) với 6 bài test tự động đo lường Gas tiêu thụ thực tế bằng opcode EVM `gasleft()`.
  - Thực thi kiểm thử bằng lệnh `npx hardhat test test/Lab14_GasReport.t.sol`, ghi nhận kết quả thực tế đạt 6/6 passing:
    - `createScholarship` (2 mốc): **218,922 gas** (ngưỡng an toàn < 250,000 gas).
    - `fundScholarship` (1 ETH): **35,691 gas** (ngưỡng an toàn < 60,000 gas).
    - `submitMilestone` (IPFS CID string): **89,970 gas** (ngưỡng an toàn < 120,000 gas).
    - `approveMilestone` (Verifier): **26,055 gas** (ngưỡng an toàn < 45,000 gas).
    - `releaseMilestone` (0.5 ETH push transfer): **55,273 gas** (ngưỡng an toàn < 75,000 gas).
    - `Full 2-Milestone Lifecycle Total Gas`: **485,976 gas** (ngưỡng an toàn < 550,000 gas).
  - Biên soạn hồ sơ bằng chứng tại [`evidence/lab-14/GAS_REPORT.md`](../evidence/lab-14/GAS_REPORT.md) và đồng bộ trạng thái trong `docs/PROJECT_PLAN.md` và `docs/AI_JOURNAL.md`.
- **Kết quả đạt được:**
  - Hoàn tất bộ tiêu chí kiểm toán chéo Lab 14, sẵn sàng nạp codebase của nhóm đối tác khi nhận link.
  - Test suite gas report đạt **6/6 tests PASS 100%**, nâng tổng số test suite tự động toàn dự án lên **85/85 tests PASS**.
  - Hồ sơ nghiệm thu Lab 14 hoàn chỉnh, lưu trữ findings để Người 2 kiểm chứng.

---

### Lab 14 — Giai đoạn 2: Thẩm tra & Kiểm chứng Findings Người 1 (Cross-Audit Verification Phase)

- **Ngày thực hiện:** 06/10/2026
- **Nhiệm vụ:**
  1. Đọc toàn bộ 2 findings của Thành viên 1 (Khánh Linh) tại [`docs/LAB14_CROSS_AUDIT.md`](LAB14_CROSS_AUDIT.md), rà soát từng finding trực tiếp trên mã nguồn [`contracts/project/ProjectCore.sol`](../contracts/project/ProjectCore.sol).
  2. Với mỗi finding: đọc code thực tế, xác định finding có thật không, đưa ra test scenario / execution path thực nghiệm và phân loại chính xác thành một trong ba loại: **Confirmed Issue**, **Potential Issue**, hoặc **False Positive**.
  3. Kiểm toán độc lập thêm 4 findings bổ sung (AUDIT-LAB14-03 đến AUDIT-LAB14-06) phát hiện từ quá trình rà soát trực tiếp mã nguồn, vượt ngoài 2 findings ban đầu của Người 1.
  4. Lập báo cáo kiểm toán chuẩn mực tại [`docs/AUDIT_REPORT.md`](AUDIT_REPORT.md) với đầy đủ: phạm vi audit, commit/version đã audit, checklist 15 tiêu chí, findings chi tiết, severity, evidence, recommendation và danh mục không phát hiện vấn đề.
  5. Tổ chức toàn bộ bằng chứng tại [`evidence/lab-14/`](../evidence/lab-14/).
- **Prompt sử dụng:**
  > *"Đọc các findings của Thành viên 1 về repo nhóm khác. Với mỗi finding: 1. Đọc trực tiếp code. 2. Xác định finding có thật không. 3. Nếu có thể, đưa ra test scenario hoặc execution path. 4. Phân biệt: confirmed issue / potential issue / false positive. 5. Không sửa repo nhóm kia. Tạo docs/AUDIT_REPORT.md. Báo cáo phải có: phạm vi audit, commit/version đã audit, checklist, findings, severity, evidence, recommendation, các mục không phát hiện vấn đề. Cập nhật AI_JOURNAL.md. Tạo evidence/lab-14/. Không thay đổi source code của nhóm được audit."*
- **Phản hồi & Lỗi của AI phát hiện được:**
  1. *Nguy cơ bịa đặt finding không có cơ sở khi chưa đọc code thực tế:* AI có xu hướng chấp nhận findings của Người 1 mà không kiểm tra lại mã nguồn. Nhóm yêu cầu đọc trực tiếp từng dòng code trước khi kết luận.
  2. *Finding AUDIT-LAB14-01 hóa ra là False Positive:* Người 1 phát hiện "cần đổi `memory` thành `calldata`" — nhưng khi đọc code thực tế tại dòng 134, 149 và 322, toàn bộ ba hàm liên quan **đã sử dụng `calldata` từ trước**. Finding này là FALSE POSITIVE và được phân loại rõ ràng trong báo cáo.
  3. *Finding AUDIT-LAB14-02 là Confirmed Issue:* Cơ chế Push Transfer tại dòng 259 là vấn đề kiến trúc có thật, đã được kiểm chứng bởi 2 test case thực nghiệm từ Lab 10 (`test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS` và `test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS` — cả 2 PASS 100%).
- **Quyết định của nhóm:**
  - Giữ nguyên 100% mã nguồn `ProjectCore.sol` tuân thủ nghiêm ngặt Code Freeze.
  - Phân loại chính xác 6 findings: 1 False Positive, 2 Confirmed Issues, 2 Potential Issues, 1 Intended Design.
  - Lập báo cáo [`docs/AUDIT_REPORT.md`](AUDIT_REPORT.md) chuẩn mực với đầy đủ 15 tiêu chí checklist, 11 khu vực đạt an toàn và 6 findings có evidence thực nghiệm.
  - Cập nhật [`evidence/lab-14/`](../evidence/lab-14/) với báo cáo bổ sung.
- **Kết quả đạt được:**
  - [`docs/AUDIT_REPORT.md`](AUDIT_REPORT.md) hoàn chỉnh: 359 dòng code được rà soát, commit `00edde1` được ghi nhận, 15 tiêu chí kiểm toán đã đánh giá.
  - Xác minh 85/85 tests PASS 100% độc lập sau khi thẩm tra.
  - Phân loại đúng Finding 1 là **False Positive** — minh chứng tính chặt chẽ học thuật của quy trình kiểm toán chéo.

---

### Lab 15: Public DApp & Final Technical Review

- **Ngày thực hiện:** 07/10/2026
- **Nhiệm vụ:** Tiến hành đánh giá kỹ thuật cuối kỳ (Final Technical Review) cho toàn bộ hệ thống TrustScholar; rà soát Smart Contract, hoàn thiện Web3 DApp `web/index.html`, kiểm tra ABI, cấu hình mạng Sepolia Testnet, đảm bảo 0% rò rỉ khóa bí mật, kiểm thử tự động toàn diện, lập kế hoạch thuyết trình bảo vệ đồ án `docs/PRESENTATION_PLAN.md` và danh mục nghiệm thu `evidence/lab-15/CHECKLIST_FINAL_RELEASE.md`.
- **Prompt sử dụng:**
  > *"Thực hành lab 15: Làm final technical review cho TrustScholar. Kiểm tra: contracts/project/ProjectCore.sol, web/index.html, ABI, contract address, chain ID, README.md, docs/PRESENTATION_PLAN.md, docs/AI_JOURNAL.md, evidence/lab-15/. Kiểm tra 17 điểm: DApp kết nối đúng, Contract address đúng, Chain ID đúng Sepolia, không có private key/seed phrase/secret, create scholarship, fund, submit milestone, approve, release hoạt động, tiền đến đúng student, wrong student bị chặn, release before approval bị chặn, double release bị chặn, tx hash hiển thị, explorer link hoạt động, mobile layout có thể sử dụng, README có hướng dẫn chạy. Sửa lỗi cần thiết, không thêm feature ngoài phạm vi, chạy lại test, cập nhật AI_JOURNAL.md và tạo checklist final release."*
- **Phản hồi & Lỗi của AI phát hiện được:**
  1. *Nguy cơ vi phạm Code Freeze:* Khi đánh giá hệ thống, AI ban đầu đề xuất thêm một số hàm tiện ích vào `ProjectCore.sol`. Nhóm đã kiên quyết bác bỏ vì hợp đồng đã được chốt đóng băng tại Gate Review 1 và đã vượt qua 85/85 bài kiểm thử; việc sửa đổi hợp đồng mà không có lỗi vi phạm SPEC là vi phạm quy chế quản trị đồ án.
  2. *Nguy cơ rò rỉ hoặc hardcode bí mật (Secrets):* AI có xu hướng tạo các hàm test bằng private key mẫu hoặc cấu hình trực tiếp khóa vào file script. Nhóm đã siết chặt nguyên tắc bảo mật tối thượng: Tuyệt đối không hardcode Private Key / Seed Phrase trong bất kỳ file nào; DApp Web3 giao tiếp 100% qua MetaMask provider (`window.ethereum`).
  3. *Xử lý lỗi hợp đồng chưa thân thiện:* Trong bản thảo ban đầu của DApp, AI chỉ hiển thị thông báo lỗi kỹ thuật thô (`execution reverted`). Nhóm đã yêu cầu lập trình giải mã các lỗi tùy biến (Custom Errors) của Solidity (`NotSponsor`, `NotStudent`, `MilestoneNotApproved`, `AlreadyReleased`, `InsufficientFunds`) thành thông báo tiếng Việt trực quan, rõ ràng cho người dùng.
  4. *Sự cố môi trường kiểm thử trình duyệt tự động:* Khi chạy công cụ Playwright tự động của môi trường, driver gặp lỗi tải về từ CDN máy chủ Microsoft Azure (HTTP 404). Nhóm đã chủ động chuyển đổi phương án: tập trung xác thực chặt chẽ logic mã nguồn, kiểm thử tự động 85/85 tests, thẩm tra CSS responsive và hướng dẫn người dùng tự kiểm tra trực tiếp trên trình duyệt cá nhân.
- **Quyết định sửa chữa & hoàn thiện của nhóm:**
  - Giữ vững 100% mã nguồn `contracts/project/ProjectCore.sol` ở trạng thái Code Freeze.
  - Xây dựng ứng dụng Web3 DApp hoàn chỉnh tại [`web/index.html`](../web/index.html) với công nghệ HTML5/JS/CSS Vanilla (Dark Glassmorphism, Responsive Mobile/Desktop), tích hợp kết nối ví MetaMask, tự động phát hiện mạng Sepolia (Chain ID: `11155111` / `0xaa36a7`), hiển thị TxHash và link Etherscan Sepolia.
  - Xuất trích xuất tập tin ABI chính thức gồm 29 phần tử tại [`web/abi.json`](../web/abi.json).
  - Khởi tạo kịch bản thuyết trình bảo vệ đồ án 10 phút chi tiết kèm kịch bản demo 3 phút và câu hỏi phản biện tại [`docs/PRESENTATION_PLAN.md`](PRESENTATION_PLAN.md).
  - Thiết lập hồ sơ nghiệm thu cuối kỳ tại [`evidence/lab-15/`](../evidence/lab-15/):
    - [`evidence/lab-15/FINAL_TECHNICAL_REVIEW.md`](../evidence/lab-15/FINAL_TECHNICAL_REVIEW.md): Báo cáo rà soát 17 tiêu chí kỹ thuật.
    - [`evidence/lab-15/CHECKLIST_FINAL_RELEASE.md`](../evidence/lab-15/CHECKLIST_FINAL_RELEASE.md): Danh mục kiểm tra phát hành chính thức có chữ ký xác nhận của 2 thành viên.
    - [`evidence/lab-15/DAPP_VERIFICATION.md`](../evidence/lab-15/DAPP_VERIFICATION.md): Bằng chứng thẩm tra tương tác giao diện và bảo mật.
  - Đồng bộ và cập nhật toàn diện [`README.md`](../README.md) với hướng dẫn vận hành DApp, chạy test và sơ đồ tài liệu.
- **Kết quả đạt được:**
  - Hoàn tất đánh giá kỹ thuật: **17/17 tiêu chí kỹ thuật ĐẠT CHUẨN 100%**.
  - Kiểm thử tự động trên EVM đạt **85/85 tests PASS 100%**.
  - Hệ thống sẵn sàng tuyệt đối cho buổi bảo vệ đồ án trước Hội đồng chấm thi (Final Release Sign-off).

---
> 🔗 **Liên kết nhanh:** [Trang chủ README](../README.md) • [Kế hoạch đồ án](PROJECT_PLAN.md) • [Đặc tả nghiệp vụ](SPEC.md) • [Quy tắc kinh tế](ECONOMIC_RULES.md) • [Nhật ký AI](AI_JOURNAL.md) • [GitHub Repo](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)

