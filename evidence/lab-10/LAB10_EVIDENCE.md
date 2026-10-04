# Bằng Chứng Thực Nghiệm Lab 10 (Lab 10 Evidence) — TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Nội dung:** Bằng chứng kiểm toán an ninh nội bộ vòng 1 & kiểm chứng thực nghiệm 8 phát hiện (Security Audit & Verification Round)  
> **Thành viên thực hiện:** Trần Thị Như Huỳnh (Audit) & Nguyễn Minh Khánh Linh (Security / Smart Contract)  
> **Thời điểm thực hiện:** 03/10/2026  
> **Tài liệu bàn giao:** [`docs/LAB10_AUDIT.md`](../../docs/LAB10_AUDIT.md), [`test/Lab10_Verify.t.sol`](../../test/Lab10_Verify.t.sol), [`docs/AI_JOURNAL.md`](../../docs/AI_JOURNAL.md)  

---

## 1. Kết Quả Kiểm Toán An Ninh Vòng 1 (Internal Security Audit)

Báo cáo kiểm toán [`docs/LAB10_AUDIT.md`](../../docs/LAB10_AUDIT.md) đã rà soát 13 nhóm tiêu chí an ninh bảo mật theo chuẩn quốc tế, ghi nhận:
- **0** Critical Vulnerability.
- **1** High Severity (`SEC-03`: Kẹt quỹ nếu sinh viên bỏ học — thiết kế phi lưu ký).
- **3** Medium Severity (`SEC-01`: Sponsor tự duyệt mốc; `SEC-02`: Thụt lùi trạng thái; `SEC-06`: DoS chuyển ETH).
- **3** Low Severity (`SEC-04`: Stranger tạo suất; `SEC-05`: Submit/Approve khi quỹ bằng 0; `SEC-07`: Mã lỗi sai tại setVerifier).
- **1** Informational (`SEC-08`: Sai khác tên Event/Error giữa SPEC và Code).
- **6 Nhóm An Toàn Tuyệt Đối:** Wrong recipient, Reentrancy, Checks-Effects-Interactions (CEI), Double release, Release before approval, Address(0) & Amount=0.

---

## 2. Bằng Chứng Thực Nghiệm Vòng Kiểm Chứng (Verification Round)

Nhóm đã lập trình tệp [`test/Lab10_Verify.t.sol`](../../test/Lab10_Verify.t.sol) với 13 test cases Foundry-style trên Hardhat 3 để tái hiện hoặc chứng minh an toàn cho từng phát hiện:

### Lệnh chạy kiểm chứng:
```bash
npx.cmd hardhat test test/Lab10_Verify.t.sol
```

### Kết quả đầu ra:
```text
Running Solidity tests

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

13 passing (13 solidity)
```

---

## 3. Kết Luận Vòng Kiểm Toán Lab 10

- 100% các phát hiện thực tế được kiểm chứng bằng test case tự động.
- Xác nhận các giả định an toàn về CEI, Non-reentrancy, và Chống giải ngân hai lần là hoàn toàn vững chắc.
- Lỗ hổng ưu tiên sửa (`SEC-02` - Thụt lùi trạng thái và bổ sung `VerifierUpdated` event) được xử lý đồng bộ trong Lab 11, đưa toàn bộ hệ thống về trạng thái an toàn.
