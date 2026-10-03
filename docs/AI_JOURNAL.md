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

