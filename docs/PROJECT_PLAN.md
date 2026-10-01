# Kế Hoạch Đồ Án (Project Plan) - TrustScholar

> **Dự án:** TrustScholar — Nền tảng giải ngân học bổng minh bạch trên Blockchain  
> **Phiên bản:** v1.0 (Kế hoạch phân vai & Lộ trình thực hiện Lab 08 – Lab 15)  
> **Repository GitHub:** [minhkhanhlinh2108-wq/LinhHuynhK58KTS](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)  
> **Điều hướng nhanh:** [Trang chủ README](../README.md) | [Đặc Tả Nghiệp Vụ (SPEC.md)](SPEC.md) | [Quy Tắc Kinh Tế (ECONOMIC_RULES.md)](ECONOMIC_RULES.md) | [Nhật Ký AI (AI_JOURNAL.md)](AI_JOURNAL.md)  
> **Mục tiêu:** Nền tảng giải ngân học bổng minh bạch, phi tập trung và chống gian lận trên Blockchain.

---

## 1. Thành Viên & Phân Vai Trách Nhiệm (Team Members & Role Allocation)

Dự án **TrustScholar** được phát triển bởi nhóm **02 thành viên**, phân chia trách nhiệm chuyên môn hóa sâu theo 2 khối kỹ thuật cốt lõi:

| STT | Thành Viên | Mã Sinh Viên | Khối Trách Nhiệm Chuyên Môn | Nhiệm Vụ Cụ Thể |
|:---:|:---|:---:|:---|:---|
| 1 | **Nguyễn Minh Khánh Linh**<br>*(Nhóm trưởng)* | 24K4320024 | **Business/SPEC + Smart Contract/Security** | • Chủ trì phân tích nghiệp vụ, mô hình dữ liệu và cập nhật tài liệu đặc tả [SPEC.md](SPEC.md), [ECONOMIC_RULES.md](ECONOMIC_RULES.md).<br>• Trực tiếp thiết kế kiến trúc và lập trình mã nguồn Smart Contract lõi (`ProjectCore.sol`, Escrow logic, RBAC).<br>• Thiết lập các cơ chế phòng vệ an ninh on-chain (Checks-Effects-Interactions, `ReentrancyGuard`, ngăn chặn rút quá quỹ, bẫy DoS).<br>• Phân tích mô hình mối đe dọa (Threat Modeling) và xử lý các lỗi bảo mật phát hiện trong quá trình phát triển. |
| 2 | **Trần Thị Như Huỳnh**<br>*(Thành viên)* | 24K4320010 | **Testing + DApp + Audit** | • Xây dựng hệ thống kiểm thử tự động (Unit Test, Fuzz Testing, Edge Case Testing cho toàn bộ quy tắc R1–R10).<br>• Thiết kế và lập trình giao diện người dùng Web3 DApp (React/Vite, kết nối ví MetaMask/WalletConnect qua Wagmi/Viem).<br>• Thực hiện kiểm toán độc lập (Audit), chạy công cụ phân tích tĩnh (Slither) và thực nghiệm bảo mật (Security Experiments).<br>• Phụ trách kiểm thử toàn trình (E2E Integration Test), tối ưu chi phí Gas và triển khai (Deploy) công khai lên Testnet/Web hosting. |

---

## 2. Người Dùng Và Vấn Đề Giải Quyết (Problem & Target Users)

### 2.1. Đối Tượng Sử Dụng Mục Tiêu
1. **Nhà tài trợ (Sponsors / Donors):**
   - Các doanh nghiệp, tổ chức phi chính phủ, quỹ thiện nguyện cá nhân hoặc cựu sinh viên.
   - **Mục tiêu:** Ký quỹ ETH minh bạch, theo dõi tiến độ giải ngân từng mốc, đảm bảo tiền chuyển trực tiếp đến đúng sinh viên mà không bị thất thoát qua khâu trung gian.
2. **Sinh viên thụ hưởng (Students / Beneficiaries):**
   - Sinh viên vượt khó, sinh viên có thành tích học tập và nghiên cứu xuất sắc được tuyển chọn nhận học bổng.
   - **Mục tiêu:** Nộp minh chứng hoàn thành mốc học tập minh bạch, nhận tiền giải ngân nhanh chóng, đúng hạn và đúng số tiền cam kết về ví cá nhân.
3. **Người thẩm định / Xác thực (Verifiers / Evaluators):**
   - Đại diện Phòng Đào tạo, Phòng Công tác sinh viên hoặc Hội đồng chuyên môn của Nhà tài trợ.
   - **Mục tiêu:** Thẩm định tính xác thực của minh chứng ngoại tuyến và phê duyệt mốc on-chain mà không cần xử lý tiền mặt thủ công.
