# Bằng Chứng Thực Nghiệm Lab 11 (Lab 11 Evidence) — TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Nội dung:** Bằng chứng kiểm chứng toàn diện quy tắc kinh tế & bảo toàn quỹ (Economic Rules Verification)  
> **Thành viên thực hiện:** Trần Thị Như Huỳnh (Testing & QA) & Nguyễn Minh Khánh Linh (Smart Contract & Security)  
> **Môi trường:** Hardhat 3.18.1 | Solidity ^0.8.20 | EVM Target: Shanghai | Node.js v20+  
> **Tài liệu đối chiếu:** [`docs/ECONOMIC_RULES.md`](../../docs/ECONOMIC_RULES.md), [`docs/SPEC.md`](../../docs/SPEC.md), [`contracts/project/ProjectCore.sol`](../../contracts/project/ProjectCore.sol)  
> **Thời điểm thực hiện:** 04/10/2026  

---

## 1. Kết Quả Biên Dịch & Chạy Kiểm Thử Tự Động

### Lệnh thực thi:
```bash
npx.cmd hardhat compile
npx.cmd hardhat test
```

### Kết quả đầu ra terminal:
```text
Compiled 1 Solidity file with solc 0.8.20 (evm target: shanghai)

Running Solidity tests

  test/ProjectCore.t.sol:ProjectCoreTest
    ✔ test_Extra_D_ReleasedAmountTracked()
    ✔ test_Extra_C_SponsorCanApproveMilestone()
    ✔ test_Extra_B_NonSponsorCannotFund()
    ✔ test_Extra_A_OverfundReverts()
    ✔ test_13_ZeroMilestoneAmountReverts()
    ✔ test_12_ZeroAddressStudentReverts()
    ✔ test_11_ReleaseWithInsufficientFundsReverts()
    ✔ test_10_DoubleReleaseReverts()
    ✔ test_09_ReleaseBeforeApproveReverts()
    ✔ test_08_StrangerCannotSubmitMilestone()
    ✔ test_07_StrangerCannotApproveMilestone()
    ✔ test_06_FundsReachStudentWallet()
    ✔ test_05_ReleaseMilestoneSuccess()
    ✔ test_04_VerifierApproveMilestone()
    ✔ test_03_StudentSubmitMilestone()
    ✔ test_02_SponsorFundScholarship()
    ✔ test_01_SponsorCreateScholarship()

  test/Lab11_EconomicRules.t.sol:Lab11EconomicRulesTest
    ✔ test_VIOLATION_WrongStudent_Reverts()
    ✔ test_VIOLATION_UnauthorizedCaller_Reverts()
    ✔ test_VIOLATION_ReleaseBeforeApprove_Reverts()
    ✔ test_VIOLATION_InsufficientFund_Reverts()
    ✔ test_VIOLATION_DoubleRelease_Reverts()
    ✔ test_VALID_StudentReceivesExactAmount()
    ✔ test_VALID_ScholarshipLifecycle_Success()
    ✔ test_ECO_R8_02_VerifierUpdatedLifecycle()
    ✔ test_ECO_R8_01_PureNativeETHLifecycle()
    ✔ test_ECO_R7_02_CrossScholarshipFundIsolation()
    ✔ test_ECO_R7_01_ContractBalanceStrictConservation()
    ✔ test_ECO_R6_01_MultiMilestoneSolvencyInvariant()
    ✔ test_ECO_R5_01_DoubleReleaseReverts()
    ✔ test_ECO_R4_03_ReleaseApprovedMilestoneSucceeds()
    ✔ test_ECO_R4_02_ReleaseSubmittedMilestoneReverts()
    ✔ test_ECO_R4_01_ReleasePendingMilestoneReverts()
    ✔ test_ECO_R3_03_ZeroPlatformFeeFullAmountReceived()
    ✔ test_ECO_R3_02_FundsReachStudentWhenSponsorCallsRelease()
    ✔ test_ECO_R3_01_FundsReachStudentWhenVerifierCallsRelease()
    ✔ test_ECO_R2_05_OverfundReverts()
    ✔ test_ECO_R2_04_IncrementalFundingSupportsSequentialReleases()
    ✔ test_ECO_R2_03_ReleaseExactMilestoneFundSucceeds()
    ✔ test_ECO_R2_02_ReleaseUnderfundedReverts()
    ✔ test_ECO_R2_01_ReleaseZeroFundReverts()
    ✔ test_ECO_R1_10_NonVerifierCannotUpdateVerifier()
    ✔ test_ECO_R1_09_StrangerCannotTriggerRelease()
    ✔ test_ECO_R1_08_SponsorCanApproveDirectGrant()
    ✔ test_ECO_R1_07_VerifierCanApproveMilestone()
    ✔ test_ECO_R1_06_StudentCannotSelfApprove()
    ✔ test_ECO_R1_05_StrangerCannotApproveMilestone()
    ✔ test_ECO_R1_04_NonStudentCannotSubmitProof()
    ✔ test_ECO_R1_03_StudentCannotFundScholarship()
    ✔ test_ECO_R1_02_NonSponsorCannotFundScholarship()
    ✔ test_ECO_R1_01_SponsorCreatesAndOwnsScholarship()

  test/Lab10_Verify.t.sol:Lab10VerifyTest
    ✔ test_VERIFY_WrongRecipient_SAFE()
    ✔ test_VERIFY_SEC08_EventNameMismatch_INFO()
    ✔ test_VERIFY_SEC07_WrongErrorCode_EXISTS()
    ✔ test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS()
    ✔ test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS()
    ✔ test_VERIFY_SEC05_SubmitApproveWithZeroFund_EXISTS()
    ✔ test_VERIFY_SEC04_AnyoneCreateScholarship_EXISTS()
    ✔ test_VERIFY_SEC03_FundLocking_EXISTS()
    ✔ test_VERIFY_SEC02_StateRegression_EXISTS()
    ✔ test_VERIFY_SEC01_SponsorSelfApprove_EXISTS()
    ✔ test_VERIFY_ReleaseBeforeApproval_SAFE()
    ✔ test_VERIFY_ReentrancyAndCEI_SAFE()
    ✔ test_VERIFY_DoubleRelease_SAFE()

64 passing (64 solidity)
```

