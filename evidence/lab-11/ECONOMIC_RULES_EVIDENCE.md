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
Compiled 3 Solidity files with solc 0.8.20 (evm target: shanghai)

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

  test/Lab11_EconomicRules.t.sol:Lab11EconomicRulesTest
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

57 passing (57 solidity)
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

## 3. Tổng Kết Về Loại Tiền Tệ
- **Chính thức:** Hệ thống vận hành bằng **100% Native ETH testnet** (Sepolia / Arbitrum Sepolia).
- **Không sử dụng token ERC-20:** Không cần mock ERC-20, không phụ thuộc thư viện token ngoại vi, tối ưu hóa gas và loại trừ rủi ro từ chuẩn token bên ngoài.
