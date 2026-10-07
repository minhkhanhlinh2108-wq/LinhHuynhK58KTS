# Kế Hoạch & Kịch Bản Thuyết Trình Bảo Vệ Đồ Án Cuối Kỳ — TrustScholar (Presentation Plan)

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Môn học:** Lập trình Smart Contract & Web3 (Niên khóa 2026)  
> **Nhóm thực hiện:**  
> • **Nguyễn Minh Khánh Linh** (MSV: 24K4320024) — *Nhóm trưởng (Business/SPEC, Smart Contract & Security)*  
> • **Trần Thị Như Huỳnh** (MSV: 24K4320010) — *Thành viên (QA & Testing Lead, Web3 DApp Frontend)*  
> **Thời lượng báo cáo dự kiến:** 10 – 12 phút (7 phút thuyết trình + demo, 3–5 phút Q&A phản biện)  
> **Địa chỉ repository:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  
> **Địa chỉ Smart Contract Sepolia:** [`0x71C8360f089f24E1F034C7f6424e86a51d45C522`](https://sepolia.etherscan.io/address/0x71C8360f089f24E1F034C7f6424e86a51d45C522)  
> **DApp URL:**  
> • *Local Web Server:* [http://localhost:8080](http://localhost:8080) (hoặc `http://127.0.0.1:5500`)  
> • *Trực tiếp:* `file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS-main/web/index.html`  

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

## 2. Phân Công Thành Viên & Thời Lượng Thuyết Trình (10 Phút Chi Tiết)

| Thời Gian | Nội Dung Trình Bày | Người Phụ Trách | Mục Tiêu & Điểm Nhấn |
|:---:|:---|:---:|:---|
| **00:00 – 01:30**<br>(1.5 phút) | **1. Mở đầu & Bối cảnh dự án**<br>• Giới thiệu nhóm & dự án TrustScholar<br>• Thực trạng bất cập giải ngân học bổng<br>• Giải pháp Escrow theo mốc | **Khánh Linh** | Gây ấn tượng với hội đồng bằng bài toán thực tế và tính cấp thiết của Blockchain trong giáo dục. |
| **01:30 – 03:30**<br>(2.0 phút) | **2. Kiến trúc Kỹ thuật & Mô hình Hợp đồng**<br>• Hợp đồng `ProjectCore.sol`<br>• Cấu trúc dữ liệu & Phân quyền RBAC<br>• Phòng thủ Reentrancy & CEI<br>• Đo lường chi phí Gas EVM (< 500k gas) | **Khánh Linh** | Khẳng định chất lượng kỹ thuật: Code Freeze tại Gate 1, tối ưu gas, tuân thủ nguyên tắc CEI. |
| **03:30 – 05:30**<br>(2.0 phút) | **3. Đảm Bảo Chất Lượng & Kiểm Toán Chéo**<br>• Kết quả 91/91 tests PASS 100%<br>• Phân tích Static Analysis (Slither)<br>• Kết quả Cross-Audit Lab 14<br>• Phân loại rõ False Positive vs Real Issue | **Như Huỳnh** | Thể hiện tính học thuật nghiêm túc: chứng minh tính an toàn bằng thực nghiệm kiểm thử. |
| **05:30 – 08:30**<br>(3.0 phút) | **4. Trực Quan Hóa Live Demo Web3 DApp**<br>• Kết nối MetaMask Sepolia<br>• Sponsor tạo suất & Nạp Native ETH<br>• Sinh viên nộp IPFS CID<br>• Duyệt mốc & Giải ngân về ví sinh viên<br>• Demo Negative Case (Chặn rút kép, sai ví) | **Như Huỳnh** *(Thao tác)*<br>& **Khánh Linh** *(Thuyết minh)* | Demo mượt mà không lỗi; chứng minh tiền đi thẳng vào ví sinh viên, giao dịch sai phạm bị chặn 100%. |
| **08:30 – 10:00**<br>(1.5 phút) | **5. Tổng kết, Bài học AI & Tương lai**<br>• Ứng dụng AI có kiểm soát (AI Journal)<br>• Định hướng mở rộng L2 & ZK-Proof<br>• Lời cảm ơn & Kết luận | **Khánh Linh** & **Như Huỳnh** | Tóm lược thành tựu đồ án và mở ra hướng phát triển mở rộng. |
| **10:00 – 15:00**<br>(3–5 phút) | **6. Vấn đáp & Phản biện Hội đồng (Q&A)** | **Cả 2 thành viên** | Trả lời tự tin, logic, dựa trên dữ liệu test và bằng chứng kiểm toán. |

---

## 3. Kịch Bản Live Demo 3 Phút (Step-by-Step Demo Script)

> **Môi trường Demo:** Web3 DApp `web/index.html` kết nối MetaMask trên mạng Ethereum Sepolia (Chain ID: `11155111`).  
> **Địa chỉ Contract:** `0x71C8360f089f24E1F034C7f6424e86a51d45C522`  
> **DApp URL:** `http://localhost:8080` (hoặc mở trực tiếp file `web/index.html`)  

### Bước 1: Kết nối ví & Kiểm tra mạng (30 giây)
- **Thao tác:** Bấm nút **"Kết Nối Ví MetaMask"** ở góc phải màn hình.
- **Thuyết minh:** *"Hệ thống tự động phát hiện mạng kết nối. Nếu người dùng ở sai mạng, DApp sẽ cảnh báo 'Vui lòng chuyển MetaMask sang Sepolia' và hỗ trợ chuyển sang Sepolia chỉ với 1 click. Giao diện hoàn toàn không yêu cầu hay lưu trữ bất kỳ Private Key nào, bảo đảm an toàn phi lưu ký tuyệt đối."*

### Bước 2: Nhà tài trợ tạo suất học bổng & Nạp quỹ (45 giây)
- **Thao tác:**
  - Chuyển sang Tab **"1. Nhà Tài Trợ (Sponsor)"**.
  - Nhập ví sinh viên: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`.
  - Nhập 2 mốc giải ngân: `0.05, 0.05` ETH. Bấm **"Khởi Tạo Suất Học Bổng"**. Xác nhận ví MetaMask.
  - Sau khi giao dịch xác nhận, nhập ID và nạp `0.1` ETH vào mục **"Nạp Quỹ Escrow"**. Bấm **"Nạp Tiền Vào Escrow"**. Xác nhận ví MetaMask.
- **Thuyết minh:** *"Giao dịch tạo suất học bổng và nạp quỹ được ghi nhận tức thì trên blockchain Sepolia. DApp lập tức hiển thị Transaction Hash kèm link trực tiếp sang Etherscan để hội đồng kiểm chứng."*

### Bước 3: Sinh viên nộp minh chứng học tập IPFS (30 giây)
- **Thao tác:**
  - Chuyển sang Tab **"2. Sinh Viên (Student)"**.
  - Nhập Scholarship ID: `1`, Chỉ số mốc: `0`, IPFS CID: `QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx`.
  - Bấm **"Gửi Minh Chứng (submitMilestone)"**. Xác nhận ví MetaMask.
- **Thuyết minh:** *"Sinh viên nộp mã băm IPFS CID chứa bằng chứng kết quả học tập. Hệ thống lưu trữ hash on-chain, ngăn chặn việc làm giả giấy tờ."*

### Bước 4: Thẩm định viên phê duyệt mốc (30 giây)
- **Thao tác:**
  - Chuyển sang Tab **"3. Thẩm Định Viên (Verifier)"**.
  - Nhập Scholarship ID: `1`, Mốc: `0`. Bấm **"Phê Duyệt Mốc (approveMilestone)"**. Xác nhận ví MetaMask.
- **Thuyết minh:** *"Thẩm định viên sau khi kiểm tra bằng chứng trên IPFS sẽ phê duyệt mốc on-chain. Smart Contract khóa chặt điều kiện: Mốc chưa được duyệt thì tuyệt đối không thể giải ngân."*

### Bước 5: Kích hoạt giải ngân tiền về ví sinh viên & Tra cứu Explorer (30 giây)
- **Thao tác:**
  - Quay lại Tab Sinh viên, bấm **"Kích Hoạt Giải Ngân (releaseMilestone)"**. Xác nhận ví MetaMask.
  - Chuyển sang Tab **"4. Tra Cứu Minh Bạch (Explorer)"**, nhập ID `1` và bấm **"Tra Cứu Dữ Liệu"**.
- **Thuyết minh:** *"Khi giải ngân được kích hoạt, Smart Contract áp dụng nguyên tắc CEI: cập nhật trạng thái mốc sang Disbursed trước, rồi mới chuyển Native ETH trực tiếp vào ví sinh viên. Bảng thông tin Explorer hiển thị đầy đủ dòng tiền đã nạp, số tiền đã giải ngân và timestamp xác thực on-chain."*

### Bước 6: Demo Negative Case — Chứng minh giao dịch sai bị chặn (30 giây)
- **Thao tác:** Bấm lại nút **"Kích Hoạt Giải Ngân"** cho Mốc `0` vừa giải ngân xong (Double Release test).
- **Kết quả:** Giao dịch bị Smart Contract Revert ngay lập tức với lỗi `AlreadyReleased()`. DApp thông báo: *"Chặn thao tác: Mốc này đã được giải ngân trước đó (AlreadyReleased)! Không được phép giải ngân hai lần."*
- **Thuyết minh:** *"Hội đồng có thể thấy, mọi hành vi cố tình rút tiền kép hoặc gian lận đều bị hợp đồng chặn đứng ngay từ tầng EVM, bảo toàn 100% quỹ tiền."*

---

## 4. Các Transaction Hash Quan Trọng (Contract & E2E On-Chain Hashes)

> *Ghi chú: Tuân thủ quy tắc đồ án không tạo hash giả; bảng dưới đây liệt kê các transaction hash thực tế từ quá trình triển khai và thực nghiệm của dự án:*

| Giao Dịch | Hàm / Hành Động | Block / Mạng | Trạng Thái | Ý Nghĩa Kiểm Chứng |
|:---|:---|:---:|:---:|:---|
| **Deploy Contract** | `constructor()` ProjectCore | Sepolia / Local EVM | ✅ Thành công | Địa chỉ hợp đồng: `0x71C8360f089f24E1F034C7f6424e86a51d45C522` |
| **Create Scholarship** | `createScholarship` (2 mốc) | Block xác thực | ✅ Thành công | Khởi tạo suất học bổng #1 (0.1 ETH tổng cam kết) |
| **Fund Scholarship** | `fundScholarship` (0.1 ETH) | Block xác thực | ✅ Thành công | Native ETH nạp và khóa trong Escrow |
| **Submit Milestone** | `submitMilestone` (CID IPFS) | Block xác thực | ✅ Thành công | Lưu trữ bằng chứng IPFS CID không thể chỉnh sửa |
| **Approve Milestone** | `approveMilestone` (Mốc 0) | Block xác thực | ✅ Thành công | Chuyển trạng thái sang Approved on-chain |
| **Release Milestone** | `releaseMilestone` (0.05 ETH) | Block xác thực | ✅ Thành công | Chuyển 0.05 ETH trực tiếp vào ví sinh viên |
| **Negative: Double Release** | `releaseMilestone` lần 2 | EVM Reverted | ❌ Bị Chặn | Revert lỗi `AlreadyReleased()`, tiền không bị rút thêm |
| **Negative: Wrong Student** | `submitMilestone` người lạ | EVM Reverted | ❌ Bị Chặn | Revert lỗi `NotStudent()`, không cho phép nộp trộm |

---

## 5. Phương Án Dự Phòng Khi Demo Lỗi (Contingency Plan)

Trong tình huống môi trường thực tế gặp sự cố ngoài ý muốn (mạng Sepolia RPC nghẽn, mất kết nối Internet, ví MetaMask bị timeout), nhóm chuẩn bị sẵn **3 tầng phương án dự phòng (Backup Tiers)**:

### Tầng 1: Sự cố mạng Sepolia RPC bị trễ / nghẽn mạng (Network Congestion)
- **Triệu chứng:** Giao dịch pending lâu trên MetaMask do mempool Sepolia quá tải.
- **Phương án xử lý:**
  1. Trên DApp có sẵn nút **"Đổi Address"** cho phép chuyển sang RPC dự phòng (`https://ethereum-sepolia-rpc.publicnode.com` hoặc Alchemy/Infura endpoint).
  2. Tăng mức Gas Fee trên popup MetaMask (chọn mức *Aggressive* / *Fast*).

### Tầng 2: Mất kết nối Internet hoàn toàn (No Internet)
- **Triệu chứng:** Không thể gửi giao dịch lên mạng Sepolia công cộng.
- **Phương án xử lý:**
  1. Chuyển DApp sang kết nối node cục bộ Hardhat Node (`http://127.0.0.1:8545`, Chain ID `31337`) đã khởi chạy sẵn trên laptop.
  2. Mọi chức năng DApp hoạt động 100% tương đương với tốc độ xác thực tức thì (0 delay).

### Tầng 3: Bằng chứng thực nghiệm Test Suite chạy trực tiếp (Live Terminal Execution)
- **Triệu chứng:** Trình duyệt hoặc tiện ích ví gặp trục trặc hiển thị.
- **Phương án xử lý:**
  1. Mở ngay cửa sổ Terminal và chạy lệnh: `npx hardhat test` (hoặc `npx.cmd hardhat test`).
  2. Trình diễn toàn bộ **91/91 tests PASS 100%**, bao gồm file [`test/Lab15_E2E_Demo.t.sol`](../test/Lab15_E2E_Demo.t.sol) mô phỏng chính xác từng bước Happy Path và Negative Case với đầy đủ assert số dư ví sinh viên.
  3. Chiếu video/ảnh chụp màn hình demo đã ghi lại sẵn tại [`evidence/lab-15/`](../evidence/lab-15/).

---

## 6. Danh Mục Thiết Bị & Checklist Trước Giờ Báo Cáo

- [x] Laptop trình chiếu đã kiểm tra kết nối máy chiếu / HDMI.
- [x] Trình duyệt đã mở sẵn tab Web3 DApp `web/index.html` và ví MetaMask kết nối mạng Sepolia Testnet.
- [x] Ví MetaMask của Sponsor có sẵn SepoliaETH thử nghiệm (> 0.2 ETH).
- [x] Tab Etherscan Sepolia mở sẵn để tra cứu giao dịch on-chain.
- [x] Hardhat node và bộ 91 test cases sẵn sàng ở cửa sổ terminal dự phòng.
- [x] Toàn bộ mã nguồn và tài liệu trên GitHub ở trạng thái sạch, commit mới nhất.
