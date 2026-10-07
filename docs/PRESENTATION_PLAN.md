# Kế Hoạch & Kịch Bản Thuyết Trình Bảo Vệ Đồ Án Cuối Kỳ — TrustScholar (Presentation Plan)

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Môn học:** Lập trình Smart Contract & Web3 (Niên khóa 2026)  
> **Nhóm thực hiện:**  
> • **Nguyễn Minh Khánh Linh** (MSV: 24K4320024) — *Nhóm trưởng (Business/SPEC & Smart Contract/Security)*  
> • **Trần Thị Như Huỳnh** (MSV: 24K4320010) — *Thành viên (QA & Testing Lead, DApp Frontend)*  
> **Thời lượng báo cáo dự kiến:** 10 – 12 phút (7 phút thuyết trình + demo, 3–5 phút Q&A)  
> **Địa chỉ repository:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  

---

## 1. Mục Tiêu & Thông Điệp Cốt Lõi (Core Message)

- **Vấn đề thực tế (Problem Statement):**
  - Các chương trình học bổng truyền thống thường gặp vấn đề thiếu minh bạch: tiền giải ngân chậm trễ, thủ tục giấy tờ rườm rà, nguy cơ giải ngân sai đối tượng hoặc lạm dụng quỹ hỗ trợ.
  - Nhà tài trợ khó theo dõi tiến độ học tập thực tế của sinh viên sau khi chuyển tiền tài trợ.
- **Giải pháp TrustScholar (The Solution):**
  - Xây dựng giải pháp **Escrow phi lưu ký theo mốc (Milestone-based Escrow)** trực tiếp trên Blockchain Ethereum Sepolia.
  - Tiền tài trợ được khóa an toàn trong Smart Contract và chỉ giải ngân từng đợt khi sinh viên nộp bằng chứng hợp lệ (IPFS CID) và được Thẩm định viên/Nhà tài trợ phê duyệt.
  - Áp dụng nguyên tắc lập trình an ninh tối cao: **Checks-Effects-Interactions (CEI)**, **Mutex ReentrancyGuard**, ngăn chặn 100% rủi ro rút tiền kép, gửi nhầm địa chỉ hoặc DoS.

---

## 2. Cấu Trúc Thời Lượng Báo Cáo (10 Phút Chi Tiết)

| Thời Gian | Nội Dung Trình Bày | Người Phụ Trách | Mục Tiêu & Điểm Nhấn |
|:---:|:---|:---:|:---|
| **00:00 – 01:30**<br>(1.5 phút) | **1. Mở đầu & Bối cảnh dự án**<br>• Giới thiệu nhóm & dự án<br>• Thực trạng giải ngân học bổng<br>• Giải pháp TrustScholar | **Khánh Linh** | Gây ấn tượng với hội đồng bằng bài toán thực tế và tính cấp thiết của Blockchain trong giáo dục. |
| **01:30 – 03:30**<br>(2.0 phút) | **2. Kiến trúc Kỹ thuật & Mô hình Hợp đồng**<br>• Hợp đồng `ProjectCore.sol`<br>• Cấu trúc dữ liệu & RBAC<br>• Phòng thủ Reentrancy & CEI<br>• Đo lường chi phí Gas EVM | **Khánh Linh** | Khẳng định chất lượng kỹ thuật: Code Freeze tại Gate 1, tối ưu gas (< 500k gas trọn vòng đời), tuân thủ CEI. |
| **03:30 – 05:30**<br>(2.0 phút) | **3. Đảm Bảo Chất Lượng & Kiểm Toán Chéo**<br>• Kết quả 85/85 tests PASS 100%<br>• Phân tích Static Analysis (Slither)<br>• Kết quả Cross-Audit Lab 14<br>• Xử lý False Positive & Issue thật | **Như Huỳnh** | Thể hiện tính học thuật nghiêm túc: phân loại rõ ràng False Positive vs Real Issue, kiểm chứng thực nghiệm bằng test. |
| **05:30 – 08:30**<br>(3.0 phút) | **4. Trực Quan Hóa Live Demo Web3 DApp**<br>• Kết nối MetaMask Sepolia<br>• Sponsor tạo suất & Nạp Native ETH<br>• Sinh viên nộp IPFS CID<br>• Duyệt mốc & Giải ngân về ví sinh viên<br>• Tra cứu Explorer On-chain | **Như Huỳnh** *(Thao tác)*<br>& **Khánh Linh** *(Thuyết minh)* | Demo mượt mà không lỗi; chứng minh tiền đi thẳng vào ví sinh viên, không thể rút trước khi duyệt hoặc rút đúp. |
| **08:30 – 10:00**<br>(1.5 phút) | **5. Tổng kết, Bài học AI & Tương lai**<br>• Ứng dụng AI có kiểm soát (AI Journal)<br>• Định hướng nâng cấp Layer 2 & ZK-Proof<br>• Lời cảm ơn & Kết luận | **Khánh Linh** & **Như Huỳnh** | Tóm lược thành tựu đồ án và mở ra hướng phát triển mở rộng. |
| **10:00 – 15:00**<br>(3–5 phút) | **6. Vấn đáp & Phản biện Hội đồng (Q&A)** | **Cả 2 thành viên** | Trả lời tự tin, logic, dựa trên dữ liệu test và bằng chứng kiểm toán. |

