// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import {Hevm} from "./Hevm.sol";
import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {Workstreams} from "../../Workstreams.sol";
import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {IDripsHub} from "../../IDripsHub.sol";
import {ManagedDripsHubProxy} from "radicle-drips-hub/ManagedDripsHub.sol";
import {DaiDripsHub, DripsReceiver, IDai, SplitsReceiver} from "radicle-drips-hub/DaiDripsHub.sol";
import {ERC20Reserve} from "radicle-drips-hub/ERC20Reserve.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract User is DSTestPlus {
    mapping(string => Workstreams) workstreams;

    constructor() {}

    function addWorkstreams(string memory key, Workstreams workstream) public {
        workstreams[key] = workstream;
    }

    function createDaiWorkstream(
        string calldata key,
        address orgAddress,
        string calldata anchor,
        address[] calldata members,
        uint128[] calldata amountsPerSecond,
        uint128 amount,
        IDripsHub.PermitArgs calldata permitArgs
    ) public returns (address) {
        return
            workstreams[key].createDaiWorkstream(
                orgAddress,
                anchor,
                members,
                amountsPerSecond,
                amount,
                permitArgs
            );
    }
    function approveERC20Workstream(address workstream, address erc20) public{
        IERC20(erc20).approve(workstream, type(uint256).max);
    }

    function createERC20Workstream(
        string calldata key,
        address orgAddress,
        string calldata anchor,
        address[] calldata members,
        uint128[] calldata amountsPerSecond,
        uint128 amount,
        address erc20
    ) public returns (address) {
        return
            workstreams[key].createERC20Workstream(
                orgAddress,
                anchor,
                members,
                amountsPerSecond,
                amount,
                erc20
            );
    }
}

contract WorkStreamTest is DSTestPlus {
    DaiDripsHub public hub;
    MockERC20 public usdc;
    Workstreams public testWorkstream;

    // Constants
    uint256 public constant ONE_TRILLION_DAI = (1 ether * 10**12);
    uint64 public constant CYCLE_SECS = 7 days;
    uint64 public constant LOCK_SECS = 30 days;
    uint128 public defaultMinAmtPerSec;

    address[] users;
    User user;
    IDripsHub iDripsHub;

    function setUp() public {
        // create a mock erc20 token
        usdc = new MockERC20("USDC", "USDC", 18);
        user = new User();
        usdc.mint(address(user), 100 * 10e18);
        assertEq(100 * 10e18, usdc.balanceOf(address(user)));
        users = new address[](1);
    }

    function testCreateErc20Workstream() public {
        address usdcAddress = address(usdc);
        users[0] = address(new User());
        uint128[] memory ampts = new uint128[](1);
        ampts[0] = 1 * 10e17;
        uint128 initialAmount = 10 * 10e18;
        // initialise the workstreams contract
        testWorkstream = new Workstreams();
        // approve the contract to transfer erc20 funds, much like you do in AMMs like Uniswap
        user.approveERC20Workstream(address(testWorkstream), usdcAddress);
        // since there is no dripshub for that erc20, create a new hub to use in workstreams
        testWorkstream.addERC20Token(usdcAddress);
        // register the workstream in the user test contract. Only for testing.
        user.addWorkstreams("test1", testWorkstream);
        string
            memory anchor = "rad:git:hnrkk1mdmp7rgrhmb786ci5fn445q4rmkfwyy@e4c81ded3a20327af695968c2fb393541609facb";
        // create a new workstream
        address workstreamId = user.createERC20Workstream(
            "test1",
            address(user),
            anchor,
            users,
            ampts,
            initialAmount,
            usdcAddress
        );
        emit log_named_address("WorkstreamId: ", workstreamId);
        (
            string memory workstreamAnchor,
            uint8 workstreamType,
            address org,
            uint256 account,
            uint64 lastTimestamp,
            uint128 newBalance,
            IDripsHub.DripsReceiver[] memory newReceivers,
            IDripsHub erc20Hub
        ) = testWorkstream.loadWorkstream(workstreamId);
        assertEq(address(user), org);
        assertEq(1, workstreamType);
        assertEq(0, lastTimestamp);
        assertEq(initialAmount, newBalance);
        assertEq(anchor, workstreamAnchor);
        assertEq(0, account);
        assertEq(
            address(testWorkstream.erc20TokensLibrary(usdcAddress)),
            address(erc20Hub)
        );
    }
}
