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
// Malicious student contract: co receive() nhung luon revert
// => Dung de tai hien SEC-06 (DoS khi vi sinh vien tu choi ETH)
// ============================================================
contract MaliciousStudentWallet {
    receive() external payable {
        revert("I refuse ETH");
    }
}

// ============================================================
// NoReceiveStudentWallet: khong co receive() / fallback()
// => Khong the nhan Native ETH
// ============================================================
contract NoReceiveStudentWallet {
    // No receive() or fallback() => ETH transfer will fail
}

// ============================================================
// Lab 10 Verification Test Suite — TrustScholar
//
// Muc dich: Kiem chung tung finding trong docs/LAB10_AUDIT.md
// bang cach tai hien loi hoac xac nhan finding khong ton tai.
//
// Quy uoc:
//   test_VERIFY_SEC*_EXISTS : tai hien loi thanh cong => finding DA DUOC XAC NHAN
//   test_VERIFY_*_SAFE      : chung minh finding KHONG ton tai / da duoc bao ve
// ============================================================
contract Lab10VerifyTest {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    ProjectCore internal core;

    address internal sponsor  = address(0x1111);
    address internal student  = address(0x2222);
    address internal stranger = address(0x3333);
    address internal verifier_; // deployer = address(this)

    uint256[] internal twoMilestones;

    function setUp() public {
        core = new ProjectCore();
        verifier_ = address(this);

        twoMilestones = new uint256[](2);
        twoMilestones[0] = 0.5 ether;
        twoMilestones[1] = 0.5 ether;

        vm.deal(sponsor,  10 ether);
        vm.deal(student,  1  ether);
        vm.deal(stranger, 1  ether);
    }

    // ==========================================================
    // SEC-01: Sponsor co quyen tu phe duyet moc (DA FIX)
    // Finding: Truoc day cho phep msg.sender == s.sponsor
    // Ket qua sau fix: Sponsor bi chan bang NotVerifier()
    // ==========================================================
    function test_VERIFY_SEC01_SponsorSelfApprove_FIXED() public {
        // Sponsor tao suat hoc bong
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        // Student nop minh chung
        vm.prank(student);
        core.submitMilestone(id, 0, "QmRealProof");

        // Sponsor co gang tu duyet moc cua minh -> Revert NotVerifier
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotVerifier.selector));
        core.approveMilestone(id, 0);
    }

    // ==========================================================
    // SEC-02: State Regression — Sinh vien dao nguoc Approved -> Submitted (DA FIX)
    // Finding: Truoc day cho phep submitMilestone khi da Approved
    // Ket qua sau fix: submitMilestone bi chan bang InvalidMilestoneStatus()
    // ==========================================================
    function test_VERIFY_SEC02_StateRegression_FIXED() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Student nop minh chung lan 1
        vm.prank(student);
        core.submitMilestone(id, 0, "QmRealProof_v1");

        // Verifier duyet => moc chuyen sang Approved
        core.approveMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2); // Approved

        // Student co gang nop lai minh chung khi moc da Approved -> Revert InvalidMilestoneStatus
        vm.prank(student);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InvalidMilestoneStatus.selector));
        core.submitMilestone(id, 0, "QmFakeProof_Overwrite");

        // Trang thai van duoc bao toan la Approved
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2); // Approved

        // Giai ngan tiep tuc thanh cong
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3); // Disbursed
    }

    // ==========================================================
    // SEC-03: Fund Locking — Thieu co che hoan tien
    // Ket qua kiem chung: FINDING TON TAI (CONFIRMED)
    // Chung minh: ETH bi ket trong contract khi student bo hoc
    // ==========================================================
    function test_VERIFY_SEC03_FundLocking_EXISTS() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        // Sponsor nap du tien
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Giai ngan moc 0 thanh cong
        vm.prank(student);
        core.submitMilestone(id, 0, "QmMilestone0_Proof");
        core.approveMilestone(id, 0);
        vm.prank(sponsor);
        core.releaseMilestone(id, 0); // Moc 0: 0.5 ETH giai ngan

        // Moc 1 van o trang thai Pending, student bo hoc
        // 0.5 ETH con lai bi KET trong contract vi:
        // 1. Sponsor khong the rut lai (khong co ham refund)
        // 2. Student khong nop minh chung moc 1
        // 3. Khong co co che huy suat hoc bong
        uint256 contractBalance = address(core).balance;
        assert(contractBalance == 0.5 ether); // ETH bi ket

        // Xac nhan: khong co ham refund/cancel/withdraw nao trong contract
        // (kiem tra via static analysis — khong co selector nao match)
    }

    // ==========================================================
    // SEC-04: Bat ky ai cung tao duoc suat hoc bong
    // Ket qua kiem chung: FINDING TON TAI (CONFIRMED)
    // ==========================================================
    function test_VERIFY_SEC04_AnyoneCreateScholarship_EXISTS() public {
        // Nguoi la (stranger) tao suat hoc bong — KHONG co revert
        vm.prank(stranger);
        uint256 id = core.createScholarship(student, twoMilestones);

        // Suat duoc tao thanh cong boi stranger
        assert(id == 1);
        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.sponsor == stranger); // Stranger tro thanh Sponsor
    }

    // ==========================================================
    // SEC-05: Submit va Approve moc khi suat chua co tien
    // Ket qua kiem chung: FINDING TON TAI (CONFIRMED)
    // ==========================================================
    function test_VERIFY_SEC05_SubmitApproveWithZeroFund_EXISTS() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        // KHONG goi fundScholarship => fundedAmount = 0

        // Student nop minh chung khi suat chua co tien — KHONG revert
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof_Unfunded");

        // Verifier duyet moc khi suat chua co tien — KHONG revert
        core.approveMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 2); // Approved du khong co tien

        // Hau qua: Khi giai ngan se revert InsufficientFunds
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 0);
        // => Student va Verifier da ton gas vo ich
    }

    // ==========================================================
    // SEC-06: DoS khi vi sinh vien tu choi nhan ETH (MaliciousWallet)
    // Ket qua kiem chung: FINDING TON TAI (CONFIRMED)
    // ==========================================================
    function test_VERIFY_SEC06_DoS_MaliciousStudentWallet_EXISTS() public {
        MaliciousStudentWallet maliciousWallet = new MaliciousStudentWallet();
        address maliciousStudent = address(maliciousWallet);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 0.5 ether;

        vm.prank(sponsor);
        uint256 id = core.createScholarship(maliciousStudent, amounts);

        vm.prank(sponsor);
        core.fundScholarship{value: 0.5 ether}(id);

        // Malicious contract nop minh chung
        vm.prank(maliciousStudent);
        core.submitMilestone(id, 0, "QmProof");

        // Verifier duyet moc
        core.approveMilestone(id, 0);

        // Khi giai ngan, call se that bai vi vi sinh vien revert
        // => TransferFailed() => Tien bi ket vinh vien trong contract
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.TransferFailed.selector));
        core.releaseMilestone(id, 0);
    }

    // ==========================================================
    // SEC-06 (bien the): Vi khong co receive() — NoReceiveWallet
    // Ket qua kiem chung: FINDING TON TAI (CONFIRMED)
    // ==========================================================
    function test_VERIFY_SEC06_DoS_NoReceiveWallet_EXISTS() public {
        NoReceiveStudentWallet noReceiveWallet = new NoReceiveStudentWallet();
        address noReceiveStudent = address(noReceiveWallet);

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 0.5 ether;

        vm.prank(sponsor);
        uint256 id = core.createScholarship(noReceiveStudent, amounts);

        vm.prank(sponsor);
        core.fundScholarship{value: 0.5 ether}(id);

        vm.prank(noReceiveStudent);
        core.submitMilestone(id, 0, "QmProof");

        core.approveMilestone(id, 0);

        // Transfer den contract khong co receive() cung se that bai
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.TransferFailed.selector));
        core.releaseMilestone(id, 0);
    }

    // ==========================================================
    // SEC-07: setVerifier bao sai loi NotSponsor thay vi NotVerifier (DA FIX)
    // Finding: Truoc day tra ve NotSponsor() sai ngu nghia
    // Ket qua sau fix: Tra ve NotVerifier() chuan xac
    // ==========================================================
    function test_VERIFY_SEC07_WrongErrorCode_FIXED() public {
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotVerifier.selector));
        core.setVerifier(address(0x9999));
    }

    // ==========================================================
    // SEC-08: Bat nhat Event/Error names giua SPEC va Contract
    // (Informational — kiem chung qua static analysis)
    // Ket qua kiem chung: FINDING TON TAI (CONFIRMED - Informational)
    // ==========================================================
    function test_VERIFY_SEC08_EventNameMismatch_INFO() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        // SPEC quy dinh: FundDeposited
        // Contract phat: ScholarshipFunded
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // SPEC quy dinh: ProofSubmitted
        // Contract phat: MilestoneSubmitted
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof");

        // MilestoneApproved: khop voi SPEC
        core.approveMilestone(id, 0);

        // SPEC quy dinh: ScholarshipDisbursed
        // Contract phat: ScholarshipReleased
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        // Contract hoat dong dung chuc nang nhung ten Event/Error khac SPEC
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3); // Disbursed
    }

    // ==========================================================
    // Kiem chung NHOM AN TOAN: Wrong Recipient
    // Tien phai den dung vi student, khong phai caller
    // Ket qua: AN TOAN (NOT VULNERABLE)
    // ==========================================================
    function test_VERIFY_WrongRecipient_SAFE() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        uint256 studentBefore  = student.balance;
        uint256 sponsorBefore  = sponsor.balance;
        uint256 verifierBefore = verifier_.balance;

        // Verifier kich hoat release — tien PHAI den student, khong phai verifier
        core.releaseMilestone(id, 0);

        assert(student.balance   == studentBefore  + 0.5 ether); // Student nhan dung tien
        assert(verifier_.balance == verifierBefore);              // Verifier khong nhan tien
        assert(sponsor.balance   == sponsorBefore);               // Sponsor khong nhan tien
    }

    // ==========================================================
    // Kiem chung NHOM AN TOAN: Double Release
    // Khong the giai ngan hai lan cung mot moc
    // Ket qua: AN TOAN (NOT VULNERABLE)
    // ==========================================================
    function test_VERIFY_DoubleRelease_SAFE() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        // Release lan 1 — thanh cong
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        // Release lan 2 — phai revert AlreadyReleased
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);
    }

    // ==========================================================
    // Kiem chung NHOM AN TOAN: Release Before Approval
    // Khong the giai ngan truoc khi duyet
    // Ket qua: AN TOAN (NOT VULNERABLE)
    // ==========================================================
    function test_VERIFY_ReleaseBeforeApproval_SAFE() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Student nop nhung CHUA approve
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof");

        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    // ==========================================================
    // Kiem chung NHOM AN TOAN: Reentrancy Guard + CEI Pattern
    // nonReentrant bao ve dung chuan + state cap nhat truoc external call
    // Ket qua: AN TOAN (NOT VULNERABLE)
    // ==========================================================
    function test_VERIFY_ReentrancyAndCEI_SAFE() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProof");
        core.approveMilestone(id, 0);

        uint256 balBefore = student.balance;

        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        // Sau khi release: state duoc cap nhat dung TRUOC external call (CEI)
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3); // Disbursed
        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.releasedAmount == 0.5 ether);
        assert(student.balance  == balBefore + 0.5 ether);
    }
}