---

## 2. Bảng Đối Chiếu 8 Yêu Cầu Kinh Tế Cốt Lõi

| STT | Yêu Cầu Kinh Tế Bắt Buộc | Ràng Buộc Kỹ Thuật Trong Code | Test Case Kiểm Chứng | Trạng Thái |
|:---:|:---|:---|:---|:---:|
| 1 | **Chỉ đúng actor được thao tác** | • `fundScholarship`: `msg.sender == s.sponsor`<br>• `submitMilestone`: `msg.sender == s.student`<br>• `approveMilestone`: `msg.sender == verifier \|\| msg.sender == s.sponsor`<br>• `releaseMilestone`: chỉ `student/sponsor/verifier`<br>• `setVerifier`: `msg.sender == verifier` | `test_ECO_R1_01` $\rightarrow$ `test_ECO_R1_10` (10 tests) | 🟢 **ĐẠT 100%** |
| 2 | **Scholarship phải được fund trước khi release** | • `releaseMilestone` kiểm tra:<br>`s.fundedAmount >= s.releasedAmount + amountToRelease`<br>• Nếu chưa nạp hoặc nạp thiếu $\rightarrow$ revert `InsufficientFunds` | `test_ECO_R2_01` $\rightarrow$ `test_ECO_R2_05` (5 tests) | 🟢 **ĐẠT 100%** |
| 3 | **Chỉ đúng student nhận tiền** | • Low-level call `s.student.call{value: amountToRelease}("")`<br>• Dù Verifier hay Sponsor gọi giải ngân, tiền luôn chuyển 100% vào ví sinh viên, không qua trung gian | `test_ECO_R3_01` $\rightarrow$ `test_ECO_R3_03` (3 tests) | 🟢 **ĐẠT 100%** |
| 4 | **Chỉ milestone đã approve mới được release** | • `if (m.status != MilestoneStatus.Approved) revert MilestoneNotApproved();`<br>• Trạng thái `Pending` hoặc `Submitted` bị từ chối giải ngân | `test_ECO_R4_01` $\rightarrow$ `test_ECO_R4_03` (3 tests) | 🟢 **ĐẠT 100%** |
| 5 | **Một milestone chỉ release một lần** | • `if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();`<br>• Cập nhật `m.status = Disbursed` trước khi chuyển tiền (CEI) | `test_ECO_R5_01`, `test_10_DoubleReleaseReverts` | 🟢 **ĐẠT 100%** |
| 6 | **Tổng released không vượt fund** | • `s.releasedAmount += amountToRelease`<br>• Bất biến `s.releasedAmount <= s.fundedAmount <= s.totalAmount` được duy trì liên tục qua nhiều mốc | `test_ECO_R6_01` (3 mốc 0.3, 0.3, 0.4 ETH) | 🟢 **ĐẠT 100%** |
| 7 | **Không có cách rút tiền trái với cam kết scholarship** | • Hợp đồng hoàn toàn không có hàm `withdraw` hay backdoor rút tiền của Admin<br>• Tiền của Suất A không thể bị rút lẹm cho Suất B (`test_ECO_R7_02`) | `test_ECO_R7_01`, `test_ECO_R7_02` | 🟢 **ĐẠT 100%** |
| 8 | **Các state-changing action quan trọng emit event** | • Bổ sung `event VerifierUpdated`<br>• Phát đầy đủ 6 events: `ScholarshipCreated`, `ScholarshipFunded`, `MilestoneSubmitted`, `MilestoneApproved`, `ScholarshipReleased`, `VerifierUpdated` | `test_ECO_R8_01`, `test_ECO_R8_02` | 🟢 **ĐẠT 100%** |