4. **Cộng đồng & Kiểm toán viên (Public Observers):**
   - Giám sát toàn bộ dòng tiền và trạng thái giải ngân công khai theo thời gian thực trên blockchain.

### 2.2. Vấn Đề Cần Giải Quyết
- **Thủ tục rườm rà & Chậm giải ngân:** Quy trình giải ngân truyền thống qua nhiều tầng trung gian mất từ vài tuần đến vài tháng, làm ảnh hưởng đến thời hạn nộp học phí của sinh viên.
- **Rủi ro thất thoát & Phê duyệt cảm tính:** Tiền mặt gửi qua tài khoản trung gian thiếu cơ chế kiểm toán tức thời, tiềm ẩn nguy cơ cấp sai đối tượng.
- **Thiếu cam kết quỹ dài hạn:** Sinh viên nỗ lực hoàn thành học kỳ nhưng có nguy cơ không nhận được tiền nếu nhà tài trợ đổi ý hoặc quỹ bị phân bổ sai mục đích.

---

## 3. Lộ Trình Phát Triển Mốc Bắt Buộc (Milestones Lab 09 – Lab 15)

Dự án bám sát 7 mốc triển khai kỹ thuật tuần tự, đảm bảo mỗi bài Lab đều có đầu ra rõ ràng và được kiểm chứng nghiêm ngặt:

```mermaid
timeline
    title Lộ Trình Mốc Kỹ Thuật TrustScholar (Lab 09 – Lab 15)
    Lab 09 : ProjectCore biên dịch được : Interface & Data Structures
    Lab 10 : Audit và sửa lỗi : Rà soát an ninh nội bộ & Vá lỗ hổng
    Lab 11 : Economic rules chạy đúng : Bộ test suite R1-R10 pass 100%
    Lab 12 : Gate Review : Đánh giá toàn diện & Code Freeze
    Lab 13 : Security experiment : Tấn công giả lập & Stress testing
    Lab 14 : Cross-audit : Kiểm toán chéo & Tối ưu hóa gas
    Lab 15 : Public DApp : Deploy Testnet & Ra mắt DApp công khai
```

### Bảng Chi Tiết Mốc Triển Khai:

| Mốc | Tên Mốc Chuẩn | Trách Nhiệm Chính | Mục Tiêu & Nội Dung Triển Khai | Tiêu Chí Nghiệm Thu (Acceptance Criteria) |
|:---:|:---|:---:|:---|:---|
| **Lab 09** | **ProjectCore biên dịch được** | **Khánh Linh** *(Chủ trì)*<br>Như Huỳnh *(Phối hợp)* | • Định nghĩa Interface (`IScholarshipPool`, `IScholarshipVerifier`).<br>• Xây dựng cấu trúc dữ liệu (`struct Scholarship`, `struct Milestone`, `enum MilestoneStatus`).<br>• Lập trình khung xương hợp đồng `ProjectCore.sol` gồm khai báo State Variables, Mappings, Custom Errors và Events.<br>• Thiết lập môi trường dự án (Foundry/Hardhat). | • Lệnh biên dịch (`forge build` hoặc `npx hardhat compile`) thành công 100%, 0 warning nghiêm trọng.<br>• Tệp ABI và bytecode được tạo thành công. |
| **Lab 10** | **Audit và sửa lỗi** | **Như Huỳnh** *(Audit)*<br>**Khánh Linh** *(Sửa lỗi)* | • Rà soát an ninh mã nguồn nội bộ vòng 1.<br>• Kiểm tra phân quyền truy cập (`AccessControl`), bẫy địa chỉ rỗng (`address(0)`), và mẫu Checks-Effects-Interactions (CEI).<br>• Tích hợp khóa chống tái nhập (`ReentrancyGuard`) cho các hàm dòng tiền.<br>• Khắc phục triệt để các cảnh báo bảo mật được chỉ ra. | • Báo cáo Internal Audit v1 ghi nhận toàn bộ điểm nghi vấn.<br>• Mã nguồn được cập nhật, vá hết các lỗ hổng tìm thấy. |
| **Lab 11** | **Economic rules chạy đúng** | **Như Huỳnh** *(Viết test)*<br>**Khánh Linh** *(Hỗ trợ)* | • Viết bộ Unit Test và Integration Test tự động kiểm chứng toàn bộ quy tắc kinh tế trong [ECONOMIC_RULES.md](ECONOMIC_RULES.md) và bộ quy tắc R1–R10 trong [SPEC.md](SPEC.md).<br>• Kiểm thử các điều kiện biên: nạp ETH testnet, khóa theo suất, sinh viên nhận tiền đúng điều kiện, tiền về đúng ví, chống giải ngân 2 lần, chống giải ngân vượt quỹ, phân quyền verifier. | • 100% test cases pass màu xanh.<br>• Test coverage đạt trên 90% cho logic giải ngân cốt lõi. |
| **Lab 12** | **Gate Review** | **Khánh Linh & Như Huỳnh** *(Đồng chủ trì)* | • Tổ chức phiên thẩm định chất lượng toàn diện (Milestone Gate Review).<br>• Đánh giá chéo sự ăn khớp giữa SPEC, Economic Rules và Smart Contract.<br>• Phân tích mô hình mối đe dọa (Threat Model) và rà soát các giả định bảo mật.<br>• Thực hiện "Code Freeze" tầng hợp đồng thông minh để chuẩn bị cho giai đoạn DApp & Testnet. | • Biên bản Gate Review có chữ ký xác nhận của 2 thành viên.<br>• Danh mục nghiệm thu (Go/No-Go Checklist) đạt chuẩn để chuyển giai đoạn. |
| **Lab 13** | **Security experiment** | **Như Huỳnh** *(Thực nghiệm)*<br>**Khánh Linh** *(Bảo mật)* | • Xây dựng các kịch bản tấn công giả lập on-chain (Security Experiments): Thử nghiệm Reentrancy Attack bằng contract độc hại, thử nghiệm Denial of Service (DoS) khi ví sinh viên là contract revert, thử nghiệm Front-running khi nạp/rút quỹ.<br>• Đo lường khả năng chống chịu của hệ thống trước hành vi người dùng thận trọng / kẻ tấn công. | • Báo cáo thực nghiệm an ninh (Security Experiment Report) chi tiết kèm bằng chứng PoC (Proof of Concept).<br>• Các cơ chế phòng vệ (Pull pattern, Timelock) được kiểm chứng hiệu quả. |
| **Lab 14** | **Cross-audit** | **Khánh Linh & Như Huỳnh** *(Kiểm toán chéo)* | • Hai thành viên đổi vai kiểm toán độc lập mã nguồn và giao diện.<br>• Chạy công cụ phân tích tĩnh chuyên sâu (Slither, Mythril) để phát hiện lỗ hổng tiềm ẩn.<br>• Bật `hardhat-gas-reporter` / `forge snapshot` để phân tích chi phí gas và thực hiện tối ưu hóa cấu trúc lưu trữ (Storage packing).<br>• Kiểm thử toàn trình (E2E Integration Test) giữa hợp đồng và Web3 provider. | • Báo cáo Cross-Audit Report hoàn chỉnh.<br>• Bảng đối chuẩn chi phí Gas trước và sau khi tối ưu hóa. |
| **Lab 15** | **Public DApp** | **Như Huỳnh** *(Frontend & Deploy)*<br>**Khánh Linh** *(Docs & Demo)* | • Triển khai (Deploy) hợp đồng lên mạng thử nghiệm công khai (Sepolia / Arbitrum Sepolia Testnet).<br>• Verify mã nguồn công khai trên Etherscan.<br>• Đóng gói và phát hành ứng dụng Frontend Web3 DApp hoàn chỉnh lên hosting công cộng (Vercel/Netlify).<br>• Thực hiện đầy đủ luồng tương tác thực tế bằng ví MetaMask (Tạo suất, Nạp ETH testnet, Nộp minh chứng, Duyệt mốc, Giải ngân).<br>• Hoàn thiện bộ slide thuyết trình, video demo và nghiệm thu đồ án. | • Smart Contract đã verify trên Testnet Explorer.<br>• Live DApp URL hoạt động ổn định và kết nối ví thành công.<br>• Video demo và toàn bộ tài liệu nghiệm thu sẵn sàng bảo vệ đồ án. |

---
> 🔗 **Liên kết nhanh:** [Trang chủ README](../README.md) • [Kế hoạch đồ án](PROJECT_PLAN.md) • [Đặc tả nghiệp vụ](SPEC.md) • [Quy tắc kinh tế](ECONOMIC_RULES.md) • [Nhật ký AI](AI_JOURNAL.md) • [GitHub Repo](https://github.com/minhkhanhlinh2108-wq/LinhHuynhK58KTS)
