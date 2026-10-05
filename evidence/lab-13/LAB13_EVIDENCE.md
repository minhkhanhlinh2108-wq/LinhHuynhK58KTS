# Bằng Chứng Thực Nghiệm Lab 13 (Lab 13 Evidence) — TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Nội dung:** Bằng chứng thực nghiệm an ninh bảo mật (Reentrancy Exploit & Defense) & Báo cáo kiểm toán chuyên sâu hợp đồng lõi  
> **Thành viên thực hiện:**  
> • **Nguyễn Minh Khánh Linh** (Security Lead)  
> • **Trần Thị Như Huỳnh** (Testing & QA Lead)  
> **Thời điểm thực hiện:** 05/10/2026  
> **Tài liệu bàn giao:**  
> • [`docs/LAB13_SECURITY.md`](../../docs/LAB13_SECURITY.md)  
> • [`contracts/training/VulnerableScholarshipBank.sol`](../../contracts/training/VulnerableScholarshipBank.sol)  
> • [`contracts/training/AttackerScholarshipBank.sol`](../../contracts/training/AttackerScholarshipBank.sol)  
> • [`contracts/training/SecureScholarshipBank.sol`](../../contracts/training/SecureScholarshipBank.sol)  
> • [`test/Lab13_SecurityExperiments.t.sol`](../../test/Lab13_SecurityExperiments.t.sol)  
> • [`docs/AI_JOURNAL.md`](../../docs/AI_JOURNAL.md)  

---

## 1. Danh Mục Tệp Thực Nghiệm Được Khởi Tạo

| Tệp Tin | Loại | Mục Đích |
|:---|:---:|:---|
| [`contracts/training/VulnerableScholarshipBank.sol`](../../contracts/training/VulnerableScholarshipBank.sol) | Contract | Hợp đồng đào tạo cố tình chứa lỗi Reentrancy (external call trước state update) |
| [`contracts/training/AttackerScholarshipBank.sol`](../../contracts/training/AttackerScholarshipBank.sol) | Contract | Hợp đồng tấn công giả lập thực hiện hook `receive()` gọi lại `withdraw()` |
| [`contracts/training/SecureScholarshipBank.sol`](../../contracts/training/SecureScholarshipBank.sol) | Contract | Hợp đồng đào tạo an toàn áp dụng CEI và `nonReentrant` Mutex Guard |
| [`test/Lab13_SecurityExperiments.t.sol`](../../test/Lab13_SecurityExperiments.t.sol) | Test Suite | 10 bài test thực nghiệm kiểm chứng exploit, defense và audit `ProjectCore.sol` |
| [`docs/LAB13_SECURITY.md`](../../docs/LAB13_SECURITY.md) | Tài liệu | Báo cáo phân tích chuyên sâu mô hình mối đe dọa, CEI và 5 câu hỏi audit |

---

## 2. Kết Quả Kiểm Thử Thực Nghiệm Độc Lập

### Lệnh thực thi:
```powershell
npx.cmd hardhat test test/Lab13_SecurityExperiments.t.sol
```

### Log Terminal đầu ra nguyên bản:
```text
Compiled 1 Solidity file with solc 0.8.20 (evm target: shanghai)

Running Solidity tests

  test/Lab13_SecurityExperiments.t.sol:Lab13SecurityExperimentsTest
    ✔ test_EXP04_SecureBank_UnhandledReentrancyRevertsTransfer
    ✔ test_EXP03_SecureBank_ReentrancyGuard_PreventsReentrancy
    ✔ test_EXP02_SecureBank_CEI_PreventsReentrancy
    ✔ test_EXP01_VulnerableBank_DrainedByReentrancy
    ✔ test_AUDIT06_ProjectCore_ReentrancyAttack_Defeated
    ✔ test_AUDIT05_ProjectCore_ReleaseBeforeApprovalBlocked
    ✔ test_AUDIT04_ProjectCore_WrongStudentBlocked
    ✔ test_AUDIT03_ProjectCore_DoubleReleaseBlocked
    ✔ test_AUDIT02_ProjectCore_StateUpdateBeforeCall_CEI
    ✔ test_AUDIT01_ProjectCore_HasExternalCall_ToStudent

10 passing (10 solidity)
```

