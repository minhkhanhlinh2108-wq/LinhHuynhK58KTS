# Kế Hoạch Đồ Án (Project Plan) - TrustScholar

Nền tảng giải ngân học bổng minh bạch, phi tập trung và chống gian lận trên Blockchain.

---

## 1. Thành Viên và Vai Trò

Dự án gồm **02 thành viên**. Toàn bộ quy trình phát triển chia thành **4 vai trò kỹ thuật chính**:
1. **Đặc tả (Specification & Architecture):** Phân tích nghiệp vụ, mô hình dữ liệu, viết tài liệu đặc tả logic hệ thống.
2. **Hợp đồng (Smart Contract Engineering):** Hiện thực hóa logic trên smart contract (Solidity), xử lý tối ưu gas và cấu trúc lưu trữ.
3. **Giao diện (Frontend & Web3 Integration):** Xây dựng giao diện tương tác người dùng dApp, kết nối ví và tương tác RPC.
4. **Kiểm thử (QA, Testing & Security Audit):** Viết unit tests, fuzz testing, kịch bản E2E và kiểm tra bảo mật (reentrancy, access control).

Để đảm bảo cả 2 thành viên đều nắm vững toàn diện kiến thức Full-stack Web3, các vai trò được **luân phiên** qua 2 giai đoạn:

### Bảng Phân Công Vai Trò Luân Phiên

| Giai Đoạn | Phạm Vi Lab | Thành Viên 1: Nguyễn Minh Khánh Linh (24K4320024) | Thành Viên 2: Trần Thị Như Huỳnh (24K4320010) |
|:---|:---:|:---|:---|
| **Giai đoạn 1: Core Contract & Verification** | **Lab 08 – Lab 11** | **Chủ trì: Hợp đồng & Đặc tả**<br>• Phân tích đặc tả v0.1 & mô hình hóa hợp đồng.<br>• Viết mã nguồn Smart Contract cốt lõi (Fund & Claim logic). | **Chủ trì: Kiểm thử & Giao diện chuẩn bị**<br>• Thiết lập test suite (Foundry/Hardhat), viết Unit Test & Fuzz Test.<br>• Phác thảo wireframe giao diện Web3. |
| **Giai đoạn 2: Frontend dApp & Integration** | **Lab 12 – Lab 15** | **Chủ trì: Kiểm thử E2E & Tối ưu hóa**<br>• Kiểm thử tích hợp Testnet, audit bảo mật nội bộ.<br>• Tối ưu chi phí Gas & hoàn thiện tài liệu nghiệm thu. | **Chủ trì: Giao diện & Kết nối Web3**<br>• Phát triển dApp UI hoàn chỉnh (React/Vite).<br>• Tích hợp thư viện kết nối ví (Wagmi/Viem/Ethers) với Smart Contract. |

---

## 2. Người Dùng và Vấn Đề

### 2.1. Người Dùng Chính (Target Users)
1. **Nhà tài trợ (Sponsors / Donors):**
   - Các tổ chức giáo dục, cựu sinh viên thành đạt, quỹ thiện nguyện, doanh nghiệp.
   - **Mục tiêu:** Muốn đóng góp quỹ học bổng và trực tiếp giám sát dòng tiền minh bạch; đảm bảo tiền nạp vào được giải ngân đúng người, đúng lộ trình và không bị thất thoát qua khâu trung gian.
2. **Sinh viên (Students / Beneficiaries):**
   - Sinh viên có hoàn cảnh khó khăn hoặc có thành tích học tập, nghiên cứu xuất sắc.
   - **Mục tiêu:** Nhận học bổng đúng hạn, quy trình xét duyệt công khai, không bị cắt xén, không phụ thuộc vào sự chậm trễ hay cảm tính của các thủ tục hành chính truyền thống.
3. **Đơn vị xác thực (Verifiers / Academic Admins - Bên thứ ba bổ trợ):**
   - Phòng Đào tạo / Công tác sinh viên xác thực GPA, tư cách sinh viên và hồ sơ minh chứng thông qua chữ ký số / cấp chứng thực.

### 2.2. Vấn Đề Cần Giải Quyết (Problem Statement)
- **Thiếu tính minh bạch và kiểm toán dòng tiền:** Các quỹ học bổng truyền thống thường tập trung tiền về một tài khoản ngân hàng trung gian, việc báo cáo thu chi diễn ra thủ công, tiềm ẩn rủi ro lạm dụng hoặc thiếu minh bạch.
- **Rủi ro cấp sai đối tượng (Nepotism / Fraud):** Tình trạng làm giả hồ sơ hoặc phê duyệt cảm tính làm mất cơ hội của những sinh viên thực sự xứng đáng.
- **Chậm trễ trong khâu giải ngân:** Quy trình phê duyệt qua nhiều tầng nấc giấy tờ thủ công khiến sinh viên thường nhận được tiền trễ hơn nhiều so với thời hạn đóng học phí.
- **Không có cơ chế hoàn tiền khi học bổng không có người nhận:** Tiền quỹ bị treo vô thời hạn nếu không tìm được người thỏa mãn điều kiện.

