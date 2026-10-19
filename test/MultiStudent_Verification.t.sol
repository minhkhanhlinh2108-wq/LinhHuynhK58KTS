// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/project/ProjectCore.sol";

// ============================================================
// Minimal Vm cheatcode interface (Hardhat 3 / Foundry built-in)
// ============================================================
interface Vm {
    function prank(address sender) external;
    function deal(address account, uint256 newBalance) external;
    function expectRevert(bytes calldata revertData) external;
}

// ============================================================
// MultiStudent_Verification.t.sol
// Kiểm thử nghiệp vụ bắt buộc:
//   - Một nhà tài trợ tạo nhiều suất học bổng với các ví sinh viên khác nhau.
//   - Suất #1: student = student0xy
//   - Suất #9: student = student0xz
//   - Đúng sinh viên 0xy nộp cho Suất #1, đúng sinh viên 0xz nộp cho Suất #9.
//   - Sinh viên 0xz nộp cho Suất #1 -> BỊ TỪ CHỐI (NotStudent).
//   - Sinh viên 0xy nộp cho Suất #9 -> BỊ TỪ CHỐI (NotStudent).
//   - Giải ngân chuyển ETH độc lập về đúng từng ví thụ hưởng tương ứng.
// ============================================================
contract MultiStudentVerificationTest {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    ProjectCore internal core;

    address internal sponsor    = address(0xAA00); // 0xx Nhà tài trợ
    address internal student0xy = address(0xBB01); // 0xy Sinh viên Suất #1
    address internal student0xz = address(0xCC09); // 0xz Sinh viên Suất #9
    address internal stranger   = address(0xDD99); // Người lạ
    address internal verifier_;                    // Thẩm định viên (deployer)

    uint256[] internal mAmounts;

    function setUp() public {
        core = new ProjectCore();
        verifier_ = address(this);

        mAmounts = new uint256[](2);
        mAmounts[0] = 0.05 ether;
        mAmounts[1] = 0.05 ether;

        vm.deal(sponsor,    20 ether);
        vm.deal(student0xy, 1 ether);
        vm.deal(student0xz, 1 ether);
        vm.deal(stranger,   1 ether);

        // Sponsor tạo Suất #1 cho student0xy
        vm.prank(sponsor);
        uint256 id1 = core.createScholarship(student0xy, mAmounts);
        assert(id1 == 1);

        // Sponsor tạo các suất trung gian #2 đến #8
        for (uint160 i = 2; i <= 8; i++) {
            address tempStudent = address(0x1000 + i);
            vm.prank(sponsor);
            core.createScholarship(tempStudent, mAmounts);
        }

        // Sponsor tạo Suất #9 cho student0xz
        vm.prank(sponsor);
        uint256 id9 = core.createScholarship(student0xz, mAmounts);
        assert(id9 == 9);

        // Nạp quỹ cho Suất #1 và Suất #9
        vm.prank(sponsor);
        core.fundScholarship{value: 0.1 ether}(1);

        vm.prank(sponsor);
        core.fundScholarship{value: 0.1 ether}(9);
    }

    /// @notice Kiểm tra khởi tạo đúng từng ví sinh viên thụ hưởng theo từng Scholarship ID
    function test_MultiStudent_01_CorrectBeneficiaryPerScholarship() public view {
        assert(core.scholarshipCount() == 9);

        ProjectCore.Scholarship memory s1 = core.getScholarship(1);
        ProjectCore.Scholarship memory s9 = core.getScholarship(9);

        assert(s1.id == 1);
        assert(s1.sponsor == sponsor);
        assert(s1.student == student0xy);
        assert(s1.fundedAmount == 0.1 ether);

        assert(s9.id == 9);
        assert(s9.sponsor == sponsor);
        assert(s9.student == student0xz);
        assert(s9.fundedAmount == 0.1 ether);

        assert(s1.student != s9.student);
    }

    /// @notice Đúng sinh viên 0xy nộp cho Suất #1 và đúng sinh viên 0xz nộp cho Suất #9 thành công
    function test_MultiStudent_02_EachStudentSubmitsTheirOwnScholarship_Success() public {
        // Sinh viên 0xy nộp minh chứng cho Suất #1 mốc 0
        vm.prank(student0xy);
        core.submitMilestone(1, 0, "QmProofStudent0xyMilestone0");
        assert(uint8(core.getMilestoneStatus(1, 0)) == 1); // Submitted

        // Sinh viên 0xz nộp minh chứng cho Suất #9 mốc 0
        vm.prank(student0xz);
        core.submitMilestone(9, 0, "QmProofStudent0xzMilestone0");
        assert(uint8(core.getMilestoneStatus(9, 0)) == 1); // Submitted
    }

    /// @notice Sinh viên 0xz cố ý nộp thay cho Suất #1 -> Bị từ chối NotStudent
    function test_MultiStudent_03_Student0xzCannotSubmitForScholarship1_RevertsNotStudent() public {
        vm.prank(student0xz);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(1, 0, "QmIllegalSubmissionFromStudent0xz");
    }

    /// @notice Sinh viên 0xy cố ý nộp thay cho Suất #9 -> Bị từ chối NotStudent
    function test_MultiStudent_04_Student0xyCannotSubmitForScholarship9_RevertsNotStudent() public {
        vm.prank(student0xy);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(9, 0, "QmIllegalSubmissionFromStudent0xy");
    }

    /// @notice Nhà tài trợ hoặc người ngoài không được nộp minh chứng thay cho sinh viên
    function test_MultiStudent_05_StrangerAndSponsorCannotSubmit_RevertsNotStudent() public {
        // Sponsor cố nộp cho Suất #1 -> Revert
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(1, 0, "QmSponsorCannotSubmit");

        // Stranger cố nộp cho Suất #9 -> Revert
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(9, 0, "QmStrangerCannotSubmit");
    }

    /// @notice Phê duyệt và giải ngân độc lập — ETH chuyển về đúng ví từng sinh viên
    function test_MultiStudent_06_IndependentApprovalAndDisbursement_StrictSolvency() public {
        // Sinh viên nộp minh chứng hợp lệ
        vm.prank(student0xy);
        core.submitMilestone(1, 0, "QmProof0xy");

        vm.prank(student0xz);
        core.submitMilestone(9, 0, "QmProof0xz");

        // Verifier phê duyệt cả hai suất
        vm.prank(verifier_);
        core.approveMilestone(1, 0);

        vm.prank(verifier_);
        core.approveMilestone(9, 0);

        uint256 bal0xyBefore = student0xy.balance;
        uint256 bal0xzBefore = student0xz.balance;

        // Giải ngân Suất #1
        vm.prank(student0xy);
        core.releaseMilestone(1, 0);

        // Kiểm tra: Ví 0xy nhận chính xác 0.05 ETH, Ví 0xz hoàn toàn không đổi
        assert(student0xy.balance == bal0xyBefore + 0.05 ether);
        assert(student0xz.balance == bal0xzBefore);

        // Giải ngân Suất #9
        vm.prank(student0xz);
        core.releaseMilestone(9, 0);

        // Kiểm tra: Ví 0xz nhận chính xác 0.05 ETH
        assert(student0xz.balance == bal0xzBefore + 0.05 ether);

        // Trạng thái mốc đều chuyển sang Disbursed (3)
        assert(uint8(core.getMilestoneStatus(1, 0)) == 3);
        assert(uint8(core.getMilestoneStatus(9, 0)) == 3);
    }
}