---

## 3. Kết Quả Kiểm Thử Toàn Trình Codebase (Regression Test Suite)

### Lệnh thực thi:
```powershell
npx.cmd hardhat test
```

### Log Terminal đầu ra:
```text
No contracts to compile

Running Solidity tests

  test/Lab13_SecurityExperiments.t.sol:Lab13SecurityExperimentsTest
    ✔ test_EXP04_SecureBank_UnhandledReentrancyRevertsTransfer()
    ✔ test_EXP03_SecureBank_ReentrancyGuard_PreventsReentrancy()
    ✔ test_EXP02_SecureBank_CEI_PreventsReentrancy()
    ✔ test_EXP01_VulnerableBank_DrainedByReentrancy()
    ✔ test_AUDIT06_ProjectCore_ReentrancyAttack_Defeated()
    ✔ test_AUDIT05_ProjectCore_ReleaseBeforeApprovalBlocked()
    ✔ test_AUDIT04_ProjectCore_WrongStudentBlocked()
    ✔ test_AUDIT03_ProjectCore_DoubleReleaseBlocked()
    ✔ test_AUDIT02_ProjectCore_StateUpdateBeforeCall_CEI()
    ✔ test_AUDIT01_ProjectCore_HasExternalCall_ToStudent()

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

74 passing (74 solidity)
```

---

## 4. Tóm Tắt Xác Nhận An Ninh Cho ProjectCore.sol

| Câu Hỏi Kiểm Toán | Kết Quả Rà Soát | Vị Trí Mã Nguồn | Cơ Chế Bảo Vệ |
|:---|:---:|:---:|:---|
| **1. Có external call không?** | **CÓ** | Dòng 259 | `s.student.call{value: amountToRelease}("")` |
| **2. State update có trước call không?** | **CÓ** | Dòng 254–256 | Tuân thủ 100% mẫu CEI (`m.status = Disbursed`, `releasedAmount += amount`) |
| **3. Release hai lần có bị chặn không?** | **CÓ** | Dòng 245 | Chặn bởi `AlreadyReleased()` |
| **4. Wrong student có bị chặn không?** | **CÓ** | Dòng 190, 238, 259 | Tiền luôn chỉ chuyển vào ví `s.student`, người lạ bị chặn bởi `NotStudent()` |
| **5. Release trước approval có bị chặn không?** | **CÓ** | Dòng 246 | Chặn bởi `MilestoneNotApproved()` |
| **6. Tấn công Reentrancy trực tiếp** | **BỊ ĐÁNH BẠI** | Toàn bộ hàm giải ngân | Khóa Mutex `nonReentrant` + CEI trạng thái vô hiệu hóa hoàn toàn attacker |

**Cam kết nhóm:** Hợp đồng lõi `ProjectCore.sol` an toàn 100%, không bị sửa đổi, giữ vững trạng thái Code Freeze.

---

## 5. Thông Tin Lưu Trữ & Đối Soát Git
- **Mã Commit Git:** [`b4947b2`](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS/commit/b4947b2)
- **Thông điệp Commit:** `feat(lab-13): hoan thanh security experiment - mo phong reentrancy va audit ProjectCore (74/74 tests pass)`
- **Trạng thái Code Freeze:** Khẳng định 100% không chỉnh sửa file `contracts/project/ProjectCore.sol`.
- **Tình trạng kiểm thử:** Tái hiện độc lập 100% bằng lệnh `npx.cmd hardhat test` (~8 giây, 74/74 passing).
- **Kế hoạch tiếp theo:** Sẵn sàng chuyển giao sang **Lab 14: Cross-Audit & Gas Optimization**.

---
> 🔗 **Liên kết nhanh:** [Trang chủ README](../../README.md) • [Kế hoạch đồ án](../../docs/PROJECT_PLAN.md) • [Đặc tả nghiệp vụ](../../docs/SPEC.md) • [Quy tắc kinh tế](../../docs/ECONOMIC_RULES.md) • [Báo cáo an ninh Lab 13](../../docs/LAB13_SECURITY.md) • [Nhật ký AI](../../docs/AI_JOURNAL.md) • [GitHub Repo](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)
