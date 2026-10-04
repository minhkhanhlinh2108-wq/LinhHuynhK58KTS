# Bằng Chứng Thực Nghiệm Lab 08 (Lab 08 Evidence) — TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Nội dung:** Khởi tạo đồ án, phân công vai trò, đặc tả nghiệp vụ v1.0 & quy tắc kinh tế chống lạm dụng  
> **Thành viên thực hiện:** Nguyễn Minh Khánh Linh (Nhóm trưởng) & Trần Thị Như Huỳnh (Thành viên)  
> **Thời điểm thực hiện:** 26/09/2026 – 01/10/2026  
> **Tài liệu bàn giao:** [`README.md`](../../README.md), [`docs/PROJECT_PLAN.md`](../../docs/PROJECT_PLAN.md), [`docs/SPEC.md`](../../docs/SPEC.md), [`docs/ECONOMIC_RULES.md`](../../docs/ECONOMIC_RULES.md), [`docs/AI_JOURNAL.md`](../../docs/AI_JOURNAL.md)  

---

## 1. Mục Tiêu & Kết Quả Bàn Giao Lab 08

Trong giai đoạn Lab 08, nhóm tập trung xây dựng toàn bộ nền tảng quản trị và kiến trúc tài liệu nghiệp vụ ("Spec First, Code Later"), tuyệt đối không sinh mã nguồn Smart Contract trước khi hoàn thiện đặc tả:

| STT | Tài Liệu Bàn Giao | Mục Tiêu Kỹ Thuật | Trạng Thái Hoàn Thành |
|:---:|:---|:---|:---:|
| 1 | **README.md** | Tổng quan hệ thống TrustScholar, liên kết repository GitHub, bảng phân vai 2 thành viên và sơ đồ điều hướng tài liệu liên kết chéo. | 🟢 **HOÀN THÀNH** |
| 2 | **docs/PROJECT_PLAN.md** | Phân công chuyên môn hóa 2 khối trách nhiệm (Khánh Linh: Business/SPEC + Security; Như Huỳnh: Testing + DApp + Audit), định nghĩa đối tượng người dùng, vấn đề cần giải quyết và 7 mốc kỹ thuật chuẩn (Lab 09 – Lab 15). | 🟢 **HOÀN THÀNH** |
| 3 | **docs/SPEC.md** | Đặc tả nghiệp vụ v1.0 với mục đích, đối tượng, input/output, vai trò actor, quy trình 5 bước theo Milestone, bộ 10 quy tắc bất biến R1–R10, 10 custom errors và ranh giới Out-of-Scope. | 🟢 **HOÀN THÀNH** |
| 4 | **docs/ECONOMIC_RULES.md** | Mô hình ký quỹ phi lưu ký bằng Native ETH, 4 giới hạn chống lạm dụng, làm rõ 3 câu hỏi quản trị cốt lõi, 4 kịch bản người dùng bị thiệt và phương án phòng ngừa. | 🟢 **HOÀN THÀNH** |
| 5 | **docs/AI_JOURNAL.md** | Nhật ký ứng dụng Generative AI chi tiết cho Lab 08 (khởi tạo, chuẩn hóa SPEC v1.0, chuyên đề Economic Rules), ghi nhận các ảo giác AI và quyết định sửa sai của nhóm. | 🟢 **HOÀN THÀNH** |

---

## 2. Bằng Chứng Rà Soát 5 Rủi Ro Lạm Dụng Tiềm Ẩn (Adversary Review)

Nhóm đã đóng vai người dùng thận trọng (Adversary/Auditor) và phát hiện 5 kịch bản lạm dụng để kịp thời hoàn thiện quy tắc trước khi lập trình:

1. **Rủi ro nạp thiếu quỹ (Underfunding Exploit):** Giải ngân khi chưa nạp đủ $\rightarrow$ Bổ sung quy tắc R4 và kiểm tra `fundedAmount >= releasedAmount + amount`.
2. **Rủi ro người thẩm định thông đồng (Collusion Risk):** Ràng buộc Verifier chỉ được duyệt mốc có minh chứng `Submitted` hợp lệ và lưu IPFS CID on-chain để kiểm toán chéo.
3. **Rủi ro DoS chuyển tiền (Push vs Pull Risk):** Nhận diện rủi ro khi ví sinh viên từ chối nhận ETH $\rightarrow$ Đưa vào kế hoạch kiểm toán Lab 10 và thực nghiệm Lab 13.
4. **Rủi ro mất khóa cá nhân (Lost Key Recovery):** Phân tích ranh giới Out-of-Scope và quy định địa chỉ ví sinh viên bất biến trên contract.
5. **Rủi ro rút trộm quỹ (Sponsor Front-running Refund):** Xác lập nguyên tắc phi lưu ký (Non-custodial Escrow), hợp đồng không cung cấp bất kỳ hàm rút tiền tùy tiện nào cho Admin hay Sponsor trái cam kết học bổng.

---

## 3. Kết Luận Bàn Giao Lab 08

Toàn bộ tài liệu kiến trúc của Lab 08 đã được nghiệm thu nội bộ, đồng bộ 100% với nhau và làm cơ sở vững chắc cho việc thiết kế Smart Contract tại Lab 09.
