// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProjectCore
 * @dev Core smart contract for TrustScholar - Transparent Milestone-Based Scholarship Escrow.
 * Follows Checks-Effects-Interactions, role checks, and non-reentrant state transitions.
 */
contract ProjectCore {
    // --- ENUMS & STRUCTS ---

    enum MilestoneStatus {
        Pending,
        Submitted,
        Approved,
        Disbursed
    }

    struct Milestone {
        uint256 amount;
        string proofHash;
        MilestoneStatus status;
        uint256 approvedAt;
        uint256 disbursedAt;
    }

    struct Scholarship {
        uint256 id;
        address sponsor;
        address student;
        uint256 totalAmount;
        uint256 fundedAmount;
        uint256 releasedAmount;
        uint256 milestoneCount;
    }

    // --- CUSTOM ERRORS ---

    error NotSponsor();
    error NotStudent();
    error NotVerifier();
    error InvalidAddress();
    error InvalidAmount();
    error ScholarshipNotFound();
    error MilestoneNotFound();
    error InvalidMilestoneStatus();
    error MilestoneNotApproved();
    error AlreadyReleased();
    error InsufficientFunds();
    error TransferFailed();

    // --- EVENTS ---

    event ScholarshipCreated(
        uint256 indexed scholarshipId,
        address indexed sponsor,
        address indexed student,
        uint256 totalAmount,
        uint256 milestoneCount
    );

    event ScholarshipFunded(
        uint256 indexed scholarshipId,
        address indexed sponsor,
        uint256 amount,
        uint256 totalFunded
    );

    event MilestoneSubmitted(
        uint256 indexed scholarshipId,
        uint256 indexed milestoneIndex,
        address indexed student,
        string proofHash
    );

    event MilestoneApproved(
        uint256 indexed scholarshipId,
        uint256 indexed milestoneIndex,
        address indexed verifier
    );

    event ScholarshipReleased(
        uint256 indexed scholarshipId,
        uint256 indexed milestoneIndex,
        address indexed student,
        uint256 amount
    );

    event VerifierUpdated(
        address indexed previousVerifier,
        address indexed newVerifier
    );

    // --- STATE VARIABLES ---

    uint256 public scholarshipCount;
    address public verifier;

    // scholarshipId => Scholarship
    mapping(uint256 => Scholarship) private _scholarships;

    // scholarshipId => milestoneIndex => Milestone
    mapping(uint256 => mapping(uint256 => Milestone)) private _milestones;

    // Reentrancy guard
    uint256 private _status;
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    // --- MODIFIERS ---

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    // --- CONSTRUCTOR ---

    constructor() {
        _status = _NOT_ENTERED;
        verifier = msg.sender;
    }

    // --- CORE WORKFLOW FUNCTIONS ---

    /**
     * @notice Create a new scholarship with milestone allocations.
     * @param student The recipient student wallet address.
     * @param milestoneAmounts Array of amounts for each milestone.
     * @return scholarshipId The ID of the newly created scholarship.
     */
    function createScholarship(
        address student,
        uint256[] calldata milestoneAmounts
    ) external returns (uint256) {
        return _createScholarship(student, milestoneAmounts);
    }

    /**
     * @notice Create a new scholarship with explicit totalAmount validation.
     * @param student The recipient student wallet address.
     * @param totalAmount The declared total scholarship amount.
     * @param milestoneAmounts Array of amounts for each milestone.
     * @return scholarshipId The ID of the newly created scholarship.
     */
    function createScholarship(
        address student,
        uint256 totalAmount,
        uint256[] calldata milestoneAmounts
    ) external returns (uint256) {
        uint256 calculatedTotal = 0;
        for (uint256 i = 0; i < milestoneAmounts.length; i++) {
            calculatedTotal += milestoneAmounts[i];
        }
        if (totalAmount != calculatedTotal) revert InvalidAmount();
        return _createScholarship(student, milestoneAmounts);
    }

    /**
     * @notice Deposit funds into an existing scholarship escrow.
     * @param scholarshipId The ID of the scholarship to fund.
     */
    function fundScholarship(uint256 scholarshipId) external payable nonReentrant {
        if (scholarshipId == 0 || scholarshipId > scholarshipCount) revert ScholarshipNotFound();
        Scholarship storage s = _scholarships[scholarshipId];

        if (msg.sender != s.sponsor) revert NotSponsor();
        if (msg.value == 0) revert InvalidAmount();
        if (s.fundedAmount + msg.value > s.totalAmount) revert InvalidAmount();

        s.fundedAmount += msg.value;

        emit ScholarshipFunded(scholarshipId, msg.sender, msg.value, s.fundedAmount);
    }

    /**
     * @notice Submit milestone proof by the designated student.
     * @param scholarshipId The scholarship ID.
     * @param milestoneIndex Index of the milestone (0-indexed).
     * @param proofHash IPFS CID or cryptographic hash of the proof.
     */
    function submitMilestone(
        uint256 scholarshipId,
        uint256 milestoneIndex,
        string calldata proofHash
    ) external {
        if (scholarshipId == 0 || scholarshipId > scholarshipCount) revert ScholarshipNotFound();
        Scholarship storage s = _scholarships[scholarshipId];

        if (msg.sender != s.student) revert NotStudent();
        if (milestoneIndex >= s.milestoneCount) revert MilestoneNotFound();

        Milestone storage m = _milestones[scholarshipId][milestoneIndex];
        if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();
        if (m.status != MilestoneStatus.Pending) revert InvalidMilestoneStatus();

        m.proofHash = proofHash;
        m.status = MilestoneStatus.Submitted;

        emit MilestoneSubmitted(scholarshipId, milestoneIndex, msg.sender, proofHash);
    }

    /**
     * @notice Approve a milestone after evaluating submitted proof.
     * @dev Can be called only by the contract verifier.
     * @param scholarshipId The scholarship ID.
     * @param milestoneIndex Index of the milestone to approve.
     */
    function approveMilestone(uint256 scholarshipId, uint256 milestoneIndex) external {
        if (scholarshipId == 0 || scholarshipId > scholarshipCount) revert ScholarshipNotFound();
        Scholarship storage s = _scholarships[scholarshipId];

        if (msg.sender != verifier) revert NotVerifier();
        if (milestoneIndex >= s.milestoneCount) revert MilestoneNotFound();

        Milestone storage m = _milestones[scholarshipId][milestoneIndex];
        if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();
        if (m.status != MilestoneStatus.Submitted) revert InvalidMilestoneStatus();

        m.status = MilestoneStatus.Approved;
        m.approvedAt = block.timestamp;

        emit MilestoneApproved(scholarshipId, milestoneIndex, msg.sender);
    }

    /**
     * @notice Release milestone funds directly to the registered student address.
     * @dev Follows Checks-Effects-Interactions: state is updated before external ETH call.
     * @param scholarshipId The scholarship ID.
     * @param milestoneIndex Index of the approved milestone to disburse.
     */
    function releaseMilestone(
        uint256 scholarshipId,
        uint256 milestoneIndex
    ) external nonReentrant {
        if (scholarshipId == 0 || scholarshipId > scholarshipCount) revert ScholarshipNotFound();
        Scholarship storage s = _scholarships[scholarshipId];

        if (msg.sender != s.student && msg.sender != s.sponsor && msg.sender != verifier) {
            revert NotStudent();
        }
        if (milestoneIndex >= s.milestoneCount) revert MilestoneNotFound();

        Milestone storage m = _milestones[scholarshipId][milestoneIndex];

        if (m.status == MilestoneStatus.Disbursed) revert AlreadyReleased();
        if (m.status != MilestoneStatus.Approved) revert MilestoneNotApproved();

        uint256 amountToRelease = m.amount;
        if (s.fundedAmount < s.releasedAmount + amountToRelease || address(this).balance < amountToRelease) {
            revert InsufficientFunds();
        }

        // Effect
        m.status = MilestoneStatus.Disbursed;
        m.disbursedAt = block.timestamp;
        s.releasedAmount += amountToRelease;

        // Interaction
        (bool success, ) = s.student.call{value: amountToRelease}("");
        if (!success) revert TransferFailed();

        emit ScholarshipReleased(scholarshipId, milestoneIndex, s.student, amountToRelease);
    }

    // --- VIEW / GETTER FUNCTIONS ---

    /**
     * @notice Get full scholarship details.
     * @param scholarshipId The scholarship ID.
     */
    function getScholarship(uint256 scholarshipId) external view returns (Scholarship memory) {
        if (scholarshipId == 0 || scholarshipId > scholarshipCount) revert ScholarshipNotFound();
        return _scholarships[scholarshipId];
    }

    /**
     * @notice Get milestone status for a specific milestone.
     * @param scholarshipId The scholarship ID.
     * @param milestoneIndex The milestone index.
     */
    function getMilestoneStatus(
        uint256 scholarshipId,
        uint256 milestoneIndex
    ) external view returns (MilestoneStatus) {
        if (scholarshipId == 0 || scholarshipId > scholarshipCount) revert ScholarshipNotFound();
        if (milestoneIndex >= _scholarships[scholarshipId].milestoneCount) revert MilestoneNotFound();
        return _milestones[scholarshipId][milestoneIndex].status;
    }

    /**
     * @notice Get full milestone information.
     * @param scholarshipId The scholarship ID.
     * @param milestoneIndex The milestone index.
     */
    function getMilestone(
        uint256 scholarshipId,
        uint256 milestoneIndex
    ) external view returns (Milestone memory) {
        if (scholarshipId == 0 || scholarshipId > scholarshipCount) revert ScholarshipNotFound();
        if (milestoneIndex >= _scholarships[scholarshipId].milestoneCount) revert MilestoneNotFound();
        return _milestones[scholarshipId][milestoneIndex];
    }

    // --- MANAGEMENT FUNCTIONS ---

    /**
     * @notice Update the verifier address.
     * @param newVerifier The address of the new verifier.
     */
    function setVerifier(address newVerifier) external {
        if (msg.sender != verifier) revert NotVerifier();
        if (newVerifier == address(0) || newVerifier == address(this)) revert InvalidAddress();
        address previousVerifier = verifier;
        verifier = newVerifier;
        emit VerifierUpdated(previousVerifier, newVerifier);
    }

    // --- INTERNAL HELPERS ---

    function _createScholarship(
        address student,
        uint256[] calldata milestoneAmounts
    ) internal returns (uint256) {
        if (student == address(0) || student == address(this)) revert InvalidAddress();
        if (milestoneAmounts.length == 0) revert InvalidAmount();

        uint256 total = 0;
        for (uint256 i = 0; i < milestoneAmounts.length; i++) {
            if (milestoneAmounts[i] == 0) revert InvalidAmount();
            total += milestoneAmounts[i];
        }

        uint256 scholarshipId = ++scholarshipCount;

        Scholarship storage s = _scholarships[scholarshipId];
        s.id = scholarshipId;
        s.sponsor = msg.sender;
        s.student = student;
        s.totalAmount = total;
        s.fundedAmount = 0;
        s.releasedAmount = 0;
        s.milestoneCount = milestoneAmounts.length;

        for (uint256 i = 0; i < milestoneAmounts.length; i++) {
            _milestones[scholarshipId][i] = Milestone({
                amount: milestoneAmounts[i],
                proofHash: "",
                status: MilestoneStatus.Pending,
                approvedAt: 0,
                disbursedAt: 0
            });
        }

        emit ScholarshipCreated(scholarshipId, msg.sender, student, total, milestoneAmounts.length);

        return scholarshipId;
    }
}
