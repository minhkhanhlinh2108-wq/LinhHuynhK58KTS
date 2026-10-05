// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title VulnerableScholarshipBank
 * @notice KHỞI TẠO MỤC ĐÍCH TRAINING / GIÁO DỤC - LAB 13 SECURITY EXPERIMENT.
 * @dev CẢNH BÁO: HỢP ĐỒNG NÀY CỐ TÌNH CHỨA LỖ HỔNG REENTRANCY ĐỂ MINH HỌA.
 *       TUYỆT ĐỐI KHÔNG SỬ DỤNG TRONG MÔI TRƯỜNG PRODUCTION THẬT.
 *       LỖ HỔNG NÀY KHÔNG ĐƯỢC ĐƯA VÀO HỢP ĐỒNG LÕI ProjectCore.sol.
 *
 * Lỗ hổng kỹ thuật:
 *   - Hàm `withdraw()` thực hiện external call (chuyển Native ETH) TRƯỚC KHI cập nhật trạng thái (State Update).
 *   - Vi phạm nghiêm trọng nguyên tắc Checks-Effects-Interactions (CEI).
 *   - Cho phép một hợp đồng độc hại gọi lại (reenter) hàm `withdraw()` trong hook fallback/receive
 *     để rút cạn toàn bộ số dư của quỹ nhiều lần.
 */
contract VulnerableScholarshipBank {
    // Sổ cái theo dõi số dư học bổng / tiền gửi của từng địa chỉ
    mapping(address => uint256) public balances;

    // Tổng số tiền quỹ đang được quản lý
    uint256 public totalDeposits;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    /**
     * @notice Nạp tiền vào quỹ học bổng cá nhân
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @notice Rút toàn bộ số dư học bổng của người gọi
     * @dev ĐÂY LÀ HÀM CÓ LỖ HỔNG (VULNERABLE FUNCTION).
     *      Thứ tự thực thi sai:
     *        1. Checks (kiểm tra balance)
     *        2. Interactions (external call chuyển tiền -> trao quyền kiểm soát luồng cho msg.sender)
     *        3. Effects (cập nhật balances = 0 -> quá muộn!)
     */
    function withdraw() external {
        // [1] CHECKS: Kiểm tra số dư người gọi
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        // [2] INTERACTIONS (LỖI NGUY HIỂM): External call xảy ra TRƯỚC KHI state update
        // Trao luồng thực thi (control flow) sang hàm receive()/fallback() của địa chỉ nhận
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");

        // [3] EFFECTS (QUÁ MUỘN): State update diễn ra sau khi tiền đã chuyển
        // Trong suốt thời gian external call ở bước [2] chạy, balances[msg.sender] vẫn giữ nguyên giá trị cũ!
        balances[msg.sender] = 0;
        if (totalDeposits >= amount) {
            totalDeposits -= amount;
        } else {
            totalDeposits = 0;
        }

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Xem số dư Native ETH thực tế của hợp đồng ngân hàng
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
