# Bằng Chứng Kiểm Toán Chéo — Lab 14 Phase 2 (Audit Verification Evidence)

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Nội dung:** Hồ sơ kiểm chứng độc lập các Findings của Thành viên 1 (Kiểm Toán Chéo)  
> **Người thẩm tra:** Trần Thị Như Huỳnh (MSV: 24K4320010) — *QA & Testing Lead*  
> **Commit kiểm toán:** `00edde110a83d11ec1d8e69b31742420527a4c4d`  
> **Ngày thực hiện:** 06/10/2026  

---

## 1. Bằng Chứng Thực Nghiệm: False Positive (AUDIT-LAB14-01)

**Finding của Người 1:** "Tham số mảng `milestoneAmounts` đang dùng `memory`, cần đổi sang `calldata`."

**Kiểm tra trực tiếp mã nguồn** tại commit `00edde1`:

```bash
# Lệnh kiểm tra
grep -n "milestoneAmounts" contracts/project/ProjectCore.sol
```

**Kết quả thực tế:**
```
Line 134: uint256[] calldata milestoneAmounts   <-- ĐÃ DÙNG calldata ✅
Line 149: uint256[] calldata milestoneAmounts   <-- ĐÃ DÙNG calldata ✅
Line 322: uint256[] calldata milestoneAmounts   <-- ĐÃ DÙNG calldata ✅
```

**Phán quyết:** ❌ FALSE POSITIVE — Finding không tồn tại trong code thực tế.

---

## 2. Bằng Chứng Thực Nghiệm: Confirmed Issue (AUDIT-LAB14-02)

**Finding của Người 1:** "Push Transfer tại `releaseMilestone` gây DoS nếu ví sinh viên là Smart Contract."

**Test case kiểm chứng** (chạy trong `test/Lab10_Verify.t.sol`):

| Test Name | Scenario | Expected | Result |
|:---|:---|:---:|:---:|
| `test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS()` | Ví sinh viên cố tình `revert()` khi nhận ETH | `revert TransferFailed()` | ✅ PASS |
| `test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS()` | Ví sinh viên là Contract không có `receive()` | `revert TransferFailed()` | ✅ PASS |

**Log kiểm thử thực tế (chạy ngày 06/10/2026):**
```text
npx hardhat test

85 passing (85 solidity)
  ✔ test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS()
  ✔ test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS()
```

**Phán quyết:** ⚠️ CONFIRMED ISSUE — Finding tồn tại thực sự về mặt kiến trúc EVM.

---

## 3. Tóm Tắt Ma Trận Phân Loại Findings

| ID Finding | Người Phát Hiện | Severity | Phân Loại Sau Kiểm Chứng | Bằng Chứng |
|:---|:---:|:---:|:---:|:---|
| AUDIT-LAB14-01 | Người 1 (Khánh Linh) | Informational | ❌ FALSE POSITIVE | `grep calldata` → 3 hàm đã dùng `calldata` |
| AUDIT-LAB14-02 | Người 1 (Khánh Linh) | Low | ✅ CONFIRMED ISSUE | 2 SEC-06 tests PASS (Lab10_Verify.t.sol) |
| AUDIT-LAB14-03 | Người 2 (Như Huỳnh) | High | ✅ CONFIRMED ISSUE | `test_VERIFY_SEC03_FundLocking_EXISTS` PASS |
| AUDIT-LAB14-04 | Người 2 (Như Huỳnh) | Low/Medium | ℹ️ INTENDED DESIGN | SPEC.md Mục 6 Bước 4 xác nhận mô hình kép |
| AUDIT-LAB14-05 | Người 2 (Như Huỳnh) | Low | ⚠️ POTENTIAL ISSUE | `test_VERIFY_SEC05_SubmitApproveWithZeroFund` PASS |
| AUDIT-LAB14-06 | Người 2 (Như Huỳnh) | Low | ✅ CONFIRMED ISSUE | `test_VERIFY_SEC07_WrongErrorCode_EXISTS` PASS |

---

## 4. Xác Nhận Toàn Bộ Test Suite Còn PASS Sau Kiểm Toán

Đảm bảo quy trình kiểm toán không làm ảnh hưởng đến tính ổn định của codebase:

```text
Running Solidity tests

  85 passing (85 solidity)

  EXIT CODE: 0
```

**✅ Xác nhận: Không có test nào fail sau quá trình kiểm toán.**  
**✅ Xác nhận: Mã nguồn `ProjectCore.sol` không bị thay đổi.**  
**✅ Xác nhận: Code Freeze vẫn được duy trì.**

---

*Hồ sơ được lập bởi Trần Thị Như Huỳnh (QA & Testing Lead) — Lab 14, ngày 06/10/2026*  
*Báo cáo đầy đủ: [`docs/AUDIT_REPORT.md`](../../docs/AUDIT_REPORT.md)*
