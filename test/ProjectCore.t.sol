// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/project/ProjectCore.sol";

// ============================================================
// Minimal Vm cheatcode interface (Foundry/Hardhat 3 built-in)
// Standard hevm address: 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
// ============================================================
interface Vm {
    function prank(address sender) external;
    function deal(address account, uint256 newBalance) external;
    function expectRevert(bytes calldata revertData) external;
}

// ============================================================
// Main Test Contract for ProjectCore (TrustScholar Lab 09)
// Convention: Hardhat 3 Solidity tests (Foundry-style)
//   - setUp()     : runs before each test
//   - test_*()    : expected SUCCESS
//   - test_*Reverts() : expected REVERT with vm.expectRevert
// ============================================================
contract ProjectCoreTest {
    // Cheat-code interface (Hardhat 3 built-in / Foundry vm)
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    ProjectCore internal core;

    // Test accounts
    address internal sponsor  = address(0x1111);
    address internal student  = address(0x2222);
    address internal stranger = address(0x3333);
    address internal verifier_; // deployer of contract

    // Shared milestone array: 2 milestones x 0.5 ETH = 1 ETH total
    uint256[] internal twoMilestones;

    // --------------------------------------------------------
    // setUp - runs before EACH test function
    // --------------------------------------------------------
    function setUp() public {
        // Deploy: msg.sender = address(this), so verifier = address(this)
        core = new ProjectCore();
        verifier_ = address(this);

        twoMilestones = new uint256[](2);
        twoMilestones[0] = 0.5 ether;
        twoMilestones[1] = 0.5 ether;

        // Give ETH to test addresses
        vm.deal(sponsor,  10 ether);
        vm.deal(student,  1  ether);
        vm.deal(stranger, 1  ether);
    }

    // ============================================================
    //  SUCCESS TESTS (1 - 6)
    // ============================================================

    // Test 1: Sponsor creates scholarship successfully
    // NOTE: createScholarship has NO role restriction in current contract.
    // Anyone can call it; sponsor is used here to match business intent.
    function test_01_SponsorCreateScholarship() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        assert(id == 1);
        assert(core.scholarshipCount() == 1);

        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.sponsor        == sponsor);
        assert(s.student        == student);
        assert(s.totalAmount    == 1 ether);
        assert(s.milestoneCount == 2);
        assert(s.fundedAmount   == 0);
        assert(s.releasedAmount == 0);
    }

    // Test 2: Sponsor funds scholarship successfully
    function test_02_SponsorFundScholarship() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.fundedAmount == 1 ether);
    }

    // Test 3: Correct student submits milestone proof
    function test_03_StudentSubmitMilestone() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        // MilestoneStatus.Submitted == 1
        assert(uint8(core.getMilestoneStatus(id, 0)) == 1);
    }

    // Test 4: Authorised verifier (deployer = address(this)) approves milestone
    function test_04_VerifierApproveMilestone() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        // address(this) == verifier_ (set in constructor)
        core.approveMilestone(id, 0);

        // MilestoneStatus.Approved == 2
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2);
    }

    // Test 5: After approve + sufficient funds, release succeeds
    function test_05_ReleaseMilestoneSuccess() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        core.approveMilestone(id, 0); // verifier_ = address(this)

        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        // MilestoneStatus.Disbursed == 3
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3);
    }

    // Test 6: ETH goes to the correct student wallet
    function test_06_FundsReachStudentWallet() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        core.approveMilestone(id, 0);

        uint256 balanceBefore = student.balance;

        // verifier_ triggers release; ETH must arrive at student, not caller
        core.releaseMilestone(id, 0);

        uint256 balanceAfter = student.balance;
        // Exactly 0.5 ether (first milestone) must be credited to student
        assert(balanceAfter - balanceBefore == 0.5 ether);
    }

    // ============================================================
    //  FAIL TESTS (7 - 13)
    // ============================================================

    // Test 7: Unauthorized person cannot approve milestone
    // DEVIATION NOTE: createScholarship has NO access control in current contract,
    // so "person without role cannot create" cannot be tested as a revert.
    // We test the actual RBAC gate: only sponsor/verifier can approveMilestone.
    // This maps to SPEC R1 intent (restricted operations require authority).
    function test_07_StrangerCannotApproveMilestone() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.approveMilestone(id, 0);
    }

    // Test 8: Someone other than the registered student cannot submit proof
    function test_08_StrangerCannotSubmitMilestone() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmFakeProof");
    }

    // Test 9: Release before approve is rejected
    function test_09_ReleaseBeforeApproveReverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Student submits, but NO approval yet
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    // Test 10: Cannot release the same milestone twice (double disbursement)
    function test_10_DoubleReleaseReverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        core.approveMilestone(id, 0);

        vm.prank(sponsor);
        core.releaseMilestone(id, 0); // First release - OK

        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0); // Second release - must revert
    }

    // Test 11: Release fails when scholarship is underfunded
    function test_11_ReleaseWithInsufficientFundsReverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        // No fundScholarship call - fundedAmount remains 0

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash_Milestone0");

        core.approveMilestone(id, 0);

        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 0);
    }

    // Test 12: address(0) as student is rejected on createScholarship
    function test_12_ZeroAddressStudentReverts() public {
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InvalidAddress.selector));
        core.createScholarship(address(0), twoMilestones);
    }

    // Test 13: amount = 0 in milestoneAmounts is rejected
    function test_13_ZeroMilestoneAmountReverts() public {
        uint256[] memory zeroAmounts = new uint256[](2);
        zeroAmounts[0] = 0;
        zeroAmounts[1] = 1 ether;

        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InvalidAmount.selector));
        core.createScholarship(student, zeroAmounts);
    }

    // ============================================================
    //  ADDITIONAL EDGE CASE COVERAGE
    // ============================================================

    // Extra A: Sponsor cannot fund more than totalAmount
    function test_Extra_A_OverfundReverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones); // total = 1 ether

        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InvalidAmount.selector));
        core.fundScholarship{value: 2 ether}(id);
    }

    // Extra B: Non-sponsor cannot fund a scholarship
    function test_Extra_B_NonSponsorCannotFund() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotSponsor.selector));
        core.fundScholarship{value: 1 ether}(id);
    }

    // Extra C: Sponsor is also allowed to approve milestone (dual authority)
    function test_Extra_C_SponsorCanApproveMilestone() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash");

        vm.prank(sponsor);
        core.approveMilestone(id, 0);

        assert(uint8(core.getMilestoneStatus(id, 0)) == 2); // Approved
    }

    // Extra D: releasedAmount accumulates correctly after disbursement
    function test_Extra_D_ReleasedAmountTracked() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof0");
        core.approveMilestone(id, 0);

        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.releasedAmount == 0.5 ether);
    }
}
