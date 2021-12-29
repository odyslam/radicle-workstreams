// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import {Hevm} from "./Hevm.sol";
import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {Workstreams} from "../../Workstreams.sol";
import {Dai} from "radicle-drips-hub/test/TestDai.sol";
import {IDripsHub} from "../../IDripsHub.sol";
import {ManagedDripsHubProxy} from "radicle-drips-hub/ManagedDripsHub.sol";
import {DaiDripsHub, DripsReceiver, IDai, SplitsReceiver} from "radicle-drips-hub/DaiDripsHub.sol";
import {ERC20Reserve} from "radicle-drips-hub/ERC20Reserve.sol";



contract User is DSTestPlus {
     mapping(string => Workstreams) workstreams;
     constructor(){}
     function addWorkstreams(string memory key, Workstreams workstream) public {
         workstreams[key] = workstream;
     }
     function createDaiWorkstream(string calldata key,
                                address orgAddress, string calldata anchor,
                                address[] calldata members, uint128[] calldata amountsPerSecond, uint128 amount,
                                IDripsHub.PermitArgs calldata permitArgs
                              )
         public
         returns(address)
     {
         return workstreams[key].createDaiWorkstream(orgAddress, anchor, members, amountsPerSecond, amount, permitArgs);
     }
     function createERC20Workstream(string calldata key,
                                address orgAddress, string calldata anchor,
                                address[] calldata members, uint128[] calldata amountsPerSecond, uint128 amount)
        public
        returns(address)
    {
        return workstreams[key].createERC20Workstream(orgAddress, anchor, members, amountsPerSecond, amount);
    }
}

contract TestDai is Dai {
    function mint(address receiver, uint256 amount) public {
        _mint(receiver, amount);
    }
}
contract WorkStreamTest is DSTestPlus {
    DaiDripsHub public hub;
    TestDai public dai;
    Workstreams public daiWorkstream;

    // Constants
    uint256 public constant ONE_TRILLION_DAI = (1 ether * 10**12);
    uint64 public constant CYCLE_SECS = 7 days;
    uint64 public constant LOCK_SECS = 30 days;
    uint128 public defaultMinAmtPerSec;

    address[] users;
    User user;
    IDripsHub iDripsHub;

    function setUp() public {
        dai = new TestDai();
        DaiDripsHub hubLogic = new DaiDripsHub(CYCLE_SECS, dai);
        ManagedDripsHubProxy proxy = new ManagedDripsHubProxy(hubLogic, address(this));
        hub = DaiDripsHub(address(proxy));
        ERC20Reserve reserve = new ERC20Reserve(dai, address(this), address(hub));
        hub.setReserve(reserve);
        // We assume that the DripsHub contract is already deployed, thus
        // we work with an interface to that contract.
        iDripsHub = IDripsHub(address(hub));
        user = new User();
        dai.mint(address(user), 100*10e18);
        assertEq(100*10e18, dai.balanceOf(address(user)));
        users = new address[](1);

    }
    function testCreateErc20Workstream() public {
        users[0] = address(new User());
        uint128[] memory ampts = new uint128[](1);
        ampts[0] = 1*10e17;
        uint128 initialAmount = 1*10e18;
        daiWorkstream = new Workstreams(iDripsHub);
        user.addWorkstreams("dai1", daiWorkstream);
        string memory anchor = "rad:git:hnrkk1mdmp7rgrhmb786ci5fn445q4rmkfwyy@e4c81ded3a20327af695968c2fb393541609facb";
        address workstreamId = user.createERC20Workstream("dai1", address(user), anchor, users, ampts, initialAmount);
        emit log_named_address("WorkstreamId: ", workstreamId);
        (string memory workstreamAnchor,
        uint8 workstreamType,
        address org,
        uint256 account,
        uint64 lastTimestamp,
        uint128 newBalance,
        IDripsHub.DripsReceiver[] memory newReceivers) = daiWorkstream.loadWorkstream(workstreamId);
    }

}
