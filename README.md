# TrustScholar - Nền Tảng Giải Ngân Học Bổng Minh Bạch Trên Blockchain

> **Dự án:** TrustScholar — Giải ngân học bổng minh bạch trên Blockchain  
> **Repository GitHub:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  
> **Điều hướng nhanh:** [Kế Hoạch Đồ Án](docs/PROJECT_PLAN.md) | [Đặc Tả Nghiệp Vụ](docs/SPEC.md) | [Quy Tắc Kinh Tế](docs/ECONOMIC_RULES.md) | [Kiểm Toán Lab 10](docs/LAB10_AUDIT.md) | [Gate Review 1](docs/GATE_REVIEW_1.md) | [Thực Nghiệm An Ninh Lab 13](docs/LAB13_SECURITY.md) | [Nhật Ký AI](docs/AI_JOURNAL.md)  
> **Slogan:** *Nhóm xây dựng nền tảng TrustScholar cho nhà tài trợ và sinh viên để đảm bảo giải ngân học bổng tự động, minh bạch và chống sai đối tượng.*

---

## 1. Thông Tin Nhóm & Đồ Án
- **Môn học:** Lập trình Smart Contract / Web3 (2026)
- **Tên dự án:** TrustScholar
- **Quy mô:** Nhóm 2 thành viên

| STT | Họ và Tên | Mã Sinh Viên | Email | Vai Trò Chính |
|:---:|:---|:---:|:---|:---|
| 1 | Nguyễn Minh Khánh Linh | 24K4320024 | 24k4320024@hce.edu.vn | Nhóm trưởng *(Business/SPEC + Smart Contract/Security)* |
| 2 | Trần Thị Như Huỳnh | 24K4320010 | 24K4320010@hce.edu.vn | Thành viên *(Testing + DApp + Audit)* |

---

## 2. Cấu Trúc Thư Mục Dự Án
```text
.
├── README.md                  # Giới thiệu tổng quan và thông tin nhóm
├── contracts/                 # Mã nguồn Smart Contract
│   ├── project/
│   │   └── ProjectCore.sol    # Hợp đồng lõi Escrow phi lưu ký theo mốc (Code Freeze)
│   └── training/              # Hợp đồng đào tạo thực nghiệm an ninh Lab 13
│       ├── VulnerableScholarshipBank.sol # Mô phỏng lỗi Reentrancy vi phạm CEI
│       ├── AttackerScholarshipBank.sol   # Contract tấn công tái nhập đệ quy
│       └── SecureScholarshipBank.sol     # Phiên bản vá lỗi bằng CEI & Mutex Guard
├── docs/                      # Tài liệu kỹ thuật và quản trị đồ án
│   ├── PROJECT_PLAN.md        # Phân công vai trò, đối tượng & lộ trình mốc Lab 08–15
│   ├── SPEC.md                # Đặc tả nghiệp vụ v1.0 với bộ 10 quy tắc R1–R10
│   ├── ECONOMIC_RULES.md      # Quy tắc kinh tế, dòng tiền, hạn mức & chống lạm dụng
│   ├── LAB10_AUDIT.md         # Báo cáo kiểm toán an ninh nội bộ vòng 1 (8 findings)
│   ├── GATE_REVIEW_1.md       # Biên bản thẩm định mốc 1 & Code Freeze Smart Contract
│   ├── LAB13_SECURITY.md      # Báo cáo thực nghiệm an ninh & kiểm toán chuyên sâu Lab 13
│   └── AI_JOURNAL.md          # Nhật ký ứng dụng AI xuyên suốt các bài Lab
├── evidence/                  # Bằng chứng thực nghiệm từng bài Lab
│   ├── lab-08/                # Bằng chứng đặc tả & quy tắc kinh tế ban đầu
│   ├── lab-09/                # Bằng chứng biên dịch & 17 unit tests đầu tiên
│   ├── lab-10/                # Bằng chứng kiểm toán an ninh & 13 verification tests
│   ├── lab-11/                # Bằng chứng 8 yêu cầu kinh tế & 34 tests chuyên sâu
│   └── lab-13/                # Bằng chứng thực nghiệm an ninh Reentrancy & 10 tests
└── test/                      # Hệ thống kiểm thử tự động (74/74 tests PASS)
    ├── ProjectCore.t.sol      # Test suite chuẩn Lab 09 (17 tests)
    ├── Lab10_Verify.t.sol     # Test suite kiểm chứng findings Lab 10 (13 tests)
    ├── Lab11_EconomicRules.t.sol # Test suite kinh tế Lab 11 (34 tests)
    └── Lab13_SecurityExperiments.t.sol # Test suite thực nghiệm an ninh Lab 13 (10 tests)
```

---

## 3. Điều Hướng Tài Liệu & Kho Lưu Trữ
- 🌐 **Mã nguồn GitHub:** [https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)
- 📋 **Kế hoạch & Phân công vai trò:** [PROJECT_PLAN.md](docs/PROJECT_PLAN.md)
- 📐 **Đặc tả nghiệp vụ & 10 Quy tắc R1–R10:** [SPEC.md](docs/SPEC.md)
- 💰 **Quy tắc kinh tế & Chống lạm dụng:** [ECONOMIC_RULES.md](docs/ECONOMIC_RULES.md)
- 🛡️ **Báo cáo kiểm toán bảo mật Lab 10:** [LAB10_AUDIT.md](docs/LAB10_AUDIT.md)
- 🚦 **Biên bản thẩm định Gate Review 1:** [GATE_REVIEW_1.md](docs/GATE_REVIEW_1.md)
- 🔬 **Báo cáo thực nghiệm an ninh Lab 13:** [LAB13_SECURITY.md](docs/LAB13_SECURITY.md)
- 🧾 **Bằng chứng thực nghiệm Lab 13:** [LAB13_EVIDENCE.md](evidence/lab-13/LAB13_EVIDENCE.md)
- 🤖 **Nhật ký ứng dụng AI xuyên suốt:** [AI_JOURNAL.md](docs/AI_JOURNAL.md)

---
> 🔗 **Liên kết nhanh:** [Trang chủ](README.md) • [Kế hoạch đồ án](docs/PROJECT_PLAN.md) • [Đặc tả nghiệp vụ](docs/SPEC.md) • [Quy tắc kinh tế](docs/ECONOMIC_RULES.md) • [Kiểm toán Lab 10](docs/LAB10_AUDIT.md) • [Gate Review 1](docs/GATE_REVIEW_1.md) • [Thực nghiệm an ninh Lab 13](docs/LAB13_SECURITY.md) • [Nhật ký AI](docs/AI_JOURNAL.md) • [GitHub Repo](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)
