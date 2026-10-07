# Bằng Chứng Xác Minh Web3 DApp — Lab 15 (DApp Verification Evidence)

> **Dự án:** TrustScholar — Nền Tảng Giải Ngân Học Bổng Minh Bạch Trên Blockchain  
> **Nội dung:** Hồ sơ kiểm tra & xác minh chức năng Web3 DApp, tích hợp mạng Sepolia và phân quyền người dùng  
> **Người thực hiện:** Trần Thị Như Huỳnh (MSV: 24K4320010) — *QA & DApp Frontend Lead*  
> **Ngày thực hiện:** 07/10/2026  

---

## 1. Tổng Quan Kiến Trúc Giao Diện DApp

Hệ thống DApp được xây dựng theo chuẩn Web3 hiện đại tại file [`web/index.html`](../../web/index.html):
- **Công nghệ cốt lõi:** HTML5 ngữ nghĩa, Vanilla JavaScript chuẩn ES6+, và Vanilla CSS hiện đại với thiết kế Dark Mode Glassmorphism.
- **Thư viện tương tác Blockchain:** Ethers.js v6.13.2 nạp qua CDN chính thức, đảm bảo tính độc lập và khả năng chạy trực tiếp trên mọi trình duyệt.
- **Tập tin ABI đồng bộ:** Trích xuất từ Artifacts biên dịch Hardhat tại [`web/abi.json`](../../web/abi.json) với 29 hàm, sự kiện và lỗi tùy biến (Custom Errors).

---

## 2. Kịch Bản Kiểm Thử Giao Diện & Tương Tác On-Chain (E2E Scenarios)

### Kịch bản 1: Kết nối ví MetaMask & Kiểm tra mạng Sepolia
- **Hành vi kiểm tra:**
  1. Người dùng truy cập DApp khi chưa kết nối ví -> Trạng thái hiển thị *"Kết Nối Ví MetaMask"*.
  2. Người dùng bấm kết nối -> Popup MetaMask hiển thị yêu cầu chọn tài khoản.
  3. Sau khi kết nối thành công:
     - Nút kết nối cập nhật địa chỉ rút gọn (ví dụ: `0x7099...79C8`).
     - Thanh huy hiệu mạng hiển thị `Sepolia Testnet (11155111)` với chấm xanh hoạt động.
  4. Nếu người dùng chuyển sang mạng khác (ví dụ Ethereum Mainnet hoặc Polygon):
     - DApp lập tức hiển thị cảnh báo viền đỏ: *"⚠️ Chưa kết nối đúng mạng Sepolia Testnet!"*.
     - Nút *"Chuyển sang Sepolia"* cho phép gọi phương thức RPC `wallet_switchEthereumChain` chuyển về Chain ID `0xaa36a7`.

### Kịch bản 2: Nhà tài trợ (Sponsor) tạo suất học bổng & Nạp quỹ
- **Hành vi kiểm tra:**
  - Nhập địa chỉ ví sinh viên: `0x70997970C51812dc3A010C7d01b50e0d17dc79C8`.
  - Nhập các mốc: `0.05, 0.05` ETH.
  - Nhấn nút *"Khởi Tạo Suất Học Bổng"*:
    - DApp tự động chuyển đổi định vị mảng `[parseEther("0.05"), parseEther("0.05")]`.
    - Trạng thái thông báo hiển thị *"Đang gửi giao dịch..."* kèm hiệu ứng vòng quay.
    - Sau khi người dùng xác nhận trên MetaMask, Transaction Hash xuất hiện kèm đường dẫn trực tiếp:
      `https://sepolia.etherscan.io/tx/0x...`
  - Nhập ID suất vừa tạo và số lượng `0.1` ETH -> Bấm *"Nạp Tiền Vào Escrow"*:
    - Smart contract nhận Native ETH qua giao dịch `fundScholarship{value: 0.1 ether}(id)`.
    - DApp hiển thị thông báo thành công khi block được xác thực.

### Kịch bản 3: Sinh viên (Student) nộp minh chứng IPFS
- **Hành vi kiểm tra:**
  - Chọn Tab *"2. Sinh Viên (Student)"*.
  - Nhập ID suất học bổng: `1`, Chỉ số mốc: `0`, IPFS CID: `QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx`.
  - Bấm *"Gửi Minh Chứng (submitMilestone)"*:
    - Giao dịch được gửi đến hàm `submitMilestone` trên `ProjectCore.sol`.
    - Nếu ví đang kết nối không phải là sinh viên thụ hưởng của suất này -> Contract revert lỗi `NotStudent()`, DApp giải mã lỗi và hiển thị thông báo thân thiện: *"Lỗi quyền: Bạn không phải là Sinh viên thụ hưởng của suất học bổng này!"*.

