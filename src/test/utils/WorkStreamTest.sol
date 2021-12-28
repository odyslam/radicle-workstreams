// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import {Hevm} from "./Hevm.sol";
import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import {ERC20DripsHubTest} from "radicle-drips-hub/test/ERC20DripsHub.t.sol";
import {ERC20DripsHubUser, ManagedDripsHubUser} from "radicle-drips-hub/test/DripsHubUser.t.sol";
import {Workstreams} from "../../Workstreams.sol";
import {IDripsHub} from "../../IDAIDripsHub.sol";

contract User is DSTestPlus {

    // mapping(string => Workstreams) workstreams;
    // constructor(){}

    // function addWorkstreams(string memory key, Workstreams workstream) public {
    //     workstreams[key] = workstream;
    // }
    // function createWorkstream(string calldata key, string calldata workstreamType, address orgAddress, string calldata projectId,
    //                  string calldata anchor, address[] calldata members, uint128[] calldata amountsPerSecond, int128 amount,
    //                 IDripsHub.PermitArgs calldata permitArgs)
    //     public
    // {
    //     if(keccak256(abi.encodePacked(workstreamType)) == "dai"){
    //         workstreams[key].createDaiWorkstream(projectId, anchor, members, amountsPerSecond, amount, permitArgs);
    //     }
    // }
}
contract WorkStreamTest is DSTestPlus, ERC20DripsHubTest {


}
