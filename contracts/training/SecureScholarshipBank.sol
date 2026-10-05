// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SecureScholarshipBank
 * @notice PHIÊN BẢN AN TOÀN / HARDENED - LAB 13 SECURITY EXPERIMENT.
 * @dev HỢP ĐỒNG ĐÃ ĐƯỢC VÁ LỖ HỔNG REENTRANCY BẰNG 2 LỚP PHÒNG THỦ:
 *      Lớp 1: Checks-Effects-Interactions (CEI) Pattern.
 *      Lớp 2: ReentrancyGuard Mutex Lock (nonReentrant modifier).
 */
contract SecureScholarshipBank {
    // Sổ cái theo dõi số dư học bổng / tiền gửi
    mapping(address => uint256) public balances;
    uint256 public totalDeposits;

    // Mutex lock trạng thái tái nhập
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    event Deposited(address indexed account, uint256 amount);
    event Withdrawn(address indexed account, uint256 amount);

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    constructor() {
        _status = _NOT_ENTERED;
    }

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
     * @notice Rút tiền an toàn chỉ sử dụng mẫu thiết kế Checks-Effects-Interactions (CEI)
     * @dev Ngay cả khi không có modifier nonReentrant, CEI đã vô hiệu hóa hoàn toàn Reentrancy:
     *      Khi attacker reenter trong bước [3], ở lần gọi thứ 2, bước [1] sẽ kiểm tra thấy
     *      `amount == 0` (vì đã bị xóa ở bước [2] của lần gọi 1) và lập tức revert!
     */
    function withdrawCEI() external {
        // [1] CHECKS: Kiểm tra điều kiện tiên quyết
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        // [2] EFFECTS: Cập nhật trạng thái TRƯỚC KHI thực hiện tương tác ngoại vi
        balances[msg.sender] = 0;
        if (totalDeposits >= amount) {
            totalDeposits -= amount;
        } else {
            totalDeposits = 0;
        }

        // [3] INTERACTIONS: Tương tác ngoại vi chỉ thực hiện sau cùng
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Rút tiền an toàn toàn diện kết hợp cả CEI và ReentrancyGuard (Defense-in-Depth)
     * @dev Đây là kiến trúc được áp dụng trong ProjectCore.sol
     */
    function withdraw() external nonReentrant {
        // [1] CHECKS
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient balance");

        // [2] EFFECTS
        balances[msg.sender] = 0;
        if (totalDeposits >= amount) {
            totalDeposits -= amount;
        } else {
            totalDeposits = 0;
        }

        // [3] INTERACTIONS
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Xem số dư Native ETH thực tế của hợp đồng ngân hàng
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
