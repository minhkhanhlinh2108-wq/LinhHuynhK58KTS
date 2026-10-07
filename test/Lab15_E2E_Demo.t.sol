// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/project/ProjectCore.sol";

// ============================================================
// Vm cheatcode interface (Hardhat 3 / Foundry built-in)
// ============================================================
interface Vm {
    function prank(address sender) external;
    function deal(address account, uint256 newBalance) external;
    function expectRevert(bytes calldata revertData) external;
}

// ============================================================
// Lab 15 — End-to-End DApp Demo Test
// Mô phỏng toàn bộ 8 phần demo:
//   PHẦN 1: Connect (simulated via setup)
//   PHẦN 2: Sponsor tạo scholarship
//   PHẦN 3: Fund scholarship
//   PHẦN 4: Student submit milestone
//   PHẦN 5: Approve milestone
//   PHẦN 6: Release scholarship
//   PHẦN 7: Kiểm tra balance, released amount, status
//   PHẦN 8: Negative cases (wrong student, release before approve, double release)
// ============================================================
contract Lab15E2EDemoTest {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    ProjectCore internal core;

    // Tài khoản demo
    address internal sponsor   = address(0xAA01);  // Nhà tài trợ
    address internal student   = address(0xBB02);  // Sinh viên thụ hưởng
    address internal stranger  = address(0xCC03);  // Người lạ (negative test)
    address internal verifier_;                      // Thẩm định viên (deployer)

    // Milestone amounts: 2 mốc x 0.05 ETH = 0.1 ETH tổng
    uint256[] internal milestoneAmounts;

    // Lưu trữ kết quả demo
    uint256 internal scholarshipId;
    uint256 internal studentBalanceBefore;
    uint256 internal studentBalanceAfter;

    function setUp() public {
        // Deploy contract — deployer = address(this) = verifier
        core = new ProjectCore();
        verifier_ = address(this);

        milestoneAmounts = new uint256[](2);
        milestoneAmounts[0] = 0.05 ether;
        milestoneAmounts[1] = 0.05 ether;

        // Cấp ETH cho các tài khoản test
        vm.deal(sponsor,  10 ether);
        vm.deal(student,   1 ether);
        vm.deal(stranger,  1 ether);
    }

    // ============================================================
    // PHẦN 1-7: HAPPY PATH — Full Lifecycle Demo
    // ============================================================

    /// @notice Demo đầy đủ vòng đời: Create → Fund → Submit → Approve → Release → Verify
    function test_DEMO_01_FullLifecycleHappyPath() public {
        // --- PHẦN 1: Connect MetaMask (simulated) ---
        // Trong EVM test, "connect" = prank as the desired user
        assert(verifier_ == address(this));
        assert(core.verifier() == address(this));

        // --- PHẦN 2: Sponsor tạo scholarship ---
        vm.prank(sponsor);
        scholarshipId = core.createScholarship(student, milestoneAmounts);
        assert(scholarshipId == 1);
        assert(core.scholarshipCount() == 1);

        // Verify scholarship data
        ProjectCore.Scholarship memory s = core.getScholarship(scholarshipId);
        assert(s.sponsor == sponsor);
        assert(s.student == student);
        assert(s.totalAmount == 0.1 ether);
        assert(s.milestoneCount == 2);
        assert(s.fundedAmount == 0);
        assert(s.releasedAmount == 0);

        // --- PHẦN 3: Fund scholarship ---
        vm.prank(sponsor);
        core.fundScholarship{value: 0.1 ether}(scholarshipId);

        s = core.getScholarship(scholarshipId);
        assert(s.fundedAmount == 0.1 ether);

        // --- PHẦN 4: Student submit milestone 0 ---
        vm.prank(student);
        core.submitMilestone(scholarshipId, 0, "QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx");

        // Verify milestone status = Submitted (1)
        assert(uint8(core.getMilestoneStatus(scholarshipId, 0)) == 1);

        // Verify proof hash stored
        ProjectCore.Milestone memory m0 = core.getMilestone(scholarshipId, 0);
        assert(keccak256(bytes(m0.proofHash)) == keccak256(bytes("QmZ4tDuvesekSs4qM5ZBKpXiZGun7S2CYtEZRB3DYXkjGx")));

        // --- PHẦN 5: Verifier approve milestone 0 ---
        // verifier_ = address(this), no prank needed
        core.approveMilestone(scholarshipId, 0);
        assert(uint8(core.getMilestoneStatus(scholarshipId, 0)) == 2); // Approved

        m0 = core.getMilestone(scholarshipId, 0);
        assert(m0.approvedAt > 0);

        // --- PHẦN 6: Release milestone 0 ---
        studentBalanceBefore = student.balance;

        vm.prank(sponsor);
        core.releaseMilestone(scholarshipId, 0);

        studentBalanceAfter = student.balance;

        // --- PHẦN 7: Kiểm tra kết quả ---
        // 7a. Balance student tăng chính xác 0.05 ETH
        assert(studentBalanceAfter - studentBalanceBefore == 0.05 ether);

        // 7b. Released amount = 0.05 ETH
        s = core.getScholarship(scholarshipId);
        assert(s.releasedAmount == 0.05 ether);

        // 7c. Milestone status = Disbursed (3)
        assert(uint8(core.getMilestoneStatus(scholarshipId, 0)) == 3);

        // 7d. Milestone 1 still Pending (0)
        assert(uint8(core.getMilestoneStatus(scholarshipId, 1)) == 0);

        // 7e. disbursedAt > 0
        m0 = core.getMilestone(scholarshipId, 0);
        assert(m0.disbursedAt > 0);
    }

    // ============================================================
    // PHẦN 8: NEGATIVE CASE — Wrong Student
    // ============================================================

    /// @notice Negative: Người lạ cố nộp minh chứng → revert NotStudent()
    function test_DEMO_02_NegativeCase_WrongStudent() public {
        // Setup: Create & fund scholarship
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, milestoneAmounts);

        vm.prank(sponsor);
        core.fundScholarship{value: 0.1 ether}(id);

        // Stranger cố nộp minh chứng → phải bị chặn
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmFakeProof_FromStranger");
    }

    // ============================================================
    // PHẦN 8: NEGATIVE CASE — Release Before Approval
    // ============================================================

    /// @notice Negative: Cố giải ngân khi milestone chưa được approve → revert MilestoneNotApproved()
    function test_DEMO_03_NegativeCase_ReleaseBeforeApproval() public {
        // Setup
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, milestoneAmounts);

        vm.prank(sponsor);
        core.fundScholarship{value: 0.1 ether}(id);

        // Student submit but NO approval
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof_NoApproveYet");

        // Try release → must revert
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    // ============================================================
    // PHẦN 8: NEGATIVE CASE — Double Release (Release Twice)
    // ============================================================

    /// @notice Negative: Giải ngân lần 2 cho cùng 1 mốc → revert AlreadyReleased()
    function test_DEMO_04_NegativeCase_DoubleRelease() public {
        // Setup: Full lifecycle for milestone 0
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, milestoneAmounts);

        vm.prank(sponsor);
        core.fundScholarship{value: 0.1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof_Milestone0");

        core.approveMilestone(id, 0);

        vm.prank(sponsor);
        core.releaseMilestone(id, 0); // Release lần 1 — OK

        // Release lần 2 → phải bị chặn
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);
    }

    // ============================================================
    // PHẦN 8: NEGATIVE CASE — Stranger cannot approve
    // ============================================================

    /// @notice Negative: Stranger cố approve milestone → revert NotSponsor()
    function test_DEMO_05_NegativeCase_StrangerCannotApprove() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, milestoneAmounts);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof");

        // Stranger cố approve → bị chặn
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.approveMilestone(id, 0);
    }

    // ============================================================
    // BONUS: Full 2-Milestone Lifecycle — cả 2 mốc đều giải ngân
    // ============================================================

    /// @notice Demo đầy đủ vòng đời cả 2 mốc: tổng tiền trả hết cho student
    function test_DEMO_06_Full2MilestoneLifecycle() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, milestoneAmounts);

        vm.prank(sponsor);
        core.fundScholarship{value: 0.1 ether}(id);

        // --- Milestone 0 ---
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof_M0");
        core.approveMilestone(id, 0);

        uint256 balBefore0 = student.balance;
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);
        assert(student.balance - balBefore0 == 0.05 ether);

        // --- Milestone 1 ---
        vm.prank(student);
        core.submitMilestone(id, 1, "QmProof_M1");
        core.approveMilestone(id, 1);

        uint256 balBefore1 = student.balance;
        vm.prank(sponsor);
        core.releaseMilestone(id, 1);
        assert(student.balance - balBefore1 == 0.05 ether);

        // Final checks
        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.releasedAmount == 0.1 ether);
        assert(s.releasedAmount == s.totalAmount);
        assert(s.releasedAmount == s.fundedAmount);

        // Both milestones disbursed
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3);
        assert(uint8(core.getMilestoneStatus(id, 1)) == 3);

        // Contract balance should be 0 (all funds disbursed)
        assert(address(core).balance == 0);
    }

    // Fallback to receive ETH if needed
    receive() external payable {}
}