---

## 3. Bảng Kiểm Tra Ca Hợp Lệ & Ca Vi Phạm Theo Yêu Cầu

### 3.1. Ca Hợp Lệ (Valid Test Cases)

| Kịch Bản Kiểm Thử | Kỳ Vọng Kỹ Thuật | Tên Hàm Test | Kết Quả Thực Nghiệm |
|:---|:---|:---|:---:|
| **1. Tạo scholarship $\rightarrow$ Fund $\rightarrow$ Submit milestone $\rightarrow$ Approve $\rightarrow$ Release thành công** | Suất tạo thành công, nạp 1.0 ETH, nộp minh chứng IPFS CID, Verifier duyệt mốc, giải ngân chuyển trạng thái `Disbursed`, `releasedAmount` tăng đúng 0.5 ETH | `test_VALID_ScholarshipLifecycle_Success`<br>`test_05_ReleaseMilestoneSuccess`<br>`test_ECO_R8_01_PureNativeETHLifecycle` | 🟢 **PASS** |
| **2. Kiểm tra student nhận đúng số tiền** | Số dư ví sinh viên tăng chính xác đúng bằng số tiền mốc (`0.5 ether`), hợp đồng bị trừ đúng `0.5 ether`, không có phí nền tảng nào bị khấu trừ | `test_VALID_StudentReceivesExactAmount`<br>`test_06_FundsReachStudentWallet`<br>`test_ECO_R3_01_FundsReachStudentWhenVerifierCallsRelease`<br>`test_ECO_R3_02_FundsReachStudentWhenSponsorCallsRelease`<br>`test_ECO_R3_03_ZeroPlatformFeeFullAmountReceived` | 🟢 **PASS** |

### 3.2. Ca Vi Phạm (Violation & Revert Test Cases)

