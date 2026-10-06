// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contracts/project/ProjectCore.sol";
import "hardhat/console.sol";

// ============================================================
// Minimal Vm cheatcode interface (Hardhat 3 built-in)
// ============================================================
interface Vm {
    function prank(address sender) external;
    function deal(address account, uint256 newBalance) external;
    function expectRevert(bytes calldata revertData) external;
}

/**
 * @title Lab14GasReportTest
 * @notice Test suite for Lab 14: Gas Profiling, Benchmark & Storage Layout Analysis.
 * Measures execution gas consumption for all 5 core functions of ProjectCore:
 *  1. createScholarship
 *  2. fundScholarship
 *  3. submitMilestone
 *  4. approveMilestone
 *  5. releaseMilestone
 */
contract Lab14GasReportTest {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    ProjectCore internal core;

    address internal sponsor = address(0x1111);
    address internal student = address(0x2222);
    address internal verifier_;

    uint256[] internal twoMilestones;

    // Events for logging gas measurements
    event GasMeasured(string action, uint256 gasUsed);

    function setUp() public {
        core = new ProjectCore();
        verifier_ = address(this);

        twoMilestones = new uint256[](2);
        twoMilestones[0] = 0.5 ether;
        twoMilestones[1] = 0.5 ether;

        vm.deal(sponsor, 10 ether);
        vm.deal(student, 1 ether);
    }

    // ------------------------------------------------------------
    // 1. Gas Measurement: createScholarship
    // ------------------------------------------------------------
    function test_GAS01_CreateScholarship_Benchmark() public {
        vm.prank(sponsor);
        uint256 gasBefore = gasleft();
        uint256 id = core.createScholarship(student, twoMilestones);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("GAS [createScholarship 2 milestones]:", gasUsed);
        emit GasMeasured("createScholarship (2 milestones)", gasUsed);
        assert(id == 1);
        // Gas should be well below 250,000 gas
        assert(gasUsed < 250000);
    }

    // ------------------------------------------------------------
    // 2. Gas Measurement: fundScholarship
    // ------------------------------------------------------------
    function test_GAS02_FundScholarship_Benchmark() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        uint256 gasBefore = gasleft();
        core.fundScholarship{value: 1 ether}(id);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("GAS [fundScholarship 1 ETH]:", gasUsed);
        emit GasMeasured("fundScholarship (1 ETH)", gasUsed);
        // Gas should be below 60,000 gas
        assert(gasUsed < 60000);
    }

    // ------------------------------------------------------------
    // 3. Gas Measurement: submitMilestone
    // ------------------------------------------------------------
    function test_GAS03_SubmitMilestone_Benchmark() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(student);
        uint256 gasBefore = gasleft();
        core.submitMilestone(id, 0, "ipfs://QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco");
        uint256 gasUsed = gasBefore - gasleft();

        console.log("GAS [submitMilestone IPFS CID]:", gasUsed);
        emit GasMeasured("submitMilestone (IPFS CID string)", gasUsed);
        // Gas for initial SSTORE string storage: < 120,000 gas
        assert(gasUsed < 120000);
    }

    // ------------------------------------------------------------
    // 4. Gas Measurement: approveMilestone
    // ------------------------------------------------------------
    function test_GAS04_ApproveMilestone_Benchmark() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(student);
        core.submitMilestone(id, 0, "ipfs://QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco");

        vm.prank(verifier_);
        uint256 gasBefore = gasleft();
        core.approveMilestone(id, 0);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("GAS [approveMilestone Verifier]:", gasUsed);
        emit GasMeasured("approveMilestone (Verifier)", gasUsed);
        // Gas should be below 45,000 gas
        assert(gasUsed < 45000);
    }

    // ------------------------------------------------------------
    // 5. Gas Measurement: releaseMilestone
    // ------------------------------------------------------------
    function test_GAS05_ReleaseMilestone_Benchmark() public {
        vm.prank(sponsor);
        uint256 id = core.createScholarship(student, twoMilestones);

        vm.prank(sponsor);
        core.fundScholarship{value: 1 ether}(id);

        vm.prank(student);
        core.submitMilestone(id, 0, "ipfs://QmXoypizjW3WknFiJnKLwHCnL72vedxjQkDDP1mXWo6uco");

        vm.prank(verifier_);
        core.approveMilestone(id, 0);

        uint256 studentBalBefore = student.balance;

        vm.prank(student);
        uint256 gasBefore = gasleft();
        core.releaseMilestone(id, 0);
        uint256 gasUsed = gasBefore - gasleft();

        console.log("GAS [releaseMilestone 0.5 ETH]:", gasUsed);
        emit GasMeasured("releaseMilestone (0.5 ETH)", gasUsed);
        assert(student.balance == studentBalBefore + 0.5 ether);
        // Gas should be below 75,000 gas
        assert(gasUsed < 75000);
    }

    // ------------------------------------------------------------
    // 6. End-to-End Cumulative Gas Measurement
    // ------------------------------------------------------------
    function test_GAS06_FullLifecycle_TotalGas() public {
        uint256 totalGas = 0;

        // 1. Create
        vm.prank(sponsor);
        uint256 g1 = gasleft();
        uint256 id = core.createScholarship(student, twoMilestones);
        totalGas += (g1 - gasleft());

        // 2. Fund
        vm.prank(sponsor);
        uint256 g2 = gasleft();
        core.fundScholarship{value: 1 ether}(id);
        totalGas += (g2 - gasleft());

        // 3. Submit 0
        vm.prank(student);
        uint256 g3 = gasleft();
        core.submitMilestone(id, 0, "ipfs://Qm1");
        totalGas += (g3 - gasleft());

        // 4. Approve 0
        vm.prank(verifier_);
        uint256 g4 = gasleft();
        core.approveMilestone(id, 0);
        totalGas += (g4 - gasleft());

        // 5. Release 0
        vm.prank(student);
        uint256 g5 = gasleft();
        core.releaseMilestone(id, 0);
        totalGas += (g5 - gasleft());

        // 6. Submit 1
        vm.prank(student);
        uint256 g6 = gasleft();
        core.submitMilestone(id, 1, "ipfs://Qm2");
        totalGas += (g6 - gasleft());

        // 7. Approve 1
        vm.prank(sponsor);
        uint256 g7 = gasleft();
        core.approveMilestone(id, 1);
        totalGas += (g7 - gasleft());

        // 8. Release 1
        vm.prank(verifier_);
        uint256 g8 = gasleft();
        core.releaseMilestone(id, 1);
        totalGas += (g8 - gasleft());

        console.log("GAS [Full 2-Milestone Lifecycle Total Gas]:", totalGas);
        emit GasMeasured("Full 2-Milestone Lifecycle Total Gas", totalGas);
        // Total cumulative lifecycle gas should be well below 550,000 gas
        assert(totalGas < 550000);
    }
}
