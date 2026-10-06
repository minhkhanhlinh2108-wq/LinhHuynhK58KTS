# Báo Cáo Đo Lường Chi Phí Gas (Gas Profiling Report) — Lab 14

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Nội dung:** Đo lường chi phí Gas thực tế, phân tích cấu trúc lưu trữ và đối chuẩn tối ưu hóa  
> **Thành viên thực hiện:**  
> • **Nguyễn Minh Khánh Linh** (Lead Gas Optimization & Smart Contract)  
> • **Trần Thị Như Huỳnh** (QA & Testing Lead)  
> **Thời điểm thực hiện:** 06/10/2026  
> **Mã nguồn kiểm thử:** [`test/Lab14_GasReport.t.sol`](../../test/Lab14_GasReport.t.sol)  

---

## 1. Kết Quả Đo Lường Gas Bằng EVM Opcodes (`gasleft()`)

### Lệnh thực thi:
```powershell
npx.cmd hardhat test test/Lab14_GasReport.t.sol
```

### Log Terminal đầu ra nguyên bản:
```text
Compiled 1 Solidity file with solc 0.8.20 (evm target: shanghai)

Running Solidity tests

  test/Lab14_GasReport.t.sol:Lab14GasReportTest
GAS [Full 2-Milestone Lifecycle Total Gas]: 485976
    ✔ test_GAS06_FullLifecycle_TotalGas()
GAS [releaseMilestone 0.5 ETH]: 55273
    ✔ test_GAS05_ReleaseMilestone_Benchmark()
GAS [approveMilestone Verifier]: 26055
    ✔ test_GAS04_ApproveMilestone_Benchmark()
GAS [submitMilestone IPFS CID]: 89970
    ✔ test_GAS03_SubmitMilestone_Benchmark()
GAS [fundScholarship 1 ETH]: 35691
    ✔ test_GAS02_FundScholarship_Benchmark()
GAS [createScholarship 2 milestones]: 218922
    ✔ test_GAS01_CreateScholarship_Benchmark()

6 passing (6 solidity)
```

---

## 2. Bảng Đối Chuẩn Chi Phí Gas Các Hàm Nghiệp Vụ Cốt Lõi

| STT | Hàm Nghiệp Vụ | Thao Tác Đo Lường | Gas Tiêu Thụ Thực Tế | Ngưỡng Giới Hạn Cho Phép | Trạng Thái Đạt Chuẩn |
|:---:|:---|:---|:---:|:---:|:---:|
| 1 | `createScholarship` | Khởi tạo suất học bổng gồm 2 mốc giải ngân (SSTORE struct & dynamic array) | **218,922 gas** | < 250,000 gas | ✅ ĐẠT TỐI ƯU |
| 2 | `fundScholarship` | Nạp 1.0 ETH ký quỹ vào hợp đồng, cập nhật `fundedAmount` | **35,691 gas** | < 60,000 gas | ✅ ĐẠT TỐI ƯU |
| 3 | `submitMilestone` | Nộp bằng chứng IPFS CID chuỗi String (SSTORE chuỗi ký tự) | **89,970 gas** | < 120,000 gas | ✅ ĐẠT TỐI ƯU |
| 4 | `approveMilestone` | Thẩm định viên phê duyệt mốc (SSTORE Enum `APPROVED`) | **26,055 gas** | < 45,000 gas | ✅ ĐẠT TỐI ƯU |
| 5 | `releaseMilestone` | Giải ngân 0.5 ETH chuyển trực tiếp tới sinh viên (CEI + low-level call) | **55,273 gas** | < 75,000 gas | ✅ ĐẠT TỐI ƯU |
| 6 | **Toàn Bộ Vòng Đời** | **Chuỗi 8 giao dịch đầy đủ 2 mốc từ Create đến Release** | **485,976 gas** | **< 550,000 gas** | ✅ **XUẤT SẮC** |

---

## 3. Phân Tích Cấu Trúc Lưu Trữ (Storage Layout & Slot Packing)

1. **`struct Milestone`:**
   - `uint256 amount`: Slot 0 (32 bytes).
   - `MilestoneStatus status`: Slot 1 (1 byte enum).
   - `string proofCid`: Slot 2 (string layout linh hoạt).
2. **`struct Scholarship`:**
   - `address sponsor`: Slot 0 (20 bytes).
   - `address student`: Slot 1 (20 bytes).
   - `uint256 totalAmount`: Slot 2 (32 bytes).
   - `uint256 fundedAmount`: Slot 3 (32 bytes).
   - `uint256 disbursedAmount`: Slot 4 (32 bytes).
   - `Milestone[] milestones`: Slot 5 (dynamic array pointer).

**Nhận xét:**
- Các biến giá trị lớn (`uint256`) và `address` được bố trí hợp lý.
- Mọi hàm dòng tiền đều tuân thủ nguyên tắc CEI và bảo đảm không xảy ra rò rỉ gas do vòng lặp vô hạn. Toàn bộ chu kỳ giải ngân 2 mốc chỉ tiêu tốn dưới 500,000 gas, hoàn toàn khả thi và tiết kiệm chi phí trên mạng L2/EVM.