---

## 3. Kịch Bản Live Demo 3 Phút (Step-by-Step Demo Script)

> **Môi trường Demo:** Web3 DApp `web/index.html` kết nối MetaMask trên mạng Ethereum Sepolia (Chain ID: `11155111`).  
> **Địa chỉ Contract:** `0x71C8360f089f24E1F034C7f6424e86a51d45C522` (hoặc Contract đã deploy trên Sepolia).

### Bước 1: Kết nối ví & Kiểm tra mạng (30 giây)
- **Thao tác:** Bấm nút **"Kết Nối Ví MetaMask"** ở góc phải màn hình.
- **Lời thuyết minh:** *"Hệ thống tự động phát hiện mạng kết nối. Nếu người dùng ở sai mạng, DApp sẽ cảnh báo và hỗ trợ chuyển sang mạng Sepolia Testnet chỉ với 1 click. Giao diện hoàn toàn không yêu cầu hay lưu trữ bất kỳ Private Key nào, bảo đảm an toàn phi lưu ký tuyệt đối."*

### Bước 2: Nhà tài trợ tạo suất học bổng & Nạp quỹ (45 giây)
- **Thao tác:**
  - Chuyển sang Tab **"1. Nhà Tài Trợ (Sponsor)"**.
  - Nhập ví sinh viên: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`.
  - Nhập 2 mốc giải ngân: `0.05, 0.05` ETH. Bấm **"Khởi Tạo Suất Học Bổng"**. Ký giao dịch.
  - Sau khi giao dịch xác nhận, nhập ID và nạp `0.1` ETH vào mục **"Nạp Quỹ Escrow"**. Bấm **"Nạp Tiền Vào Escrow"**. Ký giao dịch.
- **Lời thuyết minh:** *"Giao dịch tạo suất học bổng và nạp quỹ được ghi nhận tức thì trên blockchain Sepolia. DApp lập tức hiển thị Transaction Hash kèm link trực tiếp sang Etherscan để hội đồng kiểm chứng."*

### Bước 3: Sinh viên nộp minh chứng học tập IPFS (30 giây)
- **Thao tác:**
  - Chuyển sang Tab **"2. Sinh Viên (Student)"**.
  - Nhập Scholarship ID, Mốc 0, và IPFS CID: `QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx`.
  - Bấm **"Gửi Minh Chứng (submitMilestone)"**. Ký giao dịch.
- **Lời thuyết minh:** *"Sinh viên chỉ cần nộp mã băm IPFS CID chứa minh chứng kết quả học tập. Hệ thống lưu trữ hash on-chain, ngăn chặn việc làm giả giấy tờ."*

### Bước 4: Thẩm định viên phê duyệt mốc (30 giây)
- **Thao tác:**
  - Chuyển sang Tab **"3. Thẩm Định Viên (Verifier)"**.
  - Nhập Scholarship ID, Mốc 0. Bấm **"Phê Duyệt Mốc (approveMilestone)"**. Ký giao dịch.
- **Lời thuyết minh:** *"Thẩm định viên sau khi kiểm tra bằng chứng trên IPFS sẽ phê duyệt mốc on-chain. Smart Contract khóa chặt điều kiện: Mốc chưa được duyệt thì tuyệt đối không thể giải ngân."*

### Bước 5: Giải ngân tiền về ví sinh viên & Tra cứu Explorer (45 giây)
- **Thao tác:**
  - Quay lại Tab Sinh viên, bấm **"Kích Hoạt Giải Ngân (releaseMilestone)"**. Ký giao dịch.
  - Chuyển sang Tab **"4. Tra Cứu Minh Bạch (Explorer)"**, nhập Scholarship ID và bấm **"Tra Cứu Dữ Liệu"**.
- **Lời thuyết minh:** *"Khi giải ngân được kích hoạt, Smart Contract áp dụng nguyên tắc CEI: cập nhật trạng thái mốc sang Disbursed trước, rồi mới chuyển Native ETH trực tiếp vào ví sinh viên. Bảng thông tin Explorer hiển thị đầy đủ dòng tiền đã nạp, số tiền đã giải ngân và timestamp xác thực on-chain."*

---

## 4. Dự Trù & Chuẩn Bị Câu Hỏi Phản Biện (Q&A Defense Preparation)

### Câu hỏi 1: *"Nếu ví sinh viên bị mất khóa bí mật (lost private key), số tiền trong học bổng xử lý thế nào?"*
- **Trả lời:** Theo phạm vi đã đóng băng tại `SPEC.md` và `GATE_REVIEW_1.md`, việc khôi phục khóa ví EOA là rủi ro người dùng (Out-of-Scope) của tầng ứng dụng Web3 thông thường. Tuy nhiên, trong lộ trình nâng cấp (Lab 15+), nhóm đã thiết kế cơ chế Sponsor có thể thu hồi phần quỹ chưa giải ngân sau thời gian quá hạn (Timeout/Clawback), hoặc tích hợp ví trừu tượng hóa tài khoản ERC-4337 (Social Recovery) cho sinh viên.

### Câu hỏi 2: *"Tại sao hợp đồng sử dụng Push Transfer thay vì Pull Payment khi giải ngân?"*
- **Trả lời:**
  - Push transfer cho phép sinh viên nhận tiền thẳng vào ví ngay khi mốc được giải ngân mà không cần thêm một giao dịch rút tiền phụ.
  - Nhóm đã thực hiện kiểm toán chéo (Lab 14 Finding AUDIT-LAB14-02): Trong mô hình TrustScholar, ví sinh viên được đăng ký là ví cá nhân EOA (Externally Owned Account) nên không gặp lỗi từ chối gas. Đồng thời, hàm `releaseMilestone` áp dụng triệt để Checks-Effects-Interactions (CEI) và `nonReentrant` guard, triệt tiêu 100% nguy cơ Reentrancy Attack.

### Câu hỏi 3: *"Làm thế nào để hệ thống ngăn chặn việc rút tiền kép (Double Disbursement)?"*
- **Trả lời:**
  - Trước khi chuyển tiền, hợp đồng kiểm tra biến trạng thái `m.status`. Nếu `m.status == MilestoneStatus.Disbursed`, hợp đồng lập tức revert lỗi `AlreadyReleased()`.
  - Hợp đồng cập nhật `m.status = MilestoneStatus.Disbursed` và `s.releasedAmount += amountToRelease` **trước khi** thực thi lệnh chuyển ETH.
  - Tính năng này đã được kiểm chứng bởi test suite chuyên biệt: `test_10_DoubleReleaseReverts()`, `test_ECO_R5_01_DoubleReleaseReverts()` và `test_AUDIT03_ProjectCore_DoubleReleaseBlocked()` — tất cả đều PASS 100%.

### Câu hỏi 4: *"Chi phí Gas của hợp đồng có đắt không khi chạy trên mạng chính thức?"*
- **Trả lời:**
  - Nhóm đã đo lường chi phí Gas thực tế tại Lab 14 (`GAS_REPORT.md`):
    - `fundScholarship`: chỉ tiêu hao **35,691 gas**.
    - `approveMilestone`: chỉ tiêu hao **26,055 gas**.
    - `releaseMilestone`: chỉ tiêu hao **55,273 gas**.
    - Trọn vòng đời suất học bổng 2 mốc chỉ tốn **485,976 gas** (tương đương chưa đến 0.001 ETH ở mức gas 20 gwei).
  - Đồng thời hệ thống được thiết kế tương thích hoàn toàn để triển khai trên các giải pháp Layer 2 như Arbitrum Sepolia với chi phí giao dịch thấp hơn 95%.

---

## 5. Danh Mục Thiết Bị & Checklist Trước Giờ Báo Cáo

- [x] Laptop trình chiếu đã kiểm tra kết nối máy chiếu / HDMI.
- [x] Trình duyệt đã mở sẵn tab Web3 DApp `web/index.html` và ví MetaMask kết nối mạng Sepolia Testnet.
- [x] Ví MetaMask của Sponsor có sẵn SepoliaETH thử nghiệm (> 0.2 ETH).
- [x] Tab Etherscan Sepolia mở sẵn để tra cứu giao dịch on-chain.
- [x] Slide báo cáo định dạng PDF/PowerPoint đã sao lưu trên USB và Cloud dự phòng.
- [x] Toàn bộ mã nguồn và tài liệu trên GitHub ở trạng thái sạch, commit mới nhất.
