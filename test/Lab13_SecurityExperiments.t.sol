// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/project/ProjectCore.sol";
import "../contracts/training/VulnerableScholarshipBank.sol";
import "../contracts/training/AttackerScholarshipBank.sol";
import "../contracts/training/SecureScholarshipBank.sol";

// ============================================================
// Minimal Vm cheatcode interface (Hardhat 3 / Foundry built-in)
// ============================================================
interface Vm {
    function prank(address sender) external;
    function deal(address account, uint256 newBalance) external;
    function expectRevert(bytes calldata revertData) external;
}

// ============================================================
// Attacker for SecureScholarshipBank to demonstrate CEI & ReentrancyGuard defense
// ============================================================
contract AttackerSecureBank {
    SecureScholarshipBank public target;
    uint256 public attackCount;
    bool public useCEIOnly;
    string public lastRevertReason;
    bool public catchErrors;

    constructor(address _target, bool _useCEIOnly, bool _catchErrors) {
        target = SecureScholarshipBank(_target);
        useCEIOnly = _useCEIOnly;
        catchErrors = _catchErrors;
    }

    function attack() external payable {
        attackCount = 0;
        target.deposit{value: msg.value}();
        if (useCEIOnly) {
            target.withdrawCEI();
        } else {
            target.withdraw();
        }
    }

    receive() external payable {
        attackCount++;
        if (address(target).balance >= 1 ether) {
            if (catchErrors) {
                if (useCEIOnly) {
                    try target.withdrawCEI() {
                        // Unexpected success
                    } catch Error(string memory reason) {
                        lastRevertReason = reason;
                    }
                } else {
                    try target.withdraw() {
                        // Unexpected success
                    } catch Error(string memory reason) {
                        lastRevertReason = reason;
                    }
                }
            } else {
                // Do not catch: bubbles up and causes external call in target to fail
                if (useCEIOnly) {
                    target.withdrawCEI();
                } else {
                    target.withdraw();
                }
            }
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

// ============================================================
// Reentrant Student Wallet attempting to attack ProjectCore.sol
// ============================================================
contract ReentrantMaliciousStudent {
    ProjectCore public core;
    uint256 public targetScholarshipId;
    uint256 public targetMilestoneIndex;
    uint256 public reentrancyAttempts;
    bytes public lastRevertReason;

    constructor(address _core) {
        core = ProjectCore(_core);
    }

    function setTarget(uint256 _id, uint256 _milestone) external {
        targetScholarshipId = _id;
        targetMilestoneIndex = _milestone;
    }

    receive() external payable {
        reentrancyAttempts++;
        // Thử tái nhập gọi lại releaseMilestone khi đang trong quá trình nhận tiền
        if (address(core).balance >= 0.5 ether) {
            try core.releaseMilestone(targetScholarshipId, targetMilestoneIndex) {
                // Nếu thành công (không thể xảy ra do nonReentrant & CEI)
            } catch (bytes memory reason) {
                lastRevertReason = reason;
            }
        }
    }
}

/**
 * @title Lab13_SecurityExperimentsTest
 * @notice Test suite thực nghiệm an ninh bảo mật Lab 13 - TrustScholar:
 *   Phần 1: Thực nghiệm Reentrancy Attack trên hợp đồng đào tạo VulnerableScholarshipBank
 *   Phần 2: Thực nghiệm phòng vệ trên hợp đồng đào tạo SecureScholarshipBank (CEI & ReentrancyGuard)
 *   Phần 3: Kiểm toán chuyên sâu ProjectCore.sol theo 5 câu hỏi an ninh cốt lõi
 */
contract Lab13SecurityExperimentsTest {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    ProjectCore internal core;
    VulnerableScholarshipBank internal vulnBank;
    SecureScholarshipBank internal secureBank;

    address internal sponsor   = address(0x1111);
    address internal student   = address(0x2222);
    address internal stranger  = address(0x3333);
    address internal donor1    = address(0x4441);
    address internal donor2    = address(0x4442);
    address internal verifier_; // deployer = address(this)

    uint256[] internal twoMilestones;

    function setUp() public {
        core = new ProjectCore();
        verifier_ = address(this);

        vulnBank = new VulnerableScholarshipBank();
        secureBank = new SecureScholarshipBank();

        twoMilestones = new uint256[](2);
        twoMilestones[0] = 0.5 ether;
        twoMilestones[1] = 0.5 ether;

        vm.deal(sponsor,  10 ether);
        vm.deal(student,  2  ether);
        vm.deal(stranger, 5  ether);
        vm.deal(donor1,   10 ether);
        vm.deal(donor2,   10 ether);
    }

    // ============================================================
    // PHẦN 1: THỰC NGHIỆM REENTRANCY TRÊN HỢP ĐỒNG ĐÀO TẠO
    // ============================================================

    /**
     * @notice EXP-01: Minh họa tấn công Reentrancy rút cạn VulnerableScholarshipBank
     * @dev Các nhà tài trợ nạp 5 ETH. Kẻ tấn công dùng 1 ETH để rút cạn toàn bộ 6 ETH.
     */
    function test_EXP01_VulnerableBank_DrainedByReentrancy() public {
        // [1] Các nhà hảo tâm gửi tiền vào ngân hàng học bổng (tổng 5 ETH)
        vm.prank(donor1);
        vulnBank.deposit{value: 3 ether}();
        vm.prank(donor2);
        vulnBank.deposit{value: 2 ether}();

        assert(vulnBank.getContractBalance() == 5 ether);
        assert(vulnBank.totalDeposits() == 5 ether);

        // [2] Kẻ tấn công triển khai contract AttackerScholarshipBank
        vm.prank(stranger);
        AttackerScholarshipBank attacker = new AttackerScholarshipBank(payable(address(vulnBank)));

        // [3] Kẻ tấn công kích hoạt cuộc tấn công với 1 ETH
        // Attacker nạp 1 ETH -> Ngân hàng có 6 ETH.
        // Attacker gọi withdraw() -> nhận 1 ETH -> receive() gọi lại withdraw() 5 lần nữa.
        // Toàn bộ 6 ETH trong ngân hàng bị rút sạch!
        vm.prank(stranger);
        attacker.attack{value: 1 ether}();

        // [4] Kiểm chứng:
        // - Ngân hàng học bổng bị rút cạn về 0 ETH
        assert(vulnBank.getContractBalance() == 0);
        // - Attacker contract chiếm giữ toàn bộ 6 ETH
        assert(attacker.getBalance() == 6 ether);
        // - Tái nhập xảy ra đúng 6 lần (1 lần khởi đầu + 5 lần reenter)
        assert(attacker.attackCount() == 6);
    }

    /**
     * @notice EXP-02: Phòng vệ bằng mẫu Checks-Effects-Interactions (CEI)
     * @dev Cập nhật balances[msg.sender] = 0 TRƯỚC external call làm vô hiệu hóa reentrancy.
     */
    function test_EXP02_SecureBank_CEI_PreventsReentrancy() public {
        // Nhà tài trợ gửi 5 ETH vào Secure Bank
        vm.prank(donor1);
        secureBank.deposit{value: 5 ether}();

        // Kẻ tấn công triển khai attacker nhắm vào hàm withdrawCEI() có try/catch
        vm.prank(stranger);
        AttackerSecureBank attacker = new AttackerSecureBank(address(secureBank), true, true);

        // Kẻ tấn công cố gắng khai thác:
        // Lần đầu rút thành công 1 ETH hợp lệ của chính nó.
        // Khi receive() gọi lại withdrawCEI(), bước Checks phát hiện balances[attacker] == 0,
        // lập tức revert với "Insufficient balance"!
        // Cuộc gọi tái nhập bị bắt trong try/catch và lưu mã lỗi.
        vm.prank(stranger);
        attacker.attack{value: 1 ether}();

        // Kiểm chứng:
        // - Lần tái nhập bị từ chối với đúng lý do "Insufficient balance" do CEI đã xóa số dư trước đó
        assert(keccak256(bytes(attacker.lastRevertReason())) == keccak256(bytes("Insufficient balance")));
        // - 5 ETH của các nhà tài trợ khác hoàn toàn AN TOÀN trong ngân hàng
        assert(secureBank.getContractBalance() == 5 ether);
        // - Kẻ tấn công chỉ nhận đúng 1 ETH vốn ban đầu của mình, không chiếm đoạt được bất kỳ xu nào!
        assert(attacker.getBalance() == 1 ether);
    }

    /**
     * @notice EXP-03: Phòng vệ bằng ReentrancyGuard Mutex Lock
     * @dev Modifier nonReentrant chặn mọi nỗ lực tái nhập trước khi chạm vào logic.
     */
    function test_EXP03_SecureBank_ReentrancyGuard_PreventsReentrancy() public {
        vm.prank(donor1);
        secureBank.deposit{value: 5 ether}();

        vm.prank(stranger);
        AttackerSecureBank attacker = new AttackerSecureBank(address(secureBank), false, true);

        // Kẻ tấn công gọi withdraw() có modifier nonReentrant
        // Khi receive() gọi lại withdraw(), mutex lock phát hiện reentrancy và REVERT "ReentrancyGuard: reentrant call"
        vm.prank(stranger);
        attacker.attack{value: 1 ether}();

        // Kiểm chứng:
        // - Lỗi bắt được chính xác là "ReentrancyGuard: reentrant call"
        assert(keccak256(bytes(attacker.lastRevertReason())) == keccak256(bytes("ReentrancyGuard: reentrant call")));
        // - 5 ETH của các nhà tài trợ được bảo vệ 100%
        assert(secureBank.getContractBalance() == 5 ether);
        // - Kẻ tấn công không thể bòn rút thêm
        assert(attacker.getBalance() == 1 ether);
    }

    /**
     * @notice EXP-04: Phòng vệ toàn diện khi reentrancy unhandled khiến cả transaction revert
     */
    function test_EXP04_SecureBank_UnhandledReentrancyRevertsTransfer() public {
        vm.prank(donor1);
        secureBank.deposit{value: 5 ether}();

        // Attacker không dùng try/catch: để lỗi tái nhập nổi lên làm hỏng external call
        vm.prank(stranger);
        AttackerSecureBank attacker = new AttackerSecureBank(address(secureBank), false, false);

        vm.prank(stranger);
        vm.expectRevert("ETH transfer failed");
        attacker.attack{value: 1 ether}();

        assert(secureBank.getContractBalance() == 5 ether);
    }

    // ============================================================
    // PHẦN 2: AUDIT & KIỂM CHỨNG TOÀN DIỆN ProjectCore.sol
    // ============================================================

    /**
     * @notice AUDIT CÂU HỎI 1: Có external call không?
     * @dev Trả lời: CÓ. Dòng 259 ProjectCore.sol thực hiện:
     *      `(bool success, ) = s.student.call{value: amountToRelease}("");`
     *      Tiền Native ETH được chuyển trực tiếp vào ví sinh viên đã đăng ký.
     */
    function test_AUDIT01_ProjectCore_HasExternalCall_ToStudent() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash1");
        core.approveMilestone(id, 0);

        uint256 studentBalBefore = student.balance;

        // External call diễn ra tại releaseMilestone
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        // Khẳng định: External call đã chuyển đúng 0.5 ETH vào ví student
        assert(student.balance == studentBalBefore + 0.5 ether);
    }

    /**
     * @notice AUDIT CÂU HỎI 2: State update có trước call không?
     * @dev Trả lời: CÓ. Mẫu CEI được tuân thủ nghiêm ngặt:
     *      Dòng 254-256: Cập nhật status = Disbursed, disbursedAt, releasedAmount
     *      Dòng 259: Mới thực hiện external call chuyển ETH.
     */
    function test_AUDIT02_ProjectCore_StateUpdateBeforeCall_CEI() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash1");
        core.approveMilestone(id, 0);

        // Thực hiện giải ngân
        vm.prank(student);
        core.releaseMilestone(id, 0);

        // Kiểm chứng trạng thái on-chain sau giải ngân:
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3); // Disbursed
        ProjectCore.Milestone memory m = core.getMilestone(id, 0);
        assert(m.disbursedAt > 0);
        ProjectCore.Scholarship memory s = core.getScholarship(id);
        assert(s.releasedAmount == 0.5 ether);
    }

    /**
     * @notice AUDIT CÂU HỎI 3: Release hai lần có bị chặn không?
     * @dev Trả lời: CÓ. Dòng 245 kiểm tra:
     *      `if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();`
     *      Lần gọi thứ hai chắc chắn revert với AlreadyReleased.
     */
    function test_AUDIT03_ProjectCore_DoubleReleaseBlocked() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofHash1");
        core.approveMilestone(id, 0);

        // Release lần 1: thành công
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        // Release lần 2: PHẢI revert AlreadyReleased
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);
    }

    /**
     * @notice AUDIT CÂU HỎI 4: Wrong student có bị chặn không?
     * @dev Trả lời: CÓ.
     *      1. submitMilestone: `if (msg.sender != s.student) revert NotStudent();`
     *      2. releaseMilestone: Tiền luôn gửi đến `s.student`, người lạ kích hoạt bị revert `NotStudent()`.
     */
    function test_AUDIT04_ProjectCore_WrongStudentBlocked() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Kẻ lạ (stranger) cố nộp minh chứng thay student -> REVERT NotStudent
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmFakeProof");

        // Student hợp lệ nộp và được duyệt
        vm.prank(student);
        core.submitMilestone(id, 0, "QmValidProof");
        core.approveMilestone(id, 0);

        // Kẻ lạ (stranger) cố gọi lệnh release -> REVERT NotStudent
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.releaseMilestone(id, 0);
    }

    /**
     * @notice AUDIT CÂU HỎI 5: Release trước approval có bị chặn không?
     * @dev Trả lời: CÓ. Dòng 246 kiểm tra:
     *      `if (m.status != MilestoneStatus.Approved) revert MilestoneNotApproved();`
     */
    function test_AUDIT05_ProjectCore_ReleaseBeforeApprovalBlocked() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // [Case A] Mốc ở trạng thái Pending (chưa nộp, chưa duyệt) gọi release -> REVERT
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);

        // [Case B] Mốc đã nộp minh chứng (Submitted) nhưng CHƯA duyệt gọi release -> REVERT
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofPending");

        vm.prank(student);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    /**
     * @notice AUDIT THỰC CHỨNG NÂNG CAO: Tấn công Reentrancy trực tiếp vào ProjectCore.sol
     * @dev Ví sinh viên là ReentrantMaliciousStudent cố tình reenter hàm releaseMilestone() trong receive()
     *      Kết quả: Hoàn toàn thất bại do nonReentrant và CEI bảo vệ 2 lớp!
     */
    function test_AUDIT06_ProjectCore_ReentrancyAttack_Defeated() public {
        // Triển khai hợp đồng sinh viên độc hại
        ReentrantMaliciousStudent maliciousStudent = new ReentrantMaliciousStudent(address(core));

        // Sponsor tạo suất học bổng chỉ định ví sinh viên là maliciousStudent
        vm.prank(sponsor);
        uint256 id = core.createScholarship(address(maliciousStudent), twoMilestones);
        maliciousStudent.setTarget(id, 0);

        // Sponsor nạp 1 ETH (cho 2 mốc)
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Nộp minh chứng và duyệt mốc 0
        vm.prank(address(maliciousStudent));
        core.submitMilestone(id, 0, "QmMaliciousProof");
        core.approveMilestone(id, 0);

        // Gọi giải ngân:
        // Lệnh releaseMilestone chuyển 0.5 ETH đến maliciousStudent.
        // Khi maliciousStudent.receive() được gọi, nó cố tình gọi lại core.releaseMilestone(id, 0).
        // Nhờ có nonReentrant (và CEI status=Disbursed), cuộc gọi tái nhập bị chặn đứng!
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);

        // Kiểm chứng:
        // 1. maliciousStudent đã cố gắng reenter ít nhất 1 lần
        assert(maliciousStudent.reentrancyAttempts() == 1);
        // 2. Lệnh reenter đã bị revert (bắt được trong try/catch của receive)
        assert(maliciousStudent.lastRevertReason().length > 0);
        // 3. Số dư còn lại của ProjectCore vẫn bảo toàn đúng 0.5 ETH (cho mốc 1)
        assert(address(core).balance == 0.5 ether);
        // 4. Số tiền maliciousStudent nhận được chỉ đúng 0.5 ETH của mốc 0, không thể rút lẹm mốc 1!
        assert(address(maliciousStudent).balance == 0.5 ether);
    }

    // ============================================================
    // PHẦN 3: NEGATIVE TESTS CHUYÊN BIỆT CHO ProjectCore.sol
    // ============================================================

    /**
     * @notice NEG-01: Release trước approval bị từ chối
     * @dev Thử nghiệm giải ngân ở cả 2 trạng thái: Pending (chưa nộp) và Submitted (đã nộp nhưng chưa duyệt).
     *      Kỳ vọng: Cả 2 trường hợp đều revert với MilestoneNotApproved().
     */
    function test_NEG01_ProjectCore_ReleaseBeforeApproval_Reverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Trường hợp 1: Mốc 0 ở trạng thái Pending -> Release bị revert
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);

        // Sinh viên nộp minh chứng -> Mốc 0 chuyển sang Submitted
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofPendingApproval");

        // Trường hợp 2: Mốc 0 ở trạng thái Submitted nhưng chưa duyệt -> Release bị revert
        vm.prank(student);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.MilestoneNotApproved.selector));
        core.releaseMilestone(id, 0);
    }

    /**
     * @notice NEG-02: Release hai lần cùng một mốc bị từ chối (Double disbursement protection)
     * @dev Sau khi giải ngân thành công lần đầu, mốc chuyển sang Disbursed.
     *      Kỳ vọng: Lần giải ngân thứ hai revert với AlreadyReleased().
     */
    function test_NEG02_ProjectCore_DoubleRelease_Reverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofApproved");
        core.approveMilestone(id, 0);

        // Lần 1: Giải ngân thành công
        vm.prank(sponsor);
        core.releaseMilestone(id, 0);
        assert(uint8(core.getMilestoneStatus(id, 0)) == 3); // Disbursed

        // Lần 2: Cố tình giải ngân lại mốc 0 -> PHẢI revert AlreadyReleased
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.AlreadyReleased.selector));
        core.releaseMilestone(id, 0);
    }

    /**
     * @notice NEG-03: Wrong student không thể nộp minh chứng và không thể nhận tiền
     * @dev Một địa chỉ sinh viên lạ (stranger) không có quyền thao tác trên suất học bổng của người khác.
     *      Kỳ vọng: submitMilestone revert NotStudent().
     */
    function test_NEG03_ProjectCore_WrongStudent_Reverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        // Wrong student / stranger cố tình nộp minh chứng
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.submitMilestone(id, 0, "QmWrongStudentProof");
    }

    /**
     * @notice NEG-04: Unauthorized caller (người lạ không có vai trò) không được phép kích hoạt release
     * @dev Chỉ sponsor, student, hoặc verifier mới có quyền gọi releaseMilestone.
     *      Kỳ vọng: Caller lạ gọi releaseMilestone revert NotStudent().
     */
    function test_NEG04_ProjectCore_UnauthorizedCaller_Reverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);
        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofValid");
        core.approveMilestone(id, 0);

        // Người lạ (stranger - không phải sponsor, student, verifier) cố bấm nút release
        vm.prank(stranger);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.NotStudent.selector));
        core.releaseMilestone(id, 0);
    }

    /**
     * @notice NEG-05: Insufficient fund (quỹ chưa nạp hoặc không đủ) bị chặn khi giải ngân
     * @dev Suất học bổng được tạo nhưng chưa nạp tiền (fundedAmount = 0). Mốc được duyệt.
     *      Kỳ vọng: releaseMilestone revert InsufficientFunds().
     */
    function test_NEG05_ProjectCore_InsufficientFunds_Reverts() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        // Không nạp tiền (fundedAmount = 0)
        vm.prank(student);
        core.submitMilestone(id, 0, "QmProofUnfunded");
        core.approveMilestone(id, 0);

        // Khi release: fundedAmount (0) < releasedAmount (0) + amountToRelease (0.5 ether)
        // -> PHẢI revert InsufficientFunds
        vm.prank(sponsor);
        vm.expectRevert(abi.encodeWithSelector(ProjectCore.InsufficientFunds.selector));
        core.releaseMilestone(id, 0);
    }
}