### Kịch bản 4: Thẩm định viên (Verifier) phê duyệt mốc
- **Hành vi kiểm tra:**
  - Chọn Tab *"3. Thẩm Định Viên (Verifier)"*.
  - Nhập ID: `1`, Mốc: `0`.
  - Bấm *"Phê Duyệt Mốc (approveMilestone)"*:
    - Nếu người gọi không phải là Verifier hoặc Sponsor -> Revert `NotSponsor()`.
    - Nếu mốc chưa nộp minh chứng -> Revert `MilestoneNotFound()`.
    - Nếu hợp lệ -> Trạng thái mốc chuyển sang `Approved`.

### Kịch bản 5: Giải ngân (Release) & Chặn các trường hợp vi phạm
- **Hành vi kiểm tra:**
  1. **Thử giải ngân khi chưa phê duyệt (Negative Test):**
     - Bấm giải ngân mốc 1 (mới chỉ Pending/Submitted) -> Contract revert `MilestoneNotApproved()`.
     - DApp hiển thị thông báo chặn rõ ràng: *"Chặn giao dịch: Mốc này chưa được phê duyệt (MilestoneNotApproved)!"*.
  2. **Giải ngân mốc đã được phê duyệt (Positive Test):**
     - Bấm giải ngân mốc 0 -> Contract kích hoạt chuyển Native ETH trực tiếp vào ví sinh viên.
     - Trạng thái mốc cập nhật sang `Disbursed`.
  3. **Thử giải ngân lần 2 (Double Release Negative Test):**
     - Bấm lại nút giải ngân cho mốc 0 -> Contract lập tức revert `AlreadyReleased()`.
     - DApp hiển thị thông báo: *"Chặn giao dịch: Mốc này đã được giải ngân trước đó (AlreadyReleased)!"*.

### Kịch bản 6: Tra cứu dữ liệu minh bạch trên Tab Explorer
- **Hành vi kiểm tra:**
  - Nhập ID suất học bổng và bấm *"Tra Cứu Dữ Liệu"*.
  - DApp gọi các view getter `getScholarship(id)` và `getMilestone(id, index)`.
  - Bảng dữ liệu hiển thị chi tiết:
    - Địa chỉ Sponsor và Student.
    - Tổng định mức, Tổng tiền đã nạp, Tổng tiền đã giải ngân.
    - Bảng danh sách từng mốc với huy hiệu trạng thái có màu trực quan (`Pending` màu xám, `Submitted` màu vàng cam, `Approved` màu xanh ngọc, `Disbursed` màu xanh lá).
    - IPFS CID dạng mã băm.
    - Timestamp thời gian duyệt và thời gian giải ngân hiển thị theo định dạng ngày giờ Việt Nam (`toLocaleString("vi-VN")`).

---

## 3. Xác Minh Khả Năng Tương Thích Di Động (Responsive Mobile Design)

| Tiêu Chí Thiết Kế | Chi Tiết Thực Thi Trong CSS | Kết Quả Đạt Được |
|:---|:---|:---:|
| **Meta Viewport** | `<meta name="viewport" content="width=device-width, initial-scale=1.0">` | Chuẩn hóa tỉ lệ hiển thị trên mọi thiết bị di động |
| **Grid co giãn** | `@media (max-width: 860px) { .grid-2 { grid-template-columns: 1fr; } }` | Bố cục tự động chuyển từ 2 cột sang 1 cột trên Mobile/Tablet |
| **Header di động** | `flex-direction: column; align-items: flex-start;` | Logo, tên dự án, huy hiệu mạng và nút kết nối ví căn chỉnh gọn gàng, không bị tràn viền |
| **Bảng cuộn ngang** | `overflow-x: auto` bọc ngoài `.milestone-table` | Bảng danh sách mốc cuộn mượt mà trên màn hình nhỏ mà không làm vỡ khung trang |
| **Vùng chạm cảm ứng** | Mọi nút bấm và trường nhập liệu có chiều cao `>= 42px` | Đạt chuẩn tiện dụng Mobile UX/UI của Google Material & Apple HIG |

---

## 4. Xác Minh An Ninh: Không Rò Rỉ Private Key / Secrets

- Đã thực hiện kiểm tra quét mã nguồn tĩnh toàn diện:
  - File HTML không chứa bất kỳ biến bí mật, chuỗi khóa riêng hay chữ ký cứng nào.
  - DApp hoàn toàn hoạt động theo mô hình Web3 Client-side: người dùng kiểm soát 100% khóa bí mật thông qua ví MetaMask cá nhân.
  - Cấu hình `.gitignore` đảm bảo các biến môi trường nhạy cảm trong `.env` không bị đưa lên Git repository.
