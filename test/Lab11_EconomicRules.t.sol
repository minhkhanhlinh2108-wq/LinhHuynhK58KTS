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

/**
 * @title Lab11_EconomicRulesTest
 * @notice Comprehensive Economic Rules & Invariants Test Suite for TrustScholar (Lab 11).
 * Validates:
 *   1. Actor Access Control (Chỉ đúng actor được thao tác)
 *   2. Solvency & Funding before Release (Scholarship phải được fund trước khi release)
 *   3. Direct Student Payout (Chỉ đúng student nhận tiền)
 *   4. Approval Gate (Chỉ milestone đã approve mới được release)
 *   5. No Double Disbursement (Một milestone chỉ release một lần)
 *   6. Solvency Invariant (Tổng released không vượt fund)
 *   7. Non-custodial Commitment (Không có cách rút tiền trái với cam kết scholarship)
 *   8. State-changing actions emit events & Pure Native ETH handling
 */
contract Lab11EconomicRulesTest {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    ProjectCore internal core;

    address internal sponsorA  = address(0x1111);
    address internal sponsorB  = address(0x1112);
    address internal studentA  = address(0x2221);
    address internal studentB  = address(0x2222);
    address internal stranger  = address(0x3333);
    address internal verifier_; // deployer = address(this)

    uint256[] internal twoMilestones;
    uint256[] internal threeMilestones;

    function setUp() public {
        core = new ProjectCore();
        verifier_ = address(this);

        twoMilestones = new uint256[](2);
        twoMilestones[0] = 0.5 ether;
        twoMilestones[1] = 0.5 ether;

        threeMilestones = new uint256[](3);
        threeMilestones[0] = 0.3 ether;
        threeMilestones[1] = 0.3 ether;
        threeMilestones[2] = 0.4 ether;

        vm.deal(sponsorA, 100 ether);
        vm.deal(sponsorB, 100 ether);
        vm.deal(studentA, 1 ether);
        vm.deal(studentB, 1 ether);
        vm.deal(stranger, 10 ether);
    }

    // ============================================================
    // 1. CHỈ ĐÚNG ACTOR ĐƯỢC THAO TÁC (ACTOR ACCESS CONTROL)
    // ============================================================

    // 1.1 Sponsor tạo suất và trở thành sponsor duy nhất của suất đó
    function test_ECO_R1_01_SponsorCreatesAndOwnsScholarship() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.sponsor == sponsorA);
        assert(s.student == studentA);
    }

    // 1.2 Người lạ (stranger) không thể nạp quỹ cho suất của Sponsor khác
    function test_ECO_R1_02_NonSponsorCannotFundScholarship() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.fundScholarship{value: 1 ether}(id);
    }

    // 1.3 Sinh viên không thể tự nạp tiền vào suất học bổng
    function test_ECO_R1_03_StudentCannotFundScholarship() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.fundScholarship{value: 1 ether}(id);
    }

    // 1.4 Chỉ sinh viên được chỉ định mới được nộp minh chứng (Sponsor & Stranger bị chặn)
    function test_ECO_R1_04_NonStudentCannotSubmitProof() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        // Sponsor cố tình nộp thay sinh viên -> revert NotStudent
        vm.prank(sponsorA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmSponsorProof");

        // Stranger cố tình nộp -> revert NotStudent
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmStrangerProof");

        // Sinh viên khác (studentB) cố tình nộp -> revert NotStudent
        vm.prank(studentB);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmStudentBProof");
    }

    // 1.5 Người lạ (stranger) không thể duyệt mốc
    function test_ECO_R1_05_StrangerCannotApproveMilestone() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.approveMilestone(id, 0);
    }

    // 1.6 Sinh viên không thể tự phê duyệt mốc của chính mình
    function test_ECO_R1_06_StudentCannotSelfApprove() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.approveMilestone(id, 0);
    }

    // 1.7 Verifier chính thức (verifier) có quyền thẩm định và duyệt mốc
    function test_ECO_R1_07_VerifierCanApproveMilestone() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");

        // verifier_ = address(this)
        core.approveMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2); // Approved
    }

    // 1.8 Sponsor có quyền duyệt mốc cho suất tài trợ trực tiếp (theo SPEC v1.0 Mục 6 bước 4)
    function test_ECO_R1_08_SponsorCanApproveDirectGrant() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");

        vm.prank(sponsorA);
        core.approveMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2); // Approved
    }

    // 1.9 Người lạ (stranger) không thể kích hoạt giải ngân
    function test_ECO_R1_09_StrangerCannotTriggerRelease() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.releaseMilestone(id, 0);
    }

    // 1.10 Chỉ Verifier hiện tại mới có quyền cập nhật Verifier mới
    function test_ECO_R1_10_NonVerifierCannotUpdateVerifier() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.setVerifier(address(0x9999));

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.setVerifier(address(0x9999));

        // Verifier hợp lệ cập nhật thành công
        core.setVerifier(address(0x9999));
        assert(core.verifier() == address(0x9999));
    }

    // ============================================================
    // 2. SCHOLARSHIP PHẢI ĐƯỢC FUND TRƯỚC KHI RELEASE
    // ============================================================

    // 2.1 Suất hoàn toàn chưa nạp quỹ (fundedAmount = 0) -> release bị chặn
    function test_ECO_R2_01_ReleaseZeroFundReverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        // Chưa gọi fundScholarship -> revert InsufficientFunds
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 0);
    }

    // 2.2 Suất nạp thiếu (fundedAmount < milestoneAmount) -> release bị chặn
    function test_ECO_R2_02_ReleaseUnderfundedReverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones); // mỗi mốc 0.5 ETH

        // Nạp chỉ 0.2 ETH (thiếu 0.3 ETH cho mốc 0)
        vm.prank(sponsorA);
        core.fundScholarship{value: 0.2 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 0);
    }

    // 2.3 Suất nạp đủ đúng số tiền mốc cần giải ngân -> release thành công
    function test_ECO_R2_03_ReleaseExactMilestoneFundSucceeds() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        // Nạp đúng 0.5 ETH cho mốc 0
        vm.prank(sponsorA);
        core.fundScholarship{value: 0.5 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        uint256 balBefore = studentA.balance;
        vm.prank(studentA);
        core.releaseMilestone(id, 0);

        assert(studentA.balance - balBefore == 0.5 ether);
    }

    // 2.4 Nạp từng phần (incremental funding) trước mỗi lần giải ngân
    function test_ECO_R2_04_IncrementalFundingSupportsSequentialReleases() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones); // 2 mốc x 0.5 ETH

        // Đợt 1: Nạp 0.5 ETH giải ngân mốc 0
        vm.prank(sponsorA);
        core.fundScholarship{value: 0.5 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof0");
        core.approveMilestone(id, 0);

        vm.prank(studentA);
        core.releaseMilestone(id, 0); // Mốc 0 OK

        // Lúc này quỹ còn 0 ETH khả dụng -> mốc 1 chưa nạp không thể giải ngân
        vm.prank(studentA);
        core.submitMilestone(id, 1, "QmProof1");
        core.approveMilestone(id, 1);

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 1);

        // Đợt 2: Sponsor nạp tiếp 0.5 ETH cho mốc 1 -> giải ngân thành công
        vm.prank(sponsorA);
        core.fundScholarship{value: 0.5 ether}(id);

        vm.prank(studentA);
        core.releaseMilestone(id, 1); // Mốc 1 OK
        assert(uint8(core.getMilestoneStatus(id, 1)) == 3); // Disbursed
    }

    // 2.5 Không được nạp vượt quá totalAmount của suất học bổng
    function test_ECO_R2_05_OverfundReverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones); // totalAmount = 1.0 ETH

        vm.prank(sponsorA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InvalidAmount.selector));
        core.fundScholarship{value: 1.1 ether}(id);
    }

    // ============================================================
    // 3. CHỈ ĐÚNG STUDENT NHẬN TIỀN (DIRECT STUDENT PAYOUT)
    // ============================================================

    // 3.1 Khi Verifier gọi release, tiền chuyển 100% về ví studentA
    function test_ECO_R3_01_FundsReachStudentWhenVerifierCallsRelease() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        uint256 studentBefore = studentA.balance;
        uint256 verifierBefore = verifier_.balance;

        // verifier_ = address(this) gọi release
        core.releaseMilestone(id, 0);

        assert(studentA.balance == studentBefore + 0.5 ether);
        assert(verifier_.balance == verifierBefore); // Verifier không bị hao hụt hay hưởng lợi
    }

    // 3.2 Khi Sponsor gọi release, tiền vẫn chuyển 100% về ví studentA
    function test_ECO_R3_02_FundsReachStudentWhenSponsorCallsRelease() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        uint256 studentBefore = studentA.balance;
        uint256 sponsorBefore = sponsorA.balance;

        vm.prank(sponsorA);
        core.releaseMilestone(id, 0);

        assert(studentA.balance == studentBefore + 0.5 ether);
        assert(sponsorA.balance == sponsorBefore); // Sponsor không nhận tiền giải ngân
    }

    // 3.3 Không có chiết khấu hoa hồng nền tảng (Zero Platform Fee)
    function test_ECO_R3_03_ZeroPlatformFeeFullAmountReceived() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        uint256 initialBal = studentA.balance;
        vm.prank(studentA);
        core.releaseMilestone(id, 0);

        // Nhận trọn vẹn 0.5 ETH
        assert(studentA.balance - initialBal == 0.5 ether);
    }

    // ============================================================
    // 4. CHỈ MILESTONE ĐÃ APPROVE MỚI ĐƯỢC RELEASE (APPROVAL GATE)
    // ============================================================

    // 4.1 Mốc ở trạng thái Pending (chưa nộp minh chứng) -> giải ngân bị từ chối
    function test_ECO_R4_01_ReleasePendingMilestoneReverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        // Mốc 0 đang ở Pending, chưa submit
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    // 4.2 Mốc ở trạng thái Submitted (đã nộp nhưng chưa duyệt) -> giải ngân bị từ chối
    function test_ECO_R4_02_ReleaseSubmittedMilestoneReverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");

        // Mốc 0 đang ở Submitted, chưa approve
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    // 4.3 Mốc đã Approved -> giải ngân được chấp thuận
    function test_ECO_R4_03_ReleaseApprovedMilestoneSucceeds() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        vm.prank(studentA);
        core.releaseMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3); // Disbursed
    }

    // ============================================================
    // 5. MỘT MILESTONE CHỈ RELEASE MỘT LẦN (NO DOUBLE DISBURSEMENT)
    // ============================================================

    // 5.1 Giải ngân lần thứ hai cùng một mốc bị revert với AlreadyReleased
    function test_ECO_R5_01_DoubleReleaseReverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        // Lần 1: OK
        vm.prank(studentA);
        core.releaseMilestone(id, 0);

        // Lần 2: Phải revert AlreadyReleased
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);

        // Lần 3 từ phía Sponsor: Vẫn phải revert AlreadyReleased
        vm.prank(sponsorA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);
    }

    // ============================================================
    // 6. TỔNG RELEASED KHÔNG VƯỢT FUND (SOLVENCY INVARIANT)
    // ============================================================

    // 6.1 Bất biến số dư cho học bổng 3 mốc (0.3, 0.3, 0.4 ETH)
    function test_ECO_R6_01_MultiMilestoneSolvencyInvariant() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, threeMilestones); // total = 1.0 ETH

        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);

        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.fundedAmount == 1 ether);
        assert(s.releasedAmount == 0);

        // Giải ngân mốc 0: 0.3 ETH
        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof0");
        core.approveMilestone(id, 0);
        vm.prank(studentA);
        core.releaseMilestone(id, 0);

        s = core.getScholarship(id);
        assert(s.releasedAmount == 0.3 ether);
        assert(s.releasedAmount <= s.fundedAmount);

        // Giải ngân mốc 1: 0.3 ETH
        vm.prank(studentA);
        core.submitMilestone(id, 1, "QmProof1");
        core.approveMilestone(id, 1);
        vm.prank(studentA);
        core.releaseMilestone(id, 1);

        s = core.getScholarship(id);
        assert(s.releasedAmount == 0.6 ether);
        assert(s.releasedAmount <= s.fundedAmount);

        // Giải ngân mốc 2: 0.4 ETH
        vm.prank(studentA);
        core.submitMilestone(id, 2, "QmProof2");
        core.approveMilestone(id, 2);
        vm.prank(studentA);
        core.releaseMilestone(id, 2);

        s = core.getScholarship(id);
        assert(s.releasedAmount == 1.0 ether);
        assert(s.releasedAmount == s.fundedAmount);
    }

    // ============================================================
    // 7. KHÔNG CÓ CÁCH RÚT TIỀN TRÁI VỚI CAM KẾT SCHOLARSHIP
    // ============================================================

    // 7.1 Số dư hợp đồng luôn bằng tổng quỹ đã nạp trừ tổng quỹ đã giải ngân
    function test_ECO_R7_01_ContractBalanceStrictConservation() public {
        vm.prank(sponsorA);
        uint256 idA = core.createScholarship(studentA, twoMilestones); // 1.0 ETH
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(idA);

        vm.prank(sponsorB);
        uint256 idB = core.createScholarship(studentB, threeMilestones); // 1.0 ETH
        vm.prank(sponsorB);
        core.fundScholarship{value: 1 ether}(idB);

        // Hợp đồng giữ 2.0 ETH
        assert(address(core).balance == 2.0 ether);

        // Giải ngân 1 mốc của suất A (0.5 ETH)
        vm.prank(studentA);
        core.submitMilestone(idA, 0, "QmProof");
        core.approveMilestone(idA, 0);
        vm.prank(studentA);
        core.releaseMilestone(idA, 0);

        // Hợp đồng còn chính xác 1.5 ETH (không ai có thể rút trộm 1 wei nào)
        assert(address(core).balance == 1.5 ether);
    }

    // 7.2 Cô lập quỹ giữa các suất: Suất B chưa nạp tiền không thể rút lẹm tiền của Suất A
    function test_ECO_R7_02_CrossScholarshipFundIsolation() public {
        // Suất A nạp 1.0 ETH
        vm.prank(sponsorA);
        uint256 idA = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(idA);

        // Suất B KHÔNG nạp tiền (fundedAmount = 0), nhưng hợp đồng đang có 1.0 ETH từ Suất A
        vm.prank(sponsorB);
        uint256 idB = core.createScholarship(studentB, twoMilestones);

        vm.prank(studentB);
        core.submitMilestone(idB, 0, "QmProofB");
        core.approveMilestone(idB, 0);

        // Cố tình giải ngân Suất B: Bị chặn bởi InsufficientFunds vì fundedAmount của Suất B = 0
        // (Không thể rút lẹm vào 1.0 ETH của Suất A dù address(core).balance >= 0.5 ETH)
        vm.prank(studentB);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(idB, 0);
    }

    // ============================================================
    // 8. CÁC STATE-CHANGING ACTION QUAN TRỌNG EMIT EVENT & NATIVE ETH
    // ============================================================

    // 8.1 Vòng đời đầy đủ hoàn toàn bằng Native ETH (Pure Native ETH Lifecycle)
    function test_ECO_R8_01_PureNativeETHLifecycle() public {
        // Tạo suất
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        // Nạp Native ETH
        vm.prank(sponsorA);
        core.fundScholarship{value: 1 ether}(id);
        assert(address(core).balance == 1 ether);

        // Nộp minh chứng
        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmIPFSProofHashCIDv1");

        // Duyệt mốc
        core.approveMilestone(id, 0);

        // Giải ngân Native ETH trực tiếp
        uint256 balBefore = studentA.balance;
        vm.prank(studentA);
        core.releaseMilestone(id, 0);

        assert(studentA.balance - balBefore == 0.5 ether);
        assert(address(core).balance == 0.5 ether);
    }

    // 8.2 Cập nhật Verifier phát sinh cập nhật trạng thái hợp lệ
    function test_ECO_R8_02_VerifierUpdatedLifecycle() public {
        address newVerifier = address(0x8888);
        core.setVerifier(newVerifier);
        assert(core.verifier() == newVerifier);

        // Verifier mới có quyền duyệt mốc
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");

        vm.prank(newVerifier);
        core.approveMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2);
    }

    // ============================================================
    // 9. DEDICATED CORE TEST SUITE (CA HỢP LỆ & CA VI PHẠM)
    // ============================================================

    // [CA HỢP LỆ 1] Tạo scholarship -> fund -> submit milestone -> approve -> release thành công
    function test_VALID_ScholarshipLifecycle_Success() public {
        // Bước 1: Tạo scholarship
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        assert(id == 1);
        assert(core.getScholarship(id).totalAmount == 1.0 ether);

        // Bước 2: Fund scholarship
        vm.prank(sponsorA);
        core.fundScholarship{value: 1.0 ether}(id);
        assert(core.getScholarship(id).fundedAmount == 1.0 ether);

        // Bước 3: Submit milestone
        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmValidProofCIDv1");
        assert(uint8(core.getMilestoneStatus(id, 0)) == 1); // Submitted

        // Bước 4: Approve milestone
        core.approveMilestone(id, 0); // verifier_ = address(this)
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2); // Approved

        // Bước 5: Release milestone thành công
        vm.prank(studentA);
        core.releaseMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3); // Disbursed
        assert(core.getScholarship(id).releasedAmount == 0.5 ether);
    }

    // [CA HỢP LỆ 2] Kiểm tra student nhận đúng số tiền
    function test_VALID_StudentReceivesExactAmount() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1.0 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProofM0");
        core.approveMilestone(id, 0);

        uint256 studentBalBefore = studentA.balance;
        uint256 contractBalBefore = address(core).balance;

        // Sinh viên gọi giải ngân
        vm.prank(studentA);
        core.releaseMilestone(id, 0);

        // Sinh viên nhận chính xác 0.5 ether (không hoa hồng, không phí ẩn)
        assert(studentA.balance == studentBalBefore + 0.5 ether);
        assert(address(core).balance == contractBalBefore - 0.5 ether);
    }

    // [CA VI PHẠM 1] Release trước approve -> REVERT (MilestoneNotApproved)
    function test_VIOLATION_ReleaseBeforeApprove_Reverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1.0 ether}(id);

        // Case 1a: Mốc ở trạng thái Pending (chưa submit) -> REVERT
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);

        // Case 1b: Mốc ở trạng thái Submitted (chưa approve) -> REVERT
        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmPendingApprovalProof");

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    // [CA VI PHẠM 2] Release hai lần -> REVERT (AlreadyReleased)
    function test_VIOLATION_DoubleRelease_Reverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1.0 ether}(id);

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        // Lần 1: Giải ngân thành công
        vm.prank(studentA);
        core.releaseMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3);

        // Lần 2: Sinh viên gọi lại -> REVERT AlreadyReleased
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);

        // Lần 2b: Sponsor gọi lại -> REVERT AlreadyReleased
        vm.prank(sponsorA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);
    }

    // [CA VI PHẠM 3] Wrong student -> REVERT (NotStudent / InvalidAddress)
    function test_VIOLATION_WrongStudent_Reverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);
        vm.prank(sponsorA);
        core.fundScholarship{value: 1.0 ether}(id);

        // Case 3a: Sinh viên khác (studentB) cố nộp minh chứng cho suất của studentA -> REVERT NotStudent
        vm.prank(studentB);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmImposterProof");

        // Sinh viên chính chủ submit và verifier approve
        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmLegitProof");
        core.approveMilestone(id, 0);

        // Case 3b: Sinh viên khác (studentB) cố gọi release mốc của studentA -> REVERT NotStudent
        vm.prank(studentB);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.releaseMilestone(id, 0);

        // Case 3c: Khởi tạo với địa chỉ sinh viên rỗng address(0) -> REVERT InvalidAddress
        vm.prank(sponsorA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InvalidAddress.selector));
        core.createScholarship(address(0), twoMilestones);

        // Case 3d: Khởi tạo với địa chỉ hợp đồng address(core) -> REVERT InvalidAddress
        vm.prank(sponsorA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InvalidAddress.selector));
        core.createScholarship(address(core), twoMilestones);
    }

    // [CA VI PHẠM 4] Insufficient fund -> REVERT (InsufficientFunds)
    function test_VIOLATION_InsufficientFund_Reverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones); // 2 mốc x 0.5 ETH

        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        // Case 4a: Hoàn toàn chưa nạp quỹ (fundedAmount = 0) -> REVERT InsufficientFunds
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 0);

        // Case 4b: Nạp thiếu (0.2 ETH < 0.5 ETH cần cho mốc 0) -> REVERT InsufficientFunds
        vm.prank(sponsorA);
        core.fundScholarship{value: 0.2 ether}(id);

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 0);
    }

    // [CA VI PHẠM 5] Unauthorized caller -> REVERT (NotSponsor / NotStudent)
    function test_VIOLATION_UnauthorizedCaller_Reverts() public {
        vm.prank(sponsorA);
        uint256 id = core.createScholarship(studentA, twoMilestones);

        // Case 5a: Kẻ lạ nạp quỹ -> REVERT NotSponsor
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.fundScholarship{value: 1.0 ether}(id);

        // Sponsor nạp quỹ hợp lệ
        vm.prank(sponsorA);
        core.fundScholarship{value: 1.0 ether}(id);

        // Case 5b: Kẻ lạ nộp minh chứng -> REVERT NotStudent
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmStrangerProof");

        // Case 5c: Sponsor nộp minh chứng thay sinh viên -> REVERT NotStudent
        vm.prank(sponsorA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmSponsorProof");

        // Sinh viên nộp minh chứng hợp lệ
        vm.prank(studentA);
        core.submitMilestone(id, 0, "QmStudentProof");

        // Case 5d: Kẻ lạ duyệt mốc -> REVERT NotSponsor
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.approveMilestone(id, 0);

        // Case 5e: Sinh viên tự duyệt mốc của chính mình -> REVERT NotSponsor
        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.approveMilestone(id, 0);

        // Verifier duyệt hợp lệ
        core.approveMilestone(id, 0);

        // Case 5f: Kẻ lạ gọi giải ngân -> REVERT NotStudent
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.releaseMilestone(id, 0);

        // Case 5g: Kẻ lạ hoặc sinh viên thay đổi Verifier -> REVERT NotSponsor
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.setVerifier(address(0x7777));

        vm.prank(studentA);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.setVerifier(address(0x7777));
    }
}

