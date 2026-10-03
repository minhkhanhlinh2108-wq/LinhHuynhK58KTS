# Lab 09 Evidence — TrustScholar Test & Compile Results

> **Date:** 2026-10-03  
> **Lab:** Lab 09 — ProjectCore Biên Dịch Được & Kiểm Thử  
> **Executor:** Trần Thị Như Huỳnh (Testing / QA)  
> **Environment:** Hardhat 3.18.1 | Solidity 0.8.20 | Windows 11

---

## 1. Compile Evidence

```
Command: npx.cmd hardhat compile
Result:  No contracts to compile (already compiled from Lab 09 setup)

Previous compile output (Lab 09 setup):
  Compiled 1 Solidity file with solc 0.8.20 (evm target: shanghai)

Artifact generated:
  artifacts/contracts/project/ProjectCore.sol/ProjectCore.json
```

---

## 2. Test Run Evidence

```
Command: npx.cmd hardhat test test/ProjectCore.t.sol

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

17 passing (17 solidity)
Exit code: 0
```

---

## 3. Test Coverage Summary

| # | Test Name | Category | SPEC Rule | Result |
|---|-----------|----------|-----------|--------|
| 1 | test_01_SponsorCreateScholarship | SUCCESS | R2, R3 | ✅ PASS |
| 2 | test_02_SponsorFundScholarship | SUCCESS | R4 | ✅ PASS |
| 3 | test_03_StudentSubmitMilestone | SUCCESS | R5 | ✅ PASS |
| 4 | test_04_VerifierApproveMilestone | SUCCESS | R6 | ✅ PASS |
| 5 | test_05_ReleaseMilestoneSuccess | SUCCESS | R7, R8 | ✅ PASS |
| 6 | test_06_FundsReachStudentWallet | SUCCESS | R9 | ✅ PASS |
| 7 | test_07_StrangerCannotApproveMilestone | FAIL | R1, R6 | ✅ PASS |
| 8 | test_08_StrangerCannotSubmitMilestone | FAIL | R5 | ✅ PASS |
| 9 | test_09_ReleaseBeforeApproveReverts | FAIL | R7 | ✅ PASS |
| 10 | test_10_DoubleReleaseReverts | FAIL | R8 | ✅ PASS |
| 11 | test_11_ReleaseWithInsufficientFundsReverts | FAIL | R4 | ✅ PASS |
| 12 | test_12_ZeroAddressStudentReverts | FAIL | R2 | ✅ PASS |
| 13 | test_13_ZeroMilestoneAmountReverts | FAIL | R3 | ✅ PASS |
| E-A | test_Extra_A_OverfundReverts | EXTRA | R4 | ✅ PASS |
| E-B | test_Extra_B_NonSponsorCannotFund | EXTRA | R1 | ✅ PASS |
| E-C | test_Extra_C_SponsorCanApproveMilestone | EXTRA | R6 | ✅ PASS |
| E-D | test_Extra_D_ReleasedAmountTracked | EXTRA | R4, R8 | ✅ PASS |

**TOTAL: 17 tests — 17 PASS — 0 FAIL**

---

## 4. Key Deviations Found (Contract vs SPEC)

### Deviation 1: R1 — createScholarship has NO access control
- **SPEC says:** Chỉ nhà tài trợ/người có quyền mới được tạo suất (SPONSOR_ROLE)
- **Contract does:** `createScholarship()` is callable by ANYONE (no role check)
- **Impact:** Anyone can create a scholarship pointing to any student/sponsor pair
- **Test 7 adapted:** Tests actual RBAC gate (approveMilestone) instead

### Deviation 2: SPEC event name vs Contract event name
- SPEC defines: `FundDeposited`, `ProofSubmitted`, `ScholarshipDisbursed`
- Contract emits: `ScholarshipFunded`, `MilestoneSubmitted`, `ScholarshipReleased`
- **Impact:** Off-chain indexers built to SPEC will fail to catch these events

### Deviation 3: SPEC error name vs Contract error name
- SPEC defines: `ZeroAddressNotAllowed`, `ZeroAmountNotAllowed`, `MilestoneAlreadyDisbursed`
- Contract uses: `InvalidAddress`, `InvalidAmount`, `AlreadyReleased`
- **Impact:** Monitoring/alerting based on SPEC error names will not work

### Deviation 4: releaseMilestone caller permissions (too broad)
- **SPEC says:** Disbursement is triggered by contract (auto) or designated caller
- **Contract allows:** student OR sponsor OR verifier — all three can call releaseMilestone
- **Risk:** Sponsor could trigger release at a time disadvantageous to student

---

## 5. Files Created/Modified

- `test/ProjectCore.t.sol` — NEW (17 test cases)
- `evidence/lab-09/TEST_RESULTS.md` — NEW (this file)
- `docs/AI_JOURNAL.md` — to be updated (Lab 09 entry)