### 2.3. Sản Phẩm Cuối (Final Deliverable)
- **Hệ thống dApp TrustScholar hoàn chỉnh:**
  - **Smart Contract Layer (EVM):** Quản lý hồ bơi học bổng (Scholarship Pools), cơ chế khóa quỹ và giải ngân tự động theo mốc thời gian/điều kiện, phân quyền đa vai trò (Role-Based Access Control) và cơ chế hoàn tiền (Refund).
  - **Frontend dApp (Web3):**
    - Cổng Nhà tài trợ: Tạo quỹ mới, cấu hình tiêu chí, nạp tiền, theo dõi tiến độ giải ngân on-chain.
    - Cổng Sinh viên: Kết nối ví, tra cứu danh sách học bổng đủ điều kiện, ký giao dịch rút tiền trực tiếp về ví cá nhân.
    - Bảng thông tin minh bạch công cộng (Public Explorer): Bất kỳ ai cũng có thể tra cứu toàn bộ giao dịch giải ngân theo thời gian thực.

---

## 3. Mốc Bắt Buộc (Milestones Lab 9 – Lab 15)

Lộ trình thực hiện chi tiết theo quy chuẩn đồ án môn học Web3:

| Mốc | Tên Mốc / Bài Lab | Nội Dung Triển Khai Chi Tiết | Sản Phẩm Đầu Ra (Deliverables) |
|:---:|:---|:---|:---|
| **Lab 09** | **Kiến Trúc & Interface Hợp Đồng** | • Thiết kế kiến trúc tổng thể Smart Contract (quản lý quỹ, danh sách sinh viên).<br>• Định nghĩa Interface (`IScholarshipPool`, `IScholarshipVerifier`).<br>• Mô hình hóa trạng thái dữ liệu (Storage layout, Events, Custom Errors). | • Tệp interface `.sol` hoàn chỉnh.<br>• Sơ đồ kiến trúc & luồng dữ liệu hệ thống. |
| **Lab 10** | **Hiện Thực Hóa Core Smart Contracts** | • Viết logic nạp tiền (`deposit`), ghi nhận quỹ.<br>• Hiện thực hàm phê duyệt (`approveRecipient`) và mở khóa giải ngân (`claim`).<br>• Cài đặt phân quyền OpenZeppelin `AccessControl` và bảo vệ chống tấn công `ReentrancyGuard`. | • Hợp đồng `ScholarshipPool.sol` biên dịch không lỗi.<br>• Triển khai mock token/ETH để kiểm thử nội bộ. |
| **Lab 11** | **Unit Test & Kiểm Thử Bảo Mật Nội Bộ** | • Viết bộ kiểm thử tự động đạt độ bao phủ (coverage) > 90%.<br>• Kiểm thử các tình huống biên (Edge cases: hết hạn, số dư 0, rút quá hạn mức).<br>• Chạy Fuzz testing và quét lỗ hổng tĩnh (Slither). | • Báo cáo Test Coverage đầy đủ.<br>• Báo cáo đánh giá an ninh mã nguồn v1. |
| **Lab 12** | **Xây Dựng Giao Diện Web3 dApp** | • Khởi tạo ứng dụng Frontend (React/Vite).<br>• Xây dựng giao diện Dashboard Nhà tài trợ & Sinh viên.<br>• Tích hợp kết nối ví Web3 (MetaMask/WalletConnect qua Wagmi hoặc Viem). | • Mã nguồn Frontend dApp có thể chạy cục bộ.<br>• Giao diện trực quan, hỗ trợ chuyển đổi mạng. |
| **Lab 13** | **Tích Hợp Testnet & Xử Lý Giao Dịch** | • Triển khai (Deploy) Smart Contract lên mạng thử nghiệm (Sepolia / Arbitrum Sepolia).<br>• Verify mã nguồn hợp đồng trên Etherscan.<br>• Kết nối Frontend với Contract đã deploy trên Testnet. | • Địa chỉ contract đã được verify trên Testnet Explorer.<br>• dApp thực hiện được luồng nạp quỹ và claim thật trên Testnet. |
| **Lab 14** | **Kiểm Thử E2E, Tối Ưu Gas & UAT** | • Thực hiện kiểm thử toàn trình từ nạp tiền, duyệt hồ sơ đến sinh viên rút tiền.<br>• Phân tích Gas Reporter và tối ưu hóa chi phí thực thi hợp đồng.<br>• Thử nghiệm với người dùng thật (User Acceptance Testing). | • Bảng đối chuẩn chi phí Gas trước và sau tối ưu.<br>• Biên bản UAT và danh sách các lỗi đã vá. |
| **Lab 15** | **Đóng Gói dApp, Hoàn Thiện Tài Liệu & Báo Cáo** | • Chuẩn bị bài thuyết trình slide demo và video giới thiệu.<br>• Hoàn thiện toàn bộ tài liệu kỹ thuật, cập nhật [README.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/README.md) & [AI_JOURNAL.md](file:///d:/crypto-smart-contract-2026/LinhHuynhK58KTS/docs/AI_JOURNAL.md).<br>• Đóng gói source code và deploy phiên bản live dApp. | • Bản ghi hình Demo / Live URL dApp.<br>• Bộ tài liệu nghiệm thu hoàn chỉnh phục vụ bảo vệ đồ án. |