| Kịch Bản Kiểm Thử | Kỳ Vọng Kỹ Thuật | Tên Hàm Test | Kết Quả Thực Nghiệm |
|:---|:---|:---|:---:|
| **1. Release trước approve $\rightarrow$ REVERT** | • Mốc `Pending` (chưa nộp bài) $\rightarrow$ Revert `MilestoneNotApproved()`<br>• Mốc `Submitted` (đã nộp nhưng chưa duyệt) $\rightarrow$ Revert `MilestoneNotApproved()` | `test_VIOLATION_ReleaseBeforeApprove_Reverts`<br>`test_09_ReleaseBeforeApproveReverts`<br>`test_ECO_R4_01_ReleasePendingMilestoneReverts`<br>`test_ECO_R4_02_ReleaseSubmittedMilestoneReverts` | 🟢 **PASS** |
| **2. Release hai lần $\rightarrow$ REVERT** | Sau khi mốc đã `Disbursed`, mọi lệnh gọi `releaseMilestone` tiếp theo từ sinh viên hoặc sponsor đều bị đảo ngược với lỗi `AlreadyReleased()` | `test_VIOLATION_DoubleRelease_Reverts`<br>`test_10_DoubleReleaseReverts`<br>`test_ECO_R5_01_DoubleReleaseReverts` | 🟢 **PASS** |
| **3. Wrong student $\rightarrow$ REVERT** | • Sinh viên khác (`studentB`) nộp minh chứng $\rightarrow$ Revert `NotStudent()`<br>• Sinh viên khác gọi giải ngân $\rightarrow$ Revert `NotStudent()`<br>• Tạo suất với `student == address(0)` $\rightarrow$ Revert `InvalidAddress()`<br>• Tạo suất với `student == address(core)` $\rightarrow$ Revert `InvalidAddress()` | `test_VIOLATION_WrongStudent_Reverts`<br>`test_ECO_R1_04_NonStudentCannotSubmitProof`<br>`test_12_ZeroAddressStudentReverts` | 🟢 **PASS** |
| **4. Insufficient fund $\rightarrow$ REVERT** | • Suất chưa nạp tiền (`fundedAmount == 0`) $\rightarrow$ Revert `InsufficientFunds()`<br>• Suất nạp thiếu (`fundedAmount < milestoneAmount`) $\rightarrow$ Revert `InsufficientFunds()`<br>• Rút lẹm sang số dư suất khác $\rightarrow$ Revert `InsufficientFunds()` | `test_VIOLATION_InsufficientFund_Reverts`<br>`test_11_ReleaseWithInsufficientFundsReverts`<br>`test_ECO_R2_01_ReleaseZeroFundReverts`<br>`test_ECO_R2_02_ReleaseUnderfundedReverts`<br>`test_ECO_R7_02_CrossScholarshipFundIsolation` | 🟢 **PASS** |
| **5. Unauthorized caller $\rightarrow$ REVERT** | • Kẻ lạ nạp quỹ $\rightarrow$ Revert `NotSponsor()`<br>• Kẻ lạ nộp minh chứng $\rightarrow$ Revert `NotStudent()`<br>• Sponsor nộp thay sinh viên $\rightarrow$ Revert `NotStudent()`<br>• Kẻ lạ/Sinh viên tự duyệt mốc $\rightarrow$ Revert `NotSponsor()`<br>• Kẻ lạ gọi giải ngân $\rightarrow$ Revert `NotStudent()`<br>• Kẻ lạ/Sinh viên đổi verifier $\rightarrow$ Revert `NotSponsor()` | `test_VIOLATION_UnauthorizedCaller_Reverts`<br>`test_07_StrangerCannotApproveMilestone`<br>`test_08_StrangerCannotSubmitMilestone`<br>`test_ECO_R1_02_NonSponsorCannotFundScholarship`<br>`test_ECO_R1_05_StrangerCannotApproveMilestone`<br>`test_ECO_R1_06_StudentCannotSelfApprove`<br>`test_ECO_R1_09_StrangerCannotTriggerRelease`<br>`test_ECO_R1_10_NonVerifierCannotUpdateVerifier` | 🟢 **PASS** |

---

## 4. Đánh Giá Hợp Đồng Thông Minh (Contract Conformance Evaluation)

- **Nguyên tắc đối chiếu:** Kiểm tra xem có bất kỳ hành vi nào của contract vi phạm `docs/SPEC.md` và `docs/ECONOMIC_RULES.md` hay không.
- **Kết luận:**
  - Toàn bộ **64/64 test cases đều PASS 100%**.
  - Không có test case nào thất bại.
  - Hợp đồng [`contracts/project/ProjectCore.sol`](../../contracts/project/ProjectCore.sol) tuân thủ tuyệt đối quy định nghiệp vụ và mô hình kinh tế phi lưu ký.
  - **Không phát hiện lỗi contract vi phạm SPEC/ECONOMIC_RULES**.
  - Tuân thủ nguyên tắc: *"Không sửa contract trừ khi test chứng minh contract vi phạm SPEC/ECONOMIC_RULES"*.

---

## 5. Tổng Kết Về Loại Tiền Tệ
- **Chính thức:** Hệ thống vận hành bằng **100% Native ETH testnet** (Sepolia / Arbitrum Sepolia).
- **Không sử dụng token ERC-20:** Không cần mock ERC-20, không phụ thuộc thư viện token ngoại vi, tối ưu hóa gas và loại trừ rủi ro từ chuẩn token bên ngoài.

